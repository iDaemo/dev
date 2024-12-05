/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan add interface=BRI-TEST name=VLAN63 vlan-id=63
/interface vlan add interface=BRI-TEST name=VLAN64 vlan-id=64
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan63
/interface list add name=InterfaceListVlan64


/ip pool add name=POOL63 ranges=192.168.63.10-192.168.63.200
/ip pool add name=POOL64 ranges=192.168.64.10-192.168.64.200

/ip dhcp-server add address-pool=POOL63 interface=VLAN63 lease-time=1d name=DHCP63
/ip dhcp-server add address-pool=POOL64 interface=VLAN64 lease-time=1d name=DHCP64
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan63 pvid=63
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan64 pvid=64
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=63
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=64
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=InterfaceListVlan63
/interface list member add interface=ether3 list=InterfaceListVlan63
/interface list member add interface=ether4 list=InterfaceListVlan63
/interface list member add interface=ether5 list=InterfaceListVlan63
/interface list member add interface=VLAN63 list=LAN
/interface list member add interface=VLAN64 list=LAN

/ip address add address=192.168.63.1/24 interface=VLAN63 network=192.168.63.0
/ip address add address=192.168.64.1/24 interface=VLAN64 network=192.168.64.0
/ip address add address=10.11.11.1/24 interface=wireguard1 network=10.11.11.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

/ip dhcp-client add disabled=no interface=ether1
/ip dhcp-server network add address=192.168.63.0/24 dns-server=192.168.63.1 gateway=192.168.63.1
/ip dhcp-server network add address=192.168.64.0/24 dns-server=192.168.64.1 gateway=192.168.64.1
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
/system identity set name=coco
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/user add name=sonos group=full password=33338888
/user remove 0