#!/usr/bin/env bash
# =============================================================================
# freedomcode — scripts/start.sh
# Start all services: Ollama + optional Docker sandbox
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/.env" 2>/dev/null || true

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RESET='\033[0m'
info()    { echo -e "${CYAN}[start]${RESET} $*"; }
success() { echo -e "${GREEN}[start]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[start]${RESET} $*"; }

# ─── Ollama ──────────────────────────────────────────────────────────────────
if pgrep -x "ollama" &>/dev/null; then
  success "Ollama already running (PID: $(pgrep -x ollama))"
else
  info "Starting Ollama..."
  nohup ollama serve >> "${SCRIPT_DIR}/logs/ollama.log" 2>&1 &
  sleep 2
  if pgrep -x "ollama" &>/dev/null; then
    success "Ollama started (PID: $(pgrep -x ollama))"
  else
    warn "Ollama may not have started. Check logs/ollama.log"
  fi
fi

# ─── Verify model ─────────────────────────────────────────────────────────────
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5-coder:32b}"
if ollama list 2>/dev/null | grep -q "${OLLAMA_MODEL}"; then
  success "Model ready: ${OLLAMA_MODEL}"
else
  warn "Model ${OLLAMA_MODEL} not found. Run: ollama pull ${OLLAMA_MODEL}"
fi

# ─── Docker (optional) ────────────────────────────────────────────────────────
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  if [[ "${1:-}" == "--sandbox" ]]; then
    info "Starting Docker sandbox..."
    docker-compose -f "${SCRIPT_DIR}/docker-compose.yml" up -d sandbox
    success "Sandbox running"
  fi
else
  warn "Docker not available. Sandbox disabled."
fi

echo ""
success "Services started. Open VS Code: code ${SCRIPT_DIR}/freedomcode.code-workspace"
echo -e "  ${CYAN}Ollama API:${RESET} http://localhost:11434"
echo -e "  ${CYAN}Model:${RESET}      ${OLLAMA_MODEL}"
echo ""
