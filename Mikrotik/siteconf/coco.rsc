# 2024-01-25 18:43:43 by RouterOS 7.13.3
# software id = V0HP-VH1T
#
# model = RBD52G-5HacD2HnD
# serial number = HEZ09ACS11P
/interface bridge add ageing-time=5m arp=enabled arp-timeout=auto auto-mac=yes dhcp-snooping=no disabled=no ether-type=0x8100 fast-forward=yes frame-types=admit-all igmp-snooping=no ingress-filtering=yes mtu=auto name=BRI-TEST port-cost-mode=short protocol-mode=none pvid=1 vlan-filtering=yes
/interface ethernet set [ find default-name=ether1 ] advertise=10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full arp=enabled arp-timeout=auto auto-negotiation=yes bandwidth=unlimited/unlimited disabled=no l2mtu=1598 loop-protect=default loop-protect-disable-time=5m loop-protect-send-interval=5s mac-address=78:9A:18:44:80:45 mtu=1500 name=ether1 orig-mac-address=78:9A:18:44:80:45 rx-flow-control=off tx-flow-control=off
/interface ethernet set [ find default-name=ether2 ] advertise=10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full arp=enabled arp-timeout=auto auto-negotiation=yes bandwidth=unlimited/unlimited disabled=no l2mtu=1598 loop-protect=default loop-protect-disable-time=5m loop-protect-send-interval=5s mac-address=78:9A:18:44:80:46 mtu=1500 name=ether2 orig-mac-address=78:9A:18:44:80:46 rx-flow-control=off tx-flow-control=off
/interface ethernet set [ find default-name=ether3 ] advertise=10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full arp=enabled arp-timeout=auto auto-negotiation=yes bandwidth=unlimited/unlimited disabled=no l2mtu=1598 loop-protect=default loop-protect-disable-time=5m loop-protect-send-interval=5s mac-address=78:9A:18:44:80:47 mtu=1500 name=ether3 orig-mac-address=78:9A:18:44:80:47 rx-flow-control=off tx-flow-control=off
/interface ethernet set [ find default-name=ether4 ] advertise=10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full arp=enabled arp-timeout=auto auto-negotiation=yes bandwidth=unlimited/unlimited disabled=no l2mtu=1598 loop-protect=default loop-protect-disable-time=5m loop-protect-send-interval=5s mac-address=78:9A:18:44:80:48 mtu=1500 name=ether4 orig-mac-address=78:9A:18:44:80:48 rx-flow-control=off tx-flow-control=off
/interface ethernet set [ find default-name=ether5 ] advertise=10M-baseT-half,10M-baseT-full,100M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full arp=enabled arp-timeout=auto auto-negotiation=yes bandwidth=unlimited/unlimited disabled=no l2mtu=1598 loop-protect=default loop-protect-disable-time=5m loop-protect-send-interval=5s mac-address=78:9A:18:44:80:49 mtu=1500 name=ether5 orig-mac-address=78:9A:18:44:80:49 rx-flow-control=off tx-flow-control=off
/interface wireguard add disabled=no listen-port=13231 mtu=1420 name=wireguard1 private-key="qNe0ta0I76KoCkQFBaQedGqbsncFmPk/6UHOk1Z7yXw="
/queue interface set BRI-TEST queue=no-queue
/queue interface set wireguard1 queue=no-queue
/interface vlan add arp=enabled arp-timeout=auto disabled=no interface=BRI-TEST loop-protect=default loop-protect-disable-time=5m loop-protect-send-interval=5s mtu=1500 name=VLAN63 use-service-tag=no vlan-id=63
/interface vlan add arp=enabled arp-timeout=auto disabled=no interface=BRI-TEST loop-protect=default loop-protect-disable-time=5m loop-protect-send-interval=5s mtu=1500 name=VLAN64 use-service-tag=no vlan-id=64
/queue interface set VLAN63 queue=no-queue
/queue interface set VLAN64 queue=no-queue
/interface ethernet switch set 0 cpu-flow-control=yes mirror-source=none mirror-target=none name=switch1
/interface ethernet switch port set 0 default-vlan-id=auto vlan-header=leave-as-is vlan-mode=disabled
/interface ethernet switch port set 1 default-vlan-id=auto vlan-header=leave-as-is vlan-mode=disabled
/interface ethernet switch port set 2 default-vlan-id=auto vlan-header=leave-as-is vlan-mode=disabled
/interface ethernet switch port set 3 default-vlan-id=auto vlan-header=leave-as-is vlan-mode=disabled
/interface ethernet switch port set 4 default-vlan-id=auto vlan-header=leave-as-is vlan-mode=disabled
/interface ethernet switch port set 5 default-vlan-id=auto vlan-header=leave-as-is vlan-mode=disabled
/interface ethernet switch port-isolation set 0 !forwarding-override
/interface ethernet switch port-isolation set 1 !forwarding-override
/interface ethernet switch port-isolation set 2 !forwarding-override
/interface ethernet switch port-isolation set 3 !forwarding-override
/interface ethernet switch port-isolation set 4 !forwarding-override
/interface ethernet switch port-isolation set 5 !forwarding-override
/interface list set [ find name=all ] comment="contains all interfaces" exclude="" include="" name=all
/interface list set [ find name=none ] comment="contains no interfaces" exclude="" include="" name=none
/interface list set [ find name=dynamic ] comment="contains dynamic interfaces" exclude="" include="" name=dynamic
/interface list set [ find name=static ] comment="contains static interfaces" exclude="" include="" name=static
/interface list add exclude="" include="" name=LAN
/interface list add exclude="" include="" name=WAN
/interface list add exclude="" include="" name=InterfaceListVlan63
/interface list add exclude="" include="" name=InterfaceListVlan64
/interface lte apn set [ find default=yes ] add-default-route=yes apn=internet authentication=none default-route-distance=2 ip-type=auto name=default use-network-apn=yes use-peer-dns=yes
/interface macsec profile set [ find default-name=default ] name=default server-priority=10
/interface wireless security-profiles set [ find default=yes ] authentication-types=wpa2-psk disable-pmkid=no eap-methods=passthrough group-ciphers=aes-ccm group-key-update=5m interim-update=0s management-protection=disabled management-protection-key="" mode=dynamic-keys mschapv2-password="" mschapv2-username="" name=default radius-called-format=mac:ssid radius-eap-accounting=no radius-mac-accounting=no radius-mac-authentication=no radius-mac-caching=disabled radius-mac-format=XX:XX:XX:XX:XX:XX radius-mac-mode=as-username static-algo-0=none static-algo-1=none static-algo-2=none static-algo-3=none static-key-0="" static-key-1="" static-key-2="" static-key-3="" static-sta-private-algo=none static-sta-private-key="" static-transmit-key=key-0 supplicant-identity=MikroTik tls-certificate=none tls-mode=no-certificates unicast-ciphers=aes-ccm wpa-pre-shared-key="" wpa2-pre-shared-key=33338888
/interface wireless security-profiles add authentication-types="" disable-pmkid=no eap-methods=passthrough group-ciphers=aes-ccm group-key-update=5m interim-update=0s management-protection=disabled management-protection-key="" mode=none mschapv2-password="" mschapv2-username="" name=none radius-called-format=mac:ssid radius-eap-accounting=no radius-mac-accounting=no radius-mac-authentication=no radius-mac-caching=disabled radius-mac-format=XX:XX:XX:XX:XX:XX radius-mac-mode=as-username static-algo-0=none static-algo-1=none static-algo-2=none static-algo-3=none static-key-0="" static-key-1="" static-key-2="" static-key-3="" static-sta-private-algo=none static-sta-private-key="" static-transmit-key=key-0 supplicant-identity="" tls-certificate=none tls-mode=no-certificates unicast-ciphers=aes-ccm wpa-pre-shared-key="" wpa2-pre-shared-key=""
/interface wireless set [ find default-name=wlan1 ] adaptive-noise-immunity=none allow-sharedkey=no ampdu-priorities=0 amsdu-limit=8192 amsdu-threshold=8192 antenna-gain=3 area="" arp=enabled arp-timeout=auto band=2ghz-b/g/n basic-rates-a/g=6Mbps basic-rates-b=1Mbps bridge-mode=enabled channel-width=20mhz compression=no country=philippines default-ap-tx-limit=0 default-authentication=yes default-client-tx-limit=0 default-forwarding=yes disable-running-check=no disabled=no disconnect-timeout=3s distance=dynamic frame-lifetime=0 frequency=2412 frequency-mode=regulatory-domain frequency-offset=0 guard-interval=any hide-ssid=no ht-basic-mcs=mcs-0,mcs-1,mcs-2,mcs-3,mcs-4,mcs-5,mcs-6,mcs-7 ht-supported-mcs=mcs-0,mcs-1,mcs-2,mcs-3,mcs-4,mcs-5,mcs-6,mcs-7,mcs-8,mcs-9,mcs-10,mcs-11,mcs-12,mcs-13,mcs-14,mcs-15,mcs-16,mcs-17,mcs-18,mcs-19,mcs-20,mcs-21,mcs-22,mcs-23 hw-fragmentation-threshold=disabled hw-protection-mode=none hw-protection-threshold=0 hw-retries=7 installation=any interworking-profile=disabled keepalive-frames=enabled l2mtu=1600 mac-address=78:9A:18:44:80:4A max-station-count=2007 mode=station mtu=1500 multicast-buffering=enabled multicast-helper=default name=wlan1 nv2-cell-radius=30 nv2-downlink-ratio=50 nv2-mode=dynamic-downlink nv2-preshared-key="" nv2-qos=default nv2-queue-count=2 nv2-security=disabled nv2-sync-secret="" on-fail-retry-time=100ms preamble-mode=both radio-name=789A1844804A rate-selection=advanced rate-set=default rx-chains=0,1 scan-list=default secondary-frequency="" security-profile=none skip-dfs-channels=disabled ssid=Sofitel station-bridge-clone-mac=00:00:00:00:00:00 station-roaming=disabled supported-rates-a/g=6Mbps,9Mbps,12Mbps,18Mbps,24Mbps,36Mbps,48Mbps,54Mbps supported-rates-b=1Mbps,2Mbps,5.5Mbps,11Mbps tdma-period-size=2 tx-chains=0,1 tx-power-mode=default update-stats-interval=disabled vlan-id=1 vlan-mode=no-tag wds-cost-range=50-150 wds-default-bridge=none wds-default-cost=100 wds-ignore-ssid=no wds-mode=disabled wireless-protocol=any wmm-support=disabled wps-mode=push-button
/interface wireless set [ find default-name=wlan2 ] adaptive-noise-immunity=none allow-sharedkey=no ampdu-priorities=0 amsdu-limit=8192 amsdu-threshold=8192 antenna-gain=3 area="" arp=enabled arp-timeout=auto band=5ghz-n/ac basic-rates-a/g=6Mbps bridge-mode=enabled channel-width=20/40mhz-eC compression=no country=philippines default-ap-tx-limit=0 default-authentication=yes default-client-tx-limit=0 default-forwarding=yes disable-running-check=no disabled=no disconnect-timeout=3s distance=dynamic frame-lifetime=0 frequency=auto frequency-mode=regulatory-domain frequency-offset=0 guard-interval=any hide-ssid=no ht-basic-mcs=mcs-0,mcs-1,mcs-2,mcs-3,mcs-4,mcs-5,mcs-6,mcs-7 ht-supported-mcs=mcs-0,mcs-1,mcs-2,mcs-3,mcs-4,mcs-5,mcs-6,mcs-7,mcs-8,mcs-9,mcs-10,mcs-11,mcs-12,mcs-13,mcs-14,mcs-15,mcs-16,mcs-17,mcs-18,mcs-19,mcs-20,mcs-21,mcs-22,mcs-23 hw-fragmentation-threshold=disabled hw-protection-mode=none hw-protection-threshold=0 hw-retries=7 installation=any interworking-profile=disabled keepalive-frames=enabled l2mtu=1600 mac-address=78:9A:18:44:80:4B max-station-count=2007 mode=ap-bridge mtu=1500 multicast-buffering=enabled multicast-helper=default name=wlan2 nv2-cell-radius=30 nv2-downlink-ratio=50 nv2-mode=dynamic-downlink nv2-preshared-key="" nv2-qos=default nv2-queue-count=2 nv2-security=disabled nv2-sync-secret="" on-fail-retry-time=100ms preamble-mode=both radio-name=789A1844804B rate-selection=advanced rate-set=default rx-chains=0,1 scan-list=default secondary-frequency="" security-profile=default skip-dfs-channels=disabled ssid=Soundcontrol@COCO station-bridge-clone-mac=00:00:00:00:00:00 station-roaming=disabled supported-rates-a/g=6Mbps,9Mbps,12Mbps,18Mbps,24Mbps,36Mbps,48Mbps,54Mbps tdma-period-size=2 tx-chains=0,1 tx-power-mode=default update-stats-interval=disabled vht-basic-mcs=mcs0-7 vht-supported-mcs=mcs0-9,mcs0-9,mcs0-9 vlan-id=1 vlan-mode=no-tag wds-cost-range=50-150 wds-default-bridge=none wds-default-cost=100 wds-ignore-ssid=no wds-mode=disabled wireless-protocol=any wmm-support=disabled wps-mode=disabled
/interface wireless manual-tx-power-table set wlan1 manual-tx-powers=1Mbps:17,2Mbps:17,5.5Mbps:17,11Mbps:17,6Mbps:17,9Mbps:17,12Mbps:17,18Mbps:17,24Mbps:17,36Mbps:17,48Mbps:17,54Mbps:17,HT20-0:17,HT20-1:17,HT20-2:17,HT20-3:17,HT20-4:17,HT20-5:17,HT20-6:17,HT20-7:17,HT40-0:17,HT40-1:17,HT40-2:17,HT40-3:17,HT40-4:17,HT40-5:17,HT40-6:17,HT40-7:17
/interface wireless manual-tx-power-table set wlan2 manual-tx-powers=1Mbps:17,2Mbps:17,5.5Mbps:17,11Mbps:17,6Mbps:17,9Mbps:17,12Mbps:17,18Mbps:17,24Mbps:17,36Mbps:17,48Mbps:17,54Mbps:17,HT20-0:17,HT20-1:17,HT20-2:17,HT20-3:17,HT20-4:17,HT20-5:17,HT20-6:17,HT20-7:17,HT40-0:17,HT40-1:17,HT40-2:17,HT40-3:17,HT40-4:17,HT40-5:17,HT40-6:17,HT40-7:17
/interface wireless nstreme set wlan1 disable-csma=no enable-nstreme=no enable-polling=yes framer-limit=3200 framer-policy=none
/interface wireless nstreme set wlan2 disable-csma=no enable-nstreme=no enable-polling=yes framer-limit=3200 framer-policy=none
/ip dhcp-client option set clientid_duid code=61 name=clientid_duid value="0xff\$(CLIENT_DUID)"
/ip dhcp-client option set clientid code=61 name=clientid value="0x01\$(CLIENT_MAC)"
/ip dhcp-client option set hostname code=12 name=hostname value="\$(HOSTNAME)"
/ip hotspot profile set [ find default=yes ] dns-name="" hotspot-address=0.0.0.0 html-directory=hotspot html-directory-override="" http-cookie-lifetime=3d http-proxy=0.0.0.0:0 install-hotspot-queue=no login-by=cookie,http-chap name=default smtp-server=0.0.0.0 split-user-domain=no use-radius=no
/ip hotspot user profile set [ find default=yes ] add-mac-cookie=yes address-list="" idle-timeout=none !insert-queue-before keepalive-timeout=2m mac-cookie-timeout=3d name=default !parent-queue !queue-type shared-users=1 status-autorefresh=1m transparent-proxy=no
/ip ipsec mode-config set [ find default=yes ] name=request-only responder=no use-responder-dns=exclusively
/ip ipsec policy group set [ find default=yes ] name=default
/ip ipsec profile set [ find default=yes ] dh-group=modp2048,modp1024 dpd-interval=2m dpd-maximum-failures=5 enc-algorithm=aes-128,3des hash-algorithm=sha1 lifetime=1d name=default nat-traversal=yes proposal-check=obey
/ip ipsec proposal set [ find default=yes ] auth-algorithms=sha1 disabled=no enc-algorithms=aes-256-cbc,aes-192-cbc,aes-128-cbc lifetime=30m name=default pfs-group=modp1024
/ip pool add name=POOL63 ranges=192.168.63.10-192.168.63.200
/ip pool add name=POOL64 ranges=192.168.64.10-192.168.64.200
/ip dhcp-server add address-pool=POOL63 authoritative=yes disabled=no interface=VLAN63 lease-script="" lease-time=1d name=DHCP63 use-radius=no
/ip dhcp-server add address-pool=POOL64 authoritative=yes disabled=no interface=VLAN64 lease-script="" lease-time=1d name=DHCP64 use-radius=no
/ppp profile set *0 address-list="" !bridge !bridge-horizon bridge-learning=default !bridge-path-cost !bridge-port-priority change-tcp-mss=yes !dns-server !idle-timeout !incoming-filter !insert-queue-before !interface-list !local-address name=default on-down="" on-up="" only-one=default !outgoing-filter !parent-queue !queue-type !rate-limit !remote-address !session-timeout use-compression=default use-encryption=default use-ipv6=yes use-mpls=default use-upnp=default !wins-server
/ppp profile set *FFFFFFFE address-list="" !bridge !bridge-horizon bridge-learning=default !bridge-path-cost !bridge-port-priority change-tcp-mss=yes !dns-server !idle-timeout !incoming-filter !insert-queue-before !interface-list !local-address name=default-encryption on-down="" on-up="" only-one=default !outgoing-filter !parent-queue !queue-type !rate-limit !remote-address !session-timeout use-compression=default use-encryption=yes use-ipv6=yes use-mpls=default use-upnp=default !wins-server
/queue type set 0 kind=pfifo name=default pfifo-limit=50
/queue type set 1 kind=pfifo name=ethernet-default pfifo-limit=50
/queue type set 2 kind=sfq name=wireless-default sfq-allot=1514 sfq-perturb=5
/queue type set 3 kind=red name=synchronous-default red-avg-packet=1000 red-burst=20 red-limit=60 red-max-threshold=50 red-min-threshold=10
/queue type set 4 kind=sfq name=hotspot-default sfq-allot=1514 sfq-perturb=5
/queue type set 5 kind=pcq name=pcq-upload-default pcq-burst-rate=0 pcq-burst-threshold=0 pcq-burst-time=10s pcq-classifier=src-address pcq-dst-address-mask=32 pcq-dst-address6-mask=128 pcq-limit=50KiB pcq-rate=0 pcq-src-address-mask=32 pcq-src-address6-mask=128 pcq-total-limit=2000KiB
/queue type set 6 kind=pcq name=pcq-download-default pcq-burst-rate=0 pcq-burst-threshold=0 pcq-burst-time=10s pcq-classifier=dst-address pcq-dst-address-mask=32 pcq-dst-address6-mask=128 pcq-limit=50KiB pcq-rate=0 pcq-src-address-mask=32 pcq-src-address6-mask=128 pcq-total-limit=2000KiB
/queue type set 7 kind=none name=only-hardware-queue
/queue type set 8 kind=mq-pfifo mq-pfifo-limit=50 name=multi-queue-ethernet-default
/queue type set 9 kind=pfifo name=default-small pfifo-limit=10
/queue interface set ether1 queue=only-hardware-queue
/queue interface set ether2 queue=only-hardware-queue
/queue interface set ether3 queue=only-hardware-queue
/queue interface set ether4 queue=only-hardware-queue
/queue interface set ether5 queue=only-hardware-queue
/queue interface set wlan1 queue=wireless-default
/queue interface set wlan2 queue=wireless-default
/routing bgp template set default as=65530 name=default
/snmp community set [ find default=yes ] addresses=::/0 authentication-password="" authentication-protocol=MD5 disabled=no encryption-password="" encryption-protocol=DES name=public read-access=yes security=none write-access=no
/system logging action set 0 memory-lines=1000 memory-stop-on-full=no name=memory target=memory
/system logging action set 1 disk-file-count=2 disk-file-name=flash/log disk-lines-per-file=1000 disk-stop-on-full=no name=disk target=disk
/system logging action set 2 name=echo remember=yes target=echo
/system logging action set 3 bsd-syslog=no name=remote remote=0.0.0.0 remote-port=514 src-address=0.0.0.0 syslog-facility=daemon syslog-severity=auto syslog-time-format=bsd-syslog target=remote
/user group set read name=read policy=local,telnet,ssh,reboot,read,test,winbox,password,web,sniff,sensitive,api,romon,rest-api,!ftp,!write,!policy skin=default
/user group set write name=write policy=local,telnet,ssh,reboot,read,write,test,winbox,password,web,sniff,sensitive,api,romon,rest-api,!ftp,!policy skin=default
/user group set full name=full policy=local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,password,web,sniff,sensitive,api,romon,rest-api skin=default
/caps-man aaa set called-format=mac:ssid interim-update=disabled mac-caching=disabled mac-format=XX:XX:XX:XX:XX:XX mac-mode=as-username
/caps-man manager set ca-certificate=none certificate=none enabled=no package-path="" require-peer-certificate=no upgrade-policy=none
/caps-man manager interface set [ find default=yes ] disabled=no forbid=no interface=all
/certificate settings set crl-download=no crl-store=ram crl-use=no
/interface bridge port add auto-isolate=no bpdu-guard=no bridge=BRI-TEST broadcast-flood=yes disabled=no edge=auto fast-leave=no frame-types=admit-only-untagged-and-priority-tagged horizon=none hw=yes ingress-filtering=yes interface=InterfaceListVlan63 internal-path-cost=10 learn=auto multicast-router=temporary-query path-cost=10 point-to-point=auto priority=0x80 pvid=63 restricted-role=no restricted-tcn=no tag-stacking=no trusted=no unknown-multicast-flood=yes unknown-unicast-flood=yes
/interface bridge port add auto-isolate=no bpdu-guard=no bridge=BRI-TEST broadcast-flood=yes disabled=no edge=auto fast-leave=no frame-types=admit-only-untagged-and-priority-tagged horizon=none hw=yes ingress-filtering=yes interface=InterfaceListVlan64 internal-path-cost=10 learn=auto multicast-router=temporary-query path-cost=10 point-to-point=auto priority=0x80 pvid=64 restricted-role=no restricted-tcn=no tag-stacking=no trusted=no unknown-multicast-flood=yes unknown-unicast-flood=yes
/interface bridge port-controller
# disabled
set bridge=none cascade-ports="" switch=none
/interface bridge port-extender
# disabled
set control-ports="" excluded-ports="" switch=none
/interface bridge settings set allow-fast-path=yes use-ip-firewall=no use-ip-firewall-for-pppoe=no use-ip-firewall-for-vlan=no
/ip firewall connection tracking set enabled=auto generic-timeout=10m icmp-timeout=10s loose-tcp-tracking=yes tcp-close-timeout=10s tcp-close-wait-timeout=10s tcp-established-timeout=1d tcp-fin-wait-timeout=10s tcp-last-ack-timeout=10s tcp-max-retrans-timeout=5m tcp-syn-received-timeout=5s tcp-syn-sent-timeout=5s tcp-time-wait-timeout=10s tcp-unacked-timeout=5m udp-stream-timeout=3m udp-timeout=10s
/ip neighbor discovery-settings set discover-interface-list=static lldp-med-net-policy-vlan=disabled mode=tx-and-rx protocol=cdp,lldp,mndp
/ip settings set accept-redirects=no accept-source-route=no allow-fast-path=yes arp-timeout=30s icmp-rate-limit=10 icmp-rate-mask=0x1818 ip-forward=yes max-neighbor-entries=4096 rp-filter=no secure-redirects=yes send-redirects=yes tcp-syncookies=no
/ipv6 settings set accept-redirects=yes-if-forwarding-disabled accept-router-advertisements=yes-if-forwarding-disabled disable-ipv6=no forward=yes max-neighbor-entries=2048
/interface bridge vlan add bridge=BRI-TEST disabled=no tagged=BRI-TEST untagged="" vlan-ids=63
/interface bridge vlan add bridge=BRI-TEST disabled=no tagged=BRI-TEST untagged="" vlan-ids=64
/interface detect-internet set detect-interface-list=none internet-interface-list=none lan-interface-list=none wan-interface-list=none
/interface l2tp-server server set accept-proto-version=all accept-pseudowire-type=all allow-fast-path=no authentication=pap,chap,mschap1,mschap2 caller-id-type=ip-address default-profile=default-encryption enabled=no ipsec-secret="" keepalive-timeout=30 l2tpv3-circuit-id="" l2tpv3-cookie-length=0 l2tpv3-digest-hash=md5 !l2tpv3-ether-interface-list max-mru=1450 max-mtu=1450 max-sessions=unlimited mrru=disabled one-session-per-host=no use-ipsec=no
/interface list member add disabled=no interface=ether1 list=WAN
/interface list member add disabled=no interface=ether2 list=InterfaceListVlan63
/interface list member add disabled=no interface=ether3 list=InterfaceListVlan63
/interface list member add disabled=no interface=ether4 list=InterfaceListVlan63
/interface list member add disabled=no interface=ether5 list=InterfaceListVlan63
/interface list member add disabled=no interface=VLAN63 list=LAN
/interface list member add disabled=no interface=VLAN64 list=LAN
/interface list member add disabled=no interface=wlan2 list=InterfaceListVlan63
/interface lte settings set firmware-path=firmware mode=auto
/interface ovpn-server server set auth=sha1,md5,sha256,sha512 certificate=*0 cipher=blowfish128,aes128-cbc default-profile=default enable-tun-ipv6=no enabled=no ipv6-prefix-len=64 keepalive-timeout=60 mac-address=FE:9A:04:0B:59:30 max-mtu=1500 mode=ip netmask=24 port=1194 protocol=tcp redirect-gateway=disabled reneg-sec=3600 require-client-certificate=no tls-version=any tun-server-ipv6=::
/interface pptp-server server
# PPTP connections are considered unsafe, it is suggested to use a more modern VPN protocol instead
set authentication=mschap1,mschap2 default-profile=default-encryption enabled=no keepalive-timeout=30 max-mru=1450 max-mtu=1450 mrru=disabled
/interface sstp-server server set authentication=pap,chap,mschap1,mschap2 certificate=none default-profile=default enabled=no keepalive-timeout=60 max-mru=1500 max-mtu=1500 mrru=disabled pfs=no port=443 tls-version=any verify-client-certificate=no
/interface wifi cap set enabled=no
/interface wifi capsman set enabled=no
/interface wireless align set active-mode=yes audio-max=-20 audio-min=-100 audio-monitor=00:00:00:00:00:00 filter-mac=00:00:00:00:00:00 frame-size=300 frames-per-second=25 receive-all=no ssid-all=no
/interface wireless cap set bridge=none caps-man-addresses="" caps-man-certificate-common-names="" caps-man-names="" certificate=none discovery-interfaces="" enabled=no interfaces="" lock-to-caps-man=no static-virtual=no
/interface wireless sniffer set channel-time=200ms file-limit=10 file-name="" memory-limit=10 multiple-channels=no only-headers=no receive-errors=no streaming-enabled=no streaming-max-rate=0 streaming-server=0.0.0.0
/interface wireless snooper set channel-time=200ms multiple-channels=yes receive-errors=no
/ip address add address=192.168.63.1/24 disabled=no interface=VLAN63 network=192.168.63.0
/ip address add address=192.168.64.1/24 disabled=no interface=VLAN64 network=192.168.64.0
/ip address add address=10.11.11.1/24 disabled=no interface=wireguard1 network=10.11.11.0
/ip cloud set back-to-home-vpn=revoked-and-disabled ddns-enabled=no ddns-update-interval=1d update-time=no
/ip cloud advanced set use-local-address=no
/ip dhcp-client add add-default-route=yes default-route-distance=1 dhcp-options=hostname,clientid disabled=no interface=ether1 use-peer-dns=yes use-peer-ntp=yes
/ip dhcp-client add add-default-route=yes default-route-distance=1 dhcp-options=hostname,clientid disabled=no interface=wlan1 use-peer-dns=yes use-peer-ntp=yes
/ip dhcp-server config set accounting=yes interim-update=0s radius-password=empty store-leases-disk=5m
/ip dhcp-server network add address=192.168.63.0/24 caps-manager="" dhcp-option="" dns-server=192.168.63.1 gateway=192.168.63.1 !next-server ntp-server="" wins-server=""
/ip dhcp-server network add address=192.168.64.0/24 caps-manager="" dhcp-option="" dns-server=192.168.64.1 gateway=192.168.64.1 !next-server ntp-server="" wins-server=""
/ip dns set address-list-extra-time=0s allow-remote-requests=yes cache-max-ttl=1w cache-size=2048KiB doh-max-concurrent-queries=50 doh-max-server-connections=5 doh-timeout=5s max-concurrent-queries=100 max-concurrent-tcp-sessions=20 max-udp-packet-size=4096 query-server-timeout=2s query-total-timeout=10s servers="" use-doh-server="" verify-doh-cert=no
/ip firewall filter add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
/ip firewall filter add action=accept chain=input comment="allow WireGuard" dst-port=13231 protocol=udp
/ip firewall filter add action=accept chain=input comment="allow WireGuard traffic" in-interface=wireguard1
/ip firewall filter add action=accept chain=input comment="users to Router services" dst-port=53,8291 in-interface-list=LAN protocol=tcp
/ip firewall filter add action=accept chain=input comment="users to Router services" dst-port=53 in-interface-list=LAN protocol=udp
/ip firewall filter add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=accept chain=forward comment="allow internet" in-interface-list=LAN out-interface-list=WAN
/ip firewall filter add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
/ip firewall filter add action=drop chain=forward comment="Drop all else"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN !to-addresses !to-ports
/ip firewall service-port set ftp disabled=no ports=21
/ip firewall service-port set tftp disabled=no ports=69
/ip firewall service-port set irc disabled=yes ports=6667
/ip firewall service-port set h323 disabled=no
/ip firewall service-port set sip disabled=no ports=5060,5061 sip-direct-media=yes sip-timeout=1h
/ip firewall service-port set pptp disabled=no
/ip firewall service-port set rtsp disabled=yes ports=554
/ip firewall service-port set udplite disabled=no
/ip firewall service-port set dccp disabled=no
/ip firewall service-port set sctp disabled=no
/ip hotspot service-port set ftp disabled=no ports=21
/ip hotspot user set [ find default=yes ] comment="counters and limits for trial users" disabled=no name=default-trial
/ip ipsec policy set 0 disabled=no dst-address=::/0 group=default proposal=default protocol=all src-address=::/0 template=yes
/ip ipsec settings set accounting=yes interim-update=0s xauth-use-radius=no
/ip nat-pmp set enabled=no
/ip proxy set always-from-cache=no anonymous=no cache-administrator=webmaster cache-hit-dscp=4 cache-on-disk=no cache-path=web-proxy enabled=no max-cache-object-size=2048KiB max-cache-size=unlimited max-client-connections=600 max-fresh-time=3d max-server-connections=600 parent-proxy=:: parent-proxy-port=0 port=8080 serialize-connections=no src-address=::
/ip service set telnet address="" disabled=no port=23 vrf=main
/ip service set ftp address="" disabled=no port=21
/ip service set www address="" disabled=no port=80 vrf=main
/ip service set ssh address="" disabled=no port=22 vrf=main
/ip service set www-ssl address="" certificate=none disabled=yes port=443 tls-version=any vrf=main
/ip service set api address="" disabled=no port=8728 vrf=main
/ip service set winbox address="" disabled=no port=8291 vrf=main
/ip service set api-ssl address="" certificate=none disabled=no port=8729 tls-version=any vrf=main
/ip smb set allow-guests=yes comment=MikrotikSMB domain=MSHOME enabled=no interfaces=all
/ip smb shares set [ find default=yes ] comment="default share" directory=/flash/pub disabled=no max-sessions=10 name=pub
/ip smb users set [ find default=yes ] disabled=no name=guest password="" read-only=yes
/ip socks set auth-method=none connection-idle-timeout=2m enabled=no max-connections=200 port=1080 version=4 vrf=main
/ip ssh set allow-none-crypto=no always-allow-password-login=no forwarding-enabled=no host-key-size=2048 host-key-type=rsa strong-crypto=no
/ip tftp settings set max-block-size=4096
/ip traffic-flow set active-flow-timeout=30m cache-entries=32k enabled=no inactive-flow-timeout=15s interfaces=all packet-sampling=no sampling-interval=0 sampling-space=0
/ip traffic-flow ipfix set bytes=yes dst-address=yes dst-address-mask=yes dst-mac-address=yes dst-port=yes first-forwarded=yes gateway=yes icmp-code=yes icmp-type=yes igmp-type=yes in-interface=yes ip-header-length=yes ip-total-length=yes ipv6-flow-label=yes is-multicast=yes last-forwarded=yes nat-dst-address=yes nat-dst-port=yes nat-events=no nat-src-address=yes nat-src-port=yes out-interface=yes packets=yes protocol=yes src-address=yes src-address-mask=yes src-mac-address=yes src-port=yes sys-init-time=yes tcp-ack-num=yes tcp-flags=yes tcp-seq-num=yes tcp-window-size=yes tos=yes ttl=yes udp-length=yes
/ip upnp set allow-disable-external-interface=no enabled=no show-dummy-rule=yes
/ipv6 nd set [ find default=yes ] advertise-dns=yes advertise-mac-address=yes disabled=no dns="" hop-limit=unspecified interface=all managed-address-configuration=no mtu=unspecified other-configuration=no pref64="" ra-delay=3s ra-interval=3m20s-10m ra-lifetime=30m ra-preference=medium reachable-time=unspecified retransmit-interval=unspecified
/ipv6 nd prefix default set autonomous=yes preferred-lifetime=1w valid-lifetime=4w2d
/mpls settings set allow-fast-path=yes dynamic-label-range=16-1048575 propagate-ttl=yes
/ppp aaa set accounting=yes interim-update=0s use-circuit-id-in-nas-port-id=no use-radius=no
/radius incoming set accept=no port=3799 vrf=main
/routing igmp-proxy set query-interval=2m5s query-response-interval=10s quick-leave=no
/routing settings set single-process=no
/snmp set contact="" enabled=no engine-id-suffix="" location="" src-address=:: trap-community=public trap-generators=temp-exception trap-target="" trap-version=1 vrf=main
/system clock set time-zone-autodetect=yes time-zone-name=Asia/Manila
/system clock manual set dst-delta=+00:00 dst-end="1970-01-01 00:00:00" dst-start="1970-01-01 00:00:00" time-zone=+00:00
/system identity set name=coco
/system leds settings set all-leds-off=never
/system logging set 0 action=memory disabled=no prefix="" topics=info
/system logging set 1 action=memory disabled=no prefix="" topics=error
/system logging set 2 action=memory disabled=no prefix="" topics=warning
/system logging set 3 action=echo disabled=no prefix="" topics=critical
/system note set note="" show-at-login=no
/system ntp client set enabled=yes mode=unicast servers=time.cloudflare.com vrf=main
/system ntp server set auth-key=none broadcast=no broadcast-addresses="" enabled=no local-clock-stratum=5 manycast=no multicast=no use-local-clock=no vrf=main
/system ntp client servers add address=time.cloudflare.com auth-key=none disabled=no iburst=yes max-poll=10 min-poll=6
/system resource irq set 0 cpu=auto
/system resource irq set 1 cpu=auto
/system resource irq set 2 cpu=auto
/system resource irq set 3 cpu=auto
/system resource irq set 4 cpu=auto
/system resource irq set 5 cpu=auto
/system resource irq set 6 cpu=auto
/system resource irq set 7 cpu=auto
/system resource irq rps set ether1 disabled=yes
/system resource irq rps set ether2 disabled=yes
/system resource irq rps set ether3 disabled=yes
/system resource irq rps set ether4 disabled=yes
/system resource irq rps set ether5 disabled=yes
/system resource usb settings set authorization=no
/system routerboard settings set auto-upgrade=no boot-device=nand-if-fail-then-ethernet boot-protocol=bootp protected-routerboot=disabled reformat-hold-button=20s reformat-hold-button-max=10m silent-boot=no
/system routerboard mode-button set enabled=no hold-time=0s..1m on-event=""
/system routerboard reset-button set enabled=no hold-time=0s..1m on-event=""
/system upgrade mirror set check-interval=1d enabled=no primary-server=0.0.0.0 secondary-server=0.0.0.0 user=""
/system watchdog set auto-send-supout=no automatic-supout=yes ping-start-after-boot=5m ping-timeout=1m watch-address=none watchdog-timer=yes
/tool bandwidth-server set allocate-udp-ports-from=2000 authenticate=yes enabled=yes max-sessions=100
/tool e-mail set from=<> password="" port=25 server=0.0.0.0 tls=no user="" vrf=main
/tool graphing set page-refresh=300 store-every=5min
/tool mac-server set allowed-interface-list=all
/tool mac-server mac-winbox set allowed-interface-list=all
/tool mac-server ping set enabled=yes
/tool romon set enabled=no id=00:00:00:00:00:00 secrets=""
/tool romon port set [ find default=yes ] cost=100 disabled=no forbid=no interface=all secrets=""
/tool sms set allowed-number="" channel=0 port=none receive-enabled=no secret="" sim-pin=""
/tool sniffer set file-limit=1000KiB file-name="" filter-cpu="" filter-direction=any filter-dst-ip-address="" filter-dst-ipv6-address="" filter-dst-mac-address="" filter-dst-port="" filter-interface="" filter-ip-address="" filter-ip-protocol="" filter-ipv6-address="" filter-mac-address="" filter-mac-protocol="" filter-operator-between-entries=or filter-port="" filter-size="" filter-src-ip-address="" filter-src-ipv6-address="" filter-src-mac-address="" filter-src-port="" filter-stream=no filter-vlan="" memory-limit=100KiB memory-scroll=yes only-headers=no streaming-enabled=no streaming-server=0.0.0.0:37008
/tool traffic-generator set latency-distribution-max=100us measure-out-of-order=no stats-samples-to-keep=100 test-id=0
/user aaa set accounting=yes default-group=read exclude-groups="" interim-update=0s use-radius=no
/user settings set minimum-categories=0 minimum-password-length=0
