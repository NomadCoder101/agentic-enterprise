#!/usr/bin/env bash
# parameterize.sh -- converts a vault snapshot into a template by replacing
# hardcoded values with {{PLACEHOLDERS}}.
set -euo pipefail

SRC="$1"
if [[ -z "${SRC:-}" || ! -d "$SRC" ]]; then
  echo "Usage: $0 /path/to/snapshot"
  exit 1
fi

echo ">> Parameterizing: $SRC"

cp -a "$SRC" "${SRC}.pre-param-$(date -u +%Y%m%dT%H%M%SZ)"

find "$SRC" -type f \
  \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) \
  ! -path "*/.obsidian/*" \
  -print0 | while IFS= read -r -d '' f; do
    sed -i \
      -e 's|/home/nomadcoder/Desktop/MySecondBrain|{{VAULT_PATH}}|g' \
      -e 's|MySecondBrain|{{ENTERPRISE_SLUG}}|g' \
      -e 's|NomadCoder101|{{OWNER_NAME}}|g' \
      -e 's|nomadcoder|{{OWNER_HANDLE}}|g' \
      -e 's|qwen2\.5-coder:7b|{{CODING_MODEL}}|g' \
      -e 's|qwen2\.5:14b|{{REASONING_MODEL}}|g' \
      -e 's|qwen2\.5:7b|{{PRIMARY_MODEL}}|g' \
      -e 's|nomic-embed-text|{{EMBEDDING_MODEL}}|g' \
      "$f"
  done

echo "OK - parameterization complete."
echo
echo "Preview of substitutions:"
grep -rn "{{" "$SRC/04_Shared/00_Governance/" 2>/dev/null | head -20 || true
