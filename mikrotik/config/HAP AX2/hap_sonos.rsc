#/interface wireless security-profiles 
#set [ find default=yes ] supplicant-identity=MikroTik
#add authentication-types=wpa-psk,wpa2-psk group-key-update=1h mode=dynamic-keys name=sonos wpa-pre-shared-key=33338888 wpa2-pre-shared-key=33338888 multicast-buffering=disabled multicast-helper=disabled

#/interface wireless
#set [ find default-name=wifi1 ] band=5ghz-a/n/ac channel-width=20/40mhz-XX country=thailand disabled=no mode=ap-bridge wmm-support=enabled wps-mode=disabled ssid=@SonosLibraControl 

/interface bridge
add name=BRI-TEST protocol-mode=none vlan-filtering=yes

/interface vlan
add comment=Engineer interface=BRI-TEST name=VLAN10 vlan-id=10
add comment=Guest interface=BRI-TEST name=VLAN12 vlan-id=12

/interface list
add name=WAN
add name=InterfaceListVlan10
add name=InterfaceListVlan12
add name=LIMITED-ZONE
add include=InterfaceListVlan10,InterfaceListVlan12 name=LOCAL-BRIDGE
add include=InterfaceListVlan10 name=FREE-ZONE

/ip pool
add name=POOL10 ranges=192.168.10.110-192.168.10.180
add name=POOL12 ranges=192.168.20.110-192.168.20.180

/ip dhcp-server
add address-pool=POOL10 interface=VLAN10 name=DHCP10 lease-time=01:0:0
add address-pool=POOL12 interface=VLAN12 name=DHCP12 lease-time=01:0:0


/interface bridge port
add bridge=BRI-TEST interface=InterfaceListVlan10 pvid=10
add bridge=BRI-TEST interface=InterfaceListVlan12 pvid=12

/ip neighbor discovery-settings
set discover-interface-list=!dynamic

/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=10
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=12

/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=InterfaceListVlan10
add interface=ether3 list=InterfaceListVlan10
add interface=ether4 list=InterfaceListVlan10
add interface=ether5 list=InterfaceListVlan10
add interface=VLAN12 list=LIMITED-ZONE
add interface=wifi1 list=InterfaceListVlan10

/ip address
add address=192.168.10.1/24 interface=VLAN10 network=192.168.10.0
add address=192.168.20.1/24 interface=VLAN12 network=192.168.20.0

/ip dhcp-client
add interface=ether1

/ip dhcp-server network
add address=192.168.10.0/24 dns-server=192.168.10.1 gateway=192.168.10.1
add address=192.168.20.0/24 dns-server=192.168.20.1 gateway=192.168.20.1

/ip dns
set allow-remote-requests=yes

/ip firewall filter
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

/tool bandwidth-server set enabled=no
/user add name=sonos group=full password=33338888
/user remove 0
/system identity set name=SonosControlAP

/ip cloud set ddns-enabled=yes update-time=yes
/system clock set time-zone-autodetect=yes

/ipv6 settings set disable-ipv6=yes