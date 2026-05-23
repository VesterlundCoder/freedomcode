# freedomcode

> **Local-first AI coding agent for macOS Apple Silicon**
> A complete open-source replacement for Windsurf / Cursor / Claude Code — 100% private, 100% local.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: macOS Apple Silicon](https://img.shields.io/badge/Platform-macOS%20Apple%20Silicon-blue)](https://support.apple.com/en-us/HT211814)
[![Model: Qwen2.5-Coder 32B](https://img.shields.io/badge/Model-Qwen2.5--Coder%2032B-green)](https://ollama.com/library/qwen2.5-coder)

---

## Overview

**freedomcode** is a production-ready, privacy-first AI coding stack built entirely on open-source tools. No cloud API keys. No usage tracking. No subscription. Your code stays on your machine.

### Stack

| Component | Role | Tech |
|-----------|------|------|
| **Inference** | Run the LLM locally | [Ollama](https://ollama.com) |
| **Model** | 32B coding LLM | [Qwen2.5-Coder:32b](https://ollama.com/library/qwen2.5-coder) |
| **IDE Integration** | Autocomplete + chat | [Continue.dev](https://continue.dev) |
| **Context Protocol** | Filesystem, shell, git | [MCP](https://modelcontextprotocol.io) |
| **Agentic Coding** | Multi-file AI editing | [Aider](https://aider.chat) |
| **Sandbox** | Safe code execution | Docker |
| **Package Manager** | Fast Python envs | [uv](https://github.com/astral-sh/uv) |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    freedomcode stack                        │
│                                                             │
│  ┌──────────────┐     ┌─────────────────────────────────┐  │
│  │   VS Code    │────▶│         Continue.dev             │  │
│  │  (Editor)    │     │  Chat / Autocomplete / Edit      │  │
│  └──────────────┘     └──────────────┬──────────────────┘  │
│                                      │                      │
│  ┌──────────────┐     ┌──────────────▼──────────────────┐  │
│  │    Aider     │────▶│            Ollama                │  │
│  │ (CLI agent)  │     │   qwen2.5-coder:32b @ Metal      │  │
│  └──────────────┘     └──────────────┬──────────────────┘  │
│                                      │                      │
│  ┌───────────────────────────────────▼──────────────────┐  │
│  │                   MCP Servers                         │  │
│  │  ┌──────────────┐ ┌──────┐ ┌─────┐ ┌─────────────┐  │  │
│  │  │  Filesystem  │ │ Git  │ │Shell│ │   Python    │  │  │
│  │  │  (workspace) │ │      │ │     │ │  (sandbox)  │  │  │
│  │  └──────────────┘ └──────┘ └─────┘ └─────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │             Docker Sandbox (isolated exec)            │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
         Apple Silicon M-series · Metal GPU · 128 GB RAM
```

---

## Requirements

- macOS 13 Ventura or later
- Apple Silicon (M1 / M2 / M3 / M4 / M5)
- **≥ 32 GB RAM** (64+ GB recommended for 32B model at full quality)
- ~25 GB free disk space (model + tools)
- Internet connection for initial setup only

> **Note for M5 128 GB systems:** The 32B model runs at Q4_K_M quantization (~20 GB), leaving over 100 GB for your development work. Inference is fast (~30–60 tok/s).

---

## Installation

```bash
git clone git@github.com:VesterlundCoder/freedomcode.git
cd freedomcode
./bootstrap.sh
```

The bootstrap script will:
1. Install Homebrew (if missing)
2. Install git, node, python, uv, docker, ollama
3. Start Ollama and pull `qwen2.5-coder:32b` (~20 GB)
4. Install MCP servers via npm
5. Install Aider
6. Create Python venv with scientific + ML packages
7. Configure Continue.dev
8. Verify the full stack

**Estimated time:** 20–40 minutes (dominated by model download speed).

---

## VS Code Setup

```bash
# Open the workspace
code freedomcode.code-workspace
```

Install the **Continue** extension from the VS Code marketplace:
- Extension ID: `Continue.continue`
- Or search "Continue" in Extensions panel

Once installed, Continue will automatically pick up the configuration from `~/.continue/config.yaml`.

### Recommended Extensions (bundled in workspace config)
- `Continue.continue` — AI coding assistant
- `ms-python.python` — Python language support
- `ms-azuretools.vscode-docker` — Docker integration
- `eamodio.gitlens` — Advanced Git
- `charliermarsh.ruff` — Fast Python linter
- `ms-toolsai.jupyter` — Jupyter notebooks

---

## Usage

### Chat & Autocomplete (VS Code + Continue.dev)
- Press `⌘ + L` to open the chat panel
- Press `⌘ + I` for inline edit
- Tab autocomplete works automatically

### Agentic coding with Aider
```bash
./scripts/start-aider.sh
```
Aider will launch in your terminal with access to the workspace. Example commands:
```
/add src/main.py
/ask How should I refactor this class?
Write a unit test for the parse_results function
```

### Start all services
```bash
./scripts/start.sh
```

### JupyterLab
```bash
source .venv/bin/activate
jupyter lab --notebook-dir=workspace/notebooks
```

---

## MCP Configuration

MCP (Model Context Protocol) gives the AI agent structured access to your system.

| Server | Scope | Capability |
|--------|-------|------------|
| `filesystem` | `./workspace` only | Read, write, list files |
| `git` | current repo | Diff, log, status, blame |
| `shell` | restricted | Run safe commands |

> **Security:** Filesystem MCP is restricted to `./workspace`. It cannot access your home directory or system files.

---

## Security Model

```
┌─────────────────────────────────────────────────────┐
│  BOUNDARY: What the AI can touch                    │
│                                                     │
│  ✅ ./workspace/        — Full read/write access    │
│  ✅ Git operations      — Current repo only         │
│  ✅ Docker sandbox      — Isolated execution        │
│                                                     │
│  ❌ ~/.ssh             — NEVER accessible           │
│  ❌ ~/.config          — NEVER accessible           │
│  ❌ System files       — NEVER accessible           │
│  ❌ Other projects     — NEVER accessible           │
│  ❌ Internet           — Offline-first by default   │
└─────────────────────────────────────────────────────┘
```

**Principles:**
1. **Local-only inference** — Your code never leaves your machine
2. **Principle of least privilege** — MCP filesystem is scoped to `./workspace`
3. **Sandboxed execution** — Code runs in isolated Docker containers
4. **No telemetry** — Ollama and Continue run fully offline
5. **Auditable** — All configuration is plain YAML/JSON, no black boxes

---

## Directory Structure

```
freedomcode/
├── bootstrap.sh              # One-command installation
├── README.md                 # This file
├── .env.example              # Environment variable template
├── .gitignore                # Git ignore rules
├── docker-compose.yml        # Docker sandbox definition
├── freedomcode.code-workspace # VS Code multi-root workspace
│
├── continue/
│   └── config.yaml           # Continue.dev configuration
│
├── scripts/
│   ├── start.sh              # Start all services
│   ├── start-aider.sh        # Launch Aider agent
│   ├── verify.sh             # Verify stack health
│   └── update.sh             # Update all components
│
├── mcp/
│   ├── filesystem/           # Filesystem MCP config
│   ├── shell/                # Shell MCP config
│   ├── git/                  # Git MCP config
│   └── python/               # Python MCP config
│
├── sandbox/                  # Docker sandbox files
├── workspace/                # YOUR working directory (AI-accessible)
│   ├── projects/             # Code projects
│   ├── notebooks/            # Jupyter notebooks
│   └── scratch/              # Temporary files
│
├── docs/                     # Extended documentation
├── examples/                 # Example workflows
├── logs/                     # Runtime logs
└── .venv/                    # Python virtual environment (created by bootstrap)
```

---

## Troubleshooting

### Ollama not starting
```bash
# Check if already running
pgrep ollama
# Start manually
ollama serve
# Check logs
tail -f logs/ollama.log
```

### Model not responding
```bash
# Verify model is downloaded
ollama list
# Test directly
ollama run qwen2.5-coder:32b "Hello, write a Python hello world"
```

### Continue.dev not connecting
1. Ensure Ollama is running: `pgrep ollama`
2. Test endpoint: `curl http://localhost:11434/api/tags`
3. Check Continue config: `cat ~/.continue/config.yaml`
4. Reload VS Code window: `Cmd+Shift+P → Developer: Reload Window`

### MCP not working
```bash
# Test filesystem MCP
npx @modelcontextprotocol/server-filesystem ./workspace

# Verify npm packages
npm list -g @modelcontextprotocol/server-filesystem
```

### Docker issues
```bash
# Ensure Docker Desktop is running
docker info
# Test sandbox
docker-compose up sandbox
```

### Re-run bootstrap (safe, idempotent)
```bash
./bootstrap.sh
```

### Full verification
```bash
./scripts/verify.sh
```

---

## Scripts Reference

| Script | Description |
|--------|-------------|
| `./bootstrap.sh` | Full one-command setup |
| `./scripts/start.sh` | Start Ollama + services |
| `./scripts/start-aider.sh` | Launch Aider in workspace |
| `./scripts/verify.sh` | Health check all components |
| `./scripts/update.sh` | Update all packages |

---

## Roadmap

- [x] Ollama + Qwen2.5-Coder 32B integration
- [x] Continue.dev chat + autocomplete
- [x] MCP filesystem / git / shell servers
- [x] Aider multi-file agent
- [x] Docker sandbox
- [x] Python scientific stack
- [ ] RAG over local codebase (LlamaIndex)
- [ ] Voice-to-code (Whisper)
- [ ] Multi-model routing (fast: 7B, quality: 32B)
- [ ] Web UI (Open WebUI integration)
- [ ] Persistent memory (mem0)
- [ ] Auto-test runner on each AI edit
- [ ] GitHub Actions integration

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes
4. Push and open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE)

---

## Acknowledgements

- [Ollama](https://ollama.com) — Local LLM runtime
- [Qwen team (Alibaba)](https://github.com/QwenLM/Qwen2.5-Coder) — Qwen2.5-Coder model
- [Continue.dev](https://continue.dev) — Open-source IDE extension
- [Model Context Protocol](https://modelcontextprotocol.io) — Anthropic MCP
- [Aider](https://aider.chat) — AI pair programming CLI
- [uv](https://github.com/astral-sh/uv) — Rust-based Python package manager
