#!/usr/bin/env bash
# =============================================================================
# freedomcode — scripts/start-aider.sh
# Launch Aider with Ollama backend, pointed at the workspace
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/.env" 2>/dev/null || true

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; RESET='\033[0m'

info()  { echo -e "${CYAN}[aider]${RESET} $*"; }
error() { echo -e "${RED}[aider]${RESET} $*"; exit 1; }

OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5-coder:32b}"
WORKSPACE="${SCRIPT_DIR}/workspace"

# ─── Pre-flight checks ────────────────────────────────────────────────────────
if ! command -v aider &>/dev/null; then
  error "Aider not found. Run: pip install aider-chat  (or ./bootstrap.sh)"
fi

if ! pgrep -x "ollama" &>/dev/null; then
  info "Ollama not running. Starting it now..."
  nohup ollama serve >> "${SCRIPT_DIR}/logs/ollama.log" 2>&1 &
  sleep 3
fi

if ! curl -sf http://localhost:11434/api/tags &>/dev/null; then
  error "Ollama API not reachable at http://localhost:11434"
fi

# ─── Activate venv ───────────────────────────────────────────────────────────
if [[ -f "${SCRIPT_DIR}/.venv/bin/activate" ]]; then
  source "${SCRIPT_DIR}/.venv/bin/activate"
fi

# ─── Launch Aider ─────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║         freedomcode — Aider Agent               ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${RESET}"
echo ""
info "Model:     ${OLLAMA_MODEL}"
info "Workspace: ${WORKSPACE}"
info "Ollama:    http://localhost:11434"
echo ""

# Change to workspace dir for project-aware context
cd "${WORKSPACE}"

# Launch Aider with Ollama provider
exec aider \
  --model "ollama/${OLLAMA_MODEL}" \
  --ollama-api-base "http://localhost:11434" \
  --dark-mode \
  --no-auto-commits \
  --watch-files \
  "$@"
