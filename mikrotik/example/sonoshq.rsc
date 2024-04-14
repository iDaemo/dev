# 2024-04-13 15:54:12 by RouterOS 7.14.2
# software id = 04H0-FDC6
#
# model = CCR2004-16G-2S+
# serial number = HD0084APN5W
/interface bridge add igmp-snooping=yes igmp-version=3 name=BRI-TEST port-cost-mode=short protocol-mode=none query-interval=30s vlan-filtering=yes
/interface ethernet set [ find default-name=ether1 ] comment=WAN name=ether1-wan
/interface ethernet set [ find default-name=ether2 ] name=ether2-oob
/interface ethernet set [ find default-name=ether12 ] name=ether12-apfl2
/interface ethernet set [ find default-name=ether13 ] name=ether13-dvs
/interface ethernet set [ find default-name=ether15 ] name=ether15-trunk
/interface ethernet set [ find default-name=ether16 ] name=ether16-apfl3
/interface pppoe-client add add-default-route=yes disabled=no interface=ether1-wan name=Trueonline password=Password service-name=Trueonline use-peer-dns=yes user=9605418601@fiberhome
/interface veth add address=192.168.10.238/24 gateway=192.168.10.1 gateway6="" name=veth1
/interface veth add address=192.168.10.239/24 gateway=192.168.10.1 gateway6="" name=veth2
/interface wireguard add listen-port=13231 mtu=1420 name=wg-sonoshq private-key="0P7UrLurunhoIkU4+cUp3wjS3XbL0uUeqr4gbm/po3E="
/interface vlan add interface=BRI-TEST name=VLAN10-LOCAL vlan-id=10
/interface vlan add interface=BRI-TEST name=VLAN11-WIFI vlan-id=11
/interface vlan add interface=BRI-TEST name=VLAN12-AGORACONTROL vlan-id=256
/interface vlan add interface=BRI-TEST name=VLAN20-LIGHT vlan-id=20
/interface list add name=WAN
/interface list add name=InterfaceListVlan10
/interface list add name=InterfaceListVlan11
/interface list add name=InterfaceListVlan12
/interface list add name=VLANS
/interface list add name=Manage
/ip pool add name=POOL10 ranges=192.168.10.101-192.168.10.249
/ip pool add name=POOL11 ranges=192.168.11.101-192.168.11.249
/ip pool add name=POOL12 ranges=192.168.12.101-192.168.12.249
/ip pool add name=dhcp_pool3 ranges=192.168.99.2-192.168.99.254
/ip dhcp-server add address-pool=POOL10 interface=VLAN10-LOCAL lease-script="# DNS TTL to set for DNS entries\r\
    \n:local dnsttl \"00:15:00\";\r\
    \n\r\
    \n###\r\
    \n# Script entry point\r\
    \n#\r\
    \n# Expected environment variables:\r\
    \n# leaseBound         1 = lease bound, 0 = lease removed\r\
    \n# leaseServerName    Name of DHCP server\r\
    \n# leaseActIP         IP address of DHCP client\r\
    \n#leaseActMAC      MAC address of DHCP client\r\
    \n###\r\
    \n\r\
    \n# \"a.b.c.d\" -> \"a-b-c-d\" for IP addresses used as replacement for missing host names\r\
    \n:local ip2Host do=\\\r\
    \n{\r\
    \n  :local outStr\r\
    \n  :for i from=0 to=([:len \$inStr] - 1) do=\\\r\
    \n  {\r\
    \n    :local tmp [:pick \$inStr \$i];\r\
    \n    :if (\$tmp =\".\") do=\\\r\
    \n    {\r\
    \n      :set tmp \"-\"\r\
    \n    }\r\
    \n    :set outStr (\$outStr . \$tmp)\r\
    \n  }\r\
    \n  :return \$outStr\r\
    \n}\r\
    \n\r\
    \n:local mapHostName do={\r\
    \n# param: name\r\
    \n# max length = 63\r\
    \n# allowed chars a-z,0-9,-\r\
    \n  :local allowedChars \"abcdefghijklmnopqrstuvwxyz0123456789-\";\r\
    \n  :local numChars [:len \$name];\r\
    \n  :if (\$numChars > 63) do={:set numChars 63};\r\
    \n  :local result \"\";\r\
    \n\r\
    \n  :for i from=0 to=(\$numChars - 1) do={\r\
    \n    :local char [:pick \$name \$i];\r\
    \n    :if ([:find \$allowedChars \$char] < 0) do={:set char \"-\"};\r\
    \n    :set result (\$result . \$char);\r\
    \n  }\r\
    \n  :return \$result;\r\
    \n}\r\
    \n\r\
    \n:local lowerCase do={\r\
    \n# param: entry\r\
    \n  :local lower \"abcdefghijklmnopqrstuvwxyz\";\r\
    \n  :local upper \"ABCDEFGHIJKLMNOPQRSTUVWXYZ\";\r\
    \n  :local result \"\";\r\
    \n  :for i from=0 to=([:len \$entry] - 1) do={\r\
    \n    :local char [:pick \$entry \$i];\r\
    \n    :local pos [:find \$upper \$char];\r\
    \n    :if (\$pos > -1) do={:set char [:pick \$lower \$pos]};\r\
    \n    :set result (\$result . \$char);\r\
    \n  }\r\
    \n  :return \$result;\r\
    \n}\r\
    \n\r\
    \n:local token \"\$leaseServerName-\$leaseActMAC\";\r\
    \n:local LogPrefix \"DHCP2DNS (\$leaseServerName)\"\r\
    \n\r\
    \n:if ( [ :len \$leaseActIP ] <= 0 ) do=\\\r\
    \n{\r\
    \n  :log error \"\$LogPrefix: empty lease address\"\r\
    \n  :error \"empty lease address\"\r\
    \n}\r\
    \n\r\
    \n:if ( \$leaseBound = 1 ) do=\\\r\
    \n{\r\
    \n  # new DHCP lease added\r\
    \n  /ip dhcp-server\r\
    \n  #:local dnsttl [ get [ find name=\$leaseServerName ] lease-time ]\r\
    \n  network\r\
    \n  :local domain [ get [ find \$leaseActIP in address ] domain ]\r\
    \n  #:log info \"\$LogPrefix: DNS domain is \$domain\"\r\
    \n\r\
    \n  :local hostname [/ip dhcp-server lease get [:pick [find mac-address=\$leaseActMAC and server=\$leaseServerName] 0] value-name=host-name]\r\
    \n  #:log info \"\$LogPrefix: DHCP hostname is \$hostname\"\r\
    \n\r\
    \n #Hostname cleanup\r\
    \n  :if ( [ :len \$hostname ] <= 0 ) do=\\\r\
    \n  {\r\
    \n    :set hostname [ \$ip2Host inStr=\$leaseActIP ]\r\
    \n    :log info \"\$LogPrefix: Empty hostname for '\$leaseActIP', using generated host name '\$hostname'\"\r\
    \n  }\r\
    \n  :set hostname [\$lowerCase entry=\$hostname]\r\
    \n  :set hostname [\$mapHostName name=\$hostname]\r\
    \n  #:log info \"\$LogPrefix: Clean hostname for FQDN is \$hostname\";\r\
    \n\r\
    \n  :if ( [ :len \$domain ] <= 0 ) do=\\\r\
    \n  {\r\
    \n    :log warning \"\$LogPrefix: Empty domainname for '\$leaseActIP', cannot create static DNS name\"\r\
    \n    :error \"Empty domainname for '\$leaseActIP'\"\r\
    \n  }\r\
    \n\r\
    \n  :local fqdn (\$hostname . \".\" .  \$domain)\r\
    \n  #:log info \"\$LogPrefix: FQDN for DNS is \$fqdn\"\r\
    \n\r\
    \n    :if ([/ip dhcp-server lease get [:pick [find mac-address=\$leaseActMAC and server=\$leaseServerName] 0] ]) do={\r\
    \n      # :log info message=\"\$LogPrefix: \$leaseActMAC -> \$hostname\"\r\
    \n      :do {\r\
    \n        /ip dns static add address=\$leaseActIP name=\$fqdn ttl=\$dnsttl comment=\$token;\r\
    \n      } on-error={:log error message=\"\$LogPrefix: Failure during dns registration of \$fqdn with \$leaseActIP\"}\r\
    \n    }\r\
    \n\r\
    \n} else={\r\
    \n# DHCP lease removed\r\
    \n  /ip dns static remove [find comment=\$token];\r\
    \n}" lease-time=1d name=dhcp-vlan10
