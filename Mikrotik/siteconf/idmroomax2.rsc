# 2024-12-08 15:25:05 by RouterOS 7.16beta7
# software id = J3MH-9KLG
#
# model = C52iG-5HaxD2HaxD
# serial number = HDK08VN3F8D
/interface bridge add add-dhcp-option82=yes arp=reply-only dhcp-snooping=yes igmp-snooping=yes name=BRI-TEST port-cost-mode=short querier-interval=30s vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1 private-key="+LT0iVhvvxs7y42MWL4DxiMjCbbLy05uOMwnLaEBul4="
/interface vlan add interface=BRI-TEST name=VLAN100 vlan-id=100
/interface vlan add interface=BRI-TEST name=VLAN111 vlan-id=111
/interface macvlan add interface=VLAN100 mac-address=E6:74:52:D3:1A:DA name=macvlan100
/interface list add name=MANAGE
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan100
/interface list add name=InterfaceListVlan111
/interface wifi channel add band=2ghz-n disabled=no frequency=2300-7300 name=smart width=20/40mhz-eC
/interface wifi channel add band=5ghz-ax disabled=no name=5GAX width=20/40/80mhz
/interface wifi channel add band=2ghz-n disabled=no name=2G width=20mhz
/interface wifi configuration add channel=smart country=Thailand disabled=no mode=station name="station smart" ssid=""
/interface wifi security add authentication-types=wpa2-psk,wpa3-psk disabled=no name=idaemon passphrase=thaigaming
/interface wifi configuration add channel=5GAX channel.band=5ghz-ax .width=20/40/80mhz country=Thailand disabled=no mode=ap name=5G security=idaemon ssid=iDaemon
/interface wifi configuration add channel=2G country=Thailand disabled=no mode=ap name=2G security=idaemon ssid=iDaemon
/interface wifi set [ find default-name=wifi1 ] channel=5GAX configuration=2G configuration.country=Thailand .mode=ap .ssid=iDaemon disabled=no security=idaemon security.authentication-types=wpa2-psk,wpa3-psk
/interface wifi set [ find default-name=wifi2 ] channel=smart channel.band=2ghz-n .frequency=2300-7300 .width=20/40mhz-eC configuration=2G configuration.country=Thailand .mode=station .ssid="Smart 2-4" disabled=no
/ip pool add name=POOL100 ranges=192.168.100.10-192.168.100.200
/ip pool add name=POOL111 ranges=192.168.111.10-192.168.111.200
/ip dhcp-server add add-arp=yes address-pool=POOL100 interface=VLAN100 lease-time=1d name=DHCP100
/ip dhcp-server add address-pool=POOL111 interface=VLAN111 lease-time=1d name=DHCP111
/ip smb users set [ find default=yes ] disabled=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan100 pvid=100
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan111 pvid=111
/ip firewall connection tracking set udp-timeout=10s
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=100
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=111
/interface list member add disabled=yes interface=wifi2 list=WAN
/interface list member add interface=ether2 list=MANAGE
/interface list member add interface=ether3 list=InterfaceListVlan100
/interface list member add interface=ether4 list=InterfaceListVlan100
/interface list member add interface=ether5 list=InterfaceListVlan100
/interface list member add interface=VLAN100 list=LAN
/interface list member add interface=VLAN111 list=LAN
/interface list member add interface=*C list=InterfaceListVlan100
/interface list member add interface=wifi1 list=InterfaceListVlan100
/interface list member add interface=ether1 list=WAN
/interface wireguard peers add allowed-address=10.0.0.1/32,192.168.10.0/24 endpoint-address=hq.sonoslibra.com endpoint-port=13231 interface=wireguard1 name=peerhq public-key="hzWlAOAdla+xUtbMeJxZ7FkESNkCy4uojBdEWRnIvQo="
/ip address add address=192.168.99.1/30 interface=ether2 network=192.168.99.0
/ip address add address=192.168.100.1/24 interface=VLAN100 network=192.168.100.0
/ip address add address=192.168.111.1/24 interface=VLAN111 network=192.168.111.0
/ip address add address=10.0.0.100/24 interface=wireguard1 network=10.0.0.0
/ip cloud set ddns-update-interval=1d update-time=no
/ip dhcp-client add interface=ether1
/ip dhcp-server network add address=192.168.100.0/24 dns-server=192.168.100.1 domain=idmroom.local gateway=192.168.100.1
/ip dhcp-server network add address=192.168.111.0/24 dns-server=192.168.111.1 domain=idmroom.local gateway=192.168.111.1
/ip dns set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8
/ip firewall address-list add address=192.168.100.177 list=admin
/ip firewall filter add action=accept chain=input comment="admin accress" dst-address=192.168.100.177 dst-port=8291 protocol=tcp src-address-list=admin
/ip firewall filter add action=accept chain=input comment="ACCEPT INPUT EST,RELATED,UNTRACKED" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=input comment="DROP INVALID" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
/ip firewall filter add action=accept chain=input comment="users to Router services" dst-port=53 in-interface-list=LAN protocol=udp
/ip firewall filter add action=accept chain=input comment="users to Router services" dst-port=53 in-interface-list=LAN protocol=tcp
/ip firewall filter add action=accept chain=input comment="allow WireGuard" dst-port=13231 protocol=udp
/ip firewall filter add action=accept chain=input comment="users to Router services" dst-port=8291 in-interface-list=LAN protocol=tcp
/ip firewall filter add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
/ip firewall filter add action=accept chain=forward comment="WG to LAN" in-interface-list=LAN out-interface=wireguard1
/ip firewall filter add action=accept chain=forward comment="allow internet" in-interface-list=LAN out-interface-list=WAN
/ip firewall filter add action=drop chain=forward comment="Drop all else"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/ip ipsec profile set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip route add disabled=no dst-address=192.168.10.0/24 gateway=10.0.0.1 routing-table=main suppress-hw-offload=no
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip smb shares set [ find default=yes ] directory=/pub
/system clock set time-zone-autodetect=no time-zone-name=Asia/Bangkok
/system identity set name=iDaemonROOM
/system logging add topics=wireless,debug
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/system script add dont-require-permissions=no name=dhcp_leadstatic owner=gle policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":local lanDomain;\r\
    \n:local lanHostname;\r\
    \n\r\
    \n:set lanDomain \"gle.lan\";\r\
    \n\r\
    \n:local tHostname;\r\
    \n:local tAddress;\r\
    \n\r\
    \n:if (\$leaseBound = 1) do={\r\
    \n    :set lanHostname (\$\"lease-hostname\" . \$lanDomain);\r\
    \n\r\
    \n    /ip dns static;\r\
    \n    :foreach k,v in=[find] do={\r\
    \n        :set tHostname [get \$v \"name\"];\r\
    \n        :set tAddress [get \$v \"address\"];\r\
    \n        :if (\$tHostname = \$lanHostname) do={\r\
    \n            remove \$v ;\r\
    \n            :log info \"Removed old static DNS entry: \$tHostname => \$tAddress\" ;\r\
    \n        };\r\
    \n    };\r\
    \n    /ip dns static add name=\"\$lanHostname\" address=\"\$leaseActIP\" ;\r\
    \n    :log info \"Added new static DNS entry: \$lanHostname => \$leaseActIP\" ;\r\
    \n};"
/tool romon set enabled=yes
