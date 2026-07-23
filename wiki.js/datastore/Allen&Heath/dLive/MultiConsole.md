---
title: Multi Console Configs
description: 
published: true
date: 2023-10-22T15:45:51.973Z
tags: 
editor: markdown
dateCreated: 2023-08-02T13:39:38.655Z
---

# Single MixRack, Multiple Surface

> **Step 1:**
Ensure different IP address for each component in the system.<br>
**For Example**
MixRack: 192.168.1.70
*FoH*: 192.168.1.71
*Mons*: 192.168.1.72

> **Step 2:**
Connect *FoH* to GigaAce port as usual


> **Step 3:**
Connect *Mons* to GigaAce card in MixRack.  Ensure CONTROL NETWORK BRIDGE is ON


> **Step 4:**
Recall MultiSurface FoH **SHOW** on *FoH* and apply Strip Assign Scene

> **Step 5:**
Recall MultiSurface Mons **SHOW** on *Mons* and apply Strip Assign Scene

> *FoH* will control scenes 1-250
*Mons* will control scenes 251-500
{.is-info}

> To enable Gain Sharing, reccomend to enable *FoH* as "master".<br>
Preamp on Surface can be turned ON globally [on *FoH*]:
Hold SETUP then press on PREAMP Page<br>
GAIN SHARING can be turned ON globally [on *Mons*]:
Hold SETUP then press on PREAMP Page
{.is-info}

> For FULL Information see 
https://www.allen-heath.com/media/Understanding-Multi-Surface-ISS1.pdf
{.is-success}

# Multiple MixRack
> Gain Sharing between multiple MixRacks requires the use of Tie-Lines.  ENSURE this is unnderstood before deploying a system,
{.is-warning}

> **Step 1:**
Ensure different IP address for each component in the system.<br>
**For Example**
FoH MixRack: 192.168.1.70
FoH Surface: 192.168.1.71
Mons Surface: 192.168.1.72
Mons MixRack: 192.168.1.73

> **Step 2:**
Connect FoH Surface to GigaAce port as usual

> **Step 3:**
Connect Mons Surface to GigaAce port as usual

> **Step 4:**
Link the two systems using 2 x GigaAce or FiberAce cards.  

> Ensure CONTROL NETWORK BRIDGE IS OFF
{.is-warning}

> **Step 5:**
Patch TieLines from Input @ FoH to the GigaAce Card

> **Step 6:**
Receive inputs from the GigaAce card @ Mons

> **Step 7:**
Gain Sharing/Preamp on Surface can be enabled/disabled as above.
