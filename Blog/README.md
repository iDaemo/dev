# Blog
Font Smoothing in WINE
```
REGEDIT4

[HKEY_CURRENT_USER\Control Panel\Desktop]
"FontSmoothing"="2"
"FontSmoothingGamma"=dword:00000578
"FontSmoothingOrientation"=dword:00000001
"FontSmoothingType"=dword:00000002
```


- proper way to curl and wget from github
 
 ```
wget --no-check-certificate --content-disposition https://github.com/joyent/node/tarball/v0.7.1
# --no-check-cerftificate was necessary for me to have wget not puke about https
curl -LJO https://github.com/joyent/node/tarball/v0.7.1
 ```
 
 
 *** disable IPV6 in openwrt ***
 ```
uci set 'network.lan.ipv6=off'
uci set 'network.wan.ipv6=off'
uci set 'dhcp.lan.dhcpv6=disabled'
uci -q delete network.globals.ula_prefix
/etc/init.d/odhcpd disable
/etc/init.d/odhcpd stop
uci commit
/etc/init.d/network restart

>>
/etc/modules.d contains links to kernel modules that will be loaded on boot. 
Simply delete the links to ip6tables, ipt6-nat and nf-conntrack6 then reboot. 
IPv6 will be gone for good, until you do a hard reset.
 ```

Soundgrid Server
 ```
 - install SoundGrid Studio (or another Soundgrid application of your choice) on your System
- Download Rufus https://rufus.ie/
- insert an empty USB stick
- open Rufus and toggle "Show advanced drive properties" (below the "Partition scheme"-Dropdown). You don't need to click anything here, instead click on the "Boot selection"-Dropdown
- select "Syslinux 6.04" from the "Boot selection"-Dropdown
- hit START. You'll get some warning dialogs, as well as some dialogs where you need to allow Rufus to download syslinux.
- download and install 7-Zip https://7-zip.org/
- navigate to C:\ProgramData\Waves Audio\SoundGrid Firmware\SGS
- open the .wfi file with 7-zip
- extract the content to your USB stick
- eject the USB stick and put it in your server 
  ```
  
  
Google Drive download
```
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=FILEID' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=FILEID" -O FILENAME && rm -rf /tmp/cookies.txt
```

VMWare EsXi
```
VMware vSphere Hypervisor 8 License		N5080-26J4K-088P0-0VCA4-1X0N0
```

Wine64 run wintricks
```
mv /usr/local/bin/wine /usr/local/bin/wine32
ln -s /Applications/Wine\ Stable.app/Contents/Resources/wine/bin/wine64 wine
```

Connect to ssh cisco 
```
ssh -v -oHostKeyAlgorithms=+ssh-rsa username@ipaddress
```

SSH Config editor

SYNOLOGY BONDING
````
# Prerequisite: the bond must be already configured and running (on DSM and on LAN-Switch)

 

# Login as "root" with SSH

 

#open the config-file in vi:

vi /etc/sysconfig/network-scripts/ifcfg-bond0
#search the line:

BONDING_OPTS="mode=4 use_carrier=1 miimon=100 updelay=100 lacp_rate=fast"
# press "i" to enter the "input-mode" from vi and change it to (all in one single line!):

BONDING_OPTS="mode=4 xmit_hash_policy=layer3+4 use_carrier=1 miimon=100 updelay=100 lacp_rate=fast
 

# press "esc" and then ":wq" (without the " of course :wink: ) (wq stands for "write and quit vi afterwards")

 

# reboot and you're done
```

Windows 11 Activated
Powershell 
irm https://massgrave.dev/get | iex

````

Google Takeout Expot
https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper?tab=readme-ov-file#how-to-use


CPU pass-through is now working.

Since this will be disabled after reboot, you can place it in a user defined script:

Control Panel -> Task Scheduler

Create -> Triggered Task -> User-defined script

Name: anything you like
User: root
Event; Boot-up
Check enabled flag

Under the Task settings tab, place the two modprobe lines in the User-defined script block:

modprobe -r kvm_intel

modprobe kvm_intel nested=1

Click OK

Now on boot, pass-through will be enabled. You can either reboot the NAS, or run the script once through the interface.


### Font we use ###
Iosevka


### Windows Setup
Powershell 
  irm "https://christitus.com/win" | iex

https://www.windowsafg.com/power10.html

### Typical upgrade
sudo apt-get update && time sudo apt-get dist-upgrade
