# ==========================================
# MikroTik CCR2004 - Clean Network, Dual WAN (PCC), VLANs, WireGuard & Cake QoS
# RouterOS v7.21.3 Compatible
# /system reset-configuration no-defaults=yes run-after-reset=myoffice_full_clean.rsc
# ==========================================

/delay 5

# ==========================================
# 1. Bridge & Interfaces
# ==========================================
/interface bridge
add igmp-snooping=yes igmp-version=3 name=BRI-TEST port-cost-mode=short protocol-mode=none query-interval=30s vlan-filtering=no

/interface ethernet
set [ find default-name=ether1 ] name=ether1-wan comment="WAN" 
set [ find default-name=ether2 ] name=ether2-wan2 comment="WAN2"
set [ find default-name=ether5 ] name=ether5-nas02-1
set [ find default-name=ether6 ] name=ether6-nas02-2
set [ find default-name=ether9 ] name=ether9-nas01-1
set [ find default-name=ether10 ] name=ether10-nas01-2
set [ find default-name=ether11 ] name=ether11-apfl2
set [ find default-name=ether12 ] name=ether12-dvs
set [ find default-name=ether13 ] name=ether13-Aura-building
set [ find default-name=ether14 ] name=ether14
set [ find default-name=ether15 ] name=ether15-trunk
set [ find default-name=ether16 ] name=ether16-apfl3

/interface vlan
add interface=BRI-TEST name=VLAN10-LOCAL vlan-id=10
add interface=BRI-TEST name=VLAN11-WIFI vlan-id=11
add interface=BRI-TEST name=VLAN12-DANTE vlan-id=12
add interface=BRI-TEST name=VLAN13-AURABUILDING vlan-id=13
add interface=BRI-TEST name=VLAN20-LIGHT vlan-id=20

# ==========================================
# 2. Interface Lists
# ==========================================
/interface list
add name=WAN
add name=VLANS
add name=Manage
add name=InterfaceListVlan10
add name=InterfaceListVlan11
add name=InterfaceListVlan12
add name=InterfaceListVlan13
add name=TRUSTVLAN
add name=MGNT

/interface list member
add interface=Trueonline list=WAN
add interface=ether2-oob list=WAN
add interface=VLAN10-LOCAL list=VLANS
add interface=VLAN11-WIFI list=VLANS
add interface=VLAN12-DANTE list=VLANS
add interface=VLAN13-AURABUILDING list=VLANS
add interface=VLAN20-LIGHT list=VLANS
add interface=wg-sonoshq list=VLANS
add interface=ether3 list=InterfaceListVlan10
add interface=ether4 list=InterfaceListVlan10
add interface=ether5-nas02-1 list=InterfaceListVlan10
add interface=ether6-nas02-2 list=InterfaceListVlan10
add interface=ether7 list=InterfaceListVlan10
add interface=ether8 list=InterfaceListVlan10
add interface=ether11-apfl2 list=InterfaceListVlan10
add interface=ether12-dvs list=InterfaceListVlan10
add interface=ether14 list=InterfaceListVlan10
add interface=ether16-apfl3 list=InterfaceListVlan10
add interface=ether9-nas01-1 list=InterfaceListVlan10
add interface=ether10-nas01-2 list=InterfaceListVlan10
add interface=sfp-sfpplus1 list=InterfaceListVlan10
add interface=sfp-sfpplus2 list=InterfaceListVlan10
add interface=ether13-Aura-building list=InterfaceListVlan13

# ==========================================
# 3. Internet (WAN1 & WAN2)
# ==========================================
/interface pppoe-client
add add-default-route=no disabled=no interface=ether1-wan max-mtu=1492 name=Trueonline password=Password service-name=Trueonline user=9605418601@fiberhome

# รับ IP สำหรับ WAN2 (หากเป็น DHCP Client) - เสียบสายใช้งานได้เลย
/ip dhcp-client
add interface=ether2-oob add-default-route=no disabled=no

# ==========================================
# 4. IP Pool & DHCP Server
# ==========================================
/ip pool
add name=POOL10 ranges=192.168.10.101-192.168.10.249
add name=POOL11 ranges=192.168.11.101-192.168.11.249
add name=POOL12 ranges=192.168.12.101-192.168.12.249
add name=POOL13 ranges=192.168.13.101-192.168.13.249

