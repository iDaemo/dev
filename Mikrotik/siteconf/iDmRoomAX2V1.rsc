/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1 private-key="+LT0iVhvvxs7y42MWL4DxiMjCbbLy05uOMwnLaEBul4="
/interface wireguard peers add allowed-address=10.0.0.1/32,192.168.10.0/24 endpoint-address=hq.sonoslibra.com endpoint-port=13231 interface=wireguard1 name=sonoshq public-key="hzWlAOAdla+xUtbMeJxZ7FkESNkCy4uojBdEWRnIvQo="

/interface vlan add interface=BRI-TEST name=VLAN100 vlan-id=100
/interface vlan add interface=BRI-TEST name=VLAN111 vlan-id=111
/interface list add name=MANAGE
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan100
/interface list add name=InterfaceListVlan111

/interface wifi channel add band=5ghz-ac frequency=5500,5580,5745 name=ch-5ghz width=20/40mhz-Ce
/interface wifi channel add band=2ghz-n frequency=2412,2437,2462 name=ch-2ghz width=20mhz
/interface wifi security add authentication-types=wpa2-psk name=common-auth passphrase=thaigaming wps=disable
/interface wifi configuration add country=Thailand name=common-conf security=common-auth ssid=iDaemon
/interface wifi set [ find default-name=wifi1 ] channel=ch-5ghz configuration=common-conf disabled=no
/interface wifi set [ find default-name=wifi2 ] channel=ch-2ghz configuration=common-conf disabled=no


/ip pool add name=POOL100 ranges=192.168.100.10-192.168.100.200
/ip pool add name=POOL111 ranges=192.168.111.10-192.168.111.200

/ip dhcp-server add address-pool=POOL100 interface=VLAN100 lease-time=1d name=DHCP100
/ip dhcp-server add address-pool=POOL111 interface=VLAN111 lease-time=1d name=DHCP111

/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan100 pvid=100
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan111 pvid=111
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=100
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=111
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=MANAGE
/interface list member add interface=ether3 list=InterfaceListVlan100
/interface list member add interface=ether4 list=InterfaceListVlan100
/interface list member add interface=ether5 list=InterfaceListVlan100
/interface list member add interface=VLAN10 list=LAN
/interface list member add interface=VLAN11 list=LAN


/ip address add address=192.168.99.1/30 interface=ether2 network=192.168.99.0
/ip address add address=192.168.100.1/24 interface=VLAN10 network=192.168.100.0
/ip address add address=192.168.111.1/24 interface=VLAN11 network=192.168.111.0
/ip address add address=10.0.0.100/24 interface=wireguard1 network=10.0.0.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

/ip dhcp-client add interface=ether1 disabled=no 
/ip dhcp-server network add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1
/ip dhcp-server network add address=192.168.111.0/24 dns-server=192.168.111.1 gateway=192.168.111.1
/ip dns set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8

/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="allow WireGuard" dst-port=13231 protocol=udp 
#add action=accept chain=input comment="allow WireGuard traffic" in-interface=wireguard1 
add action=accept chain=input comment="users to Router services" in-interface-list=LAN dst-port=53,8291 protocol=tcp
add action=accept chain=input comment="users to Router services" in-interface-list=LAN dst-port=53 protocol=udp
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=forward comment="allow internet" in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
add action=accept chain=forward comment="WG to LAN" in-interface-list=LAN out-interface=wireguard1
add action=drop chain=forward comment="Drop all else"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN

/ip route add disabled=no dst-address=192.168.10.0/24 gateway=10.0.0.1 routing-table=main suppress-hw-offload=no

/ip smb users set [ find default=yes ] disabled=yes
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set ssh disabled=no
/ip service set www-ssl disabled=no
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/system clock set time-zone-autodetect=no time-zone-name=Asia/Bangkok
/system logging add topics=wireless,debug
/system identity set name=iDaemonROOM
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/user add name=gle group=full password=thaigaming
/user remove 0