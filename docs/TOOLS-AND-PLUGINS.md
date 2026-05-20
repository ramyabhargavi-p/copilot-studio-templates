# Tools, Plugins, and Extensions

Everything you need installed to build, deploy, and operate Copilot Studio agents efficiently.

---

## Required Tools

These are not optional — you need all of them.

### 1 — Power Platform CLI (`pac`)

> **This is the canonical install reference for the PAC CLI.** Other docs in this repo link here.

The command-line tool for pushing YAML to a Power Platform environment and publishing agents.

**Install:**
```powershell
# Windows — via dotnet tool
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Or download the installer
# https://learn.microsoft.com/power-platform/developer/cli/introduction
```

**Verify:**
```bash
pac --version
```

**Key commands used in this repo:**
```bash
pac auth create                           # authenticate (browser sign-in)
pac copilot list                          # list agents in environment
pac copilot extract-template              # download an existing agent as a single YAML file
pac copilot publish --bot "<display name or Copilot ID>"   # publish a draft to live — NOT schema name
pac env list                              # list environments
pac env select --environment "Dev - ..."  # switch active environment
```


---

### 2 — VS Code Copilot Studio Extension

Real-time YAML schema validation, IntelliSense for node kinds, and auto-generation of node IDs. Makes editing `.mcs.yml` files significantly less error-prone.

**Install:** VS Code → Extensions → search **"Copilot Studio"** (publisher: Microsoft)

**What it does:**
- Highlights schema errors in `.mcs.yml` files as you type
- Auto-generates unique node IDs when you save (replaces `_REPLACE` suffixes)
- Provides autocomplete for `kind:`, property names, and valid values
- Shows the topic structure in the Explorer sidebar

**Important:** After install, open a `.mcs.yml` file — if the extension is active, you'll see the Copilot Studio logo in the status bar and IntelliSense suggestions.

---

### 3 — Git

Version control for your agent YAML. Required for the CI/CD workflows in `ci-cd/`.

**Install:** https://git-scm.com/downloads

**Minimum setup:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"
```

---

### 4 — Node.js

Required only if you run the Copilot Studio Kit batch evaluation scripts locally. Not needed for the managed solution install.

**Install:** https://nodejs.org (LTS version)

---

## Recommended VS Code Extensions

Install these alongside the Copilot Studio extension for a complete development environment.

| Extension | Publisher | Why |
|-----------|-----------|-----|
| **Copilot Studio** | Microsoft | YAML validation and IntelliSense for `.mcs.yml` — **essential** |
| **YAML** | Red Hat | General YAML support, shows whitespace issues, validates indentation |
| **GitLens** | GitKraken | Enhanced git history, blame annotations — useful for tracking YAML changes |
| **Power Platform Tools** | Microsoft | Broader Power Platform tooling including environment management |
| **Markdown All in One** | Yu Zhang | Preview and edit the `.md` files in this repo |
| **Better Comments** | Aaron Bond | Colour-codes `# TODO`, `# !` warning comments in YAML |
| **indent-rainbow** | oderwat | Colour-codes indentation levels — critical for YAML where indent errors are invisible |

**Install all at once (paste in terminal):**
```bash
code --install-extension ms-CopilotStudio.vscode-copilotstudio
code --install-extension redhat.vscode-yaml
code --install-extension eamodio.gitlens
code --install-extension microsoft-IsvExpTools.powerplatform-vscode
code --install-extension yzhang.markdown-all-in-one
code --install-extension aaron-bond.better-comments
code --install-extension oderwat.indent-rainbow
```

---

## Useful Bookmarks

Bookmark these in your browser — no extension required.

| Site | Why |
|------|-----|
| **Microsoft Power Platform Admin Center** | Connections, environments, DLP policies |
| **Azure Portal** | Azure AD app registrations and Application Insights |

---

## Copilot Studio Kit (Power CAT)

A Microsoft Power Platform **managed solution** for testing, evaluating, and governing Copilot Studio agents. Installed into your Power Platform environment — not an npm package.

**What it provides:**
- Agent inventory and compliance dashboard
- Batch evaluation of agent responses against test cases
- SharePoint content synchronization for knowledge sources
- Conversation KPI reporting in Power BI

**Install:** Download and import the managed solution from the [Power CAT Copilot Studio Kit releases](https://github.com/microsoft/Power-CAT-Copilot-Studio-Kit/releases/) or install via [AppSource](https://aka.ms/DownloadCopilotStudioKit).

> **Note:** This is not a CLI tool. It does not add `pac copilot push` or any terminal command.
> For pushing agent YAML from local files, use the VS Code extension **Apply Changes** (Cloud-First path)
> or `pac copilot create` to create an agent from a template YAML file.

**Relevant pac CLI commands (built into standard pac CLI — no extra install):**

| Command | What it does |
|---------|-------------|
| `pac copilot create --displayName "X" --schemaName "x" --solution "Default" --templateFileName t.yaml` | Create a new agent from a template YAML |
| `pac copilot extract-template --bot "<display name or Copilot ID>" --templateFileName output.yaml` | Download existing agent as a template YAML file. Use display name or Copilot ID from `pac copilot list` — not schema name |
| `pac copilot publish --bot "<display name or Copilot ID>"` | Publish the current agent draft to live. Use display name or Copilot ID — not schema name |
| `pac copilot list` | List agents in the current environment |

---

## Azure Tools (for operations)

| Tool | Purpose | Install |
|------|---------|---------|
| **Azure Portal** (web) | Application Insights queries, alert setup | https://portal.azure.com |
| **Azure CLI** | Script-based alert creation, resource management | `winget install Microsoft.AzureCLI` |
| **Azure Monitor Workbooks** | Build dashboard from monitoring queries | Available in Azure Portal |

---

## Optional — Power Platform Center of Excellence Starter Kit

If your organisation is deploying multiple agents, the CoE Starter Kit provides governance tooling: agent inventory, usage reporting, environment management.

**Repository:** https://github.com/microsoft/powerapps-tools/tree/master/Administration/CoEStarterKit

**When to use:** When you have 5+ agents across multiple environments and need a centralised view.

---

## Environment Setup Checklist

After installing everything above:

```
[ ] pac --version shows a version number
[ ] pac auth create successfully authenticates to your dev environment
[ ] VS Code opens a .mcs.yml file with IntelliSense (Copilot Studio extension active)
[ ] git status works in your agent project folder
[ ] Application Insights is connected (Copilot Studio → Settings → Telemetry)
```
