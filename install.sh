#!/usr/bin/env bash
# install.sh -- one-command installer for Agentic Enterprise.
#
# Usage:
#   ./install.sh                    interactive
#   ./install.sh --unattended       uses defaults, no prompts
#   ./install.sh --skip-models      do not pull ollama models
#   ./install.sh --skip-validate    skip post-install validation
#   ./install.sh --dry-run          show what would happen

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

UNATTENDED=0
SKIP_MODELS=0
SKIP_VALIDATE=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --unattended)    UNATTENDED=1; shift ;;
    --skip-models)   SKIP_MODELS=1; shift ;;
    --skip-validate) SKIP_VALIDATE=1; shift ;;
    --dry-run)       DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

C_BOLD='\033[1m'
C_OK='\033[1;32m'
C_WARN='\033[1;33m'
C_ERR='\033[1;31m'
C_DIM='\033[2m'
C_RESET='\033[0m'

ok()     { printf "${C_OK}OK${C_RESET}   %s\n" "$*"; }
warn()   { printf "${C_WARN}WARN${C_RESET} %s\n" "$*"; }
err()    { printf "${C_ERR}FAIL${C_RESET} %s\n" "$*"; }
info()   { printf "${C_BOLD}>>${C_RESET}   %s\n" "$*"; }
dim()    { printf "${C_DIM}     %s${C_RESET}\n" "$*"; }
banner() { printf "\n${C_BOLD}=== %s ===${C_RESET}\n" "$*"; }

cat <<'BANNER'

  Agentic Enterprise -- Installer
  ================================

  A fully local, sovereign, multi-domain AI enterprise.

BANNER

# ============================================================
banner "1/7 Preflight"
# ============================================================

if ! command -v python3 >/dev/null 2>&1; then
  err "python3 not found. Install Python 3.10+ and re-run."
  exit 1
fi
pyver=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
ok "Python $pyver"

if ! python3 -c 'import yaml' 2>/dev/null; then
  warn "python yaml module missing. Attempting to install..."
  if command -v pip3 >/dev/null 2>&1; then
    pip3 install --user pyyaml >/dev/null 2>&1 \
      || pip3 install --break-system-packages pyyaml >/dev/null 2>&1 \
      || true
  fi
fi
python3 -c 'import yaml' 2>/dev/null \
  && ok "python yaml OK" \
  || { err "pyyaml not installable. Try: pip3 install pyyaml"; exit 1; }

python3 -c 'import requests' 2>/dev/null \
  && ok "python requests OK" \
  || warn "python requests missing (only needed for API mode)"

# ============================================================
banner "2/7 Ollama"
# ============================================================

if command -v ollama >/dev/null 2>&1; then
  ok "ollama CLI: $(ollama --version 2>/dev/null | head -1)"
  if curl -s --max-time 3 http://localhost:11434/api/tags >/dev/null 2>&1; then
    ok "ollama service running"
  else
    warn "ollama installed but not running. Attempting to start..."
    (ollama serve >/dev/null 2>&1 &) || true
    sleep 3
    if curl -s --max-time 3 http://localhost:11434/api/tags >/dev/null 2>&1; then
      ok "ollama service started"
    else
      warn "could not auto-start ollama. Run 'ollama serve' manually."
    fi
  fi
else
  warn "ollama not found."
  echo "     Install:"
  echo "       Linux/macOS:  curl -fsSL https://ollama.com/install.sh | sh"
  echo "       Windows:      https://ollama.com/download"
  if [[ "$UNATTENDED" == "0" ]]; then
    read -rp "Continue anyway? [y/N]: " cont
    [[ "$cont" =~ ^[Yy]$ ]] || exit 1
  fi
fi

# ============================================================
banner "3/7 Obsidian"
# ============================================================

if command -v obsidian >/dev/null 2>&1 \
   || [[ -d "/Applications/Obsidian.app" ]] \
   || [[ -d "$HOME/.config/obsidian" ]]; then
  ok "Obsidian appears installed"
else
  warn "Obsidian not detected."
  echo "     This project uses Obsidian as the vault viewer."
  echo "     Download: https://obsidian.md"
  echo "     You can still proceed and open the vault later."
fi

# ============================================================
banner "4/7 Configure"
# ============================================================

prompt_default() {
  local var="$1" text="$2" default="$3"
  local val=""
  if [[ "$UNATTENDED" == "1" ]]; then
    printf -v "$var" '%s' "$default"
    dim "$text = $default (unattended)"
    return
  fi
  read -rp "  $text [$default]: " val
  val="${val:-$default}"
  printf -v "$var" '%s' "$val"
}

prompt_default ENT_SLUG       "Enterprise slug (lowercase, folder-safe)" "myenterprise"
prompt_default ENT_NAME       "Enterprise display name"                  "My Enterprise"
prompt_default OWNER_NAME     "Your name"                                "$(whoami)"
prompt_default OWNER_HANDLE   "Your handle (unix-safe)"                  "$(whoami)"
prompt_default VAULT_PARENT   "Parent folder for the vault"              "$HOME/Desktop"
prompt_default DOMAINS        "Domains (personal,client,venture)"        "personal,client,venture"
prompt_default PRIMARY_MODEL  "Primary model"                            "qwen2.5:7b"
prompt_default CODING_MODEL   "Coding model"                             "qwen2.5-coder:7b"
prompt_default EMBED_MODEL    "Embeddings model"                         "nomic-embed-text"

