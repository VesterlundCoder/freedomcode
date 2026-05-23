#!/usr/bin/env bash
# =============================================================================
# freedomcode — scripts/update.sh
# Update all components: Homebrew, npm, Python packages, Ollama model
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[update]${RESET} $*"; }
success() { echo -e "${GREEN}[update]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[update]${RESET} $*"; }
step()    { echo -e "\n${BOLD}${CYAN}── $* ──${RESET}"; }

echo -e "\n${BOLD}freedomcode — Update All Components${RESET}\n"

# ─── Homebrew ─────────────────────────────────────────────────────────────────
step "Homebrew packages"
if command -v brew &>/dev/null; then
  info "Updating Homebrew..."
  brew update
  info "Upgrading packages..."
  brew upgrade git node python@3.12 ollama 2>/dev/null || true
  success "Homebrew packages updated"
else
  warn "Homebrew not found, skipping"
fi

# ─── npm / MCP ────────────────────────────────────────────────────────────────
step "npm global packages (MCP servers)"
if command -v npm &>/dev/null; then
  info "Updating MCP servers..."
  npm update -g @modelcontextprotocol/server-filesystem 2>/dev/null || true
  npm update -g @modelcontextprotocol/server-git 2>/dev/null || true
  npm update -g @modelcontextprotocol/server-shell 2>/dev/null || true
  success "MCP servers updated"
else
  warn "npm not found, skipping"
fi

# ─── Python packages ──────────────────────────────────────────────────────────
step "Python packages (venv)"
VENV_DIR="${SCRIPT_DIR}/.venv"
if [[ -d "${VENV_DIR}" ]]; then
  source "${VENV_DIR}/bin/activate"
  info "Updating Python packages via uv..."
  if command -v uv &>/dev/null; then
    uv pip install --upgrade \
      numpy scipy pandas matplotlib sympy \
      jupyterlab ipykernel ipywidgets \
      torch torchvision torchaudio \
      transformers datasets tokenizers accelerate \
      requests httpx rich typer \
      pytest black ruff mypy \
      gitpython python-dotenv \
      aider-chat 2>&1 | tail -5
  else
    pip install --upgrade \
      numpy scipy pandas matplotlib sympy \
      jupyterlab aider-chat 2>&1 | tail -5
  fi
  success "Python packages updated"
else
  warn "venv not found at ${VENV_DIR}. Run ./bootstrap.sh first."
fi

# ─── Aider ────────────────────────────────────────────────────────────────────
step "Aider"
if command -v aider &>/dev/null; then
  info "Updating Aider..."
  pip install --upgrade aider-chat 2>/dev/null || true
  success "Aider updated: $(aider --version 2>&1 | head -1)"
else
  warn "Aider not found. Run: pip install aider-chat"
fi

# ─── Ollama model ─────────────────────────────────────────────────────────────
step "Ollama model (qwen2.5-coder:32b)"
if command -v ollama &>/dev/null; then
  info "Checking for model updates..."
  if ! pgrep -x "ollama" &>/dev/null; then
    info "Starting Ollama for update check..."
    nohup ollama serve >> "${SCRIPT_DIR}/logs/ollama.log" 2>&1 &
    sleep 3
  fi
  ollama pull qwen2.5-coder:32b
  success "Model up to date"
else
  warn "Ollama not found, skipping model update"
fi

# ─── Continue config ──────────────────────────────────────────────────────────
step "Continue.dev config"
if [[ -f "${SCRIPT_DIR}/continue/config.yaml" ]]; then
  cp "${SCRIPT_DIR}/continue/config.yaml" "${HOME}/.continue/config.yaml"
  success "Continue config synced to ~/.continue/config.yaml"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}Update complete!${RESET}"
echo -e "Run ${CYAN}./scripts/verify.sh${RESET} to confirm everything is healthy."
echo ""
