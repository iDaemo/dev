# oct/03/2020 22:56:15 by RouterOS 6.47.1

#:local 2G ([/interface wireless print as-value where band~"2ghz*"]->0->"name");
#:local 5G ([/interface wireless print as-value where band~"5ghz*"]->0->"name");

#/interface wireless
#set [ find default-name=$5G ] band=5ghz-a/n/ac channel-width=20/40/80mhz-Ceee \
#    country=thailand antenna-gain=2 disabled=no mode=ap-bridge wmm-support=enabled wps-mode=disabled \
#    ssid=SonosLibraControl5G
#set [ find default-name=$2G ] band=2ghz-g/n channel-width=20mhz\
#    country=thailand antenna-gain=2 disabled=no mode=ap-bridge wmm-support=enabled wps-mode=disabled \
#    ssid=@SonosLibraControl2.4G
#/interface wireless security-profiles

set [ find default=yes ] supplicant-identity=iDaemonROOM

/interface bridge
add name=BRI-TEST protocol-mode=none vlan-filtering=yes

/interface vlan
add comment=ServerZone interface=BRI-TEST name=VLAN100 vlan-id=100
add comment=Engineer interface=BRI-TEST name=VLAN101 vlan-id=101

/ip dhcp-client
add disabled=no interface=ether1

/interface list
add name=WAN
add name=InterfaceListVlan100
add name=InterfaceListVlan101
add name=SERVER-ZONE
add include=InterfaceListVlan101,InterfaceListVlan102 name=LOCAL-BRIDGE
add include=SERVER-ZONE name=FREE-ZONE

/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=InterfaceListVlan101
add interface=ether3 list=InterfaceListVlan102
add interface=ether4 list=InterfaceListVlan100
add interface=ether5 list=InterfaceListVlan101
add interface=VLAN101 list=FREE-ZONE
add interface=VLAN102 list=LIMITED-ZONE
add interface=VLAN100 list=SERVER-ZONE
add interface=$5G list=InterfaceListVlan101
add interface=$2G list=InterfaceListVlan101

/ip pool
add name=POOL101 ranges=192.168.101.110-192.168.101.150
add name=POOL102 ranges=192.168.102.110-192.168.102.150
add name=POOL100 ranges=192.168.100.110-192.168.100.150
/ip dhcp-server
add address-pool=POOL101 disabled=no interface=VLAN101 name=DHCP101
add address-pool=POOL102 disabled=no interface=VLAN102 name=DHCP102
add address-pool=POOL100 disabled=no interface=VLAN100 name=DHCP100
/interface bridge port
add bridge=BRI-TEST interface=InterfaceListVlan101 pvid=101
add bridge=BRI-TEST interface=InterfaceListVlan102 pvid=102
add bridge=BRI-TEST interface=InterfaceListVlan100 pvid=100
/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=102
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=100
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=101
/ip address
add address=192.168.101.1/24 interface=VLAN101 network=192.168.101.0
add address=192.168.102.1/24 interface=VLAN102 network=192.168.102.0
add address=192.168.100.1/24 interface=VLAN100 network=192.168.100.0

/ip dhcp-server network
add address=192.168.101.0/24 dns-server=192.168.101.1 gateway=192.168.101.1
add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1
add address=192.168.102.0/24 dns-server=192.168.102.1 gateway=192.168.102.1
/ip dns
set allow-remote-requests=yes

/ip firewall filter
add action=jump chain=forward in-interface-list=LOCAL-BRIDGE jump-target=\
    ChainForwardAll out-interface-list=SERVER-ZONE
add action=jump chain=forward in-interface-list=SERVER-ZONE jump-target=\
    ChainForwardAll out-interface-list=LOCAL-BRIDGE
add action=jump chain=forward in-interface-list=LIMITED-ZONE jump-target=\
    ChainForwardLimited out-interface-list=WAN
add action=jump chain=forward in-interface-list=WAN jump-target=\
    ChainForwardLimited out-interface-list=LIMITED-ZONE
add action=jump chain=forward in-interface-list=FREE-ZONE jump-target=\
    ChainForwardAll out-interface-list=WAN
add action=jump chain=forward in-interface-list=WAN jump-target=\
    ChainForwardAll out-interface-list=FREE-ZONE
add action=drop chain=forward
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput \
    protocol=udp src-port=53
# add action=drop chain=input in-interface-list=WAN
add action=accept chain=ChainForwardLimited dst-port=80,443,8080 protocol=tcp
add action=accept chain=ChainForwardLimited protocol=tcp src-port=80,443,8080
add action=accept chain=ChainForwardLimited protocol=icmp
add action=accept chain=ChainForwardAll
add action=accept chain=AcceptInput
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
/system clock
set time-zone-name=Asia/Bangkok
/system ntp client servers
add address=162.159.200.123
add address=103.47.76.177
/user add name=gle group=full password=thaigaming
/user remove 0

# Zerotier
/zerotier enable zt1
/zerotier interface add network=233ccaac272b6e24 instance=zt1