VAULT_PATH="$VAULT_PARENT/$ENT_SLUG"

# ============================================================
banner "5/7 Build"
# ============================================================

if [[ "$DRY_RUN" == "1" ]]; then
  info "DRY RUN -- would create: $VAULT_PATH"
  info "DRY RUN -- template source: $TEMPLATE_DIR"
  info "DRY RUN -- domains: $DOMAINS"
  exit 0
fi

if [[ -e "$VAULT_PATH" ]]; then
  err "Target already exists: $VAULT_PATH"
  read -rp "  Overwrite? (type 'yes'): " ans
  [[ "$ans" == "yes" ]] || exit 1
  rm -rf "$VAULT_PATH"
fi

info "Creating vault at: $VAULT_PATH"
mkdir -p "$VAULT_PATH"

info "Copying common structure..."
rsync -a \
  --exclude='domains/' \
  --exclude='_examples/' \
  --exclude='.git/' \
  "$TEMPLATE_DIR/" "$VAULT_PATH/"

IFS=',' read -ra DOMARR <<< "$DOMAINS"
for d in "${DOMARR[@]}"; do
  d_trim="$(echo "$d" | xargs)"
  case "$d_trim" in
    personal) src="$TEMPLATE_DIR/domains/personal/01_Personal"; dst="$VAULT_PATH/01_Personal" ;;
    client)   src="$TEMPLATE_DIR/domains/client/02_Client";     dst="$VAULT_PATH/02_Client" ;;
    venture)  src="$TEMPLATE_DIR/domains/venture/03_Venture";   dst="$VAULT_PATH/03_Venture" ;;
    *) warn "Unknown domain: $d_trim (skipping)"; continue ;;
  esac
  if [[ -d "$src" ]]; then
    info "Including domain: $d_trim"
    rsync -a "$src/" "$dst/"
  else
    warn "Domain source missing: $src"
  fi
done

info "Substituting placeholders..."
find "$VAULT_PATH" -type f \
  \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) \
  ! -path "*/.obsidian/*" \
  -print0 | while IFS= read -r -d '' f; do
    sed -i.bak \
      -e "s|{{VAULT_PATH}}|$VAULT_PATH|g" \
      -e "s|{{ENTERPRISE_SLUG}}|$ENT_SLUG|g" \
      -e "s|{{ENTERPRISE_NAME}}|$ENT_NAME|g" \
      -e "s|{{OWNER_NAME}}|$OWNER_NAME|g" \
      -e "s|{{OWNER_HANDLE}}|$OWNER_HANDLE|g" \
      -e "s|{{PRIMARY_MODEL}}|$PRIMARY_MODEL|g" \
      -e "s|{{CODING_MODEL}}|$CODING_MODEL|g" \
      -e "s|{{REASONING_MODEL}}|$PRIMARY_MODEL|g" \
      -e "s|{{EMBEDDING_MODEL}}|$EMBED_MODEL|g" \
      "$f"
    rm -f "$f.bak"
  done
ok "Placeholders substituted."

ML="$VAULT_PATH/00_Communication/40_Access_Log/master/$(date -u +%Y-%m)"
mkdir -p "$ML"
echo "[$(date -u +%FT%TZ)] enterprise_created | slug=$ENT_SLUG | path=$VAULT_PATH | owner=$OWNER_NAME | installer=v1" > "$ML/master.log"
ok "Master log initialized."

# ============================================================
banner "6/7 Models"
# ============================================================

if [[ "$SKIP_MODELS" == "1" ]]; then
  warn "--skip-models passed; not pulling models"
elif ! command -v ollama >/dev/null 2>&1; then
  warn "ollama not installed; skipping model pulls"
else
  MODELS=("$PRIMARY_MODEL" "$CODING_MODEL" "$EMBED_MODEL")
  for m in "${MODELS[@]}"; do
    if ollama list 2>/dev/null | awk '{print $1}' | grep -qx "$m"; then
      ok "model already present: $m"
    else
      info "Pulling $m (may take several minutes)..."
      if ollama pull "$m"; then
        ok "pulled $m"
      else
        warn "failed to pull $m -- retry later with: ollama pull $m"
      fi
    fi
  done
fi

# ============================================================
banner "7/7 Validate"
# ============================================================

if [[ "$SKIP_VALIDATE" == "1" ]]; then
  warn "--skip-validate passed"
elif [[ -x "$SCRIPT_DIR/scripts/validate-clone.sh" ]]; then
  "$SCRIPT_DIR/scripts/validate-clone.sh" "$VAULT_PATH" || warn "validation reported issues"
else
  warn "validator not found; skipping"
fi

cat <<EOF

Installation complete.

  Enterprise:  $ENT_NAME
  Owner:       $OWNER_NAME ($OWNER_HANDLE)
  Vault:       $VAULT_PATH
  Domains:     $DOMAINS
  Models:      primary=$PRIMARY_MODEL  coding=$CODING_MODEL  embeddings=$EMBED_MODEL

Next steps:

  1. Open Obsidian.
  2. Choose "Open folder as vault".
  3. Select:  $VAULT_PATH
  4. Read:    $VAULT_PATH/01_Personal/50_Wiki/WELCOME.md
  5. Read:    $VAULT_PATH/04_Shared/00_Governance/AGENTS.md

You are ready. Write your first brief to:
  $VAULT_PATH/00_Communication/20_Outbox_To_Domains/Client/

EOF
