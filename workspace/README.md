# workspace/

This is your AI-accessible working directory.

The MCP filesystem server has **read/write access** to this directory only.
Your home directory and system files are never accessible to the AI.

## Structure

```
workspace/
├── projects/    # Your code projects
├── notebooks/   # Jupyter notebooks
└── scratch/     # Temporary files and experiments
```

## Usage

- Put all projects you want the AI to work with **in this directory**
- Open files from here in VS Code — Continue.dev will automatically have context
- Run `./scripts/start-aider.sh` to work with files here via the Aider agent

## Security

Only files inside this directory can be accessed by:
- MCP filesystem server
- Aider agent (when launched via start-aider.sh)
- Docker sandbox (mounts this directory)
