# sep/10/2022 22:39:55 by RouterOS 7.5
# software id = MIVQ-7AKA
#
# model = RBD52G-5HacD2HnD
# serial number = E5780FD77CCB
/interface bridge
add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireless
set [ find default-name=wlan1 ] antenna-gain=0 band=2ghz-b/g/n channel-width=\
    20/40mhz-eC country=thailand disabled=no frequency=2457 ssid="smart 3-3" \
    wmm-support=enabled wps-mode=disabled
/interface vlan
add comment=ServerZone interface=BRI-TEST name=VLAN100 vlan-id=100
add comment=Engineer interface=BRI-TEST name=VLAN101 vlan-id=101
add comment=Guest interface=BRI-TEST name=VLAN102 vlan-id=102
/interface list
add name=WAN
add name=InterfaceListVlan100
add name=InterfaceListVlan101
add name=InterfaceListVlan102
add name=LIMITED-ZONE
add name=SERVER-ZONE
add include=InterfaceListVlan101,InterfaceListVlan102 name=LOCAL-BRIDGE
add include=SERVER-ZONE name=FREE-ZONE
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa2-psk mode=dynamic-keys name=idaemon \
    supplicant-identity=""
/interface wireless
set [ find default-name=wlan2 ] antenna-gain=2 band=5ghz-a/n/ac \
    channel-width=20/40/80mhz-Ceee country=thailand disabled=no mode=\
    ap-bridge security-profile=idaemon ssid=iDaemon wmm-support=enabled \
    wps-mode=disabled
add disabled=no keepalive-frames=disabled mac-address=DE:2C:6E:2F:63:70 \
    master-interface=wlan1 multicast-buffering=disabled name=wlan3 \
    security-profile=idaemon ssid=iDaemon2.4 wds-cost-range=0 \
    wds-default-cost=0 wps-mode=disabled
/ip pool
add name=POOL101 ranges=192.168.101.110-192.168.101.150
add name=POOL102 ranges=192.168.102.110-192.168.102.150
add name=POOL100 ranges=192.168.100.110-192.168.100.150
/ip dhcp-server
add address-pool=POOL101 interface=VLAN101 name=DHCP101
add address-pool=POOL102 interface=VLAN102 name=DHCP102
add address-pool=POOL100 interface=VLAN100 name=DHCP100
/zerotier
set zt1 comment="ZeroTier Central controller - https://my.zerotier.com/" \
    identity="46ddbae8f7:0:c4b6b599ff5a4ee1d09713b972411ced8927559085563b55fe2\
    d355ea5e98c3df6afac2db71725bfa4ad22f29740093141d7c74235f8c66f16b24b090aace\
    ece:5018ae070a1f655a8b1d5f675f662ffe8a68c95d79ca5a22af4fdee6a717b9e32c23ce\
    e8fe66dd74002f01bef3a37dc33685422d0b3d56a30a4d30b9ab86de2b" name=zt1 \
    port=9993
/zerotier interface
add allow-default=no allow-global=no allow-managed=no disabled=no instance=\
    zt1 name=zerotier1 network=233ccaac272b6e24
/interface bridge port
add bridge=BRI-TEST interface=InterfaceListVlan101 pvid=101
add bridge=BRI-TEST interface=InterfaceListVlan102 pvid=102
add bridge=BRI-TEST interface=InterfaceListVlan100 pvid=100
/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=102
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=100
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=101
/interface list member
add interface=wlan1 list=WAN
add interface=ether2 list=InterfaceListVlan101
add interface=ether3 list=InterfaceListVlan102
add interface=ether4 list=InterfaceListVlan100
add interface=ether5 list=InterfaceListVlan101
add interface=VLAN101 list=FREE-ZONE
add interface=VLAN102 list=LIMITED-ZONE
add interface=VLAN100 list=SERVER-ZONE
add interface=wlan2 list=InterfaceListVlan101
add interface=wlan3 list=InterfaceListVlan101
/ip address
add address=192.168.101.1/24 interface=VLAN101 network=192.168.101.0
add address=192.168.102.1/24 interface=VLAN102 network=192.168.102.0
add address=192.168.100.1/24 interface=VLAN100 network=192.168.100.0
/ip dhcp-client
add interface=wlan1
/ip dhcp-server network
add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1
add address=192.168.101.0/24 dns-server=192.168.101.1 gateway=192.168.101.1
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
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput \
    protocol=udp src-port=53
add action=drop chain=input disabled=yes in-interface-list=WAN
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
/system ntp client servers
add address=162.159.200.123
add address=103.47.76.177
/tool bandwidth-server set enabled=no
