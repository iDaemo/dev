# 2025-04-14 05:55:13 by RouterOS 7.18.2
# software id = 04H0-FDC6
#
# model = CCR2004-16G-2S+
# serial number = HD0084APN5W
/interface bridge add igmp-snooping=yes igmp-version=3 name=BRI-TEST port-cost-mode=short protocol-mode=none query-interval=30s vlan-filtering=yes
/interface ethernet set [ find default-name=ether1 ] comment=WAN name=ether1-wan
/interface ethernet set [ find default-name=ether2 ] name=ether2-oob
/interface ethernet set [ find default-name=ether9 ] name=ether9-nas1
/interface ethernet set [ find default-name=ether10 ] name=ether10-nas2
/interface ethernet set [ find default-name=ether11 ] name=ether11--dvs
/interface ethernet set [ find default-name=ether12 ] name=ether12-apfl2
/interface ethernet set [ find default-name=ether13 ] name=ether13-Aura-building
/interface ethernet set [ find default-name=ether15 ] name=ether15-trunk
/interface ethernet set [ find default-name=ether16 ] name=ether16-apfl3
/interface ethernet set [ find default-name=sfp-sfpplus2 ] name=sfp-sfpplus2-apfl2
/interface pppoe-client add add-default-route=yes disabled=no interface=ether1-wan max-mtu=1492 name=Trueonline password=Password service-name=Trueonline use-peer-dns=yes user=9605418601@fiberhome
/interface wireguard add listen-port=13231 mtu=1420 name=wg-sonoshq private-key="0P7UrLurunhoIkU4+cUp3wjS3XbL0uUeqr4gbm/po3E="
/interface vlan add interface=BRI-TEST name=VLAN10-LOCAL vlan-id=10
/interface vlan add interface=BRI-TEST name=VLAN11-WIFI vlan-id=11
/interface vlan add interface=BRI-TEST name=VLAN12-DANTE vlan-id=12
/interface vlan add interface=BRI-TEST name=VLAN13-AURABUILDING vlan-id=13
/interface vlan add interface=BRI-TEST name=VLAN14-LIGHT vlan-id=14
/interface list add name=WAN
/interface list add name=InterfaceListVlan10
/interface list add name=InterfaceListVlan11
/interface list add name=InterfaceListVlan12
/interface list add name=InterfaceListVlan13
/interface list add name=InterfaceListVlan14
/interface list add name=VLANS
/interface list add name=MGMT
/ip pool add name=POOL10 ranges=192.168.10.101-192.168.10.249
/ip pool add name=POOL11 ranges=192.168.11.101-192.168.11.249
/ip pool add name=POOL12 ranges=192.168.12.101-192.168.12.249
/ip pool add name=POOL13 ranges=192.168.13.101-192.168.13.249
/ip pool add name=POOL14 ranges=192.168.14.101-192.168.14.249
/ip pool add name=pool_MGMT ranges=192.168.99.2-192.168.99.20

