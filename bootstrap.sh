#!/usr/bin/env bash
# =============================================================================
# freedomcode — bootstrap.sh
# Full automated setup for local AI coding agent stack on macOS Apple Silicon
# =============================================================================
# Usage: ./bootstrap.sh
# Requirements: macOS 13+ on Apple Silicon (M1/M2/M3/M4/M5)
# =============================================================================

set -euo pipefail

# ─── Colors & helpers ────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*"; exit 1; }
step()    { echo -e "\n${BOLD}${BLUE}━━━ $* ━━━${RESET}"; }
banner()  {
  echo -e "${BOLD}${CYAN}"
  echo "  ███████╗██████╗ ███████╗███████╗██████╗  ██████╗ ███╗   ███╗ ██████╗ ██████╗ ██████╗ ███████╗"
  echo "  ██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗██╔═══██╗████╗ ████║██╔════╝██╔═══██╗██╔══██╗██╔════╝"
  echo "  █████╗  ██████╔╝█████╗  █████╗  ██║  ██║██║   ██║██╔████╔██║██║     ██║   ██║██║  ██║█████╗"
  echo "  ██╔══╝  ██╔══██╗██╔══╝  ██╔══╝  ██║  ██║██║   ██║██║╚██╔╝██║██║     ██║   ██║██║  ██║██╔══╝"
  echo "  ██║     ██║  ██║███████╗███████╗██████╔╝╚██████╔╝██║ ╚═╝ ██║╚██████╗╚██████╔╝██████╔╝███████╗"
  echo "  ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝  ╚═════╝ ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝"
  echo -e "${RESET}"
  echo -e "  ${BOLD}Local AI Coding Agent — Apple Silicon Edition${RESET}"
  echo -e "  ${CYAN}Powered by Ollama + Qwen2.5-Coder 32B + Continue.dev + MCP${RESET}\n"
}

# ─── Environment ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/logs/bootstrap_$(date +%Y%m%d_%H%M%S).log"

# Source .env if present (allows OLLAMA_MODEL override)
[[ -f "${SCRIPT_DIR}/.env" ]] && source "${SCRIPT_DIR}/.env"

# Default to 32b unless overridden via .env or environment
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5-coder:32b}"

# Ensure logs directory exists
mkdir -p "${SCRIPT_DIR}/logs"
exec > >(tee -a "${LOG_FILE}") 2>&1

banner
info "Bootstrap log: ${LOG_FILE}"
info "Platform: $(uname -m) — $(sw_vers -productName) $(sw_vers -productVersion)"

# ─── Architecture check ───────────────────────────────────────────────────────
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
  warn "This script is optimized for Apple Silicon (arm64). Detected: $ARCH"
  warn "Proceeding, but performance may not be optimal."
fi

# ─── Step 1: Homebrew ─────────────────────────────────────────────────────────
step "Step 1: Homebrew"
if command -v brew &>/dev/null; then
  success "Homebrew already installed: $(brew --version | head -1)"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add to PATH for Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
  fi
  success "Homebrew installed"
fi

# ─── Step 2: Core CLI tools ───────────────────────────────────────────────────
step "Step 2: Core CLI tools (git, node, npm, python, uv, docker, ollama)"

install_brew_pkg() {
  local pkg="$1"
  local cmd="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    success "$pkg already installed: $($cmd --version 2>&1 | head -1)"
  else
    info "Installing $pkg..."
    brew install "$pkg"
    success "$pkg installed"
  fi
}

install_brew_pkg "git" "git"
install_brew_pkg "node" "node"
install_brew_pkg "python@3.12" "python3"

# uv — fast Python package manager
if command -v uv &>/dev/null; then
  success "uv already installed: $(uv --version)"
else
  info "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="${HOME}/.cargo/bin:${HOME}/.local/bin:${PATH}"
  success "uv installed"
fi

# Docker Desktop (Homebrew cask)
if command -v docker &>/dev/null; then
  success "Docker already installed: $(docker --version)"
else
  info "Installing Docker Desktop..."
  brew install --cask docker
  warn "Docker Desktop installed. Please launch Docker.app manually once and then re-run this script if needed."
fi

