# 2024-07-09 11:39:13 by RouterOS 7.15.2
# software id = 6TYZ-A2MN
#
# model = RBD52G-5HacD2HnD
# serial number = F66A0FE03F67
/interface bridge add igmp-snooping=yes name=BRI-TEST protocol-mode=none vlan-filtering=yes
#/interface lte set [ find default-name=lte1 ] sms-read=no
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1 private-key="cIszD9jXcGG2R1cerOTwdidw89B4R2vFM82q/KGa62k="
/interface vlan add interface=BRI-TEST name=VLAN38 vlan-id=38
/interface vlan add interface=BRI-TEST name=VLAN39 vlan-id=39
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=MGMT
/interface list add name=InterfaceListVlan38
/interface list add name=InterfaceListVlan39
/interface wifi channel add band=2ghz-n frequency=2412,2437,2462 name=ch-2ghz width=20mhz
/interface wifi channel add band=5ghz-ac frequency=5500,5580,5745 name=ch-5ghz width=20/40mhz-Ce
/interface wifi security add authentication-types=wpa2-psk name=common-auth passphrase=33338888 wps=disable
/interface wifi configuration add country=Thailand name=common-conf security=common-auth ssid=@CONTROLsonosxaura
/interface wifi set [ find default-name=wifi1 ] channel=ch-2ghz configuration=common-conf disabled=no
/interface wifi set [ find default-name=wifi2 ] channel=ch-5ghz configuration=common-conf disabled=no
/ip pool add name=POOL38 ranges=192.168.38.161-192.168.38.240
/ip pool add name=POOL39 ranges=192.168.39.161-192.168.39.240
/ip dhcp-server add address-pool=POOL38 interface=VLAN38 lease-time=1d name=DHCP38 server-address=192.168.38.1
/ip dhcp-server add address-pool=POOL39 interface=VLAN39 lease-time=1d name=DHCP39 server-address=192.168.39.1
/interface bridge port add bridge=BRI-TEST interface=ether5
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan38 pvid=38
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan39 pvid=39
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether5 vlan-ids=38
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether5 vlan-ids=39
/interface detect-internet set detect-interface-list=WAN
/interface list member add interface=ether1 list=WAN
/interface list member add interface=VLAN38 list=LAN
/interface list member add interface=VLAN39 list=LAN
/interface list member add interface=ether2 list=InterfaceListVlan38
/interface list member add interface=ether3 list=InterfaceListVlan38
/interface list member add interface=ether4 list=InterfaceListVlan38
/interface list member add interface=wifi1 list=InterfaceListVlan38
/interface list member add interface=wifi2 list=InterfaceListVlan38
#/interface list member add interface=lte1 list=WAN
/interface wireguard peers add allowed-address=192.168.10.0/24,10.0.0.0/24 disabled=yes endpoint-address=hq.sonoslibra.com endpoint-port=13231 interface=wireguard1 name=peer1 persistent-keepalive=10s public-key="hzWlAOAdla+xUtbMeJxZ7FkESNkCy4uojBdEWRnIvQo="
/ip address add address=10.0.0.38/24 interface=wireguard1 network=10.0.0.0
/ip address add address=192.168.38.1/24 interface=VLAN38 network=192.168.38.0
/ip address add address=192.168.39.1/24 interface=VLAN39 network=192.168.39.0
/ip cloud set ddns-update-interval=1d update-time=no
/ip dhcp-client add interface=ether1
/ip dhcp-server network add address=192.168.38.0/24 dns-server=192.168.38.1 domain=.local gateway=192.168.38.1 wins-server=0.0.0.0
/ip dhcp-server network add address=192.168.39.0/24 dns-server=192.168.39.1 domain=.local gateway=192.168.39.1
/ip dns set allow-remote-requests=yes
/ip dns static add address=192.168.38.11 name=ddm-sonoslibra.local
/ip dns static add name=default._dante-ddm-c._tcp.ddm-sonoslibra.local srv-port=8443 srv-priority=0 srv-target=ddm-sonoslibra srv-weight=0 type=SRV
/ip dns static add name=default._dante-ddm-d._udp.ddm-sonoslibra.local srv-port=8000 srv-priority=0 srv-target=ddm-sonoslibra srv-weight=0 type=SRV
/ip firewall filter add action=accept chain=input comment="Allow Estab & Related" connection-state=established,related
/ip firewall filter add action=drop chain=input comment="Drop invalid input" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="DNS UDP" dst-port=53 in-interface=all-vlan protocol=udp
/ip firewall filter add action=accept chain=input comment="DNS TCP" dst-port=53 in-interface=all-vlan protocol=tcp
/ip firewall filter add action=accept chain=input comment=ICMP in-interface=all-vlan protocol=icmp
/ip firewall filter add action=accept chain=input comment=WireGuard dst-port=13231 protocol=udp
/ip firewall filter add action=accept chain=input comment=Winbox dst-port=8291 protocol=tcp
/ip firewall filter add action=accept chain=input comment=DDM dst-port=8443,8000 protocol=tcp
/ip firewall filter add action=accept chain=input comment=DDM dst-port=8443,8000 protocol=udp
/ip firewall filter add action=accept chain=input comment="Allow VLAN" in-interface-list=LAN
/ip firewall filter add action=drop chain=input comment="Drop else INPUT"
/ip firewall filter add action=fasttrack-connection chain=forward comment="Fast Track" connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="Allow Established & Related" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="Drop invalid in forward chain" connection-state=invalid
/ip firewall filter add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
/ip firewall filter add action=accept chain=forward comment="WG to LAN" in-interface-list=LAN out-interface=wireguard1
/ip firewall filter add action=accept chain=forward comment="Allow internet" disabled=yes in-interface-list=LAN out-interface-list=LAN
/ip firewall filter add action=accept chain=forward comment="Allow internet" in-interface-list=LAN out-interface-list=WAN
/ip firewall filter add action=drop chain=forward comment="Drop ALL"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/ip hotspot profile set [ find default=yes ] html-directory=hotspot
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set ssh port=22022
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip ssh set strong-crypto=yes
/system clock set time-zone-name=Asia/Bangkok
/system identity set name=SonosControl38
/system logging add topics=wireless,debug
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/tool bandwidth-server set enabled=no