/ip dhcp-server add add-arp=yes address-pool=POOL10 interface=VLAN10-LOCAL lease-time=1h name=dhcp-vlan10
/ip dhcp-server add add-arp=yes address-pool=POOL11 interface=VLAN11-WIFI lease-time=1h name=dhcp-vlan11
/ip dhcp-server add add-arp=yes address-pool=POOL12 interface=VLAN12-DANTE lease-time=1h name=dhcp-vlan12
/ip dhcp-server add add-arp=yes address-pool=POOL13 interface=VLAN13-AURABUILDING lease-time=1h name=dhcp-vlan13
/ip dhcp-server add add-arp=yes address-pool=POOL14 interface=VLAN14-LIGHT lease-time=1h name=dhcp-vlan14
/ip smb users set [ find default=yes ] disabled=yes
/port set 0 name=serial0
/port set 1 name=serial1
/system logging action add name=syslog remote=192.168.10.250 remote-log-format=syslog syslog-facility=syslog target=remote
/interface bridge filter add action=drop chain=forward comment="Drop all IPv6 mDNS" disabled=yes dst-mac-address=18:FD:74:82:56:68/FF:FF:FF:FF:FF:FF log=yes log-prefix=drop.mdns.ipv6 mac-protocol=ipv6
/interface bridge filter add action=accept chain=forward comment="Allow mDNS only" disabled=yes dst-address=224.0.0.251/32 dst-mac-address=01:00:5E:00:00:FB/FF:FF:FF:FF:FF:FF dst-port=5353 in-bridge=*23 ip-protocol=udp log-prefix=mdns: mac-protocol=ip out-bridge=*23 src-port=5353
/interface bridge filter add action=drop chain=forward comment="Drop all other L2 traffic" disabled=yes in-bridge=*23 log-prefix=dropmds: out-bridge=*23
/interface bridge nat add action=src-nat chain=srcnat comment="SNAT to Primary VLAN bridge" disabled=yes dst-mac-address=01:00:5E:00:00:FB/FF:FF:FF:FF:FF:FF log-prefix=src-tovlan to-src-mac-address=18:FD:74:82:56:68
/interface bridge port add bridge=BRI-TEST fast-leave=yes frame-types=admit-only-vlan-tagged interface=ether15-trunk internal-path-cost=10 path-cost=10 trusted=yes
/interface bridge port add bridge=BRI-TEST ingress-filtering=no interface=ether2-oob pvid=99 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan10 internal-path-cost=10 path-cost=10 pvid=10 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan11 internal-path-cost=10 path-cost=10 pvid=11 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan12 internal-path-cost=10 path-cost=10 pvid=12 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan13 internal-path-cost=10 path-cost=10 pvid=13 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan14 internal-path-cost=10 path-cost=10 pvid=14 trusted=yes
/interface bridge settings set use-ip-firewall=yes
/ip firewall connection tracking set udp-timeout=10s
/ip neighbor discovery-settings set discover-interface-list=VLANS
/ip settings set max-neighbor-entries=8192 rp-filter=strict
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=10
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=11
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=12
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=13
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=14
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=99
/interface detect-internet set detect-interface-list=WAN
/interface list member add interface=Trueonline list=WAN
/interface list member add interface=ether2-oob list=Manage
/interface list member add interface=ether3 list=InterfaceListVlan10
/interface list member add interface=ether4 list=InterfaceListVlan10
/interface list member add interface=ether5 list=InterfaceListVlan10
/interface list member add interface=ether6 list=InterfaceListVlan10
/interface list member add interface=ether7 list=InterfaceListVlan10
/interface list member add interface=ether8 list=InterfaceListVlan10
/interface list member add interface=ether9-nas1 list=InterfaceListVlan10
/interface list member add interface=ether10-nas2 list=InterfaceListVlan10
/interface list member add interface=ether11--dvs list=InterfaceListVlan10
/interface list member add interface=ether13-Aura-building list=InterfaceListVlan13
/interface list member add interface=ether14 list=InterfaceListVlan10
/interface list member add interface=ether12-apfl2 list=InterfaceListVlan10
/interface list member add interface=ether16-apfl3 list=InterfaceListVlan10
/interface list member add interface=VLAN10-LOCAL list=VLANS
/interface list member add interface=VLAN11-WIFI list=VLANS
/interface list member add interface=VLAN12-DANTE list=VLANS
/interface list member add interface=VLAN13-AURABUILDING list=VLANS
/interface list member add interface=VLAN14-LIGHT list=VLANS

/interface list member add interface=wg-sonoshq list=VLANS

