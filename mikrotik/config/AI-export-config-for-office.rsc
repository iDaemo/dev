# 2026-08-31 17:55:56 by RouterOS 7.24.1
# software id = 04H0-FDC6
#
# model = CCR2004-16G-2S+
# serial number = HD0084APN5W
/interface bridge
add igmp-snooping=yes igmp-version=3 name=BRI-TEST port-cost-mode=short \
    protocol-mode=none query-interval=30s vlan-filtering=yes
/interface ethernet
set [ find default-name=ether1 ] comment=WAN name=ether1-wan
set [ find default-name=ether2 ] name=ether2-oob
set [ find default-name=ether5 ] name=ether5-nas02-1
set [ find default-name=ether6 ] name=ether6-nas02-2
set [ find default-name=ether9 ] name=ether9-nas01-1
set [ find default-name=ether10 ] name=ether10-nas01-2
set [ find default-name=ether11 ] name=ether11-apfl2
set [ find default-name=ether12 ] name=ether12-dvs
set [ find default-name=ether13 ] name=ether13-Aura-building
set [ find default-name=ether15 ] name=ether15-trunk
set [ find default-name=ether16 ] name=ether16-apfl3
/interface pppoe-client
add add-default-route=yes disabled=no interface=ether1-wan max-mtu=1492 name=\
    Trueonline service-name=Trueonline user=9605418601@fiberhome
/interface wireguard
add listen-port=13231 mtu=1420 name=wg-sonoshq
/interface vlan
add interface=BRI-TEST name=VLAN10-LOCAL vlan-id=10
add interface=BRI-TEST name=VLAN11-WIFI vlan-id=11
add interface=BRI-TEST name=VLAN12-DANTE vlan-id=12
add interface=BRI-TEST name=VLAN13-AURABUILDING vlan-id=13
add interface=BRI-TEST name=VLAN20-LIGHT vlan-id=20
/interface list
add name=WAN
add name=InterfaceListVlan10
add name=InterfaceListVlan11
add name=InterfaceListVlan12
add name=VLANS
add name=Manage
add name=TRUSTVLAN
add name=MGNT
add name=InterfaceListVlan13
/ip pool
add name=POOL10 ranges=192.168.10.101-192.168.10.249
add name=POOL11 ranges=192.168.11.101-192.168.11.249
add name=POOL12 ranges=192.168.12.101-192.168.12.249
add name=pool_MNGN ranges=192.168.99.2-192.168.99.20
add name=POOL13 ranges=192.168.13.101-192.168.13.249
/ip dhcp-server
add add-arp=yes address-pool=POOL10 interface=VLAN10-LOCAL lease-time=1h \
    name=dhcp-vlan10
add add-arp=yes address-pool=POOL11 interface=VLAN11-WIFI lease-time=1h name=\
    dhcp-vlan11
add add-arp=yes address-pool=POOL12 interface=VLAN12-DANTE lease-time=1h \
    name=dhcp-vlan12
add add-arp=yes address-pool=POOL13 interface=VLAN13-AURABUILDING lease-time=\
    1h name=dhcp-vlan13
/ip smb users
set [ find default=yes ] disabled=yes
/queue type
add cake-flowmode=dual-dsthost cake-nat=yes kind=cake name=cake-download
add cake-flowmode=dual-srchost cake-nat=yes kind=cake name=cake-upload
/queue tree
add bucket-size=0.01 max-limit=1G name=download packet-mark=no-mark parent=\
    BRI-TEST queue=cake-download
add bucket-size=0.01 max-limit=1G name=upload packet-mark=no-mark parent=\
    ether1-wan queue=cake-upload