# Ollama
if command -v ollama &>/dev/null; then
  success "Ollama already installed: $(ollama --version 2>&1 | head -1)"
else
  info "Installing Ollama..."
  brew install ollama
  success "Ollama installed"
fi

# ─── Step 3: Start Ollama ─────────────────────────────────────────────────────
step "Step 3: Start Ollama service"
if pgrep -x "ollama" &>/dev/null; then
  success "Ollama service already running"
else
  info "Starting Ollama service in background..."
  nohup ollama serve >> "${SCRIPT_DIR}/logs/ollama.log" 2>&1 &
  sleep 3
  if pgrep -x "ollama" &>/dev/null; then
    success "Ollama service started (PID: $(pgrep -x ollama))"
  else
    warn "Ollama service may not have started. Check logs/ollama.log"
  fi
fi

# ─── Step 4: Pull Qwen2.5-Coder 32B ──────────────────────────────────────────
step "Step 4: Pull ${OLLAMA_MODEL}"
if ollama list 2>/dev/null | grep -q "${OLLAMA_MODEL}"; then
  success "${OLLAMA_MODEL} already downloaded"
else
  info "Pulling ${OLLAMA_MODEL} (~20 GB). This will take a while..."
  info "Model optimized for Apple Silicon Metal inference (Q4_K_M quantization)"
  ollama pull "${OLLAMA_MODEL}"
  success "${OLLAMA_MODEL} downloaded"
fi

# ─── Step 5: MCP servers (npm) ────────────────────────────────────────────────
step "Step 5: Install MCP servers"

# Fix npm global prefix to avoid permission errors on macOS
if [[ ! -d "${HOME}/.npm-global" ]]; then
  mkdir -p "${HOME}/.npm-global"
  npm config set prefix "${HOME}/.npm-global"
  info "npm global prefix set to ~/.npm-global"
fi
export PATH="${HOME}/.npm-global/bin:${PATH}"

install_npm_global() {
  local pkg="$1"
  if npm list -g "$pkg" &>/dev/null 2>&1; then
    success "$pkg already installed globally"
  else
    info "Installing $pkg..."
    npm install -g "$pkg"
    success "$pkg installed"
  fi
}

install_npm_global "@modelcontextprotocol/server-filesystem"

# Git MCP server (Python-based, more reliable)
if ! command -v mcp-server-git &>/dev/null; then
  info "Installing mcp-server-git via pip..."
  pip3 install mcp-server-git 2>/dev/null || \
    warn "mcp-server-git not available via pip. Git context will use Continue.dev built-in."
fi

# Shell MCP server (community package)
info "Installing MCP shell server..."
npm install -g "@modelcontextprotocol/server-shell" 2>/dev/null || \
  warn "Shell MCP server not available as npm package. Using local wrapper instead."

# ─── Step 6: Aider ────────────────────────────────────────────────────────────
step "Step 6: Install Aider"
if command -v aider &>/dev/null; then
  success "Aider already installed: $(aider --version 2>&1 | head -1)"
else
  info "Installing Aider..."
  # aider-chat requires Python <3.14. Use uv tool install which auto-selects
  # a compatible Python version (3.12), bypassing any system Python 3.14 issue.
  if command -v uv &>/dev/null; then
    uv tool install aider-chat
    export PATH="${HOME}/.local/bin:${PATH}"
  elif command -v pipx &>/dev/null; then
    # pipx fallback: force Python 3.12
    pipx install aider-chat --python "$(command -v python3.12 || echo python3)"
  else
    # Last resort: install pipx first, then aider
    pip3 install pipx
    python3 -m pipx install aider-chat --python "$(command -v python3.12 || echo python3)"
    export PATH="${HOME}/.local/bin:${PATH}"
  fi
  success "Aider installed"
fi

# ─── Step 7: Python virtual environment ──────────────────────────────────────
step "Step 7: Create Python virtual environment"
VENV_DIR="${SCRIPT_DIR}/.venv"
if [[ -d "${VENV_DIR}" ]]; then
  success "Virtual environment already exists: ${VENV_DIR}"
else
  info "Creating Python 3.12 virtual environment via uv..."
  uv venv "${VENV_DIR}" --python 3.12
  success "Virtual environment created"
fi

