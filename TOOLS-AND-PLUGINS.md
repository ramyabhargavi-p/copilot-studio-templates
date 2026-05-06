# Tools, Plugins, and Extensions

Everything you need installed to build, deploy, and operate Copilot Studio agents efficiently.

---

## Required Tools

These are not optional — you need all of them.

### 1 — Power Platform CLI (`pac`)

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
pac auth create --environment <env-url>   # authenticate
pac copilot push                          # push YAML to environment
pac copilot list                          # list agents in environment
pac env list                              # list environments
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

### 4 — Node.js (for Copilot Studio Kit)

Required only if you plan to run batch evaluations via the Copilot Studio Kit CLI.

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
code --install-extension ms-powerplatform.powerplatform-vscode-extension
code --install-extension redhat.vscode-yaml
code --install-extension eamodio.gitlens
code --install-extension ms-powerplatform.vscode-powerplatform
code --install-extension yzhang.markdown-all-in-one
code --install-extension aaron-bond.better-comments
code --install-extension oderwat.indent-rainbow
```

---

## Recommended Browser Extensions

| Extension | Browser | Why |
|-----------|---------|-----|
| **Microsoft Power Platform Admin Center** | Any | Bookmark the admin center for quick access to connections, environments, DLP |
| **Azure Portal** | Any | Bookmark for Azure AD app registrations and Application Insights |

No browser extension is strictly required. The tools above are desktop-only.

---

## Copilot Studio Kit

The official Microsoft open-source toolkit for Copilot Studio — provides batch evaluation, test automation, and additional CLI commands beyond what `pac` offers.

**Repository:** https://github.com/microsoft/Copilot-Studio-Kit

**What it adds:**
- Batch eval CSV runner (`copilot-studio-kit eval run`)
- Test report generation
- Additional diagnostic commands

**Install:**
```bash
git clone https://github.com/microsoft/Copilot-Studio-Kit
cd Copilot-Studio-Kit
npm install
npm run build
```

**Use with this repo:**
- Run eval: `copilot-studio-kit eval run --eval-file evals/<agent>-eval.csv --environment <env-id>`
- See `project-delivery/05-eval-scenarios.md` for how to build the eval CSV

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
