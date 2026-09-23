#!/usr/bin/env bash
# validate-clone.sh -- sanity-checks a freshly cloned enterprise vault.
#
# Usage:
#   validate-clone.sh /path/to/cloned/vault
#
# Exit codes:
#   0 = all checks passed
#   1 = one or more checks failed

set -uo pipefail

VAULT="${1:-}"
if [[ -z "$VAULT" || ! -d "$VAULT" ]]; then
  echo "Usage: $0 /path/to/cloned/vault"
  exit 1
fi

fail=0

check() {
  local label="$1" result="$2" expected="$3"
  if [[ "$result" == "$expected" ]]; then
    printf '  OK   %s\n' "$label"
  else
    printf '  FAIL %s (got %s, expected %s)\n' "$label" "$result" "$expected"
    fail=1
  fi
}

warn() { printf '  WARN %s\n' "$1"; }
info() { printf '  OK   %s\n' "$1"; }
miss() { printf '  MISS %s\n' "$1"; fail=1; }

echo ">> Validating: $VAULT"

# ----------------------------------------------------------------
echo
echo "-- Required files --"
REQUIRED=(
  "04_Shared/00_Governance/AGENTS.md"
  "04_Shared/00_Governance/ACCESS_POLICY.yaml"
  "04_Shared/00_Governance/ORG.md"
  "04_Shared/00_Governance/INTERDOMAIN.md"
  "00_Communication/00_Agent/Identity.md"
  "00_Communication/40_Access_Log/master"
  "99_Agent_Workspace/config/runtime.yaml"
  "99_Agent_Workspace/prompts/ceo-agent.md"
  "99_Agent_Workspace/prompts/lead-agent.md"
  "99_Agent_Workspace/prompts/worker-agent.md"
  "99_Agent_Workspace/prompts/communication-agent.md"
  "01_Personal/50_Wiki/WELCOME.md"
)
for f in "${REQUIRED[@]}"; do
  if [[ -e "$VAULT/$f" ]]; then
    info "$f"
  else
    miss "$f"
  fi
done

# ----------------------------------------------------------------
echo
echo "-- YAML parse --"
if python3 -c "import yaml; yaml.safe_load(open('$VAULT/04_Shared/00_Governance/ACCESS_POLICY.yaml'))" 2>/dev/null; then
  info "ACCESS_POLICY.yaml parses"
else
  printf '  FAIL ACCESS_POLICY.yaml failed to parse\n'
  fail=1
fi

if python3 -c "import yaml; yaml.safe_load(open('$VAULT/99_Agent_Workspace/config/runtime.yaml'))" 2>/dev/null; then
  info "runtime.yaml parses"
else
  printf '  FAIL runtime.yaml failed to parse\n'
  fail=1
fi

# ----------------------------------------------------------------
echo
echo "-- Placeholders --"

ENT_PATTERN='VAULT_PATH|ENTERPRISE_SLUG|ENTERPRISE_NAME|OWNER_NAME|OWNER_HANDLE|PRIMARY_MODEL|CODING_MODEL|REASONING_MODEL|EMBEDDING_MODEL'

# Count enterprise-level placeholders (should be 0).
# Use { ... || true; } so an empty grep result doesn't kill the pipeline.
ent=$(
  { grep -rhoE '\{\{[A-Z_]+\}\}' "$VAULT/" 2>/dev/null || true; } \
    | { grep -E "$ENT_PATTERN" || true; } \
    | wc -l
)
ent=$(echo "$ent" | tr -d ' ')
check "no enterprise-level placeholders remain" "$ent" "0"

# Count agent-level placeholders (should be non-zero).
agn=$(
  { grep -rhoE '\{\{[A-Z_]+\}\}' "$VAULT/" 2>/dev/null || true; } \
    | wc -l
)
agn=$(echo "$agn" | tr -d ' ')
if [[ "$agn" -gt 0 ]]; then
  printf '  OK   agent-level placeholders preserved (%s occurrences)\n' "$agn"
else
  warn "no agent-level placeholders found (prompts may lack {{DOMAIN}} etc.)"
fi

# ----------------------------------------------------------------
echo
echo "-- Runtime vault path --"
vp=$(grep -E '^[[:space:]]*vault:' "$VAULT/99_Agent_Workspace/config/runtime.yaml" 2>/dev/null \
       | head -1 \
       | awk '{print $2}')
if [[ "$vp" == "$VAULT" ]]; then
  info "runtime.yaml vault path matches ($vp)"
else
  printf '  FAIL runtime.yaml vault path is "%s", expected "%s"\n' "$vp" "$VAULT"
  fail=1
fi

# ----------------------------------------------------------------
echo
echo "-- Master log --"
mlog_dir="$VAULT/00_Communication/40_Access_Log/master"
if [[ -d "$mlog_dir" ]]; then
  log_count=$(find "$mlog_dir" -name 'master.log' -type f 2>/dev/null | wc -l)
  if [[ "$log_count" -gt 0 ]]; then
    info "master log present"
  else
    warn "master log directory exists but no master.log found"
  fi
else
  printf '  FAIL master log directory missing\n'
  fail=1
fi

# ----------------------------------------------------------------
echo
if [[ "$fail" -eq 0 ]]; then
  echo ">> VALIDATION PASSED"
  exit 0
else
  echo ">> VALIDATION FAILED"
  exit 1
fi
