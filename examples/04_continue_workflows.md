# Continue.dev Workflows

## Setup Verification

After running `bootstrap.sh` and installing the Continue.dev VS Code extension:

1. Open `freedomcode.code-workspace` in VS Code
2. You should see the Continue sidebar icon (usually a ▶ play button)
3. Press `⌘+L` to open chat
4. Type: "Hello! Can you confirm you're running Qwen2.5-Coder 32B locally?"

## Chat Workflows

### Code Generation

```
Write a Python class for managing a local SQLite database with:
- CRUD operations
- Context manager support
- Automatic schema migration
```

### Code Review

Select code, right-click → "Continue: Review selection"
Or in chat: `@file:src/main.py Review this file for security issues`

### Explain Code

Select any code block and use `⌘+L` then:
```
Explain what this code does, focusing on the algorithm
```

### Refactoring

```
@codebase Identify the top 3 refactoring opportunities in this codebase
and suggest concrete improvements for each one
```

### Documentation

```
Generate comprehensive docstrings for all public functions in @file:src/utils.py
following Google docstring style
```

## Autocomplete Tips

- Autocomplete triggers automatically as you type
- Press `Tab` to accept a suggestion
- Press `Esc` to dismiss
- Works best when you have a clear function signature or comment above

## Inline Edit (`⌘+I`)

1. Select a block of code
2. Press `⌘+I`
3. Type your instruction: "Optimize this for memory efficiency"
4. Continue will propose a replacement in a diff view
5. Accept/reject with the toolbar buttons

## Context Management

### Add files to context
```
@file:src/main.py @file:src/utils.py
How do these two files interact? What's missing?
```

### Codebase search
```
@codebase Where is the authentication logic handled?
```

### Use git diff
```
@diff Review my changes and suggest improvements before I commit
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘+L` | Open/focus Continue chat |
| `⌘+I` | Inline edit selected code |
| `Tab` | Accept autocomplete |
| `Esc` | Dismiss autocomplete |
| `⌘+Shift+L` | Add selection to chat |