/ip dhcp-server add address-pool=POOL11 interface=VLAN11-WIFI lease-time=1d name=dhcp-vlan11
/ip dhcp-server add address-pool=POOL12 interface=VLAN12-AGORACONTROL lease-script=":local scriptName \"dhcp2dns\"\r\
    \n:do {\r\
    \n  :local scriptObj [:parse [/system script get \$scriptName source]]\r\
    \n  \$scriptObj leaseBound=\$leaseBound leaseServerName=\$leaseServerName leaseActIP=\$leaseActIP leaseActMAC=\$leaseActMAC\r\
    \n} on-error={ :log warning \"DHCP server '\$leaseServerName' lease script error\" };" lease-time=1d name=dhcp-vlan12
/ip smb users set [ find default=yes ] disabled=yes
/port set 0 name=serial0
/port set 1 name=serial1
/system logging action add bsd-syslog=yes name=syslog remote=192.168.10.250 syslog-facility=syslog target=remote
/container add cmd="tunnel --no-autoupdate run --token eyJhIjoiNjdjMzM0ZTA0ZDc1ZTc4OGNhZTFiMjQ4NWEwYWMwM2MiLCJ0IjoiNjUyNThmMTYtNGZhNy00ZGIxLTkwZTMtM2QyZTcyN2NkMWU1IiwicyI6Ik1UVTBNV1pqTURJdFl6WXlOQzAwTURKaUxUZzRabUV0WkdNek5HTXdOREF3Tm1GaiJ9" interface=veth1 start-on-boot=yes workdir=/home/nonroot
/container config set registry-url=https://registry.hub.docker.com/ tmpdir=pub
/interface bridge filter add action=drop chain=forward comment="Drop all IPv6 mDNS" disabled=yes dst-mac-address=33:33:00:00:00:FB/FF:FF:FF:FF:FF:FF log=yes log-prefix=drop.mdns.ipv6 mac-protocol=ipv6
/interface bridge port add bridge=BRI-TEST fast-leave=yes frame-types=admit-only-vlan-tagged interface=ether15-trunk internal-path-cost=10 path-cost=10 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan10 internal-path-cost=10 path-cost=10 pvid=10 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan11 internal-path-cost=10 path-cost=10 pvid=11 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan12 internal-path-cost=10 path-cost=10 pvid=12 trusted=yes
/ip firewall connection tracking set udp-timeout=10s
/ip neighbor discovery-settings set discover-interface-list=all
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=10
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=11
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=12
/interface list member add interface=Trueonline list=WAN
/interface list member add interface=ether3 list=InterfaceListVlan10
/interface list member add interface=ether4 list=InterfaceListVlan10
/interface list member add interface=ether5 list=InterfaceListVlan10
/interface list member add interface=ether6 list=InterfaceListVlan10
/interface list member add interface=ether7 list=InterfaceListVlan10
/interface list member add interface=ether8 list=InterfaceListVlan10
/interface list member add interface=ether11 list=InterfaceListVlan10
/interface list member add interface=ether13-dvs list=InterfaceListVlan10
/interface list member add interface=ether14 list=InterfaceListVlan10
/interface list member add interface=ether12-apfl2 list=InterfaceListVlan10
/interface list member add interface=ether16-apfl3 list=InterfaceListVlan10
/interface list member add interface=VLAN10-LOCAL list=VLANS
/interface list member add interface=VLAN11-WIFI list=VLANS
/interface list member add interface=VLAN12-AGORACONTROL list=VLANS
/interface list member add interface=ether2-oob list=Manage
/interface list member add interface=ether9 list=InterfaceListVlan10
/interface list member add interface=ether10 list=InterfaceListVlan10
/interface list member add interface=*21 list=InterfaceListVlan10
/interface list member add interface=veth1 list=InterfaceListVlan10
/interface list member add interface=veth2 list=InterfaceListVlan10
/interface wireguard peers add allowed-address=10.0.0.2/32 comment=Gle interface=wg-sonoshq public-key="MaHvrXErTnQ4m7gfoRR0Kbz8zKnIM9C8LlnFu1WGXRg="
/interface wireguard peers add allowed-address=10.0.0.3/32 interface=wg-sonoshq public-key="MNjdDqRmK4C0zvfqqrYoeTq1Fy7qpbqOBf23gJiDrmU="
/interface wireguard peers add allowed-address=10.0.0.4/32 interface=wg-sonoshq public-key="4GLnFZOT8xVoUy1BrxFnRaklMfNSmuBrzjq+YvH0qV0="
/interface wireguard peers add allowed-address=10.0.0.5/32 interface=wg-sonoshq public-key="TS3Vob4YZqaQSzxpYqlp+KPh3OzCg1JUMpSkxYbr9U0="
/interface wireguard peers add allowed-address=10.0.0.6/32 interface=wg-sonoshq public-key="VPPuNYcG/4lKJdCuv7vuzHXI2x4hC3W3yq3Bd4nJGy8="
/interface wireguard peers add allowed-address=10.0.0.7/32 interface=wg-sonoshq public-key="FfdbBi4N8wtIF+bSkeFVGZd1or6agClt9lsq1dcvalQ="
/interface wireguard peers add allowed-address=10.0.0.8/32 interface=wg-sonoshq public-key="kEs8ACRR5tOVdN2f+VVoK4nLaSGxNXPtiO/zkgRK+XI="
/interface wireguard peers add allowed-address=10.0.0.9/32 interface=wg-sonoshq public-key="5tduxOb3OoVkbrak4zf9Tq3GX//thS84xj3ZoaPUblU="
/interface wireguard peers add allowed-address=10.0.0.10/32 interface=wg-sonoshq public-key="sqszAiDa2nl+DhrUX0gmrHygCiQ6ugGS3fOGyCT74FE="
/interface wireguard peers add allowed-address=10.0.0.11/32 interface=wg-sonoshq public-key="Zmn0RE2rCU7AI9eqfzkiKdgQcR0yN0A0oen5VxHAIz4="
/interface wireguard peers add allowed-address=10.0.0.12/32 comment=hrc-kl interface=wg-sonoshq public-key="yAi/YI2Xj4AJRihUDRiW1muySqOK7gifIMYA4SKlgAg="
/interface wireguard peers add allowed-address=10.0.0.13/32,192.168.20.0/24 comment="Hap ac2 mobile" interface=wg-sonoshq public-key="ACW5Tee4YtTaud/5gEdvjjN/p+jUgi4ts+RiszjXvUo="
/interface wireguard peers add allowed-address=10.0.0.40/32,192.168.40.0/24 comment="Raynue 192.168.40.0/24" interface=wg-sonoshq public-key="bZjIr4w5B8LsOO0onCK1ZmFthCygs23aQvTSXemV/B4="
/ip address add address=192.168.10.1/24 interface=VLAN10-LOCAL network=192.168.10.0
/ip address add address=192.168.11.1/24 interface=VLAN11-WIFI network=192.168.11.0
/ip address add address=192.168.12.1/24 interface=VLAN12-AGORACONTROL network=192.168.12.0
/ip address add address=10.0.0.1/24 interface=wg-sonoshq network=10.0.0.0
/ip address add address=192.168.99.1/24 interface=ether2-oob network=192.168.99.0
/ip address add address=192.168.0.1/24 interface=BRI-TEST network=192.168.0.0
/ip cloud set ddns-enabled=yes ddns-update-interval=1d update-time=no
/ip dhcp-client add disabled=yes interface=ether1-wan use-peer-dns=no
/ip dhcp-server lease add address=192.168.10.236 client-id=1:2:11:32:26:28:60 mac-address=02:11:32:26:28:60 server=dhcp-vlan10
/ip dhcp-server network add address=192.168.10.0/24 dns-server=192.168.10.1 domain=hq.lan gateway=192.168.10.1
/ip dhcp-server network add address=192.168.11.0/24 dns-server=192.168.11.1 domain=hq.lan gateway=192.168.11.1
/ip dhcp-server network add address=192.168.12.0/24 dns-server=192.168.12.1 domain=hq.lan gateway=192.168.12.1
/ip dhcp-server network add address=192.168.99.0/24 dns-server=8.8.8.8,1.1.1.1 domain=hq.lan gateway=192.168.99.1
/ip dns set allow-remote-requests=yes cache-max-ttl=3d cache-size=4096KiB doh-max-concurrent-queries=500 doh-max-server-connections=50 max-concurrent-queries=1000 max-concurrent-tcp-sessions=200 servers=1.1.1.1,1.0.0.1 verify-doh-cert=yes
/ip dns static add address=192.168.10.143 comment=dhcp-vlan10-B0:1F:8C:C7:CD:C4 name=sonos-ap02-fl3.hq.lan ttl=15m
/ip dns static add address=192.168.10.119 comment=dhcp-vlan10-F0:B3:EC:80:37:B6 name=groundfshowroom.hq.lan ttl=15m
/ip dns static add address=192.168.10.220 comment=dhcp-vlan10-6E:5E:26:EB:E9:6C name=192-168-10-220.hq.lan ttl=15m
/ip dns static add address=192.168.10.219 comment=dhcp-vlan10-02:FD:0E:2B:3B:2E name=192-168-10-219.hq.lan ttl=15m
/ip dns static add address=192.168.10.123 comment=dhcp-vlan10-10:63:C8:3C:B4:A5 name=laptop-3he2sio9.hq.lan ttl=15m
/ip dns static add address=192.168.10.104 comment=dhcp-vlan10-8A:1B:C5:B6:96:B3 name=192-168-10-104.hq.lan ttl=15m
/ip dns static add address=192.168.10.103 comment=dhcp-vlan10-EE:43:85:FA:31:F1 name=192-168-10-103.hq.lan ttl=15m
/ip dns static add address=192.168.10.142 comment=dhcp-vlan10-94:E2:3C:95:65:9B name=ball.hq.lan ttl=15m
/ip dns static add address=192.168.10.113 comment=dhcp-vlan10-3A:8C:D9:28:7A:A6 name=192-168-10-113.hq.lan ttl=15m
/ip dns static add address=192.168.10.108 comment=dhcp-vlan10-FA:A8:FD:15:15:29 name=redmi-note-13.hq.lan ttl=15m
/ip dns static add address=192.168.10.131 comment=dhcp-vlan10-96:74:DE:E2:ED:9D name=a05s-khxng-alba.hq.lan ttl=15m
/ip dns static add address=192.168.10.115 comment=dhcp-vlan10-10:6F:D9:B5:58:9D name=desktop-ma8rhkf.hq.lan ttl=15m
/ip dns static add address=192.168.10.111 comment=dhcp-vlan10-62:D0:A1:C1:FA:B1 name=192-168-10-111.hq.lan ttl=15m
/ip dns static add address=192.168.10.102 comment=dhcp-vlan10-D4:1A:3F:8E:60:ED name=android-57941bd62fac9134.hq.lan ttl=15m
/ip dns static add address=192.168.10.121 comment=dhcp-vlan10-2A:81:D2:2C:EB:D1 name=192-168-10-121.hq.lan ttl=15m
/ip dns static add address=192.168.10.101 comment=dhcp-vlan10-AA:53:46:F0:47:79 name=realme-c55.hq.lan ttl=15m
/ip dns static add address=192.168.10.241 comment=dhcp-vlan10-B0:1F:8C:C7:D7:C2 name=sonos-ap01-fl2.hq.lan ttl=15m
/ip dns static add address=192.168.10.153 comment=dhcp-vlan10-00:12:41:32:A1:1F name=localhost.hq.lan ttl=15m
/ip dns static add address=192.168.10.243 comment=dhcp-vlan10-4C:06:B7:00:54:1A name=192-168-10-243.hq.lan ttl=15m
/ip dns static add address=192.168.10.223 comment=dhcp-vlan10-1C:91:80:B9:A6:45 name=guntapongs-air.hq.lan ttl=15m
/ip firewall filter add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
/ip firewall filter add action=accept chain=input dst-port=53 log-prefix=req-in-fw: protocol=udp
/ip firewall filter add action=accept chain=input dst-port=13231 log-prefix=req-in-fw: protocol=udp
/ip firewall filter add action=accept chain=input dst-port=443 log-prefix=other protocol=tcp
/ip firewall filter add action=accept chain=input in-interface=wg-sonoshq log-prefix=wg
/ip firewall filter add action=accept chain=input in-interface-list=VLANS log-prefix=vlan-req:
/ip firewall filter add action=drop chain=input comment="drop all else" log-prefix=drop-input
/ip firewall filter add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-mark=no-mark connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid log-prefix=drop-invalid-forward
/ip firewall filter add action=jump chain=forward comment="allow port forwarding" connection-nat-state=dstnat jump-target=ChainForwardAll log-prefix=chainalowportfw
/ip firewall filter add action=jump chain=forward in-interface-list=VLANS jump-target=ChainForwardAll log-prefix=vlan>wan out-interface-list=WAN
/ip firewall filter add action=jump chain=forward in-interface=ether2-oob jump-target=ChainForwardAll out-interface-list=WAN
/ip firewall filter add action=jump chain=forward in-interface=ether2-oob jump-target=ChainForwardAll out-interface-list=VLANS
/ip firewall filter add action=jump chain=forward in-interface=wg-sonoshq jump-target=ChainForwardAll out-interface-list=VLANS
/ip firewall filter add action=jump chain=forward in-interface-list=VLANS jump-target=ChainForwardAll out-interface=wg-sonoshq
/ip firewall filter add action=drop chain=forward comment="drop all else" log-prefix=drop-forward
/ip firewall filter add action=accept chain=ChainForwardAll
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/ip firewall nat add action=dst-nat chain=dstnat disabled=yes dst-port=443 in-interface-list=WAN log-prefix=go protocol=tcp to-addresses=192.168.10.250 to-ports=443
/ip firewall nat add action=dst-nat chain=dstnat disabled=yes dst-port=80 in-interface-list=WAN log-prefix=go protocol=tcp to-addresses=192.168.10.250 to-ports=80
/ip firewall nat add action=dst-nat chain=dstnat comment="DSM Synology" disabled=yes dst-port=5655,5654 in-interface-list=WAN log-prefix=go protocol=tcp to-addresses=192.168.10.250 to-ports=5655
/ip route add disabled=no distance=1 dst-address=192.168.20.0/24 gateway=10.0.0.13 routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip route add comment=RAYNUE disabled=no distance=1 dst-address=192.168.40.0/24 gateway=10.0.0.40 pref-src="" routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set ssh port=22022
/ip service set www-ssl disabled=no
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip smb shares set [ find default=yes ] directory=/pub
/system clock set time-zone-name=Asia/Bangkok
/system identity set name=SonosLibraHQ
/system logging add action=syslog topics=firewall
/system logging add action=syslog topics=critical
/system logging add action=syslog topics=warning
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/system scheduler add interval=5m name=cf-updater on-event="/system script run cf_update\r\
    \n/system script run cf_update_wiki" policy=ftp,read,write,test start-date=2023-07-09 start-time=00:49:03
