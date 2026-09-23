#!/usr/bin/env bash
# split-template.sh -- organizes a flat snapshot into a modular template.
set -euo pipefail

TPL="$HOME/enterprise-templates/v1"

echo ">> Splitting template at $TPL"

mkdir -p "$TPL/domains/personal" "$TPL/domains/client" "$TPL/domains/venture"

[[ -d "$TPL/01_Personal" ]] && mv "$TPL/01_Personal" "$TPL/domains/personal/01_Personal"
[[ -d "$TPL/02_Client"   ]] && mv "$TPL/02_Client"   "$TPL/domains/client/02_Client"
[[ -d "$TPL/03_Venture"  ]] && mv "$TPL/03_Venture"  "$TPL/domains/venture/03_Venture"

mkdir -p "$TPL/_examples"
cat > "$TPL/_examples/README.md" <<'EX_EOF'
# Examples -- not auto-copied on clone

This folder contains sample content you can manually copy into a new
enterprise for reference.
EX_EOF

echo "OK - template is now modular."
find "$TPL" -maxdepth 2 -type d | sort

