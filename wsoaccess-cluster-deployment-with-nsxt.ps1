# Author: Alex Ackerman
# Website: www.vmhomelab.org

# vCenter Server used to deploy the appliances
$VIserver = "NEED VALUE"
$VIUsername = "NEED VALUE"
$VIPassword = "NEED VALUE"

# OVA Source
$wsoSourceOva = "C:\Users\aackerman\Downloads\identity-manager-20.10.0.0-17035009_OVF10.ova"

# Target Clusters and Datastores for each appliance.  
# - Uncomment if they will not be on the same datastore and cluster
$ds1Name = "Datastore Name"
#$ds2Name = "Datastore Name"
#$ds3Name = "Datastore Name"

$cl1Name = "Cluster Name"
#$cl2Name = "Cluster Name"
#$cl3Name = "Cluster Name"

# To deploy a vApp, you have to specify the Host as well.  If the target host is the 
# same, you can leave as is. Otherwise, uncomment for the other two appliance host targets.
$host1Name = "ESXi Hostname for the appliance"
#$host2Name = "ESXi Hostname for the appliance"
#$host3Name = "ESXi Hostname for the appliance"

$vmName1 = "Appliance name in vCenter"
$vmName2 = "Appliance name in vCenter"
$vmName3 = "Appliance name in vCenter"

# Configuration Values for the Workspace ONE Access Cluster
$wsoDepOption = "xsmall"
$wsoTZ = "Asia/Seoul"
$wsoCeip = $false
$wsoHostname1 = "instance1.home.local"
$wsoHostname2 = "instance2.home.local"
$wsoHostname3 = "instance3.home.local"
$wsoHostnameLb = "instance.home.local"
$wsoIpProtocol = "IPv4"   # Other option is "IPv6" if that fits your environment
$wsoPortGroup = "NSX-T Segment"
$wsoGatewayIp = "<Gateway IP Address>"
$wsoDomain = "home.local"
$wsoDnsIp = "<DNS IP Address>"  # Can specify multiple separated by a comma
$wsoIp1 = "<Appliance #1 IP Address"
$wsoIp2 = "<Appliance #2 IP Address"
$wsoIp3 = "<Appliance #3 IP Address"
$wsoIpLb = "<Appliance Load Balanced IP Address"
$wsoNetmask = "<Appliance Netmask>"  # Assumes all three appliance in same subnet
$wsoNetmaskLb = "<Appliance Load Balanced Netmask>"

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
$OVFConfig.Common.vami.hostname.Value = $wsoHostname1
$OVFConfig.DeploymentOption.Value = $wsoDepOption
$OVFConfig.IpAssignment.IpProtocol.Value = $wsoIpProtocol
$OVFConfig.NetworkMapping.Network_1.Value = $wsoPortGroup
$OVFConfig.vami.WorkspaceOneAccess.gateway.Value = $wsoGatewayIp
$OVFConfig.vami.WorkspaceOneAccess.domain.Value = $wsoDomain
$OVFConfig.vami.WorkspaceOneAccess.searchpath.Value = $wsoDomain
$OVFConfig.vami.WorkspaceOneAccess.DNS.Value = $wsoDnsIp
$OVFConfig.vami.WorkspaceOneAccess.ip0.Value = $wsoIp1
$OVFConfig.vami.WorkspaceOneAccess.netmask0.Value = $wsoNetmask

# Get the correct deployment location information
$vmhost1 = Get-VMHost -Name $host1Name
$cluster1 = Get-Cluster -Name $cl1Name
$ds1 = Get-Datastore -Name $ds1Name

# Validate the ESXi Host, Cluster, and Datastore for the Appliance
if ( $null -eq $vmhost1 )
{
    Write-Host -ForegroundColor Red "***Hostname Not Found in vCenter***"
    exit
}
if ( $null -eq $cluster1 )
{
    Write-Host -ForegroundColor Red "***Cluster Not Found in vCenter***"
    exit
}
if ( $null -eq $ds1 )
{
    Write-Host -ForegroundColor Red "***Datastore Not Found in vCenter***"
}

# Import the first appliance into the vCenter.
Write-Host -ForegroundColor Yellow "Importing Primary Appliance..."
Import-VApp -Source $wsoSourceOva -OvfConfiguration $OVFConfig -Name $vmName1 -VMHost $vmhost1 -Location $cluster1 -Datastore $ds1 -Confirm:$false
Write-Host -ForegroundColor Yellow "Primary Appliance Imported to vCenter"

Write-Host -ForegroundColor Yellow "Disconnecting from vCenter..."
Disconnect-VIServer $vcConn -Confirm:$false