/ip dhcp-server
add add-arp=yes address-pool=POOL10 interface=VLAN10-LOCAL lease-time=1h name=dhcp-vlan10
add add-arp=yes address-pool=POOL11 interface=VLAN11-WIFI lease-time=1h name=dhcp-vlan11
add add-arp=yes address-pool=POOL12 interface=VLAN12-DANTE lease-time=1h name=dhcp-vlan12
add add-arp=yes address-pool=POOL13 interface=VLAN13-AURABUILDING lease-time=1h name=dhcp-vlan13

/ip dhcp-server network
add address=192.168.10.0/24 dns-server=192.168.10.1 domain=lan.local gateway=192.168.10.1
add address=192.168.11.0/24 dns-server=192.168.11.1 domain=wifi.local gateway=192.168.11.1
add address=192.168.12.0/24 dns-server=192.168.12.1 domain=dante.local gateway=192.168.12.1
add address=192.168.13.0/24 dns-server=192.168.13.1 domain=aurabuilding.local gateway=192.168.13.1

/ip address
add address=192.168.0.1/24 interface=BRI-TEST network=192.168.0.0
add address=192.168.10.1/24 interface=VLAN10-LOCAL network=192.168.10.0
add address=192.168.11.1/24 interface=VLAN11-WIFI network=192.168.11.0
add address=192.168.12.1/24 interface=VLAN12-DANTE network=192.168.12.0
add address=192.168.13.1/24 interface=VLAN13-AURABUILDING network=192.168.13.0
add address=10.0.0.1/24 interface=wg-sonoshq network=10.0.0.0

/ip arp
add address=192.168.10.250 comment=Server01 interface=VLAN10-LOCAL mac-address=00:11:32:B4:EF:03
add address=192.168.10.251 comment=Server02 interface=VLAN10-LOCAL mac-address=90:09:D0:84:D2:22

# DHCP Static Leases
/ip dhcp-server lease
add address=192.168.10.13 client-id=1:b0:1f:8c:c7:cd:c4 mac-address=B0:1F:8C:C7:CD:C4 server=dhcp-vlan10
add address=192.168.10.15 client-id=1:9c:3e:53:e:4:9e mac-address=9C:3E:53:0E:04:9E server=dhcp-vlan10
add address=192.168.10.12 client-id=1:b0:1f:8c:c7:d7:c2 mac-address=B0:1F:8C:C7:D7:C2 server=dhcp-vlan10
add address=192.168.13.11 mac-address=E0:46:EE:B1:67:DF server=dhcp-vlan13
add address=192.168.10.20 mac-address=94:18:65:DD:C9:9E server=dhcp-vlan10
add address=192.168.10.18 client-id=1:bc:24:11:bc:20:fe mac-address=BC:24:11:BC:20:FE server=dhcp-vlan10

# ==========================================
# 5. WireGuard VPN
# ==========================================
/interface wireguard
add listen-port=13231 mtu=1420 name=wg-sonoshq private-key="0P7UrLurunhoIkU4+cUp3wjS3XbL0uUeqr4gbm/po3E="