/interface ovpn-server server add mac-address=FE:42:A7:26:FD:64 name=ovpn-server1
/interface wireguard peers add allowed-address=10.0.0.2/32 comment=Gle interface=wg-sonoshq name=peer4 public-key="MaHvrXErTnQ4m7gfoRR0Kbz8zKnIM9C8LlnFu1WGXRg="
/interface wireguard peers add allowed-address=10.0.0.3/32 interface=wg-sonoshq name=peer5 public-key="MNjdDqRmK4C0zvfqqrYoeTq1Fy7qpbqOBf23gJiDrmU="
/interface wireguard peers add allowed-address=10.0.0.4/32 interface=wg-sonoshq name=peer6 public-key="4GLnFZOT8xVoUy1BrxFnRaklMfNSmuBrzjq+YvH0qV0="
/interface wireguard peers add allowed-address=10.0.0.5/32 interface=wg-sonoshq name=peer7 public-key="TS3Vob4YZqaQSzxpYqlp+KPh3OzCg1JUMpSkxYbr9U0="
/interface wireguard peers add allowed-address=10.0.0.6/32 interface=wg-sonoshq name=peer8 public-key="VPPuNYcG/4lKJdCuv7vuzHXI2x4hC3W3yq3Bd4nJGy8="
/interface wireguard peers add allowed-address=10.0.0.7/32 interface=wg-sonoshq name=peer9 public-key="FfdbBi4N8wtIF+bSkeFVGZd1or6agClt9lsq1dcvalQ="
/interface wireguard peers add allowed-address=10.0.0.8/32 interface=wg-sonoshq name=peer10 public-key="kEs8ACRR5tOVdN2f+VVoK4nLaSGxNXPtiO/zkgRK+XI="
/interface wireguard peers add allowed-address=10.0.0.9/32 interface=wg-sonoshq name=peer11 public-key="5tduxOb3OoVkbrak4zf9Tq3GX//thS84xj3ZoaPUblU="
/interface wireguard peers add allowed-address=10.0.0.10/32 interface=wg-sonoshq name=peer12 public-key="sqszAiDa2nl+DhrUX0gmrHygCiQ6ugGS3fOGyCT74FE="
/interface wireguard peers add allowed-address=10.0.0.11/32 interface=wg-sonoshq name=peer13 public-key="Zmn0RE2rCU7AI9eqfzkiKdgQcR0yN0A0oen5VxHAIz4="
/interface wireguard peers add allowed-address=10.0.0.12/32 comment=hrc-kl interface=wg-sonoshq name=peer14 public-key="yAi/YI2Xj4AJRihUDRiW1muySqOK7gifIMYA4SKlgAg="
/interface wireguard peers add allowed-address=10.0.0.13/32,192.168.20.0/24 comment="Hap ac2 mobile" interface=wg-sonoshq name=peer15 public-key="ACW5Tee4YtTaud/5gEdvjjN/p+jUgi4ts+RiszjXvUo="
/interface wireguard peers add allowed-address=10.0.0.40/32,192.168.40.0/24 comment="Raynue 192.168.40.0/24" disabled=yes interface=wg-sonoshq name=peer28 public-key="bZjIr4w5B8LsOO0onCK1ZmFthCygs23aQvTSXemV/B4="
/interface wireguard peers add allowed-address=10.0.0.14/32 interface=wg-sonoshq name=peer-sonos-sp1 private-key="eCJITYpAX06vy70qL3SBSRo8bzldYYvp4FFiYECnj2c=" public-key="8PJtp+54NVDfXWM6ZtvuIee8ARWDPGHLmhRozGYkmUg="
/interface wireguard peers add allowed-address=10.0.0.38/32,192.168.38.0/24 interface=wg-sonoshq name=peer38 public-key="FEp0L8tpqeDynApy+rBe3z6D8/M82xwk2NlQIMiN8lk="
/interface wireguard peers add allowed-address=10.0.0.0/24,192.168.100.0/24 comment=iDm100 disabled=yes interface=wg-sonoshq name=peer100 public-key="2ManHrTPT6c7e2jAm/HHfqoNHWhu7+/YZ98F0R5MBWI="
/interface wireguard peers add allowed-address=10.0.0.16/32 comment=yim interface=wg-sonoshq name=peer16 public-key="Vvto/vZpxJ71XcixPB+jeOjhqKLzrVrsUu7/OE9z4zY="
/interface wireguard peers add allowed-address=10.0.0.100/32,192.168.100.0/24 comment=iDm100AX2 interface=wg-sonoshq name=peerax2 public-key="xrCcvH4UFGyPed2FT/aRdaozmi3MNMPfG51dmVt7eUE="
/interface wireguard peers add allowed-address=10.0.0.17/32 comment=Bee interface=wg-sonoshq name=peer17 public-key="trUI/yb9Cs1ADjlxUhQf7NIPc+rrKFzZcSZhEe6jIyE="
/interface wireguard peers add allowed-address=10.0.0.18/32 comment=Dej interface=wg-sonoshq name=peer18 public-key="2WqcKbwj+t4uI2oZ2hpr5fNCXVfnb8VQubavGTMgwyA="
/interface wireguard peers add allowed-address=10.0.0.19/32 comment=new interface=wg-sonoshq name=peer19 private-key="2HuSCmRheOWz4zBOeap9Vs+HnmZBsJreB7wBoGL3qng=" public-key="IG+/+YlkaxXyHfor+g8a1rfm5gfc823NP0H1mdk4XnA="
/interface wireguard peers add allowed-address=10.0.0.20/32 comment=YIM interface=wg-sonoshq name=peer45 public-key="DiHGiBJh4C75jeKx/Gow4XR7paG9JRcYromF/l8gGiA="
/interface wireguard peers add allowed-address=10.0.0.21/32 comment=Bank-en interface=wg-sonoshq name=peer46 public-key="Iux7G4kRVoI2MAIFzZxuRXE8deXdB5r8MOTH+ojdJhE="
/ip address add address=192.168.10.1/24 interface=VLAN10-LOCAL network=192.168.10.0
/ip address add address=192.168.11.1/24 interface=VLAN11-WIFI network=192.168.11.0
/ip address add address=192.168.12.1/24 interface=VLAN12-DANTE network=192.168.12.0
/ip address add address=192.168.13.1/24 interface=VLAN13-AURABUILDING network=192.168.13.0
/ip address add address=192.168.14.1/24 interface=VLAN14-LIGHT network=192.168.14.0
/ip address add address=10.0.0.1/24 interface=wg-sonoshq network=10.0.0.0
/ip address add address=192.168.99.1/24 interface=ether2-oob network=192.168.99.0

