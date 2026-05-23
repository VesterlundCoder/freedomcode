# MCP Example Workflows

These examples show how to use freedomcode's MCP integration in Continue.dev chat.

## Filesystem MCP

Open Continue.dev chat (`⌘+L`) and try:

```
@filesystem List all Python files in the workspace
```

```
@filesystem Read the file workspace/projects/myapp/main.py and suggest improvements
```

```
@filesystem Create a new file workspace/projects/myapp/utils.py with a function
that reads JSON files safely
```

## Git MCP

```
@git What's the current git status?
```

```
@git Show me the diff of my last 3 commits
```

```
@git Generate a conventional commit message for my staged changes
```

## Shell MCP

```
@shell Run the tests in workspace/projects/myapp/
```

```
@shell Show me the directory tree of workspace/
```

## Codebase Context

Use `@codebase` to give Continue.dev full context of your project:

```
@codebase Explain the overall architecture of this project
```

```
@codebase Find all places where we handle errors and suggest improvements
```

## Continue.dev Slash Commands

- `/commit` — Generate a git commit message
- `/review` — Code review of current file
- `/test` — Generate unit tests
- `/explain` — Explain selected code
- `/refactor` — Suggest refactoring

## Example: Full workflow

1. Open `workspace/projects/` in VS Code
2. Create a new Python file
3. Start typing — autocomplete activates automatically
4. Press `⌘+L` for chat: "Write a REST API client for the OpenWeatherMap API"
5. Continue will generate the code, reading your project context via MCP
6. Use `/test` to generate tests for it
7. Use `/commit` to create a commit message
