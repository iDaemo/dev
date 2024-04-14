# 2024-03-17 09:26:11 by RouterOS 7.14.1
# software id = J3MH-9KLG
#
# model = C52iG-5HaxD2HaxD
# serial number = HDK08VN3F8D
/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1 private-key="+LT0iVhvvxs7y42MWL4DxiMjCbbLy05uOMwnLaEBul4="
/interface vlan add interface=BRI-TEST name=VLAN100 vlan-id=100
/interface vlan add interface=BRI-TEST name=VLAN111 vlan-id=111
/interface list add name=MANAGE
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan100
/interface list add name=InterfaceListVlan111
/interface wifi channel add band=2ghz-n disabled=no frequency=2462 name=smart width=20/40mhz-eC
/interface wifi channel add band=5ghz-ax disabled=no name=5GAX width=20/40/80mhz
/interface wifi channel add band=2ghz-n disabled=no name=2G width=20mhz
/interface wifi set [ find default-name=wifi2 ] channel=smart channel.band=2ghz-n .frequency=2457 .width=20/40mhz-eC configuration.country=Thailand .mode=station .ssid="smart 3-3" disabled=no
/interface wifi configuration add channel=smart country=Thailand disabled=no mode=station name="station smart" ssid=""
/interface wifi security add authentication-types=wpa2-psk,wpa3-psk disabled=no name=idaemon passphrase=thaigaming
/interface wifi configuration add channel=5GAX channel.band=5ghz-ax .width=20/40/80mhz country=Thailand disabled=no mode=ap name=5G security=idaemon ssid=iDaemon
/interface wifi configuration add channel=2G country=Thailand disabled=no mode=ap name=2G security=idaemon ssid=iDaemon2G
/interface wifi set [ find default-name=wifi1 ] channel=5GAX configuration=5G configuration.country=Thailand .mode=ap .ssid=iDaemon disabled=no security=idaemon security.authentication-types=wpa2-psk,wpa3-psk
/interface wifi add configuration=2G configuration.mode=ap disabled=no mac-address=4A:A9:8A:22:5F:3F master-interface=wifi2 name=wifi3 security=idaemon
/ip pool add name=POOL100 ranges=192.168.100.10-192.168.100.200
/ip pool add name=POOL111 ranges=192.168.111.10-192.168.111.200
/ip dhcp-server add address-pool=POOL100 interface=VLAN100 lease-time=1d name=DHCP100
/ip dhcp-server add address-pool=POOL111 interface=VLAN111 lease-time=1d name=DHCP111
/ip smb users set [ find default=yes ] disabled=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan100 pvid=100
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan111 pvid=111
/ip firewall connection tracking set udp-timeout=10s
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=100
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=111
/interface list member add interface=wifi2 list=WAN
/interface list member add interface=ether2 list=MANAGE
/interface list member add interface=ether3 list=InterfaceListVlan100
/interface list member add interface=ether4 list=InterfaceListVlan100
/interface list member add interface=ether5 list=InterfaceListVlan100
/interface list member add interface=VLAN100 list=LAN
/interface list member add interface=VLAN111 list=LAN
/interface list member add interface=wifi3 list=InterfaceListVlan100
/interface list member add interface=wifi1 list=InterfaceListVlan100
/ip address add address=192.168.99.1/30 interface=ether2 network=192.168.99.0
/ip address add address=192.168.100.1/24 interface=VLAN100 network=192.168.100.0
/ip address add address=192.168.111.1/24 interface=VLAN111 network=192.168.111.0
/ip address add address=10.10.10.1/24 interface=wireguard1 network=10.10.10.0
/ip cloud set ddns-update-interval=1d update-time=no
/ip dhcp-client add interface=wifi2 use-peer-dns=no
/ip dhcp-server network add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1
/ip dhcp-server network add address=192.168.111.0/24 dns-server=192.168.111.1 gateway=192.168.111.1
/ip dns set allow-remote-requests=yes servers=1.1.1.1
/ip firewall filter add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
/ip firewall filter add action=accept chain=input comment="users to Router services" dst-port=53 in-interface-list=LAN protocol=udp
/ip firewall filter add action=accept chain=input comment="allow WireGuard" dst-port=13231 protocol=udp
/ip firewall filter add action=accept chain=input comment="users to Router services" dst-port=53,8291 in-interface-list=LAN protocol=tcp
/ip firewall filter add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=accept chain=forward comment="allow internet" in-interface-list=LAN out-interface-list=WAN
/ip firewall filter add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
/ip firewall filter add action=drop chain=forward comment="Drop all else"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www-ssl disabled=no
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip smb shares set [ find default=yes ] directory=/pub
/system clock set time-zone-name=Asia/Bangkok
/system identity set name=iDaemonROOM
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