/system scheduler add interval=1m name=dnsupdate on-event="/system script run dnsrefresh" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=2023-10-04 start-time=04:34:52
/system script add dont-require-permissions=no name=cf_update owner=admin policy=ftp,read,write,test source="################# CloudFlare variables #################\r\
    \n:local CFDebug \"false\"\r\
    \n:local CFcloud \"false\"\r\
    \n\r\
    \n:global WANInterface \"Trueonline\"\r\
    \n\r\
    \n:local CFdomain \"hq.sonoslibra.com\"\r\
    \n\r\
    \n:local CFtkn \"0Wig2bVDagpecrDPqfkRKoxbLedTeE_KAnnKuOxF\"\r\
    \n\r\
    \n:local CFzoneid \"99b45096ed0908a2216d066429fc2fb9\"\r\
    \n:local CFid \"1368e72a5a6f9dc560572df630334038\"\r\
    \n\r\
    \n:local CFrecordType \"\"\r\
    \n:set CFrecordType \"A\"\r\
    \n\r\
    \n:local CFrecordTTL \"\"\r\
    \n:set CFrecordTTL \"300\"\r\
    \n\r\
    \n#########################################################################\r\
    \n########################  DO NOT EDIT BELOW  ############################\r\
    \n#########################################################################\r\
    \n\r\
    \n##:log info \"Updating \$CFDomain ...\"\r\
    \n\r\
    \n################# Internal variables #################\r\
    \n:local previousIP \"\"\r\
    \n:global WANip \"\"\r\
    \n\r\
    \n################# Build CF API Url (v4) #################\r\
    \n:local CFurl \"https://api.cloudflare.com/client/v4/zones/\"\r\
    \n:set CFurl (\$CFurl . \"\$CFzoneid/dns_records/\$CFid\");\r\
    \n \r\
    \n################# Get or set previous IP-variables #################\r\
    \n:if (\$CFcloud = \"true\") do={\r\
    \n    :set WANip [/ip cloud get public-address]\r\
    \n};\r\
    \n\r\
    \n:if (\$CFcloud = \"false\") do={\r\
    \n    :local currentIP [/ip address get [/ip address find interface=\$WANInterface ] address];\r\
    \n    :set WANip [:pick \$currentIP 0 [:find \$currentIP \"/\"]];\r\
    \n};\r\
    \n\r\
    \n:if ([/file find name=ddns.tmp.txt] = \"\") do={\r\
    \n    :log error \"No previous ip address file found, createing...\"\r\
    \n    :set previousIP \$WANip;\r\
    \n    :execute script=\":put \$WANip\" file=\"ddns.tmp\";\r\
    \n    :log info (\"CF: Updating CF, setting \$CFDomain = \$WANip\")\r\
    \n    /tool fetch http-method=put mode=https output=none url=\"\$CFurl\" http-header-field=\"Authorization:Bearer \$CFtkn,content-type:application/json\" http-data=\"{\\\"type\\\":\\\"\$CFrecordType\\\",\\\"name\\\":\\\"\$CFdomain\\\",\\\"ttl\\\":\$CFrecordTTL,\\\"content\\\":\\\"\$WANip\\\"}\"\r\
    \n    :error message=\"No previous ip address file found.\"\r\
    \n} else={\r\
    \n    :if ( [/file get [/file find name=ddns.tmp.txt] size] > 0 ) do={ \r\
    \n    :global content [/file get [/file find name=\"ddns.tmp.txt\"] contents] ;\r\
    \n    :global contentLen [ :len \$content ] ;  \r\
    \n    :global lineEnd 0;\r\
    \n    :global line \"\";\r\
    \n    :global lastEnd 0;   \r\
    \n            :set lineEnd [:find \$content \"\\n\" \$lastEnd ] ;\r\
    \n            :set line [:pick \$content \$lastEnd \$lineEnd] ;\r\
    \n            :set lastEnd ( \$lineEnd + 1 ) ;   \r\
    \n            :if ( [:pick \$line 0 1] != \"#\" ) do={   \r\
    \n                #:local previousIP [:pick \$line 0 \$lineEnd ]\r\
    \n                :set previousIP [:pick \$line 0 \$lineEnd ];\r\
    \n                :set previousIP [:pick \$previousIP 0 [:find \$previousIP \"\\r\"]];\r\
    \n            }\r\
    \n    }\r\
    \n}\r\
    \n\r\
    \n######## Write debug info to log #################\r\
    \n:if (\$CFDebug = \"true\") do={\r\
    \n :log info (\"CF: hostname = \$CFdomain\")\r\
    \n :log info (\"CF: previousIP = \$previousIP\")\r\
    \n :log info (\"CF: currentIP = \$currentIP\")\r\
    \n :log info (\"CF: WANip = \$WANip\")\r\
    \n :log info (\"CF: CFurl = \$CFurl&content=\$WANip\")\r\
    \n :log info (\"CF: Command = \\\"/tool fetch http-method=put mode=https url=\\\"\$CFurl\\\" http-header-field=\"Authorization:Bearer \$CFtkn,content-type:application/json\" output=none http-data=\\\"{\\\"type\\\":\\\"\$CFrecordType\\\",\\\"name\\\":\\\"\$CFdomain\\\",\\\"ttl\\\":\$CFrecordTTL,\\\"content\\\":\\\"\$WANip\\\"}\\\"\")\r\
    \n};\r\
    \n  \r\
    \n######## Compare and update CF if necessary #####\r\
    \n:if (\$previousIP != \$WANip) do={\r\
    \n :log info (\"CF: Updating CF, setting \$CFDomain = \$WANip\")\r\
    \n /tool fetch http-method=put mode=https url=\"\$CFurl\" http-header-field=\"Authorization:Bearer \$CFtkn,content-type:application/json\" output=none http-data=\"{\\\"type\\\":\\\"\$CFrecordType\\\",\\\"name\\\":\\\"\$CFdomain\\\",\\\"ttl\\\":\$CFrecordTTL,\\\"content\\\":\\\"\$WANip\\\"}\"\r\
    \n /ip dns cache flush\r\
    \n    :if ( [/file get [/file find name=ddns.tmp.txt] size] > 0 ) do={\r\
    \n        /file remove ddns.tmp.txt\r\
    \n        :execute script=\":put \$WANip\" file=\"ddns.tmp\"\r\
    \n    }\r\
    \n} else={\r\
    \n# :log info \"CF: No Update Needed!\"\r\
    \n}"
