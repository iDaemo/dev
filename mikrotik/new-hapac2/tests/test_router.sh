router_env() { export PATH="$STUBS:$PATH" POLL_INTERVAL=0; . "$ROOT/lib.sh"; }

test_version_lt() {
  router_env; require_fn version_lt
  assert_ok   "6.48.6 < 6.49"   version_lt 6.48.6 6.49
  assert_ok   "7.9 < 7.25.1"    version_lt 7.9 7.25.1
  assert_fail "equal not lt"    version_lt 7.25.1 7.25.1
  assert_fail "7.25.1 !< 6.49"  version_lt 7.25.1 6.49
  assert_ok   "6.49 < 7.0"      version_lt 6.49 7.0
}
test_ros_version_parse() {
  router_env; require_fn ros_version
  printf 'respond() { printf "7.25.1 (stable)\\r\\n"; }\n' > "$T/r.sh"; export STUB_SSH_RESPONDER="$T/r.sh"
  assert_eq "7.25.1" "$(ros_version)" "version parsed"
}
test_ros_cmd_runs_over_ssh() {
  router_env; require_fn ros_cmd
  ros_cmd '/system package print' || exit 1
  assert_contains "$(cat "$STUB_LOG")" "ssh /system package print" "command logged"
}
test_ros_upload() {
  router_env; require_fn ros_upload
  echo x > "$T/a.npk"; ros_upload "$T/a.npk" a.npk || exit 1
  assert_contains "$(cat "$STUB_LOG")" "scp a.npk admin@192.168.88.1:a.npk" "scp target"
}
test_wait_up_timeout() {
  router_env; require_fn wait_up
  export STUB_PING_SEQ="down"
  start=$SECONDS; POLL_INTERVAL=1 wait_up 192.168.88.1 3 && exit 1
  [ $((SECONDS-start)) -le 5 ] || { echo "    took too long"; exit 1; }
}
test_wait_up_requires_ssh() {
  router_env; require_fn wait_up
  export STUB_PING_SEQ="up"
  printf 'respond() { return 255; }\n' > "$T/r.sh"; export STUB_SSH_RESPONDER="$T/r.sh"
  REQUIRE_SSH=1 POLL_INTERVAL=1 wait_up 192.168.88.1 2 && exit 1; true
}
test_ros_reboot_waits() {
  router_env; require_fn ros_reboot
  export STUB_PING_SEQ="up down down up"
  REQUIRE_SSH=0 TIMEOUT_DOWN=5 TIMEOUT_UP=5 ros_reboot >/dev/null || exit 1
  log="$(cat "$STUB_LOG")"
  assert_contains "$log" "ssh /system reboot" "reboot sent"
  assert_eq "4" "$(grep -c '^ping' "$STUB_LOG")" "pinged down then up"
}
test_ros_reboot_timeout_fails() {
  router_env; require_fn ros_reboot
  export STUB_PING_SEQ="down"
  REQUIRE_SSH=0 TIMEOUT_DOWN=2 TIMEOUT_UP=2 POLL_INTERVAL=1 ros_reboot >/dev/null 2>&1 && exit 1; true
}