/system logging action
set 3 remote=0.0.0.0
/system script
add dont-require-permissions=no name=cloudflare_update_dns owner=sonos \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    source="##  <<  For parameters'details see README.md @ https://github.com/\
    bajodel/mikrotik-cloudflare-dns  >>\
    \n\
    \n## ---- Configuration/Start  -----\
    \n\
    \n# Define here single/multiple Dns Records (FQDNs) with their Zone IDs, R\
    ecord IDs, and AuthTokens\
    \n# (hint: populate at least the first (single record to update), uncommen\
    t the second one or create more as needed)\
    \n:local ParamVect {\
    \n                  \"hq.sonoslibra.com\"={\
    \n      \"DnsZoneID\"=\"99b45096ed0908a2216d066429fc2fb9\";\
    \n      \"DnsRcrdID\"=\"1368e72a5a6f9dc560572df630334038\";\
    \n      \"AuthToken\"=\"oj6aB-WIRjt4a8go_qHYayt3YDsp9opJclwbr6tV\";\
    \n  };\
    \n#                 \"_____mywanip2_domain_com_____\"={\
    \n#     \"DnsZoneID\"=\"__Cloudflare_Dns_Zone_ID2____\";\
    \n#     \"DnsRcrdID\"=\"__Cloudflare_Dns_Record_ID2__\";\
    \n#     \"AuthToken\"=\"_Cloudflare_Auth_Key_Token_2_\";\
    \n# };\
    \n}\
    \n\
    \n# [default: false] enable verbose (debug) log messages, by default only \
    changes will be logged\
    \n:local VerboseLog false\
    \n  \
    \n# [default: false] enable TestMode -> it will only monitor/log Wan IPv4 \
    changes (no Cloudflare DNS update)\
    \n:local TestMode false\
    \n\
    \n# [default: false] enable certificate validation for Cloudflare API call\
    s (but before install RootCA used by CF)\
    \n:local CertCheck false\
    \n\
    \n## ---- Configuration/End  ----\
    \n\
    \n:global WanIP4Cur\
    \n:do {\
    \n:local ChkIpResult [:tool fetch url=\"http://checkip.amazonaws.com/\" as\
    -value output=user]\
    \n:if (\$ChkIpResult->\"status\" = \"finished\") do={\
    \n  :local WanIP4New [:pick (\$ChkIpResult->\"data\") 0 ( [ :len (\$ChkIpR\
    esult->\"data\") ] -1 )]\
    \n  :if (\$WanIP4New != \$WanIP4Cur) do={\
    \n    # validate the new retrieved Wan IPv4\
    \n    :local WanIPv4IsValid true\
    \n    :local WanIP4NewMasked (\$WanIP4New&255.255.255.255)\
    \n    :if ( :toip \$WanIP4New != :toip \$WanIP4NewMasked ) do={ :set WanIP\
    v4IsValid true } else={ :set WanIPv4IsValid false }\
    \n    # if retrieved Wan IPv4 is valid proceed, skip update and log error \
    if not valid\
    \n    :if (\$WanIPv4IsValid) do={\
    \n      :if (\$VerboseLog = true) do={ :log info \"[script] New Wan IPv4 i\
    s valid (\$WanIP4New)\" }\
    \n      # Wan IP changed (valid and different from previously stored one)\
    \n      :log warning \"[script] Wan IPv4 changed -> New IPv4: \$WanIP4New \
    - Old IPv4: \$WanIP4Cur\"\
    \n      # If not in \"Test Mode\" proceed with Cloudflare DNS update\
    \n      :if (\$TestMode = false) do={\
    \n        # Loop through each DNS Record Names provided\
    \n        :foreach fqdn,params in=\$ParamVect do={\
    \n          :local DnsRcName \$fqdn\
    \n          :local DnsZoneID (\$params->\"DnsZoneID\")\
    \n          :local DnsRcrdID (\$params->\"DnsRcrdID\")\
    \n          :local AuthToken (\$params->\"AuthToken\")\
    \n          :if (\$VerboseLog = true) do={ :log info \"[script] Preparing \
    CF-DNS-Update for <\$DnsRcName>\" }\
    \n          # create API update url for DNS Zone/Record\
    \n          :local url \"https://api.cloudflare.com/client/v4/zones/\$DnsZ\
    oneID/dns_records/\$DnsRcrdID/\"\
    \n          :if (\$VerboseLog = true) do={ :log info \"[script] Generated \
    URL for DNS update: \$url\" }\
    \n          :if (\$VerboseLog = true) do={ :log info \"[script] Certificat\
    e check is globally set to \$CertCheck\" }\
    \n          # evaluating \"check-certificate\" (yes/no)\
    \n          :local CheckYesNo\
    \n          :if (\$CertCheck = true) do={ :set CheckYesNo \"yes\" } else={\
    \_:set CheckYesNo \"no\" }\
    \n          # updating the DNS Record\
    \n          :local CfApiResult [/tool fetch http-method=put mode=https url\
    =\$url check-certificate=\$CheckYesNo output=user as-value \\\
    \n          http-header-field=\"Authorization: Bearer \$AuthToken,Content-\
    Type: application/json\" \\\
    \n          http-data=\"{\\\"type\\\":\\\"A\\\",\\\"name\\\":\\\"\$DnsRcNa\
    me\\\",\\\"content\\\":\\\"\$WanIP4New\\\",\\\"ttl\\\":60,\\\"proxied\\\":\
    false}\"]\
    \n          if (\$CfApiResult->\"status\" = \"finished\") do={\
    \n            # log success message (log <warning> used just to make it st\
    and out in logs)\
    \n            :log warning \"[script] Updated Cloudflare DNS record for <\
    \$DnsRcName> to \$WanIP4New\"\
    \n          } else={ :log error \"[script] Error occurred updating Cloudfl\
    are DNS record for <\$DnsRcName> to \$WanIP4New\" }\
    \n          # pause a little bit before the next one\
    \n          :delay 1\
    \n      } }\
    \n      # update stored global variable\
    \n      :set WanIP4Cur \$WanIP4New\
    \n    } else={ :log error \"[script] Error occurred, retrieved Wan IPv4 is\
    \_invalid (\$WanIP4New)\" }\
    \n  } else={ :if (\$VerboseLog = true) do={ :log info \"[script] Wan IPv4 \
    didn't change (\$WanIP4New)\" } }\
    \n} else={ :log error \"[script] Error occurred retrieving current Wan IPv\
    4 (status: \$ChkIpResult)\" }\
    \n} on-error={ :log error \"[script] Error occurred during Cloudflare DNS \
    update process\" }"
