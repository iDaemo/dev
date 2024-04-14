/interface bridge
add name=BRI-TEST protocol-mode=none vlan-filtering=yes

/interface vlan
add interface=BRI-TEST name=VLAN10 vlan-id=10
add interface=BRI-TEST name=VLAN11 vlan-id=11
add interface=BRI-TEST name=VLAN12 vlan-id=12

/interface pppoe-client
add ac-name="" add-default-route=yes allow=pap,chap,mschap1,mschap2 default-route-distance=1 dial-on-demand=no disabled=no interface=ether1 keepalive-timeout=10 max-mru=auto max-mtu=auto mrru=disabled name=trueonline profile=default service-name=trueonline use-peer-dns=yes user=9605418601@fiberhome

/interface bonding
add arp=enabled disabled=no down-delay=0ms !forced-mac-address lacp-rate=30secs link-monitoring=mii mii-interval=100ms min-links=0 mode=802.3ad mtu=1500 name=nas-bonding primary=none slaves=ether9,ether10 transmit-hash-policy=layer-2-and-3 up-delay=0ms

/ip dhcp-client
add disabled=no interface=ether1

/interface list
add name=WAN
add name=InterfaceListVlan10
add name=InterfaceListVlan11
add name=InterfaceListVlan12
add name=LIMITED-ZONE
add name=SERVER-ZONE
add include=InterfaceListVlan10,InterfaceListVlan11 name=LOCAL-BRIDGE
add include=SERVER-ZONE name=FREE-ZONE

/interface list member
add interface=trueonline list=WAN
add interface=ether1 list=WAN
add interface=ether2 list=InterfaceListVlan10
add interface=ether3 list=InterfaceListVlan10
add interface=ether4 list=InterfaceListVlan10
add interface=ether5 list=InterfaceListVlan10
add interface=ether6 list=InterfaceListVlan10
add interface=ether7 list=InterfaceListVlan10
add interface=ether8 list=InterfaceListVlan10
add interface=ether11 list=InterfaceListVlan10
add interface=ether12 list=InterfaceListVlan10
add interface=ether13 list=InterfaceListVlan10
add interface=ether14 list=InterfaceListVlan10
add interface=ether16 list=InterfaceListVlan10
add interface=VLAN10 list=FREE-ZONE
add interface=VLAN11 list=SERVER-ZONE
add interface=VLAN12 list=LIMITED-ZONE
add disabled=no interface=nas-bonding list=InterfaceListVlan10

/ip pool
add name=POOL10 ranges=192.168.1.101-192.168.1.250
add name=POOL11 ranges=192.168.11.101-192.168.11.250
add name=POOL12 ranges=192.168.12.101-192.168.12.250
/ip dhcp-server
add address-pool=POOL10 disabled=no interface=VLAN10 name=DHCP10 lease-time=1d
add address-pool=POOL11 disabled=no interface=VLAN11 name=DHCP11 lease-time=1d
add address-pool=POOL12 disabled=no interface=VLAN12 name=DHCP12 lease-time=1d
 
/interface bridge port
add bridge=BRI-TEST interface=InterfaceListVlan10 pvid=10
add bridge=BRI-TEST interface=InterfaceListVlan11 pvid=11
add bridge=BRI-TEST interface=InterfaceListVlan12 pvid=12
/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST,ether15 vlan-ids=10
add bridge=BRI-TEST tagged=BRI-TEST,ether15 vlan-ids=11
add bridge=BRI-TEST tagged=BRI-TEST,ether15 vlan-ids=12

/ip address
add address=192.168.1.1/24 interface=VLAN10 network=192.168.1.0
add address=192.168.11.1/24 interface=VLAN11 network=192.168.11.0
add address=192.168.12.1/24 interface=VLAN12 network=192.168.12.0

/ip dhcp-server network
add address=192.168.1.0/24 dns-server=192.168.1.1 gateway=192.168.1.1
add address=192.168.11.0/24 dns-server=192.168.11.1 gateway=192.168.11.1
add address=192.168.12.0/24 dns-server=192.168.12.1 gateway=192.168.12.1

/ip dns
set allow-remote-requests=yes

/ip firewall filter
add action=jump chain=forward in-interface-list=LOCAL-BRIDGE jump-target=ChainForwardAll out-interface-list=SERVER-ZONE
add action=jump chain=forward in-interface-list=SERVER-ZONE jump-target=ChainForwardAll out-interface-list=LOCAL-BRIDGE
add action=jump chain=forward in-interface-list=LIMITED-ZONE jump-target=ChainForwardLimited out-interface-list=WAN
add action=jump chain=forward in-interface-list=WAN jump-target=ChainForwardLimited out-interface-list=LIMITED-ZONE
add action=jump chain=forward in-interface-list=FREE-ZONE jump-target=ChainForwardAll out-interface-list=WAN
add action=jump chain=forward in-interface-list=WAN jump-target=ChainForwardAll out-interface-list=FREE-ZONE
add action=jump chain=forward in-interface=wg-sonoshq jump-target=ChainForwardAll out-interface=VLAN10
add action=drop chain=forward
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput protocol=udp src-port=53,123
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput protocol=udp dst-port=13231
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput protocol=tcp src-port=443,123
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput protocol=tcp dst-port=8291,5900
add action=drop chain=input in-interface-list=WAN
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
set enabled=yes primary-ntp=162.159.200.123 secondary-ntp=103.47.76.177

/system identity
set name=SonoslibraHQ