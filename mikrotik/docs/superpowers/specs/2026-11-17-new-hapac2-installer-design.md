# new-hapac2 installer — design (short)

## Intent
ทีมติดตั้งหน้างานต้องเอา hAP ac2 ที่แกะกล่องใหม่ (default config) มาทำให้พร้อมลงโปรเจค
โดยไม่ต้องรู้ RouterOS: อัป RouterOS v7 → ติดตั้ง `wifi-qcom-ac` (ถอด `wireless`) → ลง config โปรเจค
ใช้ MacBook + สาย LAN เสียบพอร์ต ether2-5 (เข้า `192.168.88.1` ได้ตาม default config)

## Goals / non-goals
- Goal: รันคำสั่งเดียวบน Mac แล้วทำครบทุกขั้น พร้อมข้อความภาษาไทยบอกว่าอยู่ขั้นไหน รอรีบูตเอง
- Goal: ใช้ได้หน้างานแม้ไม่มีอินเทอร์เน็ต (เตรียมไฟล์ `.npk` ไว้ล่วงหน้า)
- Goal: ค่าต่อโปรเจค (ชื่อเครื่อง, SSID, รหัส WiFi, รหัส user, WireGuard IP) กรอกจากไฟล์โปรเจค ไม่ต้องแก้ `.rsc`
- Non-goal: แก้ไข logic ของ config เดิม (firewall/VLAN) — ใช้ `config/router-config.rsc` เป็นต้นแบบตามเดิม
- Anti-goal: router ค้างครึ่งทางโดยทีมไม่รู้ว่าพัง — ทุกขั้นต้องเช็คผลและหยุดพร้อมบอกวิธีแก้

## Approaches
1. **สคริปต์ bash บน Mac สั่งงานผ่าน SSH/SCP (เลือกอันนี้)** — อัตโนมัติทั้งหมด, ใช้ของที่มีใน macOS อยู่แล้ว, ทีมไม่ต้องคลิกใน Winbox
2. เช็คลิสต์ Winbox ทีละขั้น (ลากไฟล์ใส่ Files, กด reboot) — ไม่มีโค้ด แต่ผิดพลาดง่าย ช้า
3. Netinstall — สะอาดที่สุด แต่ไม่มีเวอร์ชัน macOS ต้องใช้ Windows/Linux จึงไม่เหมาะกับทีม

## Design
```
new-hapac2/
  install.sh              # ตัวหลัก ทีมรัน: ./install.sh projects/<ชื่อ>.conf
  fetch-packages.sh       # รันที่ออฟฟิศ (มีเน็ต) ดาวน์โหลด routeros + wifi-qcom-ac (arm) เวอร์ชันที่ล็อกไว้
  packages/               # เก็บ .npk (gitignored)
  router-config.template.rsc  # มาจาก config/router-config.rsc แทนค่าเฉพาะด้วย {{PLACEHOLDER}}
  projects/example.conf   # ตัวอย่างค่าโปรเจค; projects/*.conf อื่นๆ gitignored (มีรหัสผ่าน)
  README.md               # คู่มือภาษาไทยสำหรับทีม + วิธีแก้เมื่อขั้นไหนล้ม
```
ขั้นตอนใน `install.sh`:
1. เช็คว่า ping `192.168.88.1` ได้, ไฟล์ `.npk` ครบ, ไฟล์โปรเจคครบ
2. เข้า SSH ด้วย admin (ถามรหัส 1 ครั้ง — ว่างหรือตามสติกเกอร์) แล้ว import SSH key ชั่วคราว เพื่อไม่ต้องพิมพ์รหัสซ้ำหลังรีบูต
3. อ่านเวอร์ชัน/สถาปัตยกรรม; ถ้าไม่ใช่เวอร์ชันที่ล็อกไว้ → อัปโหลด routeros `.npk` → reboot → รอกลับมา
   (ถ้าเป็น v6 เก่ากว่าที่อัปตรงได้ → หยุดและบอกวิธีแก้)
4. อัปโหลด `wifi-qcom-ac` `.npk` + สั่งถอด `wireless` → reboot → รอ → ยืนยันว่ามี `/interface wifi` wifi1/wifi2
5. สร้าง `router-config.rsc` จาก template + ค่าโปรเจค → อัปโหลด → `reset-configuration no-defaults=yes run-after-reset=...`
6. รอ Mac ได้ IP วง `192.168.40.x` แล้ว ping `192.168.40.1` เพื่อยืนยันว่า config ลงสำเร็จ แจ้งผลสรุป

## Calls I made (แก้ได้)
- เวอร์ชัน RouterOS ล็อกไว้เป็นตัวแปรเดียวใน `fetch-packages.sh`/`install.sh` (ใช้ stable ล่าสุด ณ ตอนทำ)
- ไฟล์โปรเจคจริงไม่ commit ลง git เพราะมีรหัสผ่าน
- ไม่แก้ปัญหา Winbox เปิดฝั่ง WAN ในงานนี้ (ผู้ใช้เลือกแก้แค่ข้อ admin)

## Left to the builder
- คำสั่ง RouterOS v7 ที่แน่นอนสำหรับถอด package และ ชื่อ wifi1/wifi2 vs ย่านความถี่บน hAP ac2 — ต้องตรวจกับเอกสาร MikroTik ก่อนเขียน
