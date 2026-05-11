# Building and Deploying Solutions via CLI

Yes — you can build, export, unpack, pack, import, and publish Power Platform solutions entirely from the CLI using `pac solution` commands. No browser or admin center required after initial environment setup.

---

## Two deployment approaches

| Approach | When to use | Command |
|----------|------------|---------|
| **VS Code Apply Changes** | Development, rapid iteration, single agent | VS Code → Ctrl+Shift+P → "Copilot Studio: Apply Changes" |
| **Solution-based deployment** (`pac solution import`) | UAT → Prod promotion, enterprise ALM, multi-component solutions | `pac solution export` / `pac solution import` |

**Recommendation:** Use VS Code Apply Changes during development to push YAML edits to your agent draft. Use solution-based deployment for UAT → Production promotion. Solutions carry connection references, environment variables, and managed layers — making them the correct approach for production ALM.

> **Note:** `pac copilot push` does not exist in the pac CLI. The only way to push multi-file YAML edits is VS Code → "Copilot Studio: Apply Changes".

---

## pac solution — command reference

### Authenticate first (required before all commands)

```bash
pac auth create \
  --applicationId <CLIENT_ID> \
  --clientSecret <CLIENT_SECRET> \
  --tenant <TENANT_ID> \
  --environment <ENV_URL>
```

### Create a new solution in an environment

```bash
pac solution create \
  --name "AgentSolutionName" \
  --display-name "Agent Solution Display Name" \
  --publisher-name "YourPublisher" \
  --publisher-prefix "yourprefix" \
  --environment <ENV_URL>
```

### Add your agent to the solution

Add the agent component by its schema name:

```bash
pac solution add-component \
  --solutionName "AgentSolutionName" \
  --component "<AGENT_SCHEMA_NAME>" \
  --componentType 10230 \
  --environment <ENV_URL>
```

> `componentType 10230` = Copilot Studio agent. Other component types: `10231` = topic, `10232` = action.

### List solutions in an environment

```bash
pac solution list --environment <ENV_URL>
```

### Export a solution

```bash
# Unmanaged (for dev — can be edited after import)
pac solution export \
  --name "AgentSolutionName" \
  --path ./solutions/agent-solution-unmanaged.zip \
  --environment <DEV_ENV_URL> \
  --managed false \
  --overwrite

# Managed (for UAT/Prod — locked, cannot be edited after import)
pac solution export \
  --name "AgentSolutionName" \
  --path ./solutions/agent-solution-managed.zip \
  --environment <DEV_ENV_URL> \
  --managed true \
  --overwrite
```

**Always export managed for UAT and Production.** Managed solutions protect your agent from being accidentally edited in higher environments.

### Unpack a solution (for source control readability)

Unpacking converts the zip to individual files that can be read in git diff:

```bash
pac solution unpack \
  --zipfile ./solutions/agent-solution-unmanaged.zip \
  --folder ./solutions/unpacked/AgentSolutionName \
  --processCanvasApps
```

Commit the unpacked folder to git so you can see exactly what changed between releases.

### Pack an unpacked solution back to zip

```bash
pac solution pack \
  --zipfile ./solutions/agent-solution-managed.zip \
  --folder ./solutions/unpacked/AgentSolutionName \
  --managed
```

### Import a solution into an environment

```bash
# Import managed solution into UAT or Prod
pac solution import \
  --path ./solutions/agent-solution-managed.zip \
  --environment <UAT_OR_PROD_ENV_URL> \
  --activate-plugins \
  --force-overwrite
```

After import, always publish:

```bash
pac org publish --environment <ENV_URL>
```

### Publish the Copilot Studio agent after import

Importing a solution does not automatically publish the agent to its channels. Publish separately:

```bash
pac copilot publish \
  --environment <ENV_URL> \
  --schemaName "<AGENT_SCHEMA_NAME>"
```

### Upgrade vs Update vs Overwrite

