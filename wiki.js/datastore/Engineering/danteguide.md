---
title: Dante Guide
description: Fixing Issues with Dante
published: true
date: 2023-10-22T15:45:18.952Z
tags: 
editor: markdown
dateCreated: 2023-08-01T09:31:23.537Z
---

# QUICKFIX
- Multiple Clock Masters - IGMP SNOOPING PROBLEM, FIX IN SWITCH
- Increasing Latency all the time - DANTE BUG WITH MAC OS, UPDATE SOFTWARE
- Slow discovery - MAKE SURE NO LOOP BETWEEN PRI AND SEC, CHECK IGMP QUERY
- Popping/Clicking Sounds - MAKE SURE 1 CLOCK MASTER ONLY FOR DIGITAL SYSTEM AND ALL IS SYNCED






# Clocking Issues
## Multiple Clock Masters
- IGMP Problem, Dante multicast discovery messages are getting blocked.

- 



# Network Settings
> After any IGMP chage, it is best practise to reboot the switch
{.is-warning}

###### IGMP Snooping

ALL switches in the system should have IGMP Snooping enabled.


###### IGMP Querier

ONLY 1 switch in the system should be acting as the IGMP querier
CISCO: IGMP auto election, typically the lowest IP address in the system
NETGEAR: IGMP auto election
AGORA: NO IGMP Auto Election, it must be assigned!


###### QoS

Quality of Service (QoS) is generally not required unless you are fully saturating the switch.  Full saturation of the switch is better avoided through the use of correctly deployed IGMP snooping.

###### IP Addressing
- Dante will self discover in 169.254.xxx.xxx subnet, auto addressing
- Dante secondary will self discover in 172.31.xxx.xxx subnet


# Latency
