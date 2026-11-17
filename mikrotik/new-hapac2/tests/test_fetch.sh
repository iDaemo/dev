test_fetch_downloads_both_packages() {
  PATH="$STUBS:$PATH" PKG_DIR="$T/packages" bash "$ROOT/fetch-packages.sh" >/dev/null || exit 1
  assert_ok "routeros npk exists" test -s "$T/packages/routeros-7.25.1-arm.npk"
  assert_ok "wifi npk exists" test -s "$T/packages/wifi-qcom-ac-7.25.1-arm.npk"
  assert_contains "$(cat "$STUB_LOG")" "https://download.mikrotik.com/routeros/7.25.1/wifi-qcom-ac-7.25.1-arm.npk" "wifi url"
}
test_fetch_skips_existing() {
  PATH="$STUBS:$PATH" PKG_DIR="$T/packages" bash "$ROOT/fetch-packages.sh" >/dev/null || exit 1
  : > "$STUB_LOG"
  PATH="$STUBS:$PATH" PKG_DIR="$T/packages" bash "$ROOT/fetch-packages.sh" >/dev/null || exit 1
  assert_eq "" "$(cat "$STUB_LOG")" "no curl on second run"
}
