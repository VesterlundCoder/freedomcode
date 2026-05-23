#!/usr/bin/env bash
# =============================================================================
# freedomcode — scripts/verify.sh
# Verify all components of the stack are installed and functional
# =============================================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUIET="${1:-}"

# Source .env for OLLAMA_MODEL override; extend PATH for npm-global + uv
[[ -f "${SCRIPT_DIR}/.env" ]] && source "${SCRIPT_DIR}/.env"
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen2.5-coder:32b}"
export PATH="${HOME}/.npm-global/bin:${HOME}/.local/bin:${PATH}"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

PASS=0; FAIL=0; WARN=0

check_pass() { echo -e "  ${GREEN}✓${RESET} $*"; ((PASS++)); }
check_fail() { echo -e "  ${RED}✗${RESET} $*"; ((FAIL++)); }
check_warn() { echo -e "  ${YELLOW}!${RESET} $*"; ((WARN++)); }
section()    { echo -e "\n${BOLD}${CYAN}── $* ──${RESET}"; }

[[ -z "$QUIET" ]] && echo -e "\n${BOLD}freedomcode — Stack Verification${RESET}\n"

# ─── Core tools ───────────────────────────────────────────────────────────────
section "Core Tools"

if command -v brew &>/dev/null; then
  check_pass "Homebrew: $(brew --version | head -1)"
else
  check_fail "Homebrew: NOT FOUND"
fi

command -v git &>/dev/null && \
  check_pass "git: $(git --version)" || \
  check_fail "git: NOT FOUND"

command -v node &>/dev/null && \
  check_pass "node: $(node --version)" || \
  check_fail "node: NOT FOUND"

command -v npm &>/dev/null && \
  check_pass "npm: $(npm --version)" || \
  check_fail "npm: NOT FOUND"

command -v python3 &>/dev/null && \
  check_pass "python3: $(python3 --version)" || \
  check_fail "python3: NOT FOUND"

command -v uv &>/dev/null && \
  check_pass "uv: $(uv --version)" || \
  check_warn "uv: NOT FOUND (optional, but recommended)"

# ─── Ollama ───────────────────────────────────────────────────────────────────
section "Ollama"

command -v ollama &>/dev/null && \
  check_pass "ollama binary: $(ollama --version 2>&1 | head -1)" || \
  check_fail "ollama: NOT FOUND — run: brew install ollama"

if pgrep -x "ollama" &>/dev/null; then
  check_pass "Ollama service: running (PID: $(pgrep -x ollama))"
else
  check_warn "Ollama service: NOT running — run: ollama serve"
fi

if curl -sf http://localhost:11434/api/tags &>/dev/null; then
  check_pass "Ollama API: responding at http://localhost:11434"
else
  check_warn "Ollama API: not reachable (is service running?)"
fi

if ollama list 2>/dev/null | grep -q "${OLLAMA_MODEL}"; then
  check_pass "Model ${OLLAMA_MODEL}: installed"
else
  check_fail "Model ${OLLAMA_MODEL}: NOT installed — run: ollama pull ${OLLAMA_MODEL}"
fi

# ─── MCP servers ──────────────────────────────────────────────────────────────
section "MCP Servers (npm)"

npm list -g @modelcontextprotocol/server-filesystem &>/dev/null && \
  check_pass "@modelcontextprotocol/server-filesystem: installed" || \
  check_fail "@modelcontextprotocol/server-filesystem: NOT installed"

npm list -g @modelcontextprotocol/server-git &>/dev/null && \
  check_pass "@modelcontextprotocol/server-git: installed" || \
  check_warn "@modelcontextprotocol/server-git: not on npm (git context via Continue.dev built-in)"

# ─── Aider ────────────────────────────────────────────────────────────────────
section "Aider"

command -v aider &>/dev/null && \
  check_pass "aider: $(aider --version 2>&1 | head -1)" || \
  check_fail "aider: NOT FOUND — run: pip install aider-chat"

# ─── Python venv ──────────────────────────────────────────────────────────────
section "Python Environment"

if [[ -d "${SCRIPT_DIR}/.venv" ]]; then
  check_pass "Python venv: ${SCRIPT_DIR}/.venv"
  VENV_PYTHON="${SCRIPT_DIR}/.venv/bin/python"
  for pkg in numpy scipy pandas sympy torch; do
    "$VENV_PYTHON" -c "import $pkg" 2>/dev/null && \
      check_pass "  $pkg: available" || \
      check_warn "  $pkg: NOT available in venv"
  done
else
  check_fail "Python venv: NOT FOUND at ${SCRIPT_DIR}/.venv"
fi

# ─── Continue.dev ─────────────────────────────────────────────────────────────
section "Continue.dev"

if [[ -f "${HOME}/.continue/config.yaml" ]]; then
  check_pass "Continue config: ${HOME}/.continue/config.yaml"
  grep -q "qwen2.5-coder" "${HOME}/.continue/config.yaml" && \
    check_pass "  Model configured: qwen2.5-coder" || \
    check_warn "  Model not configured in config.yaml"
else
  check_warn "Continue config: NOT FOUND at ~/.continue/config.yaml"
  check_warn "  Run bootstrap.sh or copy continue/config.yaml manually"
fi

# ─── Docker ───────────────────────────────────────────────────────────────────
section "Docker"

command -v docker &>/dev/null && \
  check_pass "docker CLI: $(docker --version)" || \
  check_warn "docker: NOT FOUND (optional, needed for sandbox)"

if docker info &>/dev/null 2>&1; then
  check_pass "Docker daemon: running"
else
  check_warn "Docker daemon: NOT running (start Docker Desktop)"
fi

# ─── Directory structure ──────────────────────────────────────────────────────
section "Directory Structure"

for dir in workspace sandbox logs scripts continue mcp docs examples; do
  [[ -d "${SCRIPT_DIR}/${dir}" ]] && \
    check_pass "${dir}/: exists" || \
    check_warn "${dir}/: missing (run bootstrap.sh)"
done

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════${RESET}"
echo -e "  ${GREEN}✓ Passed:${RESET}  ${PASS}"
echo -e "  ${YELLOW}! Warnings:${RESET} ${WARN}"
echo -e "  ${RED}✗ Failed:${RESET}  ${FAIL}"
echo -e "${BOLD}══════════════════════════════════════${RESET}"
echo ""

if [[ $FAIL -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}Stack is healthy! Ready to code.${RESET}"
  exit 0
else
  echo -e "${RED}${BOLD}${FAIL} issue(s) found. Run ./bootstrap.sh to fix.${RESET}"
  exit 1
fi
