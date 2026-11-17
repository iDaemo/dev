#!/bin/bash
# รันที่ออฟฟิศ (ต้องมีอินเทอร์เน็ต) เพื่อดาวน์โหลดไฟล์ .npk เก็บไว้ใน packages/
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/version.sh"
PKG_DIR="${PKG_DIR:-$HERE/packages}"
mkdir -p "$PKG_DIR" || exit 1

for f in "$ROUTEROS_NPK" "$WIFI_NPK"; do
  if [ -s "$PKG_DIR/$f" ]; then
    echo "มีแล้ว: $f"
    continue
  fi
  echo "กำลังดาวน์โหลด $f ..."
  if curl -fL --progress-bar --retry 3 -o "$PKG_DIR/$f.part" "$DOWNLOAD_BASE/$f" && [ -s "$PKG_DIR/$f.part" ]; then
    mv "$PKG_DIR/$f.part" "$PKG_DIR/$f"
  else
    rm -f "$PKG_DIR/$f.part"
    echo "ดาวน์โหลด $f ไม่สำเร็จ — เช็คอินเทอร์เน็ตแล้วรันใหม่" >&2
    exit 1
  fi
done
echo "พร้อมแล้ว: ไฟล์ทั้งหมดอยู่ใน $PKG_DIR"