/ip cloud set ddns-update-interval=1d update-time=no
/ip dhcp-client add disabled=yes interface=ether1-wan use-peer-dns=no
/ip dhcp-server lease add address=192.168.10.13 client-id=1:b0:1f:8c:c7:cd:c4 mac-address=B0:1F:8C:C7:CD:C4 server=dhcp-vlan10
/ip dhcp-server lease add address=192.168.10.15 client-id=1:9c:3e:53:e:4:9e mac-address=9C:3E:53:0E:04:9E server=dhcp-vlan10
/ip dhcp-server lease add address=192.168.10.12 client-id=1:b0:1f:8c:c7:d7:c2 mac-address=B0:1F:8C:C7:D7:C2 server=dhcp-vlan10
/ip dhcp-server lease add address=192.168.13.11 mac-address=E0:46:EE:B1:67:DF server=dhcp-vlan13
/ip dhcp-server lease add address=192.168.10.16 client-id=1:dc:cd:2f:79:32:8d mac-address=DC:CD:2F:79:32:8D server=dhcp-vlan10
/ip dhcp-server lease add address=192.168.10.17 client-id=1:44:d2:44:fb:6b:1b mac-address=44:D2:44:FB:6B:1B server=dhcp-vlan10
/ip dhcp-server lease add address=192.168.10.20 mac-address=94:18:65:DD:C9:9E server=dhcp-vlan10
/ip dhcp-server lease add address=192.168.10.18 client-id=1:bc:24:11:bc:20:fe mac-address=BC:24:11:BC:20:FE server=dhcp-vlan10
/ip dhcp-server network add address=192.168.10.0/24 dns-server=192.168.10.1 gateway=192.168.10.1
/ip dhcp-server network add address=192.168.11.0/24 dns-server=192.168.11.1 gateway=192.168.11.1
/ip dhcp-server network add address=192.168.12.0/24 dns-server=192.168.12.1 gateway=192.168.12.1
/ip dhcp-server network add address=192.168.13.0/24 dns-server=192.168.13.1 gateway=192.168.13.1
/ip dhcp-server network add address=192.168.14.0/24 dns-server=192.168.14.1 gateway=192.168.14.1
/ip dhcp-server network add address=192.168.99.0/24 dns-server=192.168.99.1 gateway=192.168.99.1
/ip dns set allow-remote-requests=yes cache-max-ttl=7d cache-size=4096KiB doh-max-concurrent-queries=500 doh-max-server-connections=50 max-concurrent-queries=1000 max-concurrent-tcp-sessions=200 servers=1.1.1.1,1.0.0.1 verify-doh-cert=yes
/ip firewall address-list add address=192.168.10.141 list=admin
/ip firewall address-list add address=192.168.11.224 list=admin

