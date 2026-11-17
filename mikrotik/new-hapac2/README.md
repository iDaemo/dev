# ติดตั้ง hAP ac2 เครื่องใหม่ (new-hapac2)

สคริปต์นี้เปลี่ยน MikroTik hAP ac2 ที่แกะกล่องใหม่ ให้พร้อมลงโปรเจคด้วยคำสั่งเดียว:

1. อัป RouterOS เป็นเวอร์ชันที่กำหนด (ดูใน `version.sh`)
2. ถอด package `wireless` เดิม แล้วติดตั้ง `wifi-qcom-ac`
3. ลง config โปรเจค (VLAN40, WiFi, Firewall, WireGuard, user)

ทั้งหมดรันจาก MacBook ผ่านสาย LAN ไม่ต้องคลิกใน Winbox

---

## ก่อนออกหน้างาน (ทำที่ออฟฟิศ ต้องมีอินเทอร์เน็ต)

เปิด Terminal แล้วเข้าโฟลเดอร์นี้:

```bash
cd ~/GitHub/dev/mikrotik/new-hapac2
```

**1) ดาวน์โหลดไฟล์ติดตั้ง** (ทำครั้งเดียว ไฟล์จะอยู่ใน `packages/`)

```bash
./fetch-packages.sh
```

**2) สร้างไฟล์ค่าของโปรเจค** จากตัวอย่าง แล้วแก้ค่าให้ตรงกับไซต์

```bash
cp projects/example.conf projects/raynue.conf
```

```bash
open -e projects/raynue.conf
```

| ค่า | ความหมาย | ข้อกำหนด |
|---|---|---|
| `IDENTITY` | ชื่อเครื่อง | A-Z a-z 0-9 `_` `-` ห้ามเว้นวรรค |
| `SSID` | ชื่อ WiFi | |
| `WIFI_PASS` | รหัส WiFi | 8-63 ตัว |
| `USER_NAME` | user สำหรับเข้า Winbox (admin จะถูกลบ) | A-Z a-z 0-9 `_` `-` |
| `USER_PASS` | รหัสของ user นั้น | อย่างน้อย 8 ตัว |
| `WG_ADDRESS` | IP ของเครื่องในวง WireGuard | แบบ `10.0.0.40/24` |

ห้ามใช้ตัวอักษร `" \ $ & | { }` ในทุกค่า และห้ามมี `/` (ยกเว้น `WG_ADDRESS`)
ไฟล์ใน `projects/` (ยกเว้น example) จะไม่ถูก commit ลง git เพราะมีรหัสผ่าน

---

## ที่หน้างาน

1. เสียบปลั๊ก router รอไฟนิ่ง (~1 นาที)
2. เสียบสาย LAN จาก MacBook เข้าพอร์ต **ether2-ether5** (ห้ามใช้ ether1 / พอร์ต Internet)
3. ปิด WiFi ของ Mac (กันต่อผิดวง)
4. รัน:

```bash
./install.sh projects/raynue.conf
```

5. กด Enter เพื่อยืนยัน แล้วใส่รหัส admin เมื่อถาม
   - เครื่องใหม่: รหัสอยู่ที่สติกเกอร์ใต้เครื่อง หรือกด Enter ถ้าไม่มีรหัส
6. รอจนจบ (10-15 นาที, router จะรีบูตหลายรอบ — **ห้ามถอดปลั๊ก**)
7. ที่ขั้น 6 สคริปต์จะบอกให้ **ถอดสาย LAN แล้วเสียบใหม่** เพื่อให้ Mac ได้ IP วงใหม่ `192.168.40.x`
8. เห็น `✅ เสร็จแล้ว` = เรียบร้อย เข้า Winbox ได้ที่ `192.168.40.1` ด้วย user ในไฟล์โปรเจค

ถ้าสคริปต์หยุดกลางทาง: แก้ตามข้อความ "วิธีแก้" แล้ว **รัน `./install.sh` ซ้ำได้เลย** ขั้นที่ทำเสร็จแล้วจะถูกข้าม
(ยกเว้นหลังขั้น 5 — router ไม่ใช่ default config แล้ว ดูตารางด้านล่าง)

### แต่ละขั้นทำอะไร

| ขั้น | ทำอะไร | รีบูต? |
|---|---|---|
| 1/6 | ตรวจไฟล์โปรเจค, ไฟล์ `.npk`, ping `192.168.88.1` | |
| 2/6 | login ด้วยรหัส admin แล้วฝาก SSH key ชั่วคราว (ไม่ต้องใส่รหัสซ้ำ) | |
| 3/6 | อัป RouterOS ถ้ายังไม่ใช่เวอร์ชันที่กำหนด | ✔ |
| 4/6 | ถอด `wireless` → รีบูต → ติดตั้ง `wifi-qcom-ac` → รีบูต | ✔ ✔ |
| 5/6 | ล้าง config แล้วลง config โปรเจค | ✔ |
| 6/6 | รอ ping `192.168.40.1` ได้ แล้วสรุปผล | |

---

## แก้ปัญหา

