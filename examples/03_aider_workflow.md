# Aider Workflow Examples

## Start Aider

```bash
./scripts/start-aider.sh
```

## Basic Commands

```
# Add a file to context
/add src/main.py

# Add multiple files
/add src/main.py src/utils.py tests/test_main.py

# Show current context
/ls

# Ask a question without editing
/ask What does this function do?

# Ask Aider to implement something
Implement a function that parses CSV files with error handling

# Make a targeted change
Refactor the DataProcessor class to use a strategy pattern

# Write tests
Write pytest unit tests for the parse_csv function with edge cases

# Fix a bug
Fix the off-by-one error in the sliding window function
```

## Multi-file editing

Aider can edit multiple files in one shot:

```
Add logging to all functions in src/ using the Python logging module,
and update the main entry point to configure log level from environment
```

## Git integration

```
# Aider commits automatically (or disable with --no-auto-commits)
# View what Aider committed
git log --oneline -5

# Undo last Aider commit
/undo
```

## Tips for Apple Silicon

- Qwen2.5-Coder 32B runs at ~30-60 tokens/second on M5 128GB
- Use `--no-stream` for faster batch responses
- Context window is 32k tokens — works great for large codebases

## Example: Build a CLI tool

```bash
cd workspace/projects
mkdir my-cli-tool
cd my-cli-tool
../../scripts/start-aider.sh

# In Aider:
Create a CLI tool using typer that:
1. Reads a directory of Python files
2. Counts lines of code per file
3. Outputs a sorted table using rich
```
