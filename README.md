# Automated Workspace ONE Access Cluster Deployment

## Description

This is my first automation script and I will be the first to admit there is a TON of room for improvement.  My purpose in doing this is to improve my GitHub experience, add to my repetroir, and share some skills with the larger community.

This script will implement several of the steps that are part of my [SAML Authentication with Workspace ONE Access](https://www.vmhomelab.org/2021/02/saml-authentication-with-workspace-one-access-part-1-preparation/) series.  By the end, I would like to see if I can automate a significant portion of it (perhaps all???) for a HomeLab environment.  Although the default sizing will be based on production needs, this is intended for HomeLab use only.  I am just lucky enough my wife allows me to have enough compute and storage to allow me to support a small production deployment.

This script assumes you have access to valid licenses for Horizon 8 Advanced, vSphere 7, and NSX-T 3.1.  If you do not have access to these licenses, check out [VMUG Advantage](https://www.vmug.com/membership/vmug-advantage-membership) for a reasonable annual membership fee, you will get 365-day evaluation licenses for much of VMware's product line.

I would be remiss if I did not give credit where credit is due.  The basis of the scripting is from William Lam's EXCELLENT [VMware vSphere with Kubernetes automation scripts](https://www.virtuallyghetto.com/2020/04/automated-vsphere-7-and-vsphere-with-kubernetes-lab-deployment-script.html).  In addition, I found some good pointers on configuring the vApp from [Raul Cunha's blog](https://raulcunha.com/2021/01/29/how-to-deploy-workspace-one-access-using-powercli/).  

## Requirements
- Microsoft PowerShell 7.0 or later
- VMware PowerCLI 12.3 or later

