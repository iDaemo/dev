#!/bin/bash
# ติดตั้ง hAP ac2 เครื่องใหม่ให้พร้อมลงโปรเจค
# ใช้: ./install.sh projects/<ชื่อไซต์>.conf
# ต่อสาย LAN จาก MacBook เข้า ether2-ether5 ของ router ที่ยังเป็น default config
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/version.sh"
. "$HERE/lib.sh"

PKG_DIR="${PKG_DIR:-$HERE/packages}"
CONFIG_IP="${CONFIG_IP:-192.168.40.1}"
TIMEOUT_CONFIG="${TIMEOUT_CONFIG:-300}"
WIFI_WAIT="${WIFI_WAIT:-60}"
# kept between runs: once a key is imported RouterOS refuses admin password login over SSH
INSTALLER_KEY="${INSTALLER_KEY:-$HERE/.installer_key/installer}"
MIN_V6="6.49"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

step() { echo; echo "[ขั้น $1/6] $2"; }
die()  { err "$1"; [ -n "${2:-}" ] && echo "   วิธีแก้: $2" >&2; echo "   (รัน ./install.sh ซ้ำได้ — ขั้นที่ทำเสร็จแล้วจะถูกข้าม)" >&2; exit 1; }
trim() { local v="$1"; v="${v%%$'\r'*}"; echo "${v//[[:space:]]/}"; }
has_pkg()   { [ "$(trim "$(ros_cmd ":put [:len [/system package find name=$1]]")")" = 1 ]; }
has_iface() { [ "$(trim "$(ros_cmd ":put [:len [/interface wifi find name=$1]]")")" = 1 ]; }

