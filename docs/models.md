# Model Guide

## Primary Model: qwen2.5-coder:32b

| Property | Value |
|----------|-------|
| Parameters | 32B |
| Quantization | Q4_K_M |
| Disk size | ~20 GB |
| RAM usage | ~22 GB (unified memory) |
| Context | 32,768 tokens |
| Speed (M5 128GB) | ~30–60 tok/s |
| Languages | 92 |
| License | Apache 2.0 |

**Best for:** Complex code generation, multi-file refactoring, architecture discussions, detailed code review.

## Alternative Models

Pull with `ollama pull <model>`:

### Fast (lighter RAM usage)
```bash
ollama pull qwen2.5-coder:7b    # ~4.5 GB, ~150 tok/s
ollama pull qwen2.5-coder:14b   # ~9 GB, ~90 tok/s
ollama pull deepseek-coder-v2:16b  # ~9 GB, great for code
```

### Maximum quality (128 GB RAM recommended)
```bash
ollama pull qwen2.5-coder:72b   # ~42 GB, best quality
ollama pull deepseek-r1:70b     # ~40 GB, reasoning model
```

### Instruct / General
```bash
ollama pull llama3.3:70b        # ~40 GB, great general assistant
ollama pull mistral-nemo:12b    # ~7 GB, fast + good
```

## Changing the Model

Edit `~/.continue/config.yaml` (or `continue/config.yaml` and re-run bootstrap):

```yaml
models:
  - name: My Custom Model
    provider: ollama
    model: qwen2.5-coder:7b  # change this
```

Or for Aider:
```bash
AIDER_MODEL=ollama/qwen2.5-coder:7b ./scripts/start-aider.sh
```

## Performance on Apple Silicon

| Chip | RAM | Recommended model |
|------|-----|-------------------|
| M1 / M2 | 16 GB | qwen2.5-coder:7b |
| M2 Pro | 32 GB | qwen2.5-coder:14b |
| M3 Max | 64 GB | qwen2.5-coder:32b (Q4) |
| M4 / M5 | 128 GB | qwen2.5-coder:32b (Q8) |
