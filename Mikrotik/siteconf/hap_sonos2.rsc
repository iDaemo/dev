#:local 2G ([/interface wireless print as-value where band~"2ghz*"]->0->"name");
#:local 5G ([/interface wireless print as-value where band~"5ghz*"]->0->"name");

#/interface wireless
#set [ find default-name=$5G ] band=5ghz-a/n/ac channel-width=20/40/80mhz-Ceee \
#    country=thailand antenna-gain=2 disabled=no mode=ap-bridge wmm-support=enabled wps-mode=disabled \
#    ssid=@SonosLibraControl
#set [ find default-name=$2G ] band=2ghz-g/n channel-width=20mhz\
#    country=thailand antenna-gain=2 disabled=no mode=ap-bridge wmm-support=enabled wps-mode=disabled \
#    ssid=@SonosLibraControl2.4G

#/interface wireless security-profiles
#set [ find default=yes ] supplicant-identity=EngineerRack
#/interface wireless security-profiles
#set [ find default=yes ] supplicant-identity=MikroTik
#add authentication-types=wpa2-psk mode=dynamic-keys name=sonos supplicant-identity=""
#/interface wireless
#set [ find default-name=wlan2 ] band=5ghz-a/n/ac country=thailand disabled=no frequency=auto mode=\
#   ap-bridge security-profile=sonos ssid=@SonosControl5G wps-mode=disabled

/interface bridge
add name=BRI-TEST protocol-mode=none vlan-filtering=yes
#/interface wireless
#set [ find default-name=wlan1 ] band=2ghz-g/n country=thailand ssid=MikroTik

/interface vlan
add comment=ServerZone interface=BRI-TEST name=VLAN100 vlan-id=10
add comment=Engineer interface=BRI-TEST name=VLAN101 vlan-id=11
add comment=Guest interface=BRI-TEST name=VLAN102 vlan-id=12

/interface list
add name=WAN
add name=InterfaceListVlan10
add name=InterfaceListVlan11
add name=InterfaceListVlan12
add name=LIMITED-ZONE
add name=SERVER-ZONE
add include=InterfaceListVlan11,InterfaceListVlan12 name=LOCAL-BRIDGE
add include=SERVER-ZONE name=FREE-ZONE

/ip pool
add name=POOL10 ranges=192.168.0.110-192.168.0.180
add name=POOL11 ranges=192.168.100.110-192.168.100.180
add name=POOL12 ranges=192.168.200.110-192.168.200.180

/ip dhcp-server
add address-pool=POOL11 interface=VLAN11 name=DHCP11
add address-pool=POOL12 interface=VLAN12 name=DHCP12
add address-pool=POOL10 interface=VLAN10 name=DHCP10
/interface bridge port
add bridge=BRI-TEST interface=InterfaceListVlan11 pvid=11
add bridge=BRI-TEST interface=InterfaceListVlan12 pvid=12
add bridge=BRI-TEST interface=InterfaceListVlan10 pvid=10
/ip neighbor discovery-settings
set discover-interface-list=!dynamic

/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=12
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=10
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=11
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=InterfaceListVlan10
add interface=ether3 list=InterfaceListVlan10
add interface=ether4 list=InterfaceListVlan11
add interface=ether5 list=InterfaceListVlan11
add interface=VLAN11 list=FREE-ZONE
add interface=VLAN12 list=LIMITED-ZONE
add interface=VLAN10 list=SERVER-ZONE
#add interface=wlan1 list=InterfaceListVlan101
#add interface=wlan2 list=InterfaceListVlan11

/ip address
add address=192.168.100.1/24 interface=VLAN11 network=192.168.100.0
add address=192.168.200.1/24 interface=VLAN12 network=192.168.200.0
add address=192.168.0.1/24 interface=VLAN10 network=192.168.0.0
/ip dhcp-client
add interface=ether1
/ip dhcp-server network
add address=192.168.0.0/24 dns-server=192.168.0.1 gateway=192.168.0.1
add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1
add address=192.168.200.0/24 dns-server=192.168.200.1 gateway=192.168.200.1
/ip dns
set allow-remote-requests=yes
/ip firewall filter
add action=jump chain=forward in-interface-list=LOCAL-BRIDGE jump-target=ChainForwardAll \
    out-interface-list=SERVER-ZONE
add action=jump chain=forward in-interface-list=SERVER-ZONE jump-target=ChainForwardAll \
    out-interface-list=LOCAL-BRIDGE
add action=jump chain=forward in-interface-list=LIMITED-ZONE jump-target=ChainForwardLimited \
    out-interface-list=WAN
add action=jump chain=forward in-interface-list=WAN jump-target=ChainForwardLimited \
    out-interface-list=LIMITED-ZONE
add action=jump chain=forward in-interface-list=FREE-ZONE jump-target=ChainForwardAll \
    out-interface-list=WAN
add action=jump chain=forward in-interface-list=WAN jump-target=ChainForwardAll \
    out-interface-list=FREE-ZONE
add action=drop chain=forward
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput protocol=udp src-port=53
add action=accept chain=ChainForwardLimited dst-port=80,443,8080 protocol=tcp
add action=accept chain=ChainForwardLimited protocol=tcp src-port=80,443,8080
add action=accept chain=ChainForwardLimited protocol=icmp
add action=accept chain=ChainForwardAll
add action=accept chain=AcceptInput
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN

/system clock
set time-zone-name=Asia/Bangkok
/system ntp client
set enabled=yes
#/system ntp client servers
#add address=162.159.200.123
#add address=103.47.76.177
#disable bandwidth server
#clean up
/tool bandwidth-server set enabled=no
/user add name=sonos group=full password=33338888
/system identity set name=SonosEngineerRack
/user remove 0