| ข้อความ | สาเหตุ / วิธีแก้ |
|---|---|
| ต้องระบุไฟล์โปรเจค | พิมพ์ `./install.sh projects/<ชื่อไซต์>.conf` |
| อ่านไฟล์โปรเจคไม่ได้ | ชื่อไฟล์ผิด หรือยังไม่ได้ copy จาก `projects/example.conf` |
| ค่าในไฟล์โปรเจคไม่ถูกต้อง | ดูบรรทัด ❌ ด้านบนว่าค่าไหนผิด แก้ตามตารางค่าด้านบน (`CHANGE_ME` ต้องเปลี่ยนเป็นรหัสจริง) |
| ไม่พบไฟล์ ... ใน packages | ยังไม่ได้รัน `./fetch-packages.sh` — ต้องรันที่ที่มีอินเทอร์เน็ต |
| ping 192.168.88.1 ไม่ได้ | สายไม่ได้เสียบ ether2-5 / Mac ไม่ได้ IP `192.168.88.x` / router ไม่ใช่ default config (กดปุ่ม reset ค้าง ~5 วิ จนไฟกระพริบ แล้วปล่อย) |
| สร้าง SSH key ไม่ได้ | Mac มีปัญหา ลองปิด Terminal เปิดใหม่ |
| login ไม่สำเร็จ | รหัส admin ผิด — ดูสติกเกอร์ หรือ reset router กลับ default |
| อัปโหลด SSH key ไม่ได้ / import SSH key ไม่ได้ / login ด้วย SSH key ไม่ได้ | รันใหม่อีกครั้ง; ถ้ายังไม่ได้ ให้ reset router กลับ default แล้วรันใหม่ |
| อ่านเวอร์ชันไม่ได้ | การเชื่อมต่อหลุด เช็คสายแล้วรันใหม่ |
| RouterOS ... เก่าเกินไป อัปตรงเป็น v7 ไม่ได้ | เครื่องเป็น v6 รุ่นเก่า: Winbox → System → Packages → Check For Updates → channel `long-term` → Download&Install (ได้ 6.49 ขึ้นไป) แล้วรันใหม่ |
| อัปโหลดไฟล์ RouterOS ไม่ได้ | flash เต็ม: Winbox → Files ลบไฟล์ `.npk` / `.backup` เก่า แล้วรันใหม่ |
| router ไม่กลับมาหลังอัปเกรด / router ไม่กลับมาหลังถอด wireless / router ไม่กลับมาหลังติดตั้ง wifi-qcom-ac | รอ 2-3 นาที (บางครั้งรีบูตนาน) แล้วรันใหม่; ถ้าไฟไม่ขึ้นเลย ติดต่อทีม engineer |
| อัปเกรดไม่สำเร็จ | Winbox → Log ดูสาเหตุ (ส่วนใหญ่ flash ไม่พอ) ลบไฟล์เก่าใน Files แล้วรันใหม่ |
| สั่งถอด wireless ไม่ได้ / ถอด wireless ไม่สำเร็จ | Winbox → System → Packages → เลือก `wireless` → Uninstall → Reboot แล้วรันใหม่ |
| พื้นที่ flash ไม่พอ | Winbox → Files ลบไฟล์ `.npk` / `.backup` / `.rsc` เก่า แล้วรันใหม่ |
| อัปโหลด wifi-qcom-ac ไม่ได้ | เหมือนข้อ flash ไม่พอ |
| ติดตั้ง wifi-qcom-ac ไม่สำเร็จ | Winbox → New Terminal → `/system resource print` ดู free-hdd-space และดู Log แล้วส่งภาพให้ทีม engineer |
| สร้างไฟล์ config ไม่ได้ / อัปโหลด config ไม่ได้ | รันใหม่; ถ้ายังไม่ได้ ส่งข้อความ error ให้ทีม engineer |
| ping 192.168.40.1 ไม่ได้ | ถอด-เสียบสาย LAN ใหม่ แล้วลอง Winbox → Neighbors (เข้าด้วย MAC) ถ้าเข้าได้ ดู Log ว่า config หยุดตรงไหน ส่งให้ทีม engineer |

**หลังขั้น 5 แล้วอยากเริ่มใหม่:** router ไม่ใช่ default config แล้ว (เข้า `192.168.88.1` ไม่ได้)
ให้กดปุ่ม reset ค้างจนไฟกระพริบเพื่อกลับเป็น default แล้วรัน `./install.sh` ใหม่ — package ที่ติดตั้งแล้วยังอยู่ จะข้ามขั้น 3-4 ให้เอง

---

## สำหรับทีม engineer

- เปลี่ยนเวอร์ชัน RouterOS: แก้ `ROS_VERSION` ใน `version.sh` แล้วรัน `./fetch-packages.sh`
- แก้ config: แก้ `router-config.template.rsc` (ค่าเฉพาะโปรเจคใช้ `{{KEY}}`) — ถ้าเพิ่ม key ใหม่ต้องเพิ่มใน `CONF_KEYS` ใน `lib.sh` และ `projects/example.conf`
- รันเทสต์: `bash tests/run-tests.sh` (ใช้ ssh/scp/ping จำลอง ไม่ต้องมี router)
- สิ่งที่เทสต์ไม่ครอบคลุม ต้องลองกับเครื่องจริง: login ครั้งแรก, การยืนยัน reboot ผ่าน SSH, พื้นที่ flash จริง, wifi1 = 2.4GHz / wifi2 = 5GHz
