/interface wifiwave2 set [ find default-name=wifi2 ] configuration.mode=station security.authentication-types=wpa-psk,wpa2-psk .passphrase=guest1234
/interface wifiwave2 set [ find default-name=wifi5G ] channel.band=5ghz-ax .frequency=2300-7000 .width=20/40mhz-Ce configuration.country=Thailand .mode=ap .ssid=@SonosControl-15 disabled=no name=wifi5G security.authentication-types=wpa2-psk,wpa3-psk .passphrase=33338888

/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan add interface=BRI-TEST name=VLAN20 vlan-id=20
/interface vlan add interface=BRI-TEST name=VLAN21 vlan-id=21
/interface list add name=MANAGE
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan20
/interface list add name=InterfaceListVlan21


/ip pool add name=POOL20 ranges=192.168.20.10-192.168.20.200
/ip pool add name=POOL21 ranges=192.168.21.10-192.168.21.200

/ip dhcp-server add address-pool=POOL20 interface=VLAN20 lease-time=1d name=DHCP20
/ip dhcp-server add address-pool=POOL21 interface=VLAN21 lease-time=1d name=DHCP21
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan20 pvid=20
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan21 pvid=21
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=20
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=21
#/interface list member add interface=wlan1 list=WAN
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=InterfaceListVlan20
/interface list member add interface=ether3 list=InterfaceListVlan20
/interface list member add interface=ether4 list=InterfaceListVlan20
/interface list member add interface=ether5 list=InterfaceListVlan20
/interface list member add interface=VLAN20 list=LAN
/interface list member add interface=VLAN21 list=LAN
/interface list member add interface=wifi1 list=InterfaceListVlan20
#/interface list member add interface=wifi2 list=InterfaceListVlan21

/ip address add address=192.168.99.1/30 interface=ether2 network=192.168.99.0
/ip address add address=192.168.20.1/24 interface=VLAN20 network=192.168.20.0
/ip address add address=192.168.21.1/24 interface=VLAN21 network=192.168.21.0
/ip address add address=10.10.20.1/24 interface=wireguard1 network=10.10.20.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

#/ip dhcp-client add disabled=no interface=wifi2
/ip dhcp-server network add address=192.168.20.0/24 dns-server=192.168.20.1 gateway=192.168.20.1
/ip dhcp-server network add address=192.168.21.0/24 dns-server=192.168.21.1 gateway=192.168.21.1
/ip dns set allow-remote-requests=yes
/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="allow WireGuard" dst-port=13231 protocol=udp 
add action=accept chain=input comment="allow WireGuard traffic" in-interface=wireguard1 
add action=accept chain=input comment="users to Router services" in-interface-list=LAN dst-port=53,8291 protocol=tcp
add action=accept chain=input comment="users to Router services" in-interface-list=LAN dst-port=53 protocol=udp
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=forward comment="allow internet" in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
add action=drop chain=forward comment="Drop all else"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/system clock set time-zone-name=Asia/Bangkok
/system identity set name=SonosRACKAX
/system note set show-at-login=no
/system ntp client set enabled=yes
#/system ntp client servers add address=time.cloudflare.com
/user add name=gle group=full password=thaigaming
/user add name=sonos group=full password=33338888
/user remove 0