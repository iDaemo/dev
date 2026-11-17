# new-hapac2 Installer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** One command on a MacBook takes a factory-default hAP ac2 to a project-ready router (RouterOS 7.25.1 + wifi-qcom-ac + project config).

**Architecture:** `install.sh` (orchestrator) sources `lib.sh` (pure, testable functions: config parsing/validation, template rendering, version compare, router helpers that call `ssh`/`scp`). Tests are plain bash in `tests/run-tests.sh`; router I/O is tested by putting stub `ssh`/`scp`/`ping` on `PATH`.

**Tech Stack:** macOS stock bash 3.2, OpenSSH, curl, sed. No extra installs.

**Spec:** `docs/superpowers/specs/2026-11-17-new-hapac2-installer-design.md`

## Global Constraints

- Must run on macOS stock `/bin/bash` 3.2: no associative arrays, no `${v,,}`, no `mapfile`.
- RouterOS version pinned in one place: `ROS_VERSION=7.25.1` in `new-hapac2/version.sh`, sourced by both scripts.
- Package files: `routeros-${ROS_VERSION}-arm.npk`, `wifi-qcom-ac-${ROS_VERSION}-arm.npk` from `https://download.mikrotik.com/routeros/${ROS_VERSION}/`.
- Router default address `192.168.88.1`, user `admin`; after config: `192.168.40.1`, SSH disabled (so final check is ping only).
- hAP ac2 flash is ~16 MB: `wireless` must be uninstalled + reboot **before** uploading `wifi-qcom-ac`. Order: upgrade RouterOS (if needed) → `/system package uninstall wireless` + reboot → upload wifi-qcom-ac + reboot → reset with config.
- Interface mapping: wifi1 = 2.4 GHz, wifi2 = 5 GHz (forum-reported for hAP ac2 with wifi-qcom-ac); verify after package install.
- All user-facing messages in Thai. Each failure prints what failed + what to do, exits non-zero.
- `projects/*.conf` gitignored except `projects/example.conf`; `packages/` gitignored.
- SSH options for every call: `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa` (host key changes on reset; v6 units only speak ssh-rsa). Temp RSA key in `$(mktemp -d)`, imported once so later steps need no password.

## Review Focus

1. Project conf with WiFi passphrase < 8 chars or > 63 → RouterOS rejects mid-script and leaves a half-configured router; must be rejected before touching the router.
2. Value containing `"`, `\`, `$`, `&`, `|` or `/` → breaks sed rendering or the `.rsc` quoting; must be rejected by validation.
3. Router still on v6 below 6.49 → upload of v7 npk may not boot cleanly; must stop with a Thai message to upgrade v6 first.
4. Router doesn't come back after reboot within timeout (240 s) → must stop with a clear message, not hang forever.
5. Missing `.npk` in `packages/` (team forgot `fetch-packages.sh`) → must stop before connecting to the router.

---

### Task 1: Scaffolding, version pin, fetch-packages.sh

**Files:**
- Create: `new-hapac2/version.sh`, `new-hapac2/fetch-packages.sh`, `new-hapac2/.gitignore`, `new-hapac2/tests/run-tests.sh`, `new-hapac2/tests/stubs/curl`

**Interfaces:**
- Produces: `ROS_VERSION`, `ROUTEROS_NPK`, `WIFI_NPK` (file names) from `version.sh`; test runner with `assert_eq <expected> <actual> <name>`, `assert_fail <name> <cmd...>`, `assert_ok <name> <cmd...>`; exits 1 if any failed, prints `PASS n / FAIL m`.

- [ ] Step 1: Write test `test_fetch_downloads_both_packages`: with stub `curl` (writes `fake` to the `-o` target, logs args), running `fetch-packages.sh` creates `packages/routeros-7.25.1-arm.npk` and `packages/wifi-qcom-ac-7.25.1-arm.npk`; test `test_fetch_skips_existing` (second run makes no curl call).
- [ ] Step 2: Run `bash new-hapac2/tests/run-tests.sh` → FAIL (script missing).
- [ ] Step 3: Implement `fetch-packages.sh` using `curl -fL --retry 3 -o`; download to `.part` then `mv`; delete `.part` on failure.
- [ ] Step 4: Run tests → PASS. Run the real script once with network → both files present with sizes ~12 MB and ~2.3 MB.
- [ ] Step 5: Commit `feat(new-hapac2): pin RouterOS 7.25.1 and add package fetcher`.

### Task 2: Project config + template rendering

**Files:**
- Create: `new-hapac2/router-config.template.rsc` (from `config/router-config.rsc`), `new-hapac2/projects/example.conf`, `new-hapac2/lib.sh`
- Test: `new-hapac2/tests/run-tests.sh`

**Interfaces:**
- Produces in `lib.sh`:
  - `load_conf <file>` → sets `IDENTITY SSID WIFI_PASS USER_NAME USER_PASS WG_ADDRESS`; returns 1 + Thai message on stderr if file missing.
  - `validate_conf` → 0 / 1 with Thai message naming the bad key. Rules: all keys non-empty; `WIFI_PASS` length 8–63; `USER_PASS` length ≥ 8; `WG_ADDRESS` matches `^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$`; `IDENTITY` matches `^[A-Za-z0-9_-]+$`; no value contains `" \ $ & | /` (except `/` in WG_ADDRESS).
  - `render_config <template> <out>` → replaces `{{IDENTITY}} {{SSID}} {{WIFI_PASS}} {{USER_NAME}} {{USER_PASS}} {{WG_ADDRESS}}`; returns 1 if any `{{` remains.
