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