/interface wireguard peers
add allowed-address=10.0.0.2/32 comment=Gle interface=wg-sonoshq name=peer4 public-key="MaHvrXErTnQ4m7gfoRR0Kbz8zKnIM9C8LlnFu1WGXRg="
add allowed-address=10.0.0.3/32 interface=wg-sonoshq name=peer5 public-key="MNjdDqRmK4C0zvfqqrYoeTq1Fy7qpbqOBf23gJiDrmU="
add allowed-address=10.0.0.4/32 interface=wg-sonoshq name=peer6 public-key="4GLnFZOT8xVoUy1BrxFnRaklMfNSmuBrzjq+YvH0qV0="
add allowed-address=10.0.0.5/32 interface=wg-sonoshq name=peer7 public-key="TS3Vob4YZqaQSzxpYqlp+KPh3OzCg1JUMpSkxYbr9U0="
add allowed-address=10.0.0.6/32 interface=wg-sonoshq name=peer8 public-key="VPPuNYcG/4lKJdCuv7vuzHXI2x4hC3W3yq3Bd4nJGy8="
add allowed-address=10.0.0.7/32 interface=wg-sonoshq name=peer9 public-key="FfdbBi4N8wtIF+bSkeFVGZd1or6agClt9lsq1dcvalQ="
add allowed-address=10.0.0.8/32 interface=wg-sonoshq name=peer10 public-key="kEs8ACRR5tOVdN2f+VVoK4nLaSGxNXPtiO/zkgRK+XI="
add allowed-address=10.0.0.9/32 interface=wg-sonoshq name=peer11 public-key="5tduxOb3OoVkbrak4zf9Tq3GX//thS84xj3ZoaPUblU="
add allowed-address=10.0.0.10/32 interface=wg-sonoshq name=peer12 public-key="sqszAiDa2nl+DhrUX0gmrHygCiQ6ugGS3fOGyCT74FE="
add allowed-address=10.0.0.11/32 interface=wg-sonoshq name=peer13 public-key="Zmn0RE2rCU7AI9eqfzkiKdgQcR0yN0A0oen5VxHAIz4="
add allowed-address=10.0.0.12/32 comment=hrc-kl interface=wg-sonoshq name=peer14 public-key="yAi/YI2Xj4AJRihUDRiW1muySqOK7gifIMYA4SKlgAg="
add allowed-address=10.0.0.13/32,192.168.20.0/24 comment="Hap ac2 mobile" interface=wg-sonoshq name=peer15 public-key="ACW5Tee4YtTaud/5gEdvjjN/p+jUgi4ts+RiszjXvUo="
add allowed-address=10.0.0.40/32,192.168.40.0/24 comment="Raynue 192.168.40.0/24" disabled=yes interface=wg-sonoshq name=peer28 public-key="bZjIr4w5B8LsOO0onCK1ZmFthCygs23aQvTSXemV/B4="
add allowed-address=10.0.0.14/32 interface=wg-sonoshq name=peer-sonos-sp1 private-key="eCJITYpAX06vy70qL3SBSRo8bzldYYvp4FFiYECnj2c=" public-key="8PJtp+54NVDfXWM6ZtvuIee8ARWDPGHLmhRozGYkmUg="
add allowed-address=10.0.0.38/32,192.168.38.0/24 interface=wg-sonoshq name=peer38 public-key="FEp0L8tpqeDynApy+rBe3z6D8/M82xwk2NlQIMiN8lk="
add allowed-address=10.0.0.0/24,192.168.100.0/24 comment=iDm100 interface=wg-sonoshq name=peer100 public-key="2ManHrTPT6c7e2jAm/HHfqoNHWhu7+/YZ98F0R5MBWI="
add allowed-address=10.0.0.16/32 comment=yim interface=wg-sonoshq name=peer16 public-key="Vvto/vZpxJ71XcixPB+jeOjhqKLzrVrsUu7/OE9z4zY="
add allowed-address=10.0.0.100/32,192.168.100.0/24 comment=iDm100AX2 interface=wg-sonoshq name=peerax2 public-key="xrCcvH4UFGyPed2FT/aRdaozmi3MNMPfG51dmVt7eUE="
add allowed-address=10.0.0.17/32 comment=Bee interface=wg-sonoshq name=peer17 public-key="trUI/yb9Cs1ADjlxUhQf7NIPc+rrKFzZcSZhEe6jIyE="
add allowed-address=10.0.0.18/32 comment=Dej interface=wg-sonoshq name=peer18 public-key="2WqcKbwj+t4uI2oZ2hpr5fNCXVfnb8VQubavGTMgwyA="
add allowed-address=10.0.0.19/32 comment=new interface=wg-sonoshq name=peer19 private-key="2HuSCmRheOWz4zBOeap9Vs+HnmZBsJreB7wBoGL3qng=" public-key="IG+/+YlkaxXyHfor+g8a1rfm5gfc823NP0H1mdk4XnA="
add allowed-address=10.0.0.20/32 comment=YIM interface=wg-sonoshq name=peer45 public-key="DiHGiBJh4C75jeKx/Gow4XR7paG9JRcYromF/l8gGiA="
add allowed-address=10.0.0.21/32 comment=Bank-en interface=wg-sonoshq name=peer46 public-key="Iux7G4kRVoI2MAIFzZxuRXE8deXdB5r8MOTH+ojdJhE="
add allowed-address=10.0.0.22/32,192.168.10.0/24,192.168.100.0/24,192.168.1.0/24 interface=wg-sonoshq name=GleiPad public-key="FHJsigXjAa0lfk9ZIIAKy4Zs7xFkmOzpCpbIRvVZmEA="
add allowed-address=10.0.0.23/32 comment=Gle-Engineer001 interface=wg-sonoshq name=peer20-Engineer001 public-key="mPPsT+j7GDGk9L0fVm5e8wpo8IP1u1HiDVk5b8j9YQ0="

