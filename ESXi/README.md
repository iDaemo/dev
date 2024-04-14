# ESXi

import
vmkfstools -i source target -d thin



## Installation
Steps : 
1 - Create Vmware Customer Connect Account (https://customerconnect.vmware.com)
2 - Download Esxi 8 from Vmware Customer Connect Account 
3 - Get the no expiration license from Vmware Customer Connect Account https://kb.vmware.com/s/article/2107518 >> N5080-26J4K-088P0-0VCA4-1X0N0 <<
4 - Download drivers from Vmware fings (https://flings.vmware.com)
5 - Install Python 3.7.9
6 - Upgrading pip
7 - Installing required Python packages "pip install six psutil lxml pyopenssl"
8 - Enable remote signed script "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
9 - Install PowerCli "Install-Module -Name VMware.PowerCLI -RequiredVersion 13.0.0.20829139"
10 - Import ImageBuidler module "Import-Module VMware.ImageBuilder"
11 - Add depot to PowerCli session "Add-EsxSoftwareDepot .\VMware-ESXi-8.0U1-21495797-depot.zip"
12 - Verify that the depot is loaded correctly "Get-EsxImageProfile"
13 - Creating the custom image "New-EsxImageProfile -CloneProfile ESXi-8.0U1-21495797-standard -Name Custom-Esxi8 -Vendor Vmware"
14 - Adding network community driver to the PowerCli Session "Add-EsxSoftwareDepot .\Net-Community-Driver_1.2.7.0-1vmw.700.1.0.15843807_19480755.zip"
15 - Adding network community driver to the PowerCli Session "Add-EsxSoftwareDepot .\ESXi80U1-VMKUSB-NIC-FLING-64098092-component-21669994.zip"
16 - Adding net-community driver to custom image "Add-EsxSoftwarePackage -ImageProfile Custom-Esxi8 -SoftwarePackage net-community"
17 - Adding vmkusb-nic-fling driver to custom image "Add-EsxSoftwarePackage -ImageProfile Custom-Esxi8 -SoftwarePackage vmkusb-nic-fling"
18 - Change the Acceptance Level "Set-EsxImageProfile -AcceptanceLevel CommunitySupported –ImageProfile Custom-Esxi8"
18 - Export-EsxImageProfile -ImageProfile Custom-Esxi8 -ExportToIso -FilePath C:\Users\User\Desktop\esxi-image\Custom-Esxi8.iso

Xpenoloty Synology
The original location for tinycore-redpill
https://github.com/pocopico/tinycore-...

Peter Suh Github that has the vmdk file that I use in this video
https://github.com/PeterSuh-Q3/tinyco...

Once you have established a successful SSH connection, type the 2 commands below. (Or copy and paste..) to install the VMware Tools docker container.

sudo mkdir /root/.ssh

sudo docker run -d --restart=always --net=host -v /root/.ssh/:/root/.ssh/ --name open-vm-tools yalewp/xpenology-open-vm-tools



use HPE or Dell ISO
when install hit shift+o and type runweasel

