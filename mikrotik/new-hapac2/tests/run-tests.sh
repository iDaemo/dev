#!/bin/bash
# Test runner: sources tests/test_*.sh, runs every test_* function in a subshell
# with a fresh temp dir in $T. Usage: bash tests/run-tests.sh [name-filter]
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$TESTS_DIR/.." && pwd)"
STUBS="$TESTS_DIR/stubs"
export ROOT STUBS

assert_eq() { # <expected> <actual> <name>
  if [ "$1" != "$2" ]; then echo "    assert_eq failed: $3"; echo "      expected: [$1]"; echo "      actual:   [$2]"; exit 1; fi
}
assert_ok() { # <name> <cmd...>
  local n="$1"; shift
  if ! "$@" >/dev/null 2>&1; then echo "    assert_ok failed: $n"; exit 1; fi
}
assert_fail() { # <name> <cmd...>
  local n="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "    assert_fail failed (command succeeded): $n"; exit 1; fi
}
assert_contains() { # <haystack> <needle> <name>
  case "$1" in *"$2"*) ;; *) echo "    assert_contains failed: $3"; echo "      missing: [$2]"; exit 1;; esac
}
assert_not_contains() { # <haystack> <needle> <name>
  case "$1" in *"$2"*) echo "    assert_not_contains failed: $3"; echo "      found: [$2]"; exit 1;; esac
}

for f in "$TESTS_DIR"/test_*.sh; do . "$f"; done

pass=0; fail=0; failed=""
for t in $(declare -F | awk '{print $3}' | grep '^test_' | grep -- "${1:-}"); do
  T="$(mktemp -d)"
  if ( export T STUB_LOG="$T/stub.log"; cd "$T" && "$t" ); then
    pass=$((pass+1)); echo "ok   $t"
  else
    fail=$((fail+1)); failed="$failed $t"; echo "FAIL $t"
  fi
  rm -rf "$T"
done
echo "PASS $pass / FAIL $fail"
[ -n "$failed" ] && echo "failed:$failed"
[ "$fail" -eq 0 ]
