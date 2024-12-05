/interface bridge
add name=BRI-TEST protocol-mode=none vlan-filtering=yes

/interface vlan
add comment=ServerZone interface=BRI-TEST name=VLAN100 vlan-id=100
add comment=Engineer interface=BRI-TEST name=VLAN101 vlan-id=101
add comment=Guest interface=BRI-TEST name=VLAN102 vlan-id=102

/ip dhcp-client
add disabled=no interface=ether1

/interface list
add name=WAN
add name=InterfaceListVlan100
add name=InterfaceListVlan101
add name=InterfaceListVlan102
add name=LIMITED-ZONE
add name=SERVER-ZONE
add include=InterfaceListVlan101,InterfaceListVlan102 name=LOCAL-BRIDGE
add include=SERVER-ZONE name=FREE-ZONE

/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=InterfaceListVlan101
add interface=ether3 list=InterfaceListVlan101
add interface=ether4 list=InterfaceListVlan101
add interface=ether5 list=InterfaceListVlan101
add interface=ether6 list=InterfaceListVlan101
add interface=ether7 list=InterfaceListVlan101
add interface=ether8 list=InterfaceListVlan101
add interface=ether9 list=InterfaceListVlan102
add interface=ether10 list=InterfaceListVlan102
add interface=ether11 list=InterfaceListVlan102
add interface=ether12 list=InterfaceListVlan102
add interface=ether13 list=InterfaceListVlan100
add interface=ether14 list=InterfaceListVlan100
add interface=ether15 list=InterfaceListVlan100
add interface=ether16 list=InterfaceListVlan100
add interface=sfp-sfpplus1 list=InterfaceListVlan101
add interface=sfp-sfpplus2 list=InterfaceListVlan100
add interface=VLAN101 list=FREE-ZONE
add interface=VLAN102 list=LIMITED-ZONE
add interface=VLAN100 list=SERVER-ZONE


/ip pool
add name=POOL101 ranges=192.168.1.110-192.168.1.210
add name=POOL102 ranges=192.168.2.110-192.168.2.210
add name=POOL100 ranges=192.168.0.110-192.168.0.210

/ip dhcp-server
add address-pool=POOL101 disabled=no interface=VLAN101 name=DHCP101 lease-time=4:0:0
add address-pool=POOL102 disabled=no interface=VLAN102 name=DHCP102 lease-time=4:0:0
add address-pool=POOL100 disabled=no interface=VLAN100 name=DHCP100 lease-time=4:0:0

/interface bridge port
add bridge=BRI-TEST interface=InterfaceListVlan101 pvid=101
add bridge=BRI-TEST interface=InterfaceListVlan102 pvid=102
add bridge=BRI-TEST interface=InterfaceListVlan100 pvid=100

/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=102
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=100
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=101
/ip address
add address=192.168.1.1/24 interface=VLAN101 network=192.168.1.0
add address=192.168.2.1/24 interface=VLAN102 network=192.168.2.0
add address=192.168.0.1/24 interface=VLAN100 network=192.168.0.0

/ip dhcp-server network
add address=192.168.1.0/24 dns-server=192.168.1.1 gateway=192.168.1.1
add address=192.168.0.0/24 dns-server=192.168.0.1 gateway=192.168.0.1
add address=192.168.2.0/24 dns-server=192.168.2.1 gateway=192.168.2.1
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

/user add name=sonos group=full password=33338888
/user remove 0

# Zerotier
/zerotier enable zt1
/zerotier interface add network=233ccaac272b6e24 instance=zt1

#disable unessesories service
/tool bandwidth-server set enabled=no