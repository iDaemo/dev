# Every die "<message>" in install.sh must appear (its fixed text, up to the first $ or "(") in README.md
test_readme_covers_every_error() {
  [ -f "$ROOT/README.md" ] || { echo "    README.md missing"; exit 1; }
  missing=""
  while IFS= read -r msg; do
    key="${msg%%\$*}"; key="${key%%(*}"; key="$(echo "$key" | sed 's/[[:space:]]*$//')"
    [ -z "$key" ] && continue
    grep -qF -- "$key" "$ROOT/README.md" || missing="$missing|$key"
  done < <(grep -o 'die "[^"]*"' "$ROOT/install.sh" | sed 's/^die "//; s/"$//')
  [ -z "$missing" ] || { echo "    not in README:$missing"; exit 1; }
}