# ---------------------------------------------------------------- 1. preflight
preflight() {
  step 1 "ตรวจไฟล์และการเชื่อมต่อ"
  [ $# -eq 1 ] || die "ต้องระบุไฟล์โปรเจค" "./install.sh projects/<ชื่อไซต์>.conf"
  load_conf "$1" || die "อ่านไฟล์โปรเจคไม่ได้" "เช็คชื่อไฟล์ หรือ copy จาก projects/example.conf"
  validate_conf || die "ค่าในไฟล์โปรเจคไม่ถูกต้อง" "แก้ค่าตามข้อความด้านบนใน $1"
  local f
  for f in "$ROUTEROS_NPK" "$WIFI_NPK"; do
    [ -s "$PKG_DIR/$f" ] || die "ไม่พบไฟล์ $f ใน $PKG_DIR" "รัน ./fetch-packages.sh ที่ออฟฟิศ (ต้องมีเน็ต) ก่อนออกหน้างาน"
  done
  BIND_IF="$(route_if "$ROUTER_IP")"
  if [ -n "$BIND_IF" ] && [ "$BIND_IF" = "$(wifi_dev)" ]; then
    die "Mac กำลังต่อ $ROUTER_IP ผ่าน WiFi ไม่ใช่สาย LAN" "ปิด WiFi ของ Mac (มุมขวาบน) แล้วรันใหม่"
  fi
  export BIND_IF
  ping_ok "$ROUTER_IP" || die "ping $ROUTER_IP ไม่ได้" "เสียบสาย LAN ที่ ether2-ether5 และเช็คว่า Mac ได้ IP 192.168.88.x (router ต้องเป็น default config)"
  echo "   โปรเจค: $IDENTITY  |  WiFi: $SSID"
  if [ "${ASSUME_YES:-0}" != 1 ]; then
    echo "   ⚠️  config เดิมใน router จะถูกล้างทั้งหมด"
    printf "   กด Enter เพื่อเริ่ม หรือ Ctrl+C เพื่อยกเลิก "; read -r _
  fi
}

# ---------------------------------------------------------------- 2. login
login() {
  step 2 "เข้าสู่ระบบ router"
  if [ -s "$INSTALLER_KEY" ] && SSH_KEY="$INSTALLER_KEY" ros_cmd ':put ok' >/dev/null 2>&1; then
    SSH_KEY="$INSTALLER_KEY"; echo "   ✅ เข้าระบบด้วย key เดิม (รันซ้ำ)"; return
  fi
  if [ ! -s "$INSTALLER_KEY" ]; then
    mkdir -p "$(dirname "$INSTALLER_KEY")" && rm -f "$INSTALLER_KEY.pub" \
      && ssh-keygen -q -t rsa -b 2048 -N "" -f "$INSTALLER_KEY" >/dev/null || die "สร้าง SSH key ไม่ได้"
  fi
  echo "   ใส่รหัส admin (เครื่องใหม่: ดูที่สติกเกอร์ใต้เครื่อง หรือกด Enter ถ้าไม่มีรหัส)"
  SSH_KEY=""; SSH_CTL="$WORK/ctl"
  # shellcheck disable=SC2046
  ssh $(ssh_opts) -o ControlMaster=yes -o ControlPersist=120 -N -f "$ROUTER_USER@$ROUTER_IP" \
    || die "login ไม่สำเร็จ" "เช็ครหัส admin; ถ้าลืม ให้กดปุ่ม reset ค้างจนไฟกระพริบเพื่อกลับเป็น default"
  ros_upload "$INSTALLER_KEY.pub" installer.pub || die "อัปโหลด SSH key ไม่ได้"
  ros_cmd "/user ssh-keys import public-key-file=installer.pub user=$ROUTER_USER" >/dev/null \
    || die "import SSH key ไม่ได้"
  # shellcheck disable=SC2046
  ssh $(ssh_opts) -O exit "$ROUTER_USER@$ROUTER_IP" >/dev/null 2>&1
  SSH_CTL=""; SSH_KEY="$INSTALLER_KEY"
  ros_cmd ':put ok' >/dev/null || die "login ด้วย SSH key ไม่ได้"
  echo "   ✅ เข้าระบบแล้ว"
}

# ---------------------------------------------------------------- 3. RouterOS version
upgrade_routeros() {
  step 3 "ตรวจเวอร์ชัน RouterOS (ต้องเป็น $ROS_VERSION)"
  local v; v="$(ros_version)" || die "อ่านเวอร์ชันไม่ได้"
  echo "   เวอร์ชันตอนนี้: $v"
  if version_lt "$v" "$MIN_V6"; then
    die "RouterOS $v เก่าเกินไป อัปตรงเป็น v7 ไม่ได้" \
        "ใน Winbox ไปที่ System > Packages > Check For Updates เลือก channel long-term แล้วอัปเป็น $MIN_V6 ขึ้นไปก่อน แล้วรันใหม่"
  fi
  [ "$v" = "$ROS_VERSION" ] && { echo "   ✅ เวอร์ชันถูกต้องแล้ว ข้าม"; return; }
  echo "   อัปโหลด $ROUTEROS_NPK ..."
  ros_upload "$PKG_DIR/$ROUTEROS_NPK" "$ROUTEROS_NPK" || die "อัปโหลดไฟล์ RouterOS ไม่ได้"
  ros_reboot || die "router ไม่กลับมาหลังอัปเกรด" "รอ 2-3 นาทีแล้วรันใหม่; ถ้าไฟไม่ขึ้นเลยให้ติดต่อทีม engineer"
  v="$(ros_version)"
  [ "$v" = "$ROS_VERSION" ] || die "อัปเกรดไม่สำเร็จ (ยังเป็น $v)" "ใน Winbox เปิด Log ดูสาเหตุ (มักเป็นพื้นที่ flash ไม่พอ)"
  echo "   ✅ อัปเกรดเป็น $v แล้ว"
}

# ---------------------------------------------------------------- 4. wifi-qcom-ac
install_wifi() {
  step 4 "ติดตั้ง wifi-qcom-ac"
  if has_pkg wireless; then
    echo "   ถอด package wireless เดิม (flash ไม่พอให้มีทั้งสองตัว)"
    ros_cmd "/system package uninstall wireless" >/dev/null || die "สั่งถอด wireless ไม่ได้"
    ros_reboot || die "router ไม่กลับมาหลังถอด wireless" "รอ 2-3 นาทีแล้วรันใหม่"
    has_pkg wireless && die "ถอด wireless ไม่สำเร็จ" "ใน Winbox: System > Packages เลือก wireless กด Uninstall แล้ว Reboot"
  fi
  if ! has_pkg wifi-qcom-ac; then
    local free need
    free="$(trim "$(ros_cmd ':put [/system resource get free-hdd-space]')")"
    need=$(( $(wc -c < "$PKG_DIR/$WIFI_NPK") + 262144 ))
    if [ "${free:-0}" -lt "$need" ] 2>/dev/null; then
      die "พื้นที่ flash ไม่พอ (เหลือ $free bytes ต้องการ $need)" "ใน Winbox: Files ลบไฟล์ .npk/.backup เก่าทิ้ง แล้วรันใหม่"
    fi
    echo "   อัปโหลด $WIFI_NPK ..."
    ros_upload "$PKG_DIR/$WIFI_NPK" "$WIFI_NPK" || die "อัปโหลด wifi-qcom-ac ไม่ได้"
    ros_reboot || die "router ไม่กลับมาหลังติดตั้ง wifi-qcom-ac" "รอ 2-3 นาทีแล้วรันใหม่"
  fi
  # wifi interfaces appear some seconds after SSH is already up
  local end=$((SECONDS + WIFI_WAIT))
  until has_pkg wifi-qcom-ac && has_iface wifi1 && has_iface wifi2; do
    [ $SECONDS -ge $end ] && die "ติดตั้ง wifi-qcom-ac ไม่สำเร็จ (ไม่เจอ wifi1/wifi2)" \
        "ใน Winbox: New Terminal พิมพ์ /system resource print ดู free-hdd-space และดู Log แล้วส่งให้ทีม engineer"
    sleep "$POLL_INTERVAL"
  done
  echo "   ✅ wifi-qcom-ac พร้อม (wifi1, wifi2)"
}

# ---------------------------------------------------------------- 5. config
apply_config() {
  step 5 "ลง config โปรเจค ($IDENTITY)"
  render_config "$HERE/router-config.template.rsc" "$WORK/router-config.rsc" || die "สร้างไฟล์ config ไม่ได้"
  ros_upload "$WORK/router-config.rsc" router-config.rsc || die "อัปโหลด config ไม่ได้"
  echo "   ล้าง config แล้วรีบูตพร้อม config ใหม่ ..."
  echo y | ros_cmd "/system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=router-config.rsc" >/dev/null 2>&1
  wait_down "$ROUTER_IP" "$TIMEOUT_DOWN" \
    || die "router ไม่ยอมล้าง config" "รันใหม่อีกครั้ง; ถ้ายังไม่ได้ ใน Winbox ดู Files ว่ามี router-config.rsc และดู Log แล้วส่งให้ทีม engineer"
}

# ---------------------------------------------------------------- 6. verify
verify() {
  step 6 "ตรวจผล"
  echo "   รอ router รีบูต แล้ว ถอดสาย LAN ออกแล้วเสียบใหม่ เพื่อให้ Mac ได้ IP วง 192.168.40.x"
  echo "   (รอได้ถึง $TIMEOUT_CONFIG วินาที)"
  REQUIRE_SSH=0 wait_up "$CONFIG_IP" "$TIMEOUT_CONFIG" \
    || die "ping $CONFIG_IP ไม่ได้" "ถอด-เสียบสาย LAN ใหม่ แล้วเปิด Winbox เข้า $CONFIG_IP; ถ้าไม่ได้ให้ดู Log ใน Winbox (Neighbors > MAC) — config อาจหยุดกลางทาง"
  echo
  echo "✅ เสร็จแล้ว"
  echo "   ชื่อเครื่อง : $IDENTITY"
  echo "   WiFi        : $SSID"
  echo "   Winbox      : $CONFIG_IP  user: $USER_NAME  (SSH ปิดไว้ ใช้ Winbox เท่านั้น)"
}

main() {
  preflight "$@"
  login
  upgrade_routeros
  install_wifi
  apply_config
  verify
}
main "$@"
