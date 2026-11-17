# helper: write a valid conf to $T/p.conf, with optional KEY=VALUE overrides
write_conf() {
  cat > "$T/p.conf" <<C
# comment line
IDENTITY=Raynue
SSID=@CONTROLsonosxaura
WIFI_PASS=wifipass123
USER_NAME=sonos
USER_PASS=userpass123
WG_ADDRESS=10.0.0.40/24
C
  for kv in "$@"; do
    k="${kv%%=*}"; grep -v "^$k=" "$T/p.conf" > "$T/p.tmp"; echo "$kv" >> "$T/p.tmp"; mv "$T/p.tmp" "$T/p.conf"
  done
}
validate_with() { ( . "$ROOT/lib.sh"; type validate_conf >/dev/null 2>&1 || exit 0; write_conf "$@"; load_conf "$T/p.conf" && validate_conf ); }

test_load_example_conf() {
  . "$ROOT/lib.sh"
  load_conf "$ROOT/projects/example.conf" || exit 1
  assert_eq "Raynue" "$IDENTITY" "IDENTITY"
  assert_eq "@CONTROLsonosxaura" "$SSID" "SSID"
  assert_eq "sonos" "$USER_NAME" "USER_NAME"
  assert_eq "10.0.0.40/24" "$WG_ADDRESS" "WG_ADDRESS"
}
test_load_missing_file_fails() { . "$ROOT/lib.sh"; require_fn load_conf; assert_fail "missing conf" load_conf "$T/nope.conf"; }
test_validate_ok()                { assert_ok   "valid conf" validate_with; }
test_validate_example_rejected()  { . "$ROOT/lib.sh"; require_fn load_conf validate_conf; load_conf "$ROOT/projects/example.conf"; assert_fail "CHANGE_ME passwords" validate_conf; }
test_validate_short_wifi_pass()   { assert_fail "7 chars" validate_with WIFI_PASS=1234567; }
test_validate_long_wifi_pass()    { assert_fail "64 chars" validate_with WIFI_PASS=1234567890123456789012345678901234567890123456789012345678901234; }
test_validate_short_user_pass()   { assert_fail "user pass 7" validate_with USER_PASS=1234567; }
test_validate_quote_in_ssid()     { assert_fail "quote" validate_with 'SSID=ab"cd'; }
test_validate_dollar_in_pass()    { assert_fail "dollar" validate_with 'WIFI_PASS=abc$defgh'; }
test_validate_slash_in_ssid()     { assert_fail "slash" validate_with 'SSID=a/b'; }
test_validate_bad_wg_address()    { assert_fail "no prefix" validate_with WG_ADDRESS=10.0.0.40; }
test_validate_bad_identity()      { assert_fail "space in identity" validate_with 'IDENTITY=Ray nue'; }
test_validate_missing_key()       { ( . "$ROOT/lib.sh"; type validate_conf >/dev/null 2>&1 || exit 0; write_conf; grep -v '^SSID=' "$T/p.conf" > "$T/q.conf"; load_conf "$T/q.conf" && validate_conf ) && exit 1; true; }
test_validate_message_names_key() {
  out="$(validate_with WIFI_PASS=short 2>&1)"
  assert_contains "$out" "WIFI_PASS" "message names key"
}
test_render_replaces_all() {
  . "$ROOT/lib.sh"; write_conf; load_conf "$T/p.conf"
  render_config "$ROOT/router-config.template.rsc" "$T/out.rsc" || exit 1
  out="$(cat "$T/out.rsc")"
  assert_not_contains "$out" "{{" "no placeholders left"
  assert_contains "$out" 'ssid="@CONTROLsonosxaura"' "ssid quoted"
  assert_contains "$out" "/system identity set name=Raynue" "identity"
  assert_contains "$out" 'passphrase="wifipass123"' "wifi pass"
  assert_contains "$out" "address=10.0.0.40/24 interface=wireguard1" "wg"
  assert_contains "$out" '/user add name=sonos group=full password="userpass123"' "user"
  assert_contains "$out" "/user remove [find name=admin]" "admin removed"
}
test_render_unknown_placeholder_fails() {
  . "$ROOT/lib.sh"; require_fn render_config; write_conf; load_conf "$T/p.conf"
  echo '/system identity set name={{FOO}}' > "$T/tpl.rsc"
  assert_fail "unknown placeholder" render_config "$T/tpl.rsc" "$T/out.rsc"
}