/system script add dont-require-permissions=no name=updatearp owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":local wanInterfaceName \"Trueonline\";\r\
    \n# Remove ARP entries that do not have static DHCP leases or are disabled\r\
    \n:foreach arpId in=[/ip arp find] do={\r\
    \n#Don't remove the dynamic entry on the WAN side\r\
    \n  :if ([/ip arp get \$arpId interface] != \$wanInterfaceName) do={\r\
    \n#If there is no matching entry in the lease table remove it\r\
    \n:local mac [/ip arp get \$arpId mac-address];\r\
    \n:local leaseId [/ip dhcp-server lease find where mac-address=\$mac];\r\
    \n:if (\$leaseId=\"\") do={\r\
    \n/ip arp remove \$arpId;\r\
    \n:log info (\"Removing old ARP entry\");\r\
    \n} else={\r\
    \n:if ([/ip dhcp-server lease get \$leaseId disabled]) do={\r\
    \n/ip arp remove \$arpId;\r\
    \n:log info (\"Removing disabled ARP entry\");\r\
    \n}}}}\r\
    \n:foreach leaseId in=[/ip dhcp-server lease find where !dynamic] do={\r\
    \n:local mac  [/ip dhcp-server lease get \$leaseId mac-address];\r\
    \n:local arpId [/ip arp find where mac-address=\$mac];\r\
    \n:if (\$arpId=\"\" && ![/ip dhcp-server lease get \$leaseId disabled]) do={\r\
    \n:local ip [/ip dhcp-server lease get \$leaseId address];\r\
    \n:local comment  [/ip dhcp-server lease get \$leaseId comment];\r\
    \n#interface should not be hard coded but couldn't figure out what to do\r\
    \n:local interface lan_wlan_bridge;\r\
    \n/ip arp add address= \$ip mac-address= \$mac comment= \$comment interface= \$interface;\r\
    \n:log info (\"Adding new ARP entry\");\r\
    \n}\r\
    \n}"
/tool bandwidth-server set enabled=no
/tool mac-server mac-winbox set allowed-interface-list=Manage
