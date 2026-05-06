# Commands Reference

Four dedicated command references for the full end-to-end Copilot Studio development workflow.

---

## Files in this folder

| File | Tool | Use it for |
|------|------|-----------|
| [`pac-commands.md`](pac-commands.md) | pac CLI | Auth, environments, push, pull, publish, promote Dev→UAT→Prod |
| [`git-commands.md`](git-commands.md) | Git | Branching, committing, tagging, promoting across environments |
| [`vscode-commands.md`](vscode-commands.md) | VS Code | Keyboard shortcuts, Copilot Studio extension, YAML editing, find/replace |
| [`nodejs-commands.md`](nodejs-commands.md) | Node.js / npm | Batch eval (Kit), npm scripts, troubleshooting |

---

## Which file to open and when

| Situation | Open |
|-----------|------|
| First time setting up on a new machine | `pac-commands.md` → Section 1–2, then `vscode-commands.md` → Section 1 |
| Starting a new agent | `pac-commands.md` → Section 3–4, `git-commands.md` → Section 3 |
| Daily dev loop | `pac-commands.md` → Section 5 (quick card at bottom) |
| Promoting to UAT or Prod | `pac-commands.md` → Section 6, `git-commands.md` → Section 5 |
| Replacing `_REPLACE` node IDs | `vscode-commands.md` → Section 6 |
| Running automated evals | `nodejs-commands.md` → Section 2 |
| Something is broken | Check the quick reference card at the bottom of each file |

---

## Confirmed working on Windows 11

```powershell
winget install Microsoft.PowerAppsCLI   # pac CLI
winget install Microsoft.VisualStudioCode
winget install Git.Git
winget install OpenJS.NodeJS.LTS        # only needed for eval Kit
```