# ==========================================
# 7. DNS, NTP, System
# ==========================================
/ip dns
set allow-remote-requests=yes cache-max-ttl=3d cache-size=4096KiB servers=1.1.1.1,8.8.8.8 verify-doh-cert=yes
/ip dns static
add address=192.168.10.250 name=sl-server01.lan.local type=A
add address=192.168.10.251 name=sl-server02.lan.local type=A
add address=192.168.10.251 name=ldap.lan.local type=A
add address=192.168.10.251 name=portal.lan.local type=A

/system clock
set time-zone-autodetect=no time-zone-name=Asia/Bangkok
/system identity
set name=SonosLibraHQ
/system ntp client
set enabled=yes
/system ntp client servers
add address=time.cloudflare.com

/ip service
set ftp disabled=yes
set telnet disabled=yes
set www-ssl disabled=no
set api disabled=yes
set api-ssl disabled=yes
set ssh port=22022
/ip ssh
set strong-crypto=yes
/tool mac-server
set allowed-interface-list=VLANS
/tool mac-server mac-winbox
set allowed-interface-list=VLANS

# ==========================================
# 8. Firewall (Security & PCC Load Balance)
# ==========================================
/ip firewall address-list
add address=192.168.10.141 list=admin
add address=192.168.11.224 list=admin
add address=192.168.0.0/16 list=LOCAL_SUBNETS
add address=10.0.0.0/8 list=LOCAL_SUBNETS

/ip firewall filter
# Input (Protecting Router)
add action=accept chain=input comment="Accept established, related, untracked" connection-state=established,related,untracked
add action=drop chain=input comment="Drop invalid" connection-state=invalid
add action=accept chain=input comment="Allow ICMP" protocol=icmp
add action=accept chain=input comment="Allow Management from Admin List" in-interface-list=VLANS src-address-list=admin
add action=accept chain=input comment="Allow DNS UDP" dst-port=53 in-interface-list=VLANS protocol=udp
add action=accept chain=input comment="Allow DNS TCP" dst-port=53 in-interface-list=VLANS protocol=tcp
add action=accept chain=input comment="Allow Wireguard" dst-port=13231 protocol=udp
add action=accept chain=input comment="Allow Drivesynce" dst-port=6690 protocol=tcp
add action=accept chain=input comment="Allow Winbox/Web from LAN only" dst-port=8291,80,443 in-interface-list=VLANS protocol=tcp
add action=drop chain=input comment="Drop all else from WAN" in-interface-list=WAN

# Forward (Protecting LAN & Routing)
add action=accept chain=forward comment="Accept established, related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="Drop invalid" connection-state=invalid
add action=accept chain=forward comment="Port Forwarding" connection-nat-state=dstnat
add action=accept chain=forward comment="LAN to WAN" in-interface-list=VLANS out-interface-list=WAN
add action=accept chain=forward comment="WireGuard to LAN" in-interface=wg-sonoshq out-interface-list=VLANS
add action=accept chain=forward comment="LAN to WireGuard" in-interface-list=VLANS out-interface=wg-sonoshq
add action=accept chain=forward comment="Inter-VLAN Routing" in-interface-list=VLANS out-interface-list=VLANS
add action=drop chain=forward comment="Drop All Else"

