# Simulated router: state lives in $T/sim/{version,pkgs,uploaded,pending_uninstall}
sim_router() { # <version> <pkg...>
  mkdir -p "$T/sim"; echo "$1" > "$T/sim/version"; shift
  : > "$T/sim/pkgs"; for p in "$@"; do echo "$p" >> "$T/sim/pkgs"; done
  : > "$T/sim/uploaded"
  cat > "$T/sim/responder.sh" <<'R'
S="$T/sim"
has() { grep -qx "$1" "$S/pkgs"; }
respond() {
  case "$1" in
    *"resource get version"*) printf '%s (stable)\r\n' "$(cat "$S/version")";;
    *"resource get free-hdd-space"*) echo "${SIM_FREE:-5000000}";;
    *"package find name="*) n="${1#*name=}"; n="${n%%]*}"; if has "$n"; then echo 1; else echo 0; fi;;
    *"package uninstall wireless"*) touch "$S/pending_uninstall";;
    *"interface wifi find name="*) if has wifi-qcom-ac; then echo 1; else echo 0; fi;;
    "/system reboot")
      touch "$S/down"
      [ -f "$S/pending_uninstall" ] && { grep -vx wireless "$S/pkgs" > "$S/p2"; mv "$S/p2" "$S/pkgs"; rm "$S/pending_uninstall"; }
      grep -q '^routeros-' "$S/uploaded" && grep '^routeros-' "$S/uploaded" | sed 's/^routeros-\(.*\)-arm.npk$/\1/' | head -1 > "$S/version"
      grep -q '^wifi-qcom-ac-' "$S/uploaded" && ! has wireless && echo wifi-qcom-ac >> "$S/pkgs"
      : > "$S/uploaded";;
  esac
  return 0
}
R
  # scp stub logs uploads; mirror them into the sim
  cat > "$T/bin_scp" <<'R'
#!/bin/bash
dst="${!#}"; echo "${dst#*:}" >> "$T/sim/uploaded"; exec "$STUBS/scp" "$@"
R
  mkdir -p "$T/bin"; mv "$T/bin_scp" "$T/bin/scp"; chmod +x "$T/bin/scp"
  # ping: down exactly once after each reboot, otherwise up
  cat > "$T/bin/ping" <<'R'
#!/bin/bash
echo "ping ${!#}" >> "$STUB_LOG"
if [ -f "$T/sim/down" ]; then rm "$T/sim/down"; exit 2; fi
exit 0
R
  chmod +x "$T/bin/ping"
  export STUB_SSH_RESPONDER="$T/sim/responder.sh"
}
install_env() {
  mkdir -p "$T/packages"; echo fake > "$T/packages/routeros-7.25.1-arm.npk"; echo fake > "$T/packages/wifi-qcom-ac-7.25.1-arm.npk"
  sed 's/CHANGE_ME_8chars/goodpass123/' "$ROOT/projects/example.conf" > "$T/site.conf"
  export PATH="$T/bin:$STUBS:$PATH" PKG_DIR="$T/packages" POLL_INTERVAL=0 TIMEOUT_DOWN=3 TIMEOUT_UP=3 TIMEOUT_CONFIG=3 ASSUME_YES=1
}
run_install() { bash "$ROOT/install.sh" "$T/site.conf" > "$T/out.txt" 2>&1; }

test_install_stops_without_npk() {
  install_env; sim_router 7.25.1 wireless; rm "$T/packages/wifi-qcom-ac-7.25.1-arm.npk"
  run_install && exit 1
  assert_not_contains "$(cat "$STUB_LOG" 2>/dev/null)" "ssh " "no ssh before preflight passes"
  assert_contains "$(cat "$T/out.txt")" "fetch-packages.sh" "tells team what to run"
}
test_install_stops_on_bad_conf() {
  install_env; sim_router 7.25.1 wireless; echo "WIFI_PASS=short" >> "$T/site.conf"
  run_install && exit 1
  assert_not_contains "$(cat "$STUB_LOG" 2>/dev/null)" "ssh " "no ssh with bad conf"
  assert_contains "$(cat "$T/out.txt")" "WIFI_PASS" "names the bad key"
}
test_install_stops_on_v6_old() {
  install_env; sim_router 6.45.9 wireless
  run_install && exit 1
  assert_not_contains "$(cat "$STUB_LOG")" "scp routeros" "no upgrade upload"
  assert_contains "$(cat "$T/out.txt")" "6.49" "says upgrade v6 first"
}
test_install_full_flow_from_v7_with_wireless() {
  install_env; sim_router 7.20.4 wireless
  run_install || { cat "$T/out.txt"; exit 1; }
  seq="$(grep -E 'scp (routeros|wifi|router-config)|/system reboot|uninstall wireless|reset-configuration' "$STUB_LOG" | sed 's/^ssh //' | tr '\n' ';')"
  assert_eq "scp routeros-7.25.1-arm.npk admin@192.168.88.1:routeros-7.25.1-arm.npk;/system reboot;/system package uninstall wireless;/system reboot;scp wifi-qcom-ac-7.25.1-arm.npk admin@192.168.88.1:wifi-qcom-ac-7.25.1-arm.npk;/system reboot;scp router-config.rsc admin@192.168.88.1:router-config.rsc;/system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=router-config.rsc;" "$seq" "step order"
}
test_install_skips_done_steps() {
  install_env; sim_router 7.25.1 wifi-qcom-ac
  run_install || { cat "$T/out.txt"; exit 1; }
  log="$(cat "$STUB_LOG")"
  assert_not_contains "$log" "/system reboot" "no reboot needed"
  assert_not_contains "$log" "scp routeros" "no upgrade"
  assert_contains "$log" "reset-configuration" "config applied"
}
test_install_stops_when_wifi_missing_after_install() {
  install_env; sim_router 7.25.1 wireless
  # wifi package never appears: drop it from uploads
  sed -i '' 's/echo wifi-qcom-ac >> "$S\/pkgs"/true/' "$T/sim/responder.sh"
  run_install && exit 1
  assert_not_contains "$(cat "$STUB_LOG")" "reset-configuration" "config not applied"
  assert_contains "$(cat "$T/out.txt")" "free-hdd-space" "points at flash space"
}
test_install_stops_on_low_flash() {
  install_env; sim_router 7.25.1 wireless; export SIM_FREE=100000
  run_install && exit 1
  assert_not_contains "$(cat "$STUB_LOG")" "scp wifi-qcom-ac" "no wifi upload"
  assert_contains "$(cat "$T/out.txt")" "พื้นที่ flash ไม่พอ" "says flash is low"
}
test_install_imports_ssh_key() {
  install_env; sim_router 7.25.1 wifi-qcom-ac
  run_install || exit 1
  assert_contains "$(cat "$STUB_LOG")" "/user ssh-keys import public-key-file=installer.pub user=admin" "key imported"
}