/ip firewall filter add action=accept chain=input in-interface-list=MGMT log=yes log-prefix=admin:
/ip firewall filter add action=accept chain=input comment="ACCEPT established,related,untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=input comment="DROP INVALID" connection-state=invalid log-prefix="DROP-Invalid :"
/ip firewall filter add action=accept chain=input comment="Allow Wireguard" dst-port=13231 log-prefix=req-in-fw-wg: protocol=udp
/ip firewall filter add action=accept chain=input comment="Allow ICMP" protocol=icmp
/ip firewall filter add action=accept chain=input comment="Allow DNS" dst-port=53 log-prefix=req-in-fw: protocol=udp
/ip firewall filter add action=accept chain=input comment="Allow DNS" dst-port=53 log-prefix=req-in-fw: protocol=tcp
/ip firewall filter add action=accept chain=input comment="Allow Drivesynce" dst-port=6690 log-prefix=req-in-fw-drivesynce: protocol=tcp
/ip firewall filter add action=accept chain=input comment="Rate limit Winbox (new TCP)" protocol=tcp dst-port=8291 in-interface-list=VLANS connection-state=new limit=10,5
/ip firewall filter add action=accept chain=input in-interface-list=VLANS
/ip firewall filter add action=drop chain=input comment="drop all else" log-prefix="DROP-inputWAN :"

/ip firewall filter add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-mark=no-mark connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid log-prefix="DROP-invalid-forward :"
/ip firewall filter add action=accept chain=forward comment="Port Forwarding" connection-nat-state=dstnat disabled=yes log-prefix=fw-portfwd:
/ip firewall filter add action=accept chain=forward comment="Allow Internet" in-interface-list=VLANS out-interface-list=WAN
/ip firewall filter add action=accept chain=forward comment="WireGuard  VLAN" in-interface=wg-sonoshq out-interface-list=VLANS
/ip firewall filter add action=accept chain=forward comment="VLAN  WireGuard" in-interface-list=VLANS out-interface=wg-sonoshq
/ip firewall filter add action=drop chain=forward comment="Drop All Else" log-prefix=drop-forward:
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN

