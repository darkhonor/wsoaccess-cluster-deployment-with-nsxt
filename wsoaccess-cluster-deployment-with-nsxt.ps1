# Author: Alex Ackerman
# Website: www.vmhomelab.org

# vCenter Server used to deploy the appliances
$VIserver = "NEED VALUE"
$VIUsername = "NEED VALUE"
$VIPassword = "NEED VALUE"

# OVA Source
$wsoSourceOva = "C:\Users\aackerman\Downloads\identity-manager-20.10.0.0-17035009_OVF10.ova"

# Target Cluster and Datastore for the appliance.  
$dsName = "Datastore Name"
$clName = "Cluster Name"

# To deploy a vApp, you have to specify the Host as well.  If the target host is the 
# same, you can leave as is. Otherwise, uncomment for the other two appliance host targets.
$hostName = "ESXi Hostname for the appliance"
$vmName = "Appliance name in vCenter"

# Configuration Values for the Workspace ONE Access Cluster
$wsoDepOption = "xsmall"
$wsoTZ = "Asia/Tokyo"
$wsoCeip = $false
$wsoHostname = "instance1.home.local"
#$wsoHostnameLb = "instance.home.local"
$wsoIpProtocol = "IPv4"   # Other option is "IPv6" if that fits your environment
$wsoPortGroup = "NSX-T Segment"
$wsoGatewayIp = "<Gateway IP Address>"
$wsoDomain = "home.local"
$wsoDnsIp = "<DNS IP Address>"  # Can specify multiple separated by a comma
$wsoIp = "<Appliance IP Address"
#$wsoIpLb = "<Appliance Load Balanced IP Address"
$wsoNetmask = "<Appliance Netmask>"  # Assumes all three appliance in same subnet
#$wsoNetmaskLb = "<Appliance Load Balanced Netmask>"

### DO NOT EDIT BELOW THIS LINE ###
# Validate PowerShell version is correct
if ( "Core" -ne $PSVersionTable.PSEdition)
{
    Write-Host -ForegroundColor Red "***PowerShell Core not detected.  Please install before continuing"
    exit
} else {
    Write-Host -ForegroundColor Yellow "* PowerShell Core Installed: " $PSVersionTable.PSVersion
}

# Verify that PowerCLI is installed and available


# Verify Source OVA exists
if ( !(Test-Path $wsoSourceOva)) 
{
    Write-Host -ForegroundColor Red "***Missing Appliance OVA.  Verify script matches actual file location"
    exit
} else {
    Write-Host -ForegroundColor Yellow "* Appliance OVA Found: $wsoSourceOva"
}

# Validate key default values changed
if ( "NEED VALUE" -eq $VIserver -or
         "NEED VALUE" -eq $VIUsername -or
         "NEED VALUE" -eq $VIPassword ) 
{
    Write-Host -ForegroundColor Red "***Default Values Set.  Unable to Proceed.  Edit Script before continuing***"
    exit
}

# Log into the vCenter Server
Write-Host -ForegroundColor Yellow "Connecting to vCenter..."
$vcConn = Connect-VIServer $VIserver -User $VIUsername -Password $VIPassword -WarningAction SilentlyContinue

if ( $null -eq $vcConn )
{
    Write-Host -ForegroundColor Red "***Not Connected to vCenter***"
    exit
}
Write-Host -ForegroundColor Yellow "Connected to vCenter"

# Configure the vApp Properties
Write-Host -ForegroundColor Yellow "Configuring vApp Settings..."
$OVFConfig = Get-OvfConfiguration -Ovf $wsoSourceOva
$OVFConfig.Common.vamitimezone.Value = $wsoTZ
$OVFConfig.Common.ceip.enable.Value = $wsoCeip
$OVFConfig.Common.vami.hostname.Value = $wsoHostname
$OVFConfig.DeploymentOption.Value = $wsoDepOption
$OVFConfig.IpAssignment.IpProtocol.Value = $wsoIpProtocol
$OVFConfig.NetworkMapping.Network_1.Value = $wsoPortGroup
$OVFConfig.vami.WorkspaceOneAccess.gateway.Value = $wsoGatewayIp
$OVFConfig.vami.WorkspaceOneAccess.domain.Value = $wsoDomain
$OVFConfig.vami.WorkspaceOneAccess.searchpath.Value = $wsoDomain
$OVFConfig.vami.WorkspaceOneAccess.DNS.Value = $wsoDnsIp
$OVFConfig.vami.WorkspaceOneAccess.ip0.Value = $wsoIp
$OVFConfig.vami.WorkspaceOneAccess.netmask0.Value = $wsoNetmask

# Get the correct deployment location information
$vmhost = Get-VMHost -Name $hostName
$cluster = Get-Cluster -Name $clName
$ds = Get-Datastore -Name $dsName

# Validate the ESXi Host, Cluster, and Datastore for the Appliance
if ( $null -eq $vmhost )
{
    Write-Host -ForegroundColor Red "***Hostname Not Found in vCenter***"
    exit
}
if ( $null -eq $cluster )
{
    Write-Host -ForegroundColor Red "***Cluster Not Found in vCenter***"
    exit
}
if ( $null -eq $ds )
{
    Write-Host -ForegroundColor Red "***Datastore Not Found in vCenter***"
}

# Import the first appliance into the vCenter.
Write-Host -ForegroundColor Yellow "Importing Primary Appliance..."
$wsoVm = Import-VApp -Source $wsoSourceOva -OvfConfiguration $OVFConfig -Name $vmName -VMHost $vmhost -Location $cluster -Datastore $ds -DiskStorageFormat thin -Confirm:$false
Write-Host -ForegroundColor Yellow "Primary Appliance Imported to vCenter"

Write-Host -ForegroundColor Yellow "Powering on $vmName"
$wsoVm | Start-VM -RunAsync | Out-Null

# Need to wait until the system is up and running, which can take a LONG TIME
# Invote-RestMethod is a PowerShell command that can be used to communicate...

Write-Host -ForegroundColor Yellow "Disconnecting from vCenter..."
Disconnect-VIServer $vcConn -Confirm:$false