/interface bridge port
add bridge=BRI-TEST fast-leave=yes frame-types=admit-only-vlan-tagged \
    interface=ether15-trunk internal-path-cost=10 path-cost=10 trusted=yes
add bridge=BRI-TEST interface=*21 trusted=yes
add bridge=BRI-TEST interface=*22 trusted=yes
add bridge=BRI-TEST ingress-filtering=no interface=ether2-oob pvid=99 \
    trusted=yes
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan10 internal-path-cost=10 path-cost=10 pvid=10 \
    trusted=yes
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan11 internal-path-cost=10 path-cost=10 pvid=11 \
    trusted=yes
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan12 internal-path-cost=10 path-cost=10 pvid=12 \
    trusted=yes
add bridge=BRI-TEST interface=InterfaceListVlan13 pvid=13 trusted=yes
/interface bridge settings
set use-ip-firewall=no
/ip firewall connection tracking
set udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=VLANS
/ip settings
set max-neighbor-entries=8192 rp-filter=strict
/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=10
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=11
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=12
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=99
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=13
add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=20
/interface detect-internet
set detect-interface-list=WAN
/interface list member
add interface=Trueonline list=WAN
add interface=ether3 list=InterfaceListVlan10
add interface=ether4 list=InterfaceListVlan10
add interface=ether5-nas02-1 list=InterfaceListVlan10
add interface=ether6-nas02-2 list=InterfaceListVlan10
add interface=ether7 list=InterfaceListVlan10
add interface=ether8 list=InterfaceListVlan10
add interface=ether11-apfl2 list=InterfaceListVlan10
add interface=ether13-Aura-building list=InterfaceListVlan13
add interface=ether14 list=InterfaceListVlan10
add interface=ether12-dvs list=InterfaceListVlan10
add interface=ether16-apfl3 list=InterfaceListVlan10
add interface=VLAN10-LOCAL list=VLANS
add interface=VLAN11-WIFI list=VLANS
add interface=VLAN12-DANTE list=VLANS
add interface=VLAN20-LIGHT list=VLANS
add interface=ether2-oob list=Manage
add interface=ether9-nas01-1 list=InterfaceListVlan10
add interface=ether10-nas01-2 list=InterfaceListVlan10
add interface=wg-sonoshq list=VLANS
add interface=sfp-sfpplus1 list=InterfaceListVlan10
add interface=VLAN13-AURABUILDING list=VLANS
add interface=sfp-sfpplus2 list=InterfaceListVlan10
/interface ovpn-server server
add mac-address=FE:42:A7:26:FD:64 name=ovpn-server1
/interface wireguard peers
add allowed-address=10.0.0.2/32 comment=Gle interface=wg-sonoshq name=peer4 \
    public-key="MaHvrXErTnQ4m7gfoRR0Kbz8zKnIM9C8LlnFu1WGXRg="
add allowed-address=10.0.0.3/32 interface=wg-sonoshq name=peer5 public-key=\
    "MNjdDqRmK4C0zvfqqrYoeTq1Fy7qpbqOBf23gJiDrmU="