/ip firewall nat add action=dst-nat chain=dstnat disabled=yes dst-port=443 in-interface-list=WAN log-prefix=go protocol=tcp to-addresses=192.168.10.250 to-ports=443
/ip firewall nat add action=dst-nat chain=dstnat disabled=yes dst-port=80 in-interface-list=WAN log-prefix=go protocol=tcp to-addresses=192.168.10.250 to-ports=80
/ip firewall nat add action=dst-nat chain=dstnat comment="DSM Synology" disabled=yes dst-port=5655,5654 in-interface-list=WAN log-prefix=go protocol=tcp to-addresses=192.168.10.250 to-ports=5655
/ip ipsec profile set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip route add disabled=no distance=1 dst-address=192.168.20.0/24 gateway=10.0.0.13 routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip route add comment=PEER38 disabled=no distance=1 dst-address=192.168.38.0/24 gateway=10.0.0.38 pref-src="" routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip route add comment=iDM disabled=no distance=1 dst-address=192.168.100.0/24 gateway=10.0.0.100 pref-src="" routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set ssh port=22022
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip smb shares set [ find default=yes ] directory=/pub
/ip ssh set strong-crypto=yes
/system clock set time-zone-autodetect=no time-zone-name=Asia/Bangkok
/system identity set name=SonosLibraHQ
/system logging add action=syslog topics=firewall
/system logging add action=syslog topics=critical
/system logging add action=syslog topics=warning
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/system scheduler add interval=1m name=UPDATECF on-event="/system script run cf_update" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup
/system script add dont-require-permissions=no name=cf_update owner=sonos policy=ftp,read,write,test source="\r\
    \n:local apiToken \"G3afN0_d8SM2nOOneu2KlrgO1j7sXB8j2LhwhY-C\"\r\
    \n:local zoneId \"99b45096ed0908a2216d066429fc2fb9\"\r\
    \n:local dnsRecord \"hq.sonoslibra.com\"\r\
    \n:local wanInterface \"Trueonline\"\r\
    \n:local dnsRecordId \"1368e72a5a6f9dc560572df630334038\"\r\
    \n\r\
    \n# Fetch the current WAN IP address\r\
    \n:local newIp [/ip address get [find interface=\$wanInterface] address];\r\
    \n:set newIp [:pick \$newIp 0 ([:len \$newIp] -3)];\r\
    \n#:log info (\"DDNS Update: Current WAN IP is \" . \$newIp);\r\
    \n\r\
    \n# Resolve the current DNS record IP to check if update is needed\r\
    \n:local currentIp [[:resolve \"\$dnsRecord\"]];\r\
    \n#:log info (\"DDNS Update: Current DNS IP for \$dnsRecord is \" . \$currentIp);\r\
    \n\r\
    \n# Compare and update if different\r\
    \n:if (\$newIp != \$currentIp) do={\r\
    \n    :log info \"DDNS Update: IP change detected, updating Cloudflare DNS record...\";\r\
    \n    \r\
    \n    # Perform the update\r\
    \n    :log info \"DDNS Update: Sending update request to Cloudflare...\";\r\
    \n    /tool fetch url=\"https://api.cloudflare.com/client/v4/zones/\$zoneId/dns_records/\$dnsRecordId\" \\\r\
    \n    http-method=put \\\r\
    \n    http-header-field=(\"authorization: Bearer \" . \$apiToken . \", content-type: application/json\") \\\r\
    \n    http-data=(\"{\\\"type\\\":\\\"A\\\",\\\"name\\\":\\\"\" . \$dnsRecord . \"\\\",\\\"content\\\":\\\"\" . \$newIp . \"\\\",\\\"ttl\\\":1,\\\"proxied\\\":false}\") \\\r\
    \n    mode=https \\\r\
    \n    dst-path=\"/disk/cloudflare-update-response.json\";\r\
    \n    \r\
    \n    :delay 5s; # Give some time for the operation to complete and the response to be written\r\
    \n    \r\
    \n    # Check if the file exists and has content\r\
    \n    :if ([:len [/file find name=\"/disk/cloudflare-update-response.json\"]] > 0) do={\r\
    \n        :local fileSize [/file get [/file find name=\"/disk/cloudflare-update-response.json\"] size];\r\
    \n        :if (\$fileSize > 0) do={\r\
    \n            :local updateResponse [/file get [/file find name=\"/disk/cloudflare-update-response.json\"] contents];\r\
    \n            :log info (\"DDNS Update: Cloudflare DNS update response: \" . \$updateResponse);\r\
    \n        } else={\r\
    \n            :log error \"DDNS Update: Cloudflare response file is empty.\";\r\
    \n        }\r\
    \n    } else={\r\
    \n        :log error \"DDNS Update: Failed to fetch update response from Cloudflare.\";\r\
    \n    }\r\
    \n} else={\r\
    \n#    :log info \"DDNS Update: No update necessary.\"\r\
    \n}\r\
    \n"
/tool bandwidth-server set enabled=no
/tool mac-server set allowed-interface-list=VLANS
/tool mac-server mac-winbox set allowed-interface-list=VLANS