# NAT
/ip firewall nat
add action=masquerade chain=srcnat comment="NAT for All WANs" out-interface-list=WAN
add action=dst-nat chain=dstnat comment="DSM Synology" disabled=yes dst-port=5655,5654 in-interface-list=WAN protocol=tcp to-addresses=192.168.10.251 to-ports=5655

# Mangle (PCC Load Balance 1:1)
/ip firewall mangle
add action=accept chain=prerouting comment="Bypass PCC for Local Routing" dst-address-list=LOCAL_SUBNETS in-interface-list=VLANS
add action=mark-connection chain=prerouting comment="PCC: Mark incoming WAN1" connection-mark=no-mark in-interface=Trueonline new-connection-mark=WAN1_conn passthrough=yes
add action=mark-connection chain=prerouting comment="PCC: Mark incoming WAN2" connection-mark=no-mark in-interface=ether2-oob new-connection-mark=WAN2_conn passthrough=yes
add action=mark-connection chain=prerouting comment="PCC: Load Balance 1/2" connection-mark=no-mark dst-address-type=!local in-interface-list=VLANS new-connection-mark=WAN1_conn passthrough=yes per-connection-classifier=both-addresses:2/0
add action=mark-connection chain=prerouting comment="PCC: Load Balance 2/2" connection-mark=no-mark dst-address-type=!local in-interface-list=VLANS new-connection-mark=WAN2_conn passthrough=yes per-connection-classifier=both-addresses:2/1
add action=mark-routing chain=prerouting connection-mark=WAN1_conn in-interface-list=VLANS new-routing-mark=to_WAN1 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=WAN2_conn in-interface-list=VLANS new-routing-mark=to_WAN2 passthrough=yes
add action=mark-routing chain=output connection-mark=WAN1_conn new-routing-mark=to_WAN1 passthrough=yes
add action=mark-routing chain=output connection-mark=WAN2_conn new-routing-mark=to_WAN2 passthrough=yes

# ==========================================
# 9. Routing Tables (RouterOS v7) & Routes
# ==========================================
/routing table
add fib name=to_WAN1
add fib name=to_WAN2

/ip route
# PCC Routes
add check-gateway=ping distance=1 gateway=Trueonline routing-table=to_WAN1
# *** หมายเหตุ: เปลี่ยน 192.168.99.254 เป็น IP Gateway ของเน็ตเส้น 2 ***
add check-gateway=ping distance=1 gateway=192.168.99.254 routing-table=to_WAN2

# Default Routes (Failover)
add check-gateway=ping distance=1 gateway=Trueonline
add check-gateway=ping distance=2 gateway=192.168.99.254

# Static Routes for WireGuard
add distance=1 dst-address=192.168.20.0/24 gateway=10.0.0.13 routing-table=main
add distance=1 dst-address=192.168.38.0/24 gateway=10.0.0.38 routing-table=main
add distance=1 dst-address=192.168.100.0/24 gateway=10.0.0.100 routing-table=main

# ==========================================
# 10. Cake QoS (Bandwidth Management)
# ==========================================
/queue type
add cake-flowmode=dual-dsthost cake-nat=yes kind=cake name=cake-download
add cake-flowmode=dual-srchost cake-nat=yes kind=cake name=cake-upload

/queue tree
# [แก้ไขที่นี่] Limit ให้เป็น 95% ของความเร็วเน็ต (สมมติ 1000/500 x 2 เส้น = โหลดรวม 2000M หัก 5% เหลือ 1900M)
add bucket-size=0.01 max-limit=1900M name=QoS-Download packet-mark=no-mark parent=BRI-TEST queue=cake-download
add bucket-size=0.01 max-limit=475M name=QoS-Upload-WAN1 packet-mark=no-mark parent=Trueonline queue=cake-upload
add bucket-size=0.01 max-limit=475M name=QoS-Upload-WAN2 packet-mark=no-mark parent=ether2-oob queue=cake-upload

