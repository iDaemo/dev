# Shared functions for install.sh. Pure bash 3.2 (macOS stock).

CONF_KEYS="IDENTITY SSID WIFI_PASS USER_NAME USER_PASS WG_ADDRESS"

err() { echo "❌ $*" >&2; }

# load_conf <file> : parse KEY=VALUE lines (no `source`, so the file cannot run code)
load_conf() {
  local file="$1" line key val
  if [ ! -f "$file" ]; then err "ไม่พบไฟล์โปรเจค: $file"; return 1; fi
  for key in $CONF_KEYS; do eval "$key=''"; done
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    case "$line" in ''|'#'*) continue;; *=*) ;; *) continue;; esac
    key="${line%%=*}"; val="${line#*=}"
    case " $CONF_KEYS " in *" $key "*) printf -v "$key" '%s' "$val";; esac
  done < "$file"
  return 0
}

# validate_conf : check values loaded by load_conf; prints Thai message naming the bad key
validate_conf() {
  local key val ok=0
  for key in $CONF_KEYS; do
    eval "val=\"\$$key\""
    if [ -z "$val" ]; then err "ไฟล์โปรเจคไม่มีค่า $key"; ok=1; continue; fi
    case "$val" in *CHANGE_ME*) err "$key ยังเป็นค่าตัวอย่าง (CHANGE_ME) — ใส่ค่าจริงก่อน"; ok=1; continue;; esac
    case "$val" in *'"'*|*'\'*|*'$'*|*'&'*|*'|'*|*'{'*|*'}'*)
      err "$key มีตัวอักษรที่ห้ามใช้ ( \" \\ \$ & | { } )"; ok=1; continue;; esac
    if [ "$key" != WG_ADDRESS ]; then
      case "$val" in */*) err "$key ห้ามมีตัว /"; ok=1; continue;; esac
    fi
  done
  if [ -n "$WIFI_PASS" ] && { [ ${#WIFI_PASS} -lt 8 ] || [ ${#WIFI_PASS} -gt 63 ]; }; then
    err "WIFI_PASS ต้องยาว 8-63 ตัว (ตอนนี้ ${#WIFI_PASS} ตัว)"; ok=1; fi
  if [ -n "$SSID" ] && [ "$(printf %s "$SSID" | LC_ALL=C wc -c | tr -d ' ')" -gt 32 ]; then
    err "SSID ยาวเกิน 32 bytes (ภาษาไทย 1 ตัว = 3 bytes)"; ok=1; fi
  if [ -n "$WIFI_PASS" ] && printf %s "$WIFI_PASS" | LC_ALL=C grep -q '[^ -~]'; then
    err "WIFI_PASS ต้องเป็นภาษาอังกฤษ/ตัวเลข/สัญลักษณ์เท่านั้น (ห้ามภาษาไทย)"; ok=1; fi
  if [ -n "$USER_PASS" ] && [ ${#USER_PASS} -lt 8 ]; then
    err "USER_PASS ต้องยาวอย่างน้อย 8 ตัว"; ok=1; fi
  if [ -n "$IDENTITY" ] && ! echo "$IDENTITY" | grep -Eq '^[A-Za-z0-9_-]+$'; then
    err "IDENTITY ใช้ได้แค่ A-Z a-z 0-9 _ - (ห้ามเว้นวรรค)"; ok=1; fi
  if [ -n "$USER_NAME" ] && ! echo "$USER_NAME" | grep -Eq '^[A-Za-z0-9_-]+$'; then
    err "USER_NAME ใช้ได้แค่ A-Z a-z 0-9 _ -"; ok=1; fi
  if [ -n "$WG_ADDRESS" ] && ! echo "$WG_ADDRESS" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$'; then
    err "WG_ADDRESS ต้องเป็นแบบ 10.0.0.40/24"; ok=1; fi
  return $ok
}

# render_config <template> <out> : replace {{KEY}} with loaded values
render_config() {
  local tpl="$1" out="$2" key val
  cp "$tpl" "$out.tmp" || return 1
  for key in $CONF_KEYS; do
    eval "val=\"\$$key\""
    # values are validated (no | & \ " $), so they are safe as sed replacement text
    sed "s|{{$key}}|$val|g" "$out.tmp" > "$out.tmp2" && mv "$out.tmp2" "$out.tmp" || { rm -f "$out.tmp" "$out.tmp2"; return 1; }
  done
  mv "$out.tmp" "$out"
  if grep -q '{{' "$out"; then
    err "template ยังมี placeholder ที่ไม่รู้จัก: $(grep -o '{{[A-Z_]*}}' "$out" | sort -u | tr '\n' ' ')"
    return 1
  fi
}

# ---------------------------------------------------------------- router I/O
ROUTER_IP="${ROUTER_IP:-192.168.88.1}"
ROUTER_USER="${ROUTER_USER:-admin}"
POLL_INTERVAL="${POLL_INTERVAL:-2}"
TIMEOUT_DOWN="${TIMEOUT_DOWN:-60}"
TIMEOUT_UP="${TIMEOUT_UP:-240}"
REQUIRE_SSH="${REQUIRE_SSH:-1}"
SSH_KEY="${SSH_KEY:-}"     # set by install.sh after the key is imported
SSH_CTL="${SSH_CTL:-}"     # ControlPath for the first password login

ssh_opts() {
  echo "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
  echo "-o ConnectTimeout=5 -o ServerAliveInterval=5 -o ServerAliveCountMax=3"
  echo "-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"
  [ -n "$SSH_KEY" ] && echo "-i $SSH_KEY -o BatchMode=yes"
  [ -n "$SSH_CTL" ] && echo "-o ControlPath=$SSH_CTL"
}

# ros_cmd "<routeros command>" : run on router, stdout passes through
ros_cmd() {
  # shellcheck disable=SC2046
  ssh $(ssh_opts) "$ROUTER_USER@$ROUTER_IP" "$1"
}

# ros_upload <local> <remote-name>
ros_upload() {
  # shellcheck disable=SC2046
  scp -q $(ssh_opts) "$1" "$ROUTER_USER@$ROUTER_IP:$2"
}

# ros_version : prints e.g. 7.25.1
ros_version() {
  local v
  v="$(ros_cmd ':put [/system resource get version]')" || return 1
  v="${v%%$'\r'*}"; echo "${v%% *}"
}

# version_lt <a> <b> : true if a < b (dotted numeric)
version_lt() {
  local a="$1" b="$2" i x y
  for i in 1 2 3 4; do
    x="$(echo "$a" | cut -d. -f$i | tr -cd '0-9')"; y="$(echo "$b" | cut -d. -f$i | tr -cd '0-9')"
    x="${x:-0}"; y="${y:-0}"
    [ "$x" -lt "$y" ] && return 0
    [ "$x" -gt "$y" ] && return 1
  done
  return 1
}

# ping_ok <ip> : one ping; bound to $BIND_IF (the wired port) when set
ping_ok() {
  if [ -n "${BIND_IF:-}" ]; then ping -c1 -t1 -b "$BIND_IF" "$1" >/dev/null 2>&1
  else ping -c1 -t1 "$1" >/dev/null 2>&1; fi
}

# route_if <ip> : Mac interface used to reach ip (e.g. en7)
route_if() { route -n get "$1" 2>/dev/null | awk '/interface:/{print $2}'; }

# wifi_dev : Mac Wi-Fi device name (e.g. en0)
wifi_dev() { networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: Wi-Fi/{getline; print $2}'; }

# wait_down <ip> <timeout_s>
wait_down() {
  local end=$((SECONDS + $2))
  while ping_ok "$1"; do
    [ $SECONDS -ge $end ] && return 1
    sleep "$POLL_INTERVAL"
  done
}

# wait_up <ip> <timeout_s> : ping (and ssh when REQUIRE_SSH=1) must answer
wait_up() {
  local end=$((SECONDS + $2))
  while :; do
    if ping_ok "$1"; then
      [ "$REQUIRE_SSH" != 1 ] && return 0
      ros_cmd ':put ok' >/dev/null 2>&1 && return 0
    fi
    [ $SECONDS -ge $end ] && return 1
    sleep "$POLL_INTERVAL"
  done
}

# ros_reboot : reboot and wait until the router answers again
ros_reboot() {
  echo "   รีบูต router ... (รอได้ถึง $((TIMEOUT_DOWN + TIMEOUT_UP)) วินาที ห้ามถอดปลั๊ก)"
  echo y | ros_cmd '/system reboot' >/dev/null 2>&1
  if ! wait_down "$ROUTER_IP" "$TIMEOUT_DOWN"; then err "router ไม่ยอมรีบูต"; return 1; fi
  if ! wait_up "$ROUTER_IP" "$TIMEOUT_UP"; then err "router ไม่กลับมาหลังรีบูต (รอ $TIMEOUT_UP วินาที)"; return 1; fi
  echo "   router กลับมาแล้ว"
}
