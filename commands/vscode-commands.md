# VS Code Commands — Full Reference for Copilot Studio Dev

All VS Code keyboard shortcuts, command palette actions, and Copilot Studio extension commands used in agent development.

---

## 1. Install VS Code and Extensions

```bash
# Install VS Code via winget
winget install Microsoft.VisualStudioCode

# After install, open VS Code and install the Copilot Studio extension:
# Extensions panel (Ctrl+Shift+X) → search "Copilot Studio" → Install (publisher: Microsoft)

# Useful supporting extensions (optional but recommended):
# - YAML (by Red Hat)          → better YAML syntax highlighting
# - GitLens                    → see git blame inline while editing
# - indent-rainbow             → colour-coded indentation (critical for YAML)
```

**Verify Copilot Studio extension is active:**
Open any `.mcs.yml` file → Copilot Studio logo appears in the VS Code status bar (bottom).

---

## 2. Opening Your Agent Project

```bash
# Open the templates repo root in VS Code
code C:/projects/copilot-studio-templates

# Open just your agent folder
code C:/projects/copilot-studio-templates/agents/hr-assistant/

# Open a specific file directly
code agents/hr-assistant/agent.mcs.yml
```

---

## 3. Essential Keyboard Shortcuts

### Navigation

| Shortcut | What it does |
|----------|-------------|
| `Ctrl+P` | Quick open — type a filename to jump to it |
| `Ctrl+Shift+E` | Toggle Explorer sidebar (file tree) |
| `Ctrl+\`` | Open integrated terminal |
| `Ctrl+B` | Toggle sidebar visibility |
| `Ctrl+Shift+F` | Search across all files |
| `Ctrl+G` | Go to line number |
| `Ctrl+Shift+O` | Go to symbol (e.g. jump to a node `id:`) |

### Editing YAML

| Shortcut | What it does |
|----------|-------------|
| `Ctrl+Space` | Trigger IntelliSense / autocomplete |
| `Tab` | Accept autocomplete suggestion |
| `Ctrl+D` | Select next occurrence of highlighted text (multi-cursor edit) |
| `Ctrl+Shift+L` | Select ALL occurrences — use to rename all `_REPLACE` at once |
| `Alt+Shift+F` | Format document (auto-indent YAML) |
| `Ctrl+/` | Toggle comment on selected lines |
| `Alt+↑ / Alt+↓` | Move line up / down |
| `Ctrl+Z` | Undo |
| `Ctrl+Shift+Z` | Redo |

### Multi-cursor (critical for replacing `_REPLACE` node IDs)

| Shortcut | What it does |
|----------|-------------|
| `Ctrl+Shift+L` | Select all instances of highlighted text |
| `Alt+Click` | Add a cursor at click position |
| `Ctrl+Alt+↑/↓` | Add cursor above / below |

### File management

| Shortcut | What it does |
|----------|-------------|
| `Ctrl+N` | New file |
| `Ctrl+S` | Save |
| `Ctrl+Shift+S` | Save As |
| `Ctrl+W` | Close tab |
| `Ctrl+Shift+T` | Reopen last closed tab |

---

## 4. Command Palette — Copilot Studio Extension Commands

Open Command Palette with `Ctrl+Shift+P`, then type:

| Command | What it does |
|---------|-------------|
| `Copilot Studio: Apply Changes` | Push current agent folder to connected environment (replaces `pac copilot push`) |
| `Copilot Studio: Clone Agent` | Pull agent from environment into current folder |
| `Copilot Studio: Publish Agent` | Publish current draft to make it live |
| `Copilot Studio: Open Agent` | Open and sign in to an agent in the UI |
| `Copilot Studio: Select Environment` | Switch active environment |
| `Copilot Studio: Sign In` | Authenticate with Microsoft account |
| `Copilot Studio: Sign Out` | Sign out |
| `Copilot Studio: Validate Agent` | Validate YAML schema without pushing |

---

## 5. Terminal Inside VS Code

Open terminal: `` Ctrl+` ``

Run pac commands directly inside VS Code — no separate terminal window needed:

```bash
pac env who                                    # confirm active environment
# To push (apply changes): Ctrl+Shift+P → "Copilot Studio: Apply Changes"
pac copilot publish --bot "<AgentName>"        # publish
start https://make.preview.microsoft.com       # open in browser
# Then: select environment → Copilot Studio → click your agent → Test pane

git status                   # check git state
git add .
git commit -m "your message"
git push origin feature/hr-assistant
```

Split terminal (run two commands in parallel):
- `Ctrl+Shift+5` → split terminal
- Left: apply changes via `Ctrl+Shift+P → "Copilot Studio: Apply Changes"`
- Right: watch git log or run validation

---

## 6. Find and Replace `_REPLACE` Node IDs

After copying a scaffold or template, replace all `_REPLACE` suffixes with unique IDs.

**In VS Code:**

1. `Ctrl+H` → open Find and Replace
2. In Find box: `_REPLACE\d*`
3. Check **Use Regular Expression** (`Alt+R` or the `.*` icon)
4. Replace each one with a unique 6-char string (e.g. `a1b2c3`)
5. Click **Replace** (not Replace All — each ID should be unique)

**Or use the terminal script:**

```powershell
# Windows PowerShell — run from your agent folder
Get-ChildItem -Recurse -Filter "*.yml" | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  while ($content -match '_REPLACE\d*') {
    $id = -join ((97..122) + (48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
    $content = [regex]::Replace($content, '_REPLACE\d*', $id, 1)
  }
  Set-Content $_.FullName $content
}
```

---

## 7. Useful VS Code Settings for YAML / MCS Files

Add to `.vscode/settings.json` in your project root:

```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "files.associations": {
    "*.mcs.yml": "yaml"
  },
  "yaml.schemas": {},
  "editor.formatOnSave": false,
  "editor.rulers": [120],
  "editor.wordWrap": "on"
}
```

**Why `formatOnSave: false`:** YAML formatters can change indentation and break `.mcs.yml` files — format manually with `Alt+Shift+F` only when needed.

---

## 8. Searching Across Agent Files

```
Ctrl+Shift+F    → Search across all files

Useful searches:
  _REPLACE        → find any node IDs not yet replaced
  <              → find any placeholders not yet filled in
  SAFETY TIER    → find all connector actions and their tier declarations
  BeginDialog    → find all topic-to-topic calls
  LogCustomTelemetryEvent  → find all telemetry nodes
```

---

## 9. Split Editor — Compare Two YAML Files

Useful when copying a component and customising it:

1. Open the template file (e.g. `_scaffold/TopicScaffold.topic.mcs.yml`)
2. Right-click the file tab → **Split Right**
3. Open your copy in the right panel
4. Edit right panel while referencing the template on the left

---

## Quick Reference Card

| Task | Shortcut / Command |
|------|-------------------|
| Open file quickly | `Ctrl+P` → type filename |
| Search all files | `Ctrl+Shift+F` |
| Open terminal | `` Ctrl+` `` |
| Format YAML | `Alt+Shift+F` |
| Select all occurrences | `Ctrl+Shift+L` |
| Find and replace | `Ctrl+H` |
| Command palette | `Ctrl+Shift+P` |
| Push agent (apply changes) | `Ctrl+Shift+P` → `Copilot Studio: Apply Changes` |
| Validate YAML | `Ctrl+Shift+P` → `Copilot Studio: Validate Agent` |
| Go to line | `Ctrl+G` |
| Toggle sidebar | `Ctrl+B` |
