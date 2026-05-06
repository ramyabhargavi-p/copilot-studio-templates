# Node.js and npm Commands — Reference for Copilot Studio Dev

Node.js is used for the Copilot Studio Kit (batch evaluation and testing), and optionally for the pac CLI via npm. Not required for basic agent development — only needed if you run automated evals or build custom tooling.

---

## 1. Install Node.js

```powershell
# Windows — via winget (recommended)
winget install OpenJS.NodeJS.LTS

# Verify
node --version
# Expected: v20.X.X  (LTS version)

npm --version
# Expected: 10.X.X
```

**Note:** If npm commands fail with a PowerShell execution policy error:
```powershell
# Run PowerShell as Administrator, then:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 2. Copilot Studio Kit — Batch Evaluation

The Kit runs automated routing accuracy tests against your agent. Target: ≥ 85% routing accuracy before UAT.

```bash
# Clone the Kit (one-time)
git clone https://github.com/microsoft/Copilot-Studio-Kit.git
cd Copilot-Studio-Kit

# Install dependencies
npm install

# Build the Kit
npm run build

# Run evaluation against your agent
npm run eval -- --agent-name "HR Assistant" --environment <ENV_URL>

# Run with a specific eval scenarios file
npm run eval -- --scenarios ./project-delivery/05-eval-scenarios.yml
```

---

## 3. pac CLI via npm (alternative to winget)

If winget is not available on your machine:

```bash
# First fix execution policy (run PowerShell as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then install pac CLI via npm
npm install -g @microsoft/powerplatform-cli

# Verify
pac --version
```

**Prefer winget when available** — `winget install Microsoft.PowerAppsCLI` works without any execution policy changes.

---

## 4. Project-Level npm Commands

If your project includes a `package.json` (e.g. for custom scripts or the Kit):

```bash
# Install all project dependencies listed in package.json
npm install

# Install a specific package
npm install <package-name>

# Install a package as a dev dependency only (not shipped)
npm install --save-dev <package-name>

# Run a script defined in package.json
npm run <script-name>

# Common scripts in this type of project:
npm run build          # compile/bundle
npm run test           # run tests
npm run eval           # run evaluation suite
npm run lint           # check code style

# List all available scripts in the project
npm run
```

---

## 5. Keeping Node.js and npm Up to Date

```bash
# Check current versions
node --version
npm --version

# Update npm itself
npm install -g npm@latest

# Update Node.js — via winget
winget upgrade OpenJS.NodeJS.LTS

# Update a globally installed package (e.g. pac CLI via npm)
npm update -g @microsoft/powerplatform-cli
```

---

## 6. Troubleshooting npm

```bash
# Clear npm cache (fixes many install errors)
npm cache clean --force

# See full error detail on a failed install
npm install --verbose

# Check what global packages are installed
npm list -g --depth=0

# Fix permissions issue on Windows (run as Administrator)
npm install -g <package> --unsafe-perm

# Check if a package is installed globally
npm list -g @microsoft/powerplatform-cli
```

---

## When You Need Node.js vs When You Don't

| Task | Needs Node.js? |
|------|---------------|
| Edit agent YAML files | No |
| Push / publish with pac CLI (installed via winget) | No |
| Run VS Code | No |
| Run git commands | No |
| Run automated batch evaluations (Kit) | Yes |
| Install pac CLI via npm (instead of winget) | Yes |
| Build custom evaluation or reporting scripts | Yes |
| Run CI/CD pipelines that use npm scripts | Yes |

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Install Node.js | `winget install OpenJS.NodeJS.LTS` |
| Verify Node | `node --version` |
| Verify npm | `npm --version` |
| Install project deps | `npm install` |
| Run eval suite | `npm run eval` |
| Run build | `npm run build` |
| List scripts | `npm run` |
| Update npm | `npm install -g npm@latest` |
| Clear cache | `npm cache clean --force` |
| Fix execution policy | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
