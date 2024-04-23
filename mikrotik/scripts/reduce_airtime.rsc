/interface bridge settings
set use-ip-firewall=yes use-ip-firewall-for-vlan=yes
/interface bridge filter
add action=drop chain=forward comment="Drop all IPv6 mDNS" dst-mac-address=\
    33:33:00:00:00:FB/FF:FF:FF:FF:FF:FF mac-protocol=ipv6
/ip firewall mangle
add action=change-ttl chain=forward comment="Sanitise mDNS TTL to 1" \
    dst-address=224.0.0.251 dst-port=5353 log-prefix=ttl new-ttl=set:1 \
    passthrough=yes protocol=udp src-port=5353 ttl=not-equal:1
add action=change-dscp chain=forward comment="Sanitise mDNS DSCP to 0" dscp=!0 \
    dst-address=224.0.0.251 dst-port=5353 log-prefix=ttl new-dscp=0 \
    passthrough=yes protocol=udp src-port=5353
/ip firewall mangle
add action=set-priority chain=postrouting comment="Set Prio outbound on Wifi" \
    new-priority=from-dscp-high-3-bits out-bridge-port=all-wireless \
    passthrough=yes