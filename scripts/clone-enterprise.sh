#!/usr/bin/env bash
# clone-enterprise.sh -- creates a new enterprise vault from the template.
#
# Usage:
#   clone-enterprise.sh [--vars /path/to/vars.yaml]
#
# Direct args:
#   clone-enterprise.sh --slug newbiz --name "NewBiz Holdings" \
#     --owner "NomadCoder101" --handle nomadcoder \
#     --path ~/Desktop/NewBizBrain --domains personal,client,venture

set -euo pipefail

TEMPLATE_DIR="$HOME/enterprise-templates/v1"
VARS_FILE=""

SLUG=""
NAME=""
OWNER=""
HANDLE=""
VAULT_PATH=""
DOMAINS="personal,client,venture"
PRIMARY_MODEL="qwen2.5:7b"
REASONING_MODEL="qwen2.5:14b"
CODING_MODEL="qwen2.5-coder:7b"
EMBEDDING_MODEL="nomic-embed-text"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --vars)            VARS_FILE="$2"; shift 2 ;;
    --slug)            SLUG="$2"; shift 2 ;;
    --name)            NAME="$2"; shift 2 ;;
    --owner)           OWNER="$2"; shift 2 ;;
    --handle)          HANDLE="$2"; shift 2 ;;
    --path)            VAULT_PATH="$2"; shift 2 ;;
    --domains)         DOMAINS="$2"; shift 2 ;;
    --primary-model)   PRIMARY_MODEL="$2"; shift 2 ;;
    --coding-model)    CODING_MODEL="$2"; shift 2 ;;
    --reasoning-model) REASONING_MODEL="$2"; shift 2 ;;
    --embedding-model) EMBEDDING_MODEL="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -n "$VARS_FILE" ]]; then
  if [[ ! -f "$VARS_FILE" ]]; then
    echo "Vars file not found: $VARS_FILE" >&2; exit 1
  fi
  eval "$(python3 - "$VARS_FILE" <<'PYEOF'
import sys, yaml, shlex
d = yaml.safe_load(open(sys.argv[1]))
for k, v in d.items():
    print(f"{k.upper()}={shlex.quote(str(v))}")
PYEOF
)"
fi

prompt() {
  local var_name="$1" prompt_text="$2" default="${3:-}"
  local current="${!var_name}"
  if [[ -z "$current" ]]; then
    read -rp "$prompt_text${default:+ [$default]}: " val
    val="${val:-$default}"
    printf -v "$var_name" '%s' "$val"
  fi
}

prompt SLUG   "Enterprise slug (folder-safe)" ""
prompt NAME   "Enterprise display name" "Enterprise $SLUG"
prompt OWNER  "Owner name" "Owner"
prompt HANDLE "Owner handle" "$USER"
prompt VAULT_PATH "Target vault path" "$HOME/Desktop/${SLUG}Brain"

if [[ -z "$SLUG" || -z "$NAME" || -z "$OWNER" || -z "$HANDLE" || -z "$VAULT_PATH" ]]; then
  echo "Missing required values." >&2; exit 1
fi
if [[ ! "$SLUG" =~ ^[a-z0-9-]+$ ]]; then
  echo "Slug must be lowercase alphanumeric with hyphens only." >&2; exit 1
fi
if [[ -e "$VAULT_PATH" ]]; then
  echo "Target already exists: $VAULT_PATH" >&2
  read -rp "Overwrite? (type 'yes'): " confirm
  [[ "$confirm" == "yes" ]] || exit 1
  rm -rf "$VAULT_PATH"
fi

mkdir -p "$VAULT_PATH"

echo ">> Copying common tree..."
rsync -a --exclude='.obsidian/' \
  --exclude='domains/' \
  --exclude='_examples/' \
  --exclude='TEMPLATE.md' \
  --exclude='*.pre-param-*' \
  "$TEMPLATE_DIR/" "$VAULT_PATH/"

IFS=',' read -ra DOMAIN_LIST <<< "$DOMAINS"
for d in "${DOMAIN_LIST[@]}"; do
  d_trim="$(echo "$d" | xargs)"
  case "$d_trim" in
    personal) src="$TEMPLATE_DIR/domains/personal/01_Personal"; dst="$VAULT_PATH/01_Personal" ;;
    client)   src="$TEMPLATE_DIR/domains/client/02_Client";     dst="$VAULT_PATH/02_Client" ;;
    venture)  src="$TEMPLATE_DIR/domains/venture/03_Venture";   dst="$VAULT_PATH/03_Venture" ;;
    *) echo "Unknown domain: $d_trim" >&2; exit 1 ;;
  esac
  if [[ -d "$src" ]]; then
    echo ">> Including domain: $d_trim"
    rsync -a "$src/" "$dst/"
  else
    echo "!! Domain source missing in template: $src"
  fi
done

echo ">> Substituting placeholders..."
find "$VAULT_PATH" -type f \
  \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) \
  ! -path "*/.obsidian/*" \
  -print0 | while IFS= read -r -d '' f; do
    sed -i \
      -e "s|{{VAULT_PATH}}|$VAULT_PATH|g" \
      -e "s|{{ENTERPRISE_SLUG}}|$SLUG|g" \
      -e "s|{{ENTERPRISE_NAME}}|$NAME|g" \
      -e "s|{{OWNER_NAME}}|$OWNER|g" \
      -e "s|{{OWNER_HANDLE}}|$HANDLE|g" \
      -e "s|{{PRIMARY_MODEL}}|$PRIMARY_MODEL|g" \
      -e "s|{{REASONING_MODEL}}|$REASONING_MODEL|g" \
      -e "s|{{CODING_MODEL}}|$CODING_MODEL|g" \
      -e "s|{{EMBEDDING_MODEL}}|$EMBEDDING_MODEL|g" \
      "$f"
  done

ML="$VAULT_PATH/00_Communication/40_Access_Log/master/$(date -u +%Y-%m)"
mkdir -p "$ML"
echo "[$(date -u +%FT%TZ)] enterprise_created | slug=$SLUG | path=$VAULT_PATH | owner=$OWNER | template=v1" > "$ML/master.log"

cat <<EOF

Enterprise created: $NAME
  Slug:    $SLUG
  Path:    $VAULT_PATH
  Owner:   $OWNER ($HANDLE)
  Domains: $DOMAINS
  Models:  primary=$PRIMARY_MODEL  coding=$CODING_MODEL  reasoning=$REASONING_MODEL

Next steps:
  1. Open Obsidian -> Open folder as vault -> $VAULT_PATH
  2. Verify:  head -20 "$VAULT_PATH/04_Shared/00_Governance/AGENTS.md"

EOF