info "Activating virtual environment..."
source "${VENV_DIR}/bin/activate"

# ─── Step 8: Python packages ─────────────────────────────────────────────────
step "Step 8: Install Python packages"
info "Installing core scientific packages..."
uv pip install \
  numpy scipy pandas matplotlib sympy \
  jupyterlab ipykernel ipywidgets \
  torch torchvision torchaudio \
  transformers datasets tokenizers accelerate \
  requests httpx rich typer \
  pytest black ruff mypy \
  gitpython python-dotenv \
  2>&1 | tail -5
success "Python packages installed"

# Register Jupyter kernel for this venv
python -m ipykernel install --user --name freedomcode --display-name "FreedomCode (Python 3.12)" 2>/dev/null || true

# ─── Step 9: Create workspace directories ────────────────────────────────────
step "Step 9: Create workspace directories"
for dir in \
  "${SCRIPT_DIR}/workspace" \
  "${SCRIPT_DIR}/workspace/projects" \
  "${SCRIPT_DIR}/workspace/notebooks" \
  "${SCRIPT_DIR}/workspace/scratch" \
  "${SCRIPT_DIR}/sandbox" \
  "${SCRIPT_DIR}/logs" \
  "${SCRIPT_DIR}/docs" \
  "${SCRIPT_DIR}/examples"; do
  mkdir -p "$dir"
  success "Created: $dir"
done

# Create workspace .gitkeep files
touch "${SCRIPT_DIR}/workspace/.gitkeep"
touch "${SCRIPT_DIR}/sandbox/.gitkeep"
touch "${SCRIPT_DIR}/logs/.gitkeep"

# ─── Step 10: Continue.dev config ─────────────────────────────────────────────
step "Step 10: Configure Continue.dev"
CONTINUE_DIR="${HOME}/.continue"
mkdir -p "${CONTINUE_DIR}"

if [[ -f "${CONTINUE_DIR}/config.yaml" ]]; then
  info "Backing up existing Continue config..."
  cp "${CONTINUE_DIR}/config.yaml" "${CONTINUE_DIR}/config.yaml.bak.$(date +%Y%m%d_%H%M%S)"
fi

info "Installing Continue.dev config (model: ${OLLAMA_MODEL})..."
sed "s/qwen2.5-coder:32b/${OLLAMA_MODEL}/g" \
  "${SCRIPT_DIR}/continue/config.yaml" > "${CONTINUE_DIR}/config.yaml"
success "Continue.dev configured at ${CONTINUE_DIR}/config.yaml"

# ─── Step 11: Set executable permissions ─────────────────────────────────────
step "Step 11: Set script permissions"
chmod +x "${SCRIPT_DIR}/bootstrap.sh"
chmod +x "${SCRIPT_DIR}/scripts/"*.sh 2>/dev/null || true
success "Scripts are executable"

# ─── Step 12: Verify installation ─────────────────────────────────────────────
step "Step 12: Verification"
"${SCRIPT_DIR}/scripts/verify.sh" --quiet || warn "Some checks failed. Run scripts/verify.sh for details."

# ─── Done ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║          freedomcode bootstrap complete!                 ║${RESET}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${CYAN}Quick start:${RESET}"
echo -e "  ${BOLD}1.${RESET} Open VS Code:         ${YELLOW}code freedomcode.code-workspace${RESET}"
echo -e "  ${BOLD}2.${RESET} Install Continue.dev: Search 'Continue' in VS Code Extensions"
echo -e "  ${BOLD}3.${RESET} Start Aider:          ${YELLOW}./scripts/start-aider.sh${RESET}"
echo -e "  ${BOLD}4.${RESET} Start all services:   ${YELLOW}./scripts/start.sh${RESET}"
echo -e "  ${BOLD}5.${RESET} Verify stack:         ${YELLOW}./scripts/verify.sh${RESET}"
echo ""
echo -e "  ${CYAN}Model:${RESET}   ${OLLAMA_MODEL} (Ollama, Metal-accelerated)"
echo -e "  ${CYAN}Docs:${RESET}    ${SCRIPT_DIR}/README.md"
echo -e "  ${CYAN}Log:${RESET}     ${LOG_FILE}"
echo ""
