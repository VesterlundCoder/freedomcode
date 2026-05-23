# Architecture Deep Dive

## Component Overview

### Ollama
- Local LLM inference runtime
- Exposes OpenAI-compatible REST API at `http://localhost:11434`
- Handles model loading, tokenization, and Metal GPU dispatch
- Apple Silicon: Uses Metal Performance Shaders (MPS) via llama.cpp backend

### Qwen2.5-Coder 32B
- 32B parameter code-specialized LLM by Alibaba
- Quantized: Q4_K_M (~20 GB VRAM/RAM)
- Context window: 32,768 tokens
- Trained on 5.5T tokens of code and text
- Supports 92 programming languages

### Continue.dev
- VS Code extension providing IDE-native AI interface
- Communicates with Ollama via REST API
- MCP integration for context injection (filesystem, git, shell)
- Tab autocomplete via FIM (Fill-In-Middle) model calls

### MCP (Model Context Protocol)
- Anthropic's open standard for AI-tool interfaces
- Servers expose "tools" and "resources" to the LLM
- freedomcode ships: filesystem, git, shell, python servers
- Transport: stdin/stdout JSON-RPC 2.0

### Aider
- Command-line AI coding agent
- Repository-aware: understands your full codebase via git
- Sends diffs to Ollama, applies them automatically
- Supports whole-repo refactoring across many files simultaneously

### Docker Sandbox
- Isolated execution environment for AI-generated code
- `network_mode: none` — completely air-gapped
- `mem_limit: 4g` — bounded resource usage
- Mounts only `./workspace` — no host system access

## Data Flow

```
User types code / prompt
        │
        ▼
  Continue.dev (VS Code extension)
        │
        ├── Tab autocomplete ──────────────────────────┐
        │                                              │
        ├── Chat request ─────────────────────────┐   │
        │                                         │   │
        ▼                                         ▼   ▼
    MCP Servers                              Ollama REST API
    (filesystem, git, shell)                 http://localhost:11434
        │                                         │
        │                                         ▼
        └────── Context injection ──────► qwen2.5-coder:32b
                                              (Metal GPU)
                                                  │
                                                  ▼
                                         Generated response
                                                  │
                               ┌──────────────────┴──────────────┐
                               │                                  │
                               ▼                                  ▼
                        Inline edit diff                     Chat response
                        (applied to file)               (displayed in panel)
```

## Security Boundaries

```
┌─────────────────────────────────────────────────────────────────────┐
│  TRUSTED ZONE (AI can read/write)                                   │
│  ┌─────────────────────────────────────────────────────────┐        │
│  │  ./workspace/                                           │        │
│  │  Git operations on current repo                         │        │
│  └─────────────────────────────────────────────────────────┘        │
│                                                                     │
│  EXECUTION ZONE (sandboxed)                                         │
│  ┌─────────────────────────────────────────────────────────┐        │
│  │  Docker: network=none, mem=4g, mounts workspace only    │        │
│  └─────────────────────────────────────────────────────────┘        │
│                                                                     │
│  FORBIDDEN ZONE (never accessible)                                  │
│  ~/.ssh, ~/.config, ~/.aws, /etc, /var, /System                     │
│  Any path outside ./workspace                                       │
└─────────────────────────────────────────────────────────────────────┘
```
