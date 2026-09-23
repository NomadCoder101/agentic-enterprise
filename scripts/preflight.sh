#!/usr/bin/env bash
# preflight.sh -- checks the environment without installing anything.
# Safe to run before install.sh to see what is missing.
set -euo pipefail

C_OK='\033[1;32m'
C_WARN='\033[1;33m'
C_ERR='\033[1;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

ok()     { printf "${C_OK}OK${C_RESET}   %s\n" "$*"; }
warn()   { printf "${C_WARN}WARN${C_RESET} %s\n" "$*"; }
err()    { printf "${C_ERR}FAIL${C_RESET} %s\n" "$*"; }
banner() { printf "\n${C_BOLD}=== %s ===${C_RESET}\n" "$*"; }

fails=0

banner "Python"
if command -v python3 >/dev/null 2>&1; then
  ok "python3: $(python3 --version)"
  if python3 -c 'import yaml' 2>/dev/null; then
    ok "pyyaml installed"
  else
    err "pyyaml missing -- pip3 install pyyaml"
    fails=$((fails+1))
  fi
  if python3 -c 'import requests' 2>/dev/null; then
    ok "requests installed"
  else
    warn "requests missing (optional) -- pip3 install requests"
  fi
else
  err "python3 not found"
  fails=$((fails+1))
fi

banner "Ollama"
if command -v ollama >/dev/null 2>&1; then
  ok "ollama: $(ollama --version 2>/dev/null | head -1)"
  if curl -s --max-time 3 http://localhost:11434/api/tags >/dev/null 2>&1; then
    ok "service responding on localhost:11434"
    echo "     installed models:"
    ollama list 2>/dev/null | tail -n +2 | awk '{printf "       - %s\n", $1}'
  else
    warn "service NOT responding. Start with: ollama serve &"
  fi
else
  err "ollama not found. Install: curl -fsSL https://ollama.com/install.sh | sh"
  fails=$((fails+1))
fi

banner "Obsidian"
if command -v obsidian >/dev/null 2>&1 \
   || [[ -d "/Applications/Obsidian.app" ]] \
   || [[ -d "$HOME/.config/obsidian" ]]; then
  ok "Obsidian appears installed"
else
  warn "Obsidian not detected. Download: https://obsidian.md"
fi

banner "Shell tools"
for tool in rsync git curl; do
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool: $(command -v $tool)"
  else
    warn "$tool missing (recommended but not required)"
  fi
done

banner "Disk space"
avail_kb=$(df -Pk "$HOME" | tail -1 | awk '{print $4}')
avail_gb=$((avail_kb / 1024 / 1024))
if [[ "$avail_gb" -ge 15 ]]; then
  ok "$avail_gb GB available in $HOME"
elif [[ "$avail_gb" -ge 8 ]]; then
  warn "$avail_gb GB available -- tight but workable"
else
  err "$avail_gb GB available -- need at least 8 GB"
  fails=$((fails+1))
fi

banner "Summary"
if [[ "$fails" -eq 0 ]]; then
  printf "${C_OK}Environment is ready.${C_RESET}\n"
  exit 0
else
  printf "${C_ERR}%d blocking issue(s) found.${C_RESET} Fix them before running install.sh.\n" "$fails"
  exit 1
fi

