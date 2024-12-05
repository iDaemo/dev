/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan add interface=BRI-TEST name=VLAN101 vlan-id=101
/interface vlan add interface=BRI-TEST name=VLAN102 vlan-id=102
/interface list add name=MANAGE
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan101
/interface list add name=InterfaceListVlan102


/ip pool add name=POOL101 ranges=192.168.101.11-192.168.101.240
/ip pool add name=POOL102 ranges=192.168.102.11-192.168.102.240

/ip dhcp-server add address-pool=POOL101 interface=VLAN101 lease-time=1d name=DHCP101
/ip dhcp-server add address-pool=POOL102 interface=VLAN102 lease-time=1d name=DHCP102
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan101 pvid=101
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan102 pvid=102
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=101
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=102
#/interface list member add interface=wlan1 list=WAN
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=InterfaceListVlan101
/interface list member add interface=ether3 list=InterfaceListVlan101
/interface list member add interface=ether4 list=InterfaceListVlan101
/interface list member add interface=ether5 list=InterfaceListVlan101
/interface list member add interface=VLAN101 list=LAN
/interface list member add interface=VLAN102 list=LAN
#/interface list member add interface=wifi1 list=InterfaceListVlan101
#/interface list member add interface=wifi2 list=InterfaceListVlan21

#/ip address add address=192.168.99.1/30 interface=ether2 network=192.168.99.0
/ip address add address=192.168.101.1/24 interface=VLAN101 network=192.168.101.0
/ip address add address=192.168.102.1/24 interface=VLAN102 network=192.168.102.0
/ip address add address=10.10.1.1/24 interface=wireguard1 network=10.10.1.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

#/ip dhcp-client add disabled=no interface=wifi2
/ip dhcp-server network add address=192.168.101.0/24 dns-server=192.168.101.1 gateway=192.168.101.1
/ip dhcp-server network add address=192.168.102.0/24 dns-server=192.168.102.1 gateway=192.168.102.1
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
/system identity set name=TGMedia
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/user add name=gle group=full password=thaigaming
/user remove 0