- Template keeps current config logic, with values replaced by placeholders, string values quoted (`ssid="{{SSID}}"`, `passphrase="{{WIFI_PASS}}"`, `password="{{USER_PASS}}"`), `/user remove [find name=admin]`, `domain=lan`, and `:delay 30s` kept.
- `example.conf` holds the current Raynue values as a sample (`IDENTITY=Raynue`, `SSID=@CONTROLsonosxaura`, `WG_ADDRESS=10.0.0.40/24`, `USER_NAME=sonos`) with placeholder passwords `CHANGE_ME_8chars`.

- [ ] Step 1: Tests: `test_load_example_conf` (values equal the above), `test_validate_ok_example`, `test_validate_short_wifi_pass` (7 chars → fail), `test_validate_long_wifi_pass` (64 → fail), `test_validate_quote_in_ssid` (fail), `test_validate_bad_wg_address` (`10.0.0.40` → fail), `test_render_replaces_all` (output has no `{{`, contains `ssid="@CONTROLsonosxaura"` and `/system identity set name=Raynue`), `test_render_unknown_placeholder_fails` (template with `{{FOO}}` → fail).
- [ ] Step 2: Run tests → FAIL.
- [ ] Step 3: Implement the three functions and create the template + example conf. `load_conf` parses `KEY=VALUE` lines itself (no `source`, so a conf can't run code).
- [ ] Step 4: Run tests → PASS. `diff` rendered example vs `config/router-config.rsc` shows only the intended changes (quoting, domain, placeholders).
- [ ] Step 5: Commit `feat(new-hapac2): project conf validation and config template`.

### Task 3: Router helpers (SSH/SCP/wait/version)

**Files:**
- Modify: `new-hapac2/lib.sh`
- Create: `new-hapac2/tests/stubs/ssh`, `new-hapac2/tests/stubs/scp`, `new-hapac2/tests/stubs/ping`

**Interfaces:**
- Produces in `lib.sh` (all use `ROUTER_IP`, `SSH_KEY`, `SSH_OPTS`):
  - `ros_cmd "<routeros command>"` → runs via ssh, prints stdout, returns ssh's status.
  - `ros_upload <local> <remote-name>` → scp.
  - `ros_version` → prints e.g. `7.25.1` or `6.48.6` (parsed from `:put [/system resource get version]`, text before first space).
  - `version_lt <a> <b>` → 0 if a < b, dotted numeric compare.
  - `wait_down <ip> <timeout_s>` / `wait_up <ip> <timeout_s>` → poll `ping -c1 -t1` every 2 s; `wait_up` also requires `ros_cmd ':put ok'` to succeed when `REQUIRE_SSH=1`; return 1 on timeout.
  - `ros_reboot` → sends `/system reboot` (ignore ssh exit code), then `wait_down` 60, `wait_up` 240.
- Stubs: `ssh` answers from env `STUB_SSH_<n>` / logs commands to `$STUB_LOG`; `ping` succeeds/fails based on a counter file to simulate down→up.

- [ ] Step 1: Tests: `test_version_lt` (`6.48.6 < 6.49`, `7.9 < 7.25.1`, not `7.25.1 < 7.25.1`), `test_ros_version_parse` (stub prints `7.25.1 (stable)` → `7.25.1`), `test_wait_up_timeout` (ping always fails, timeout 3 → returns 1 within ~4 s), `test_ros_reboot_waits` (ping fails twice then succeeds → returns 0, log has `/system reboot`).
- [ ] Step 2: Run → FAIL.
- [ ] Step 3: Implement.
- [ ] Step 4: Run → PASS.
- [ ] Step 5: Commit `feat(new-hapac2): router ssh helpers`.

### Task 4: install.sh orchestration

**Files:**
- Create: `new-hapac2/install.sh`
- Test: `new-hapac2/tests/run-tests.sh` (end-to-end with stubs)

**Interfaces:**
- Consumes everything above. CLI: `./install.sh projects/<name>.conf`. Env overrides for tests: `ROUTER_IP`, `TIMEOUT_UP`.
- Steps (each prints `[ขั้น N/6] …` in Thai):
  1. Preflight: conf loads + validates; both npk files exist; `ping 192.168.88.1` ok. Fail → exit 1 before any ssh.
  2. Login: generate temp RSA key, open one password-prompting ssh with `ControlMaster`, scp `.pub`, `/user ssh-keys import public-key-file=<name> user=admin`. Subsequent calls use the key.
  3. Version: if `version_lt $(ros_version) 6.49` → stop with Thai message "อัป v6 เป็น 6.49 ก่อน". If not `7.25.1` → upload routeros npk, `ros_reboot`, recheck equals `7.25.1` else stop.
  4. Wireless: if `/system package print` lists `wireless` → `/system package uninstall wireless`, `ros_reboot`. If `wifi-qcom-ac` not listed → upload it, `ros_reboot`, then require `/interface wifi print` to show `wifi1` and `wifi2`; else stop ("ติดตั้ง wifi-qcom-ac ไม่สำเร็จ — เช็คพื้นที่ flash: /system resource print").
  5. Config: `render_config` to temp `router-config.rsc`, upload, run `/system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=router-config.rsc` (connection drop is expected).
  6. Verify: tell team "ถอดสาย LAN แล้วเสียบใหม่" so Mac renews DHCP; `wait_up 192.168.40.1` 300 s with `REQUIRE_SSH=0`; print summary (identity, SSID, how to enter Winbox at 192.168.40.1 as `USER_NAME`).
- Steps are idempotent: re-running on a half-done router skips what's already done.

- [ ] Step 1: Tests: `test_install_stops_without_npk` (no ssh calls logged), `test_install_stops_on_v6_old` (stub version `6.45.9` → exit 1, no upload), `test_install_full_flow_from_v7_with_wireless` (stub: version `7.25.1`, packages list has `wireless`, after reboot has `wifi-qcom-ac`, wifi print shows wifi1/wifi2 → log contains in order: `uninstall wireless`, `/system reboot`, upload `wifi-qcom-ac-7.25.1-arm.npk`, `/system reboot`, `reset-configuration`), `test_install_skips_done_steps` (already 7.25.1 + wifi-qcom-ac, no wireless → no reboot before reset).
- [ ] Step 2: Run → FAIL.
- [ ] Step 3: Implement.
- [ ] Step 4: Run → PASS; `bash -n` on all scripts.
- [ ] Step 5: Commit `feat(new-hapac2): installer orchestration`.

### Task 5: README for the install team

**Files:**
- Create: `new-hapac2/README.md` (Thai)

- [ ] Step 1: Write: what to prepare at office (`./fetch-packages.sh`, copy `projects/example.conf` → `projects/<site>.conf` and fill), on-site steps (cable into ether2–5, run `./install.sh projects/<site>.conf`, enter admin password from sticker or blank), what each `[ขั้น N/6]` does, and a troubleshooting table matching every stop message in `install.sh`.
- [ ] Step 2: Check every Thai error string in `install.sh` appears in the README table (`grep`).
- [ ] Step 3: Commit `docs(new-hapac2): Thai install guide`.

### Final verification
- [ ] `bash new-hapac2/tests/run-tests.sh` → all PASS.
- [ ] Not covered by tests (must be done on a real hAP ac2 before field use): real SSH login on factory unit, package swap fitting in flash, wifi1/wifi2 band mapping, config applying fully.