# ==========================================
# 11. Cloudflare DDNS Script
# ==========================================
/system script
add dont-require-permissions=no name=cloudflare_update_dns owner=sonos \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source=":local ParamVect { \"hq.sonoslibra.com\"={ \"DnsZoneID\"=\"99b45096ed0908a2216d066429fc2fb9\"; \"DnsRcrdID\"=\"1368e72a5a6f9dc560572df630334038\"; \"AuthToken\"=\"oj6aB-WIRjt4a8go_qHYayt3YDsp9opJclwbr6tV\"; } }; :local VerboseLog false; :local TestMode false; :local CertCheck false; :global WanIP4Cur; :do { :local ChkIpResult [:tool fetch url=\"http://checkip.amazonaws.com/\" as-value output=user]; :if (\$ChkIpResult->\"status\" = \"finished\") do={ :local WanIP4New [:pick (\$ChkIpResult->\"data\") 0 ( [ :len (\$ChkIpResult->\"data\") ] -1 )]; :if (\$WanIP4New != \$WanIP4Cur) do={ :local WanIPv4IsValid true; :local WanIP4NewMasked (\$WanIP4New&255.255.255.255); :if ( :toip \$WanIP4New != :toip \$WanIP4NewMasked ) do={ :set WanIPv4IsValid true } else={ :set WanIPv4IsValid false }; :if (\$WanIPv4IsValid) do={ :log warning \"[script] Wan IPv4 changed -> New IPv4: \$WanIP4New - Old IPv4: \$WanIP4Cur\"; :if (\$TestMode = false) do={ :foreach fqdn,params in=\$ParamVect do={ :local DnsRcName \$fqdn; :local DnsZoneID (\$params->\"DnsZoneID\"); :local DnsRcrdID (\$params->\"DnsRcrdID\"); :local AuthToken (\$params->\"AuthToken\"); :local url \"https://api.cloudflare.com/client/v4/zones/\$DnsZoneID/dns_records/\$DnsRcrdID/\"; :local CheckYesNo; :if (\$CertCheck = true) do={ :set CheckYesNo \"yes\" } else={ :set CheckYesNo \"no\" }; :local CfApiResult [/tool fetch http-method=put mode=https url=\$url check-certificate=\$CheckYesNo output=user as-value http-header-field=\"Authorization: Bearer \$AuthToken,Content-Type: application/json\" http-data=\"{\\\"type\\\":\\\"A\\\",\\\"name\\\":\\\"\$DnsRcName\\\",\\\"content\\\":\\\"\$WanIP4New\\\",\\\"ttl\\\":60,\\\"proxied\\\":false}\"]; if (\$CfApiResult->\"status\" = \"finished\") do={ :log warning \"[script] Updated Cloudflare DNS record for <\$DnsRcName> to \$WanIP4New\" } else={ :log error \"[script] Error occurred updating Cloudflare DNS record for <\$DnsRcName> to \$WanIP4New\" }; :delay 1 } }; :set WanIP4Cur \$WanIP4New } else={ :log error \"[script] Error occurred, retrieved Wan IPv4 is invalid (\$WanIP4New)\" } } } else={ :log error \"[script] Error occurred retrieving current Wan IPv4 (status: \$ChkIpResult)\" } } on-error={ :log error \"[script] Error occurred during Cloudflare DNS update process\" }"

/system scheduler
add interval=10m name=schedule1 on-event=cloudflare_update_dns policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup

# ==========================================
# 12. Bridge Ports & VLAN Filtering (สำคัญ: ทำเป็นขั้นตอนสุดท้าย)
# ==========================================
/interface bridge port
add bridge=BRI-TEST fast-leave=yes frame-types=admit-only-vlan-tagged interface=ether15-trunk internal-path-cost=10 path-cost=10 trusted=yes
add bridge=BRI-TEST ingress-filtering=no interface=ether2-oob pvid=99 trusted=yes
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan10 internal-path-cost=10 path-cost=10 pvid=10 trusted=yes
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan11 internal-path-cost=10 path-cost=10 pvid=11 trusted=yes
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan12 internal-path-cost=10 path-cost=10 pvid=12 trusted=yes
add bridge=BRI-TEST interface=InterfaceListVlan13 pvid=13 trusted=yes

/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=10
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=11
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=12
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=99
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=13

/interface bridge settings
set use-ip-firewall=yes

/interface bridge
set BRI-TEST vlan-filtering=yes