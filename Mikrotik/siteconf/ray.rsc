/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan add interface=BRI-TEST name=VLAN41 vlan-id=41
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan41
/interface wifi channel add band=2ghz-n frequency=2412,2437,2462 name=ch-2ghz width=20mhz
/interface wifi channel add band=5ghz-ac frequency=5500,5580,5745 name=ch-5ghz width=20/40mhz-Ce
/interface wifi security add authentication-types=wpa2-psk name=common-auth passphrase=33338888 wps=disable
/interface wifi configuration add country=Thailand name=common-conf security=common-auth ssid=@AVCONTROLsonosxauraxFATBOY
/interface wifi set [ find default-name=wifi1 ] channel=ch-2ghz configuration=common-conf disabled=no
/interface wifi set [ find default-name=wifi2 ] channel=ch-5ghz configuration=common-conf disabled=no
/ip hotspot profile set [ find default=yes ] html-directory=hotspot
/ip pool add name=POOL41 ranges=192.168.41.10-192.168.41.200
/ip dhcp-server add address-pool=POOL41 interface=VLAN41 lease-time=1d name=DHCP41
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan41 pvid=41
/ipv6 settings set disable-ipv6=yes
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=41
/interface detect-internet set detect-interface-list=WAN
/interface list member add interface=ether1 list=WAN
/interface list member add interface=VLAN41 list=LAN
/interface list member add interface=ether2 list=InterfaceListVlan41
/interface list member add interface=ether3 list=InterfaceListVlan41
/interface list member add interface=ether4 list=InterfaceListVlan41
/interface list member add interface=ether5 list=InterfaceListVlan41
/interface list member add interface=wifi1 list=InterfaceListVlan41
/interface list member add interface=wifi2 list=InterfaceListVlan41
/interface wireguard peers add allowed-address=10.0.0.1/32,192.168.10.0/24 disabled=yes endpoint-address=hq.sonoslibra.com endpoint-port=13231 interface=wireguard1 persistent-keepalive=5s
/ip address add address=10.0.0.41/24 interface=wireguard1 network=10.0.0.0
/ip address add address=192.168.41.1/24 interface=VLAN41 network=192.168.41.0
/ip cloud set ddns-update-interval=1d update-time=no
/ip dhcp-client add interface=ether1
/ip dhcp-server network add address=192.168.41.0/24 dns-server=192.168.41.1 domain=.lan gateway=192.168.41.1
/ip dns set allow-remote-requests=yes
/ip firewall filter add action=accept chain=input comment="Allow Estab & Related" connection-state=established,related
/ip firewall filter add action=drop chain=input comment="Drop invalid input" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="DNS UDP" dst-port=53 in-interface=all-vlan protocol=udp
/ip firewall filter add action=accept chain=input comment="DNS TCP" dst-port=53 in-interface=all-vlan protocol=tcp
/ip firewall filter add action=accept chain=input comment=ICMP in-interface=all-vlan protocol=icmp
/ip firewall filter add action=accept chain=input comment=WireGuard dst-port=13231 protocol=udp
/ip firewall filter add action=accept chain=input comment=Winbox dst-port=8291 protocol=tcp
/ip firewall filter add action=accept chain=input comment="Allow VLAN" in-interface-list=LAN
/ip firewall filter add action=drop chain=input comment="Drop else INPUT"
/ip firewall filter add action=fasttrack-connection chain=forward comment="Fast Track" connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="Allow Established & Related" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="Drop invalid in forward chain" connection-state=invalid
/ip firewall filter add action=accept chain=forward comment="Allow internet" in-interface-list=LAN out-interface-list=WAN
/ip firewall filter add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
/ip firewall filter add action=drop chain=forward comment="Drop ALL"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set ssh disabled=yes port=22022
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip ssh set strong-crypto=yes
/ipv6 nd set [ find default=yes ] disabled=yes
/system clock set time-zone-name=Asia/Bangkok
/system identity set name=Fatboy
/system logging add topics=wireless,debug
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/tool bandwidth-server set enabled=no