| Flag | Behaviour | When to use |
|------|-----------|------------|
| `--force-overwrite` | Replaces the existing solution | Standard for agent updates |
| `--import-as-holding` | Imports as a holding solution for a staged upgrade | When you need zero-downtime upgrade |
| (default — no flag) | Merges / updates if solution already exists | When solution partially exists |

For Copilot Studio agents in most enterprise scenarios, `--force-overwrite` is correct.

---

## Full Dev → UAT → Prod CLI workflow (manual)

```bash
# ─── DEV: Build and push agent YAML ───────────────────────────────
pac auth create --environment <DEV_ENV_URL> ...
cd agents/<AGENT_SCHEMA_NAME>
# Push YAML edits to the agent draft:
# VS Code → Ctrl+Shift+P → "Copilot Studio: Apply Changes"
# (pac copilot push does not exist — Apply Changes is the only way to push multi-file YAML)

# ─── DEV: Package into a solution ─────────────────────────────────
# (first time only — create the solution)
pac solution create --name "AgentSolution" --environment <DEV_ENV_URL>
pac solution add-component --solutionName "AgentSolution" \
  --component "<AGENT_SCHEMA_NAME>" --componentType 10230 --environment <DEV_ENV_URL>

# ─── DEV: Export managed solution for promotion ───────────────────
pac solution export \
  --name "AgentSolution" \
  --path ./solutions/AgentSolution_managed.zip \
  --environment <DEV_ENV_URL> \
  --managed true \
  --overwrite

# ─── UAT: Import and publish ──────────────────────────────────────
pac auth create --environment <UAT_ENV_URL> ...
pac solution import \
  --path ./solutions/AgentSolution_managed.zip \
  --environment <UAT_ENV_URL> \
  --force-overwrite
pac org publish --environment <UAT_ENV_URL>

# Run UAT testing (project-delivery/04-uat-test-plan.md)

# ─── PROD: Import, publish, and go live ───────────────────────────
pac auth create --environment <PROD_ENV_URL> ...
pac solution import \
  --path ./solutions/AgentSolution_managed.zip \
  --environment <PROD_ENV_URL> \
  --force-overwrite
pac org publish --environment <PROD_ENV_URL>
pac copilot publish --environment <PROD_ENV_URL> --schemaName "<AGENT_SCHEMA_NAME>"
```

---

## Connection references after import

When importing a solution into a new environment, connection references must be re-mapped to connections that exist in that environment.

```bash
# List connection references in the solution
pac solution list-connection-references \
  --solutionName "AgentSolution" \
  --environment <ENV_URL>

# Update a connection reference to point to an existing connection
pac solution update-connection-reference \
  --connectionReferenceLogicalName "shared_office365users_ref" \
  --connectionId "<CONNECTION_ID_IN_TARGET_ENV>" \
  --environment <ENV_URL>
```

Get the connection ID from:
```bash
pac connector list --environment <ENV_URL>
```

---

## Automated pipeline

For automated Dev → UAT → Prod promotion, use the GitHub Actions workflow at:
`ci-cd/solution-build-and-deploy.yml`

It handles: export → artifact storage → UAT import → production import (with approval gate).

---

## Required GitHub Secrets and Variables

| Secret | Value |
|--------|-------|
| `POWER_PLATFORM_CLIENT_ID` | Service principal app ID |
| `POWER_PLATFORM_CLIENT_SECRET` | Service principal client secret |
| `POWER_PLATFORM_TENANT_ID` | Azure AD tenant ID |
| `POWER_PLATFORM_DEV_URL` | Dev environment URL |
| `POWER_PLATFORM_UAT_URL` | UAT environment URL |
| `POWER_PLATFORM_PROD_URL` | Production environment URL |

| Variable | Value |
|----------|-------|
| `AGENT_SCHEMA_NAME` | Agent's schemaName (e.g. `cyclotron_hr_assistant`) |
| `SOLUTION_NAME` | Solution unique name (e.g. `AgentSolution`) |
