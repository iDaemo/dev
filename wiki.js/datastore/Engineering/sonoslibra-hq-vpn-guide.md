---
title: SONOS LIBRA HQ VPN Details
description: 
published: true
date: 2023-10-22T15:45:04.995Z
tags: vpn
editor: markdown
dateCreated: 2023-07-31T19:28:55.745Z
---

## Preparing

> Download VPN Config file from <a href="https://drive.google.com/drive/folders/1pKqVn7fmYF1vs19eXNIuCmCmUYxjfVJq?usp=drive_link" target="_blank">[DOWNLOAD LINK]</a>
{.is-info}


> Please note there a list of config files follow with username please download your own prepared config individual
> Config file format : **SonosHQ-VPN.yourusername.conf**  
{.is-success}

{.is-warning}

<br>

## Install Wireguard VPN Client  

## Tabs {.tabset}
### MacOS

1. Download App “**WireGuard**” from App Store
<br>

![screenshot_2023-08-01_at_04.20.20.png](/screenshot_2023-08-01_at_04.20.20.png =600x)
 
2. Open WireGuard and click ADD(+) Import Tunnel(s) from File….
<br>

![screenshot_2023-08-01_at_04.28.31.png](/images/screenshot_2023-08-01_at_04.28.31.png =600x)
 
3. Select you downloaded config file and import to application
<br>

![screenshot_2023-08-01_at_04.30.40.png](/images/screenshot_2023-08-01_at_04.30.40.png =600x)
![screenshot_2023-08-01_at_04.31.08.png](/images/screenshot_2023-08-01_at_04.31.08.png =600x)

4. Now you can start VPN Connection via macOS VPN Control
<br>
![screenshot_2023-08-01_at_04.31.15.png](/images/screenshot_2023-08-01_at_04.31.15.png =600x)

### iOS,iPadOS

1.  Search and Download App “**WireGuard**” from App Store
<br>
![img_4338.png](/engineering/vpn/img_4338.png =400x)

2.  Run App WireGuard and Add Tunnel choose Create from file or archive
<br>
![img_4338.png](/engineering/vpn/img_4338.png =400x)

3.  Choose you config file that you downloaded and click allow when system showing up
<br>
![img_4340.png](/engineering/vpn/img_4340.png =400x)


4. Config file will add VPN to the iOS and iPadOS and you can starting from system menu
<br>
![img_4342.png](/engineering/vpn/img_4342.png =400x)

### Windows

I won’t tell you. 🤓 yet..

### Android

I won’t tell you. 🤓 yet ..

## Current Services 
 
### File Server

Now you may want to connect to file server

Windows Explorer: `//192.168.10.250`
Mac Finder: `smb://192.168.10.250`

### Showroom Mac Mini Control Machine

Mac Screen Sharing : `192.168.10.20`

Other services coming...

  
## Benefits and Fixed Update

-   Fast and Secure file transfer with most modern encrypt protocol
-   Direct connect peer to server \[ [HQ.SONOSLIBRA.COM](http://HQ.SONOSLIBRA.COM)\] not pass trough 3rd party server got full speed of your connection
-   Expect to Fixed some problems relate to re-connect share folder by use separate peer connection account.