add allowed-address=10.0.0.4/32 interface=wg-sonoshq name=peer6 public-key=\
    "4GLnFZOT8xVoUy1BrxFnRaklMfNSmuBrzjq+YvH0qV0="
add allowed-address=10.0.0.5/32 interface=wg-sonoshq name=peer7 public-key=\
    "TS3Vob4YZqaQSzxpYqlp+KPh3OzCg1JUMpSkxYbr9U0="
add allowed-address=10.0.0.6/32 interface=wg-sonoshq name=peer8 public-key=\
    "VPPuNYcG/4lKJdCuv7vuzHXI2x4hC3W3yq3Bd4nJGy8="
add allowed-address=10.0.0.7/32 interface=wg-sonoshq name=peer9 public-key=\
    "FfdbBi4N8wtIF+bSkeFVGZd1or6agClt9lsq1dcvalQ="
add allowed-address=10.0.0.8/32 interface=wg-sonoshq name=peer10 public-key=\
    "kEs8ACRR5tOVdN2f+VVoK4nLaSGxNXPtiO/zkgRK+XI="
add allowed-address=10.0.0.9/32 interface=wg-sonoshq name=peer11 public-key=\
    "5tduxOb3OoVkbrak4zf9Tq3GX//thS84xj3ZoaPUblU="
add allowed-address=10.0.0.10/32 interface=wg-sonoshq name=peer12 public-key=\
    "sqszAiDa2nl+DhrUX0gmrHygCiQ6ugGS3fOGyCT74FE="
add allowed-address=10.0.0.11/32 interface=wg-sonoshq name=peer13 public-key=\
    "Zmn0RE2rCU7AI9eqfzkiKdgQcR0yN0A0oen5VxHAIz4="
add allowed-address=10.0.0.12/32 comment=hrc-kl interface=wg-sonoshq name=\
    peer14 public-key="yAi/YI2Xj4AJRihUDRiW1muySqOK7gifIMYA4SKlgAg="
add allowed-address=10.0.0.13/32,192.168.20.0/24 comment="Hap ac2 mobile" \
    interface=wg-sonoshq name=peer15 public-key=\
    "ACW5Tee4YtTaud/5gEdvjjN/p+jUgi4ts+RiszjXvUo="
add allowed-address=10.0.0.40/32,192.168.40.0/24 comment=\
    "Raynue 192.168.40.0/24" disabled=yes interface=wg-sonoshq name=peer28 \
    public-key="bZjIr4w5B8LsOO0onCK1ZmFthCygs23aQvTSXemV/B4="
add allowed-address=10.0.0.14/32 interface=wg-sonoshq name=peer-sonos-sp1 \
    public-key="8PJtp+54NVDfXWM6ZtvuIee8ARWDPGHLmhRozGYkmUg="
add allowed-address=10.0.0.38/32,192.168.38.0/24 interface=wg-sonoshq name=\
    peer38 public-key="FEp0L8tpqeDynApy+rBe3z6D8/M82xwk2NlQIMiN8lk="
add allowed-address=10.0.0.0/24,192.168.100.0/24 comment=iDm100 interface=\
    wg-sonoshq name=peer100 public-key=\
    "2ManHrTPT6c7e2jAm/HHfqoNHWhu7+/YZ98F0R5MBWI="
add allowed-address=10.0.0.16/32 comment=yim interface=wg-sonoshq name=peer16 \
    public-key="Vvto/vZpxJ71XcixPB+jeOjhqKLzrVrsUu7/OE9z4zY="
# allowed-address match other peers
add allowed-address=10.0.0.100/32,192.168.100.0/24 comment=iDm100AX2 \
    interface=wg-sonoshq name=peerax2 public-key=\
    "xrCcvH4UFGyPed2FT/aRdaozmi3MNMPfG51dmVt7eUE="
add allowed-address=10.0.0.17/32 comment=Bee interface=wg-sonoshq name=peer17 \
    public-key="trUI/yb9Cs1ADjlxUhQf7NIPc+rrKFzZcSZhEe6jIyE="
add allowed-address=10.0.0.18/32 comment=Dej interface=wg-sonoshq name=peer18 \
    public-key="2WqcKbwj+t4uI2oZ2hpr5fNCXVfnb8VQubavGTMgwyA="
add allowed-address=10.0.0.19/32 comment=new interface=wg-sonoshq name=peer19 \
    public-key="IG+/+YlkaxXyHfor+g8a1rfm5gfc823NP0H1mdk4XnA="
add allowed-address=10.0.0.20/32 comment=YIM interface=wg-sonoshq name=peer45 \
    public-key="DiHGiBJh4C75jeKx/Gow4XR7paG9JRcYromF/l8gGiA="
add allowed-address=10.0.0.21/32 comment=Bank-en interface=wg-sonoshq name=\
    peer46 public-key="Iux7G4kRVoI2MAIFzZxuRXE8deXdB5r8MOTH+ojdJhE="
# allowed-address match other peers
add allowed-address=\
    10.0.0.22/32,192.168.10.0/24,192.168.100.0/24,192.168.1.0/24 interface=\
    wg-sonoshq name=GleiPad public-key=\
    "FHJsigXjAa0lfk9ZIIAKy4Zs7xFkmOzpCpbIRvVZmEA="
add allowed-address=10.0.0.23/32 comment=Gle-Engineer001 interface=wg-sonoshq \
    name=peer20-Engineer001 public-key=\
    "mPPsT+j7GDGk9L0fVm5e8wpo8IP1u1HiDVk5b8j9YQ0="
/ip address
add address=192.168.10.1/24 interface=VLAN10-LOCAL network=192.168.10.0
add address=192.168.11.1/24 interface=VLAN11-WIFI network=192.168.11.0
add address=192.168.12.1/24 interface=VLAN12-DANTE network=192.168.12.0
add address=10.0.0.1/24 interface=wg-sonoshq network=10.0.0.0
add address=192.168.99.1/24 interface=ether2-oob network=192.168.99.0
add address=192.168.0.1/24 interface=BRI-TEST network=192.168.0.0
add address=192.168.13.1/24 interface=VLAN13-AURABUILDING network=\
    192.168.13.0
/ip arp
add address=192.168.10.250 comment=Server01 interface=VLAN10-LOCAL \
    mac-address=00:11:32:B4:EF:03
add address=192.168.10.251 comment=Server02 interface=VLAN10-LOCAL \
    mac-address=90:09:D0:84:D2:22
/ip cloud
set ddns-update-interval=1d update-time=no
/ip dhcp-client
add disabled=yes interface=ether1-wan name=client1 use-peer-dns=no
/ip dhcp-server lease
add address=192.168.10.13 client-id=1:b0:1f:8c:c7:cd:c4 mac-address=\
    B0:1F:8C:C7:CD:C4 server=dhcp-vlan10
add address=192.168.10.15 client-id=1:9c:3e:53:e:4:9e mac-address=\
    9C:3E:53:0E:04:9E server=dhcp-vlan10
add address=192.168.10.12 client-id=1:b0:1f:8c:c7:d7:c2 mac-address=\
    B0:1F:8C:C7:D7:C2 server=dhcp-vlan10
add address=192.168.13.11 mac-address=E0:46:EE:B1:67:DF server=dhcp-vlan13
add address=192.168.10.20 mac-address=94:18:65:DD:C9:9E server=dhcp-vlan10
add address=192.168.10.18 client-id=1:bc:24:11:bc:20:fe mac-address=\
    BC:24:11:BC:20:FE server=dhcp-vlan10
/ip dhcp-server network
add address=192.168.10.0/24 dns-server=192.168.10.1 domain=lan.local gateway=\
    192.168.10.1
add address=192.168.11.0/24 dns-server=192.168.11.1 domain=wifi.local \
    gateway=192.168.11.1
add address=192.168.12.0/24 dns-server=192.168.12.1 domain=dante.local \
    gateway=192.168.12.1
add address=192.168.13.0/24 dns-server=192.168.13.1 domain=aurabuilding.local \
    gateway=192.168.13.1
add address=192.168.99.0/24 dns-server=192.168.99.1 gateway=192.168.99.1
/ip dns
set allow-remote-requests=yes cache-max-ttl=3d cache-size=4096KiB \
    doh-max-concurrent-queries=500 doh-max-server-connections=50 \
    max-concurrent-queries=1000 max-concurrent-tcp-sessions=200 \
    mdns-repeat-ifaces=VLAN10-LOCAL,VLAN11-WIFI,VLAN12-DANTE,VLAN13-AURABUILDING,VLAN20-LIGHT \
    servers=1.1.1.1,8.8.8.8 verify-doh-cert=yes
/ip dns static
add address=192.168.10.250 name=sl-server01.lan.local type=A
add address=192.168.10.251 name=sl-server02.lan.local type=A
add address=192.168.10.251 name=ldap.lan.local type=A
add address=192.168.10.251 name=portal.lan.local type=A
/ip firewall address-list
add address=192.168.10.141 list=admin
add address=192.168.11.224 list=admin
/ip firewall filter
add action=accept chain=input in-interface-list=Manage log=yes log-prefix=\
    admin:
add action=accept chain=input comment="ACCEPT established,related,untracked" \
    connection-state=established,related,untracked
add action=drop chain=input comment="DROP INVALID" connection-state=invalid \
    log-prefix="DROP-Invalid :"
add action=accept chain=input comment="Allow ICMP" protocol=icmp
add action=accept chain=input comment="Allow DNS" dst-port=53 log-prefix=\
    req-in-fw: protocol=udp
add action=accept chain=input comment="Allow DNS" dst-port=53 log-prefix=\
    req-in-fw: protocol=tcp
add action=accept chain=input comment="Allow mDNS" dst-port=5353 protocol=udp
add action=accept chain=input comment="Allow Wireguard" dst-port=13231 \
    log-prefix=req-in-fw-wg: protocol=udp
add action=accept chain=input comment="Allow Drivesynce" dst-port=6690 \
    log-prefix=req-in-fw-drivesynce: protocol=tcp
add action=accept chain=input dst-port=8291 protocol=tcp
add action=accept chain=input dst-port=80 protocol=tcp
add action=accept chain=input dst-port=443 protocol=tcp
add action=accept chain=input in-interface-list=VLANS log-prefix=vlan-req:
add action=drop chain=input comment="drop all else" log-prefix=\
    "DROP-inputWAN :"
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-mark=no-mark connection-state=established,related
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid log-prefix="DROP-invalid-forward :"
add action=accept chain=forward comment="Port Forwarding" \
    connection-nat-state=dstnat log-prefix=fw-portfwd:
add action=accept chain=forward comment="VLAN  WAN" in-interface-list=VLANS \
    out-interface-list=WAN
add action=accept chain=forward comment="WireGuard  VLAN" in-interface=\
    wg-sonoshq out-interface-list=VLANS
add action=accept chain=forward comment="VLAN  WireGuard" in-interface-list=\
    VLANS out-interface=wg-sonoshq
add action=accept chain=forward comment="Allow Inter-VLAN Communication" \
    in-interface-list=VLANS out-interface-list=VLANS
add action=drop chain=forward comment="Drop All Else" log-prefix=\
    drop-forward:
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
add action=dst-nat chain=dstnat disabled=yes dst-port=443 in-interface-list=\
    WAN log-prefix=go protocol=tcp to-addresses=192.168.10.250 to-ports=443
add action=dst-nat chain=dstnat disabled=yes dst-port=80 in-interface-list=\
    WAN log-prefix=go protocol=tcp to-addresses=192.168.10.250 to-ports=80
add action=dst-nat chain=dstnat comment="DSM Synology" disabled=yes dst-port=\
    5655,5654 in-interface-list=WAN log-prefix=go protocol=tcp to-addresses=\
    192.168.10.251 to-ports=5655
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip route
add disabled=no distance=1 dst-address=192.168.20.0/24 gateway=10.0.0.13 \
    routing-table=main scope=30 target-scope=10
add comment=PEER38 disabled=no distance=1 dst-address=192.168.38.0/24 \
    gateway=10.0.0.38 pref-src="" routing-table=main scope=30 target-scope=10
add comment=iDM disabled=no distance=1 dst-address=192.168.100.0/24 gateway=\
    10.0.0.100 pref-src="" routing-table=main scope=30 target-scope=10
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www-ssl disabled=no
set api disabled=yes
set api-ssl disabled=yes
set ssh port=22022
/ip ssh
set strong-crypto=yes
/ipv6 nd
# automatic dns option advertising is not started, re-apply dns config
set [ find default=yes ] advertise-dns=yes
/system clock
set time-zone-autodetect=no time-zone-name=Asia/Bangkok
/system identity
set name=SonosLibraHQ
/system ntp client
set enabled=yes
/system ntp client servers
add address=time.cloudflare.com
/system scheduler
add !days interval=10m name=schedule1 on-event=cloudflare_update_dns policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2025-06-13 start-time=16:30:49
/tool bandwidth-server
set enabled=no
/tool graphing interface
add interface=ether1-wan
/tool graphing resource
add
/tool mac-server
set allowed-interface-list=VLANS
/tool mac-server mac-winbox
set allowed-interface-list=VLANS
