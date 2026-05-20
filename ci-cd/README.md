# CI/CD Pipelines

> **Prerequisites before using these pipelines:**
> - Service principal with Contributor role on the Power Platform environment
> - GitHub secrets set: `POWER_PLATFORM_URL`, `CLIENT_ID`, `CLIENT_SECRET`, `TENANT_ID`
> - Note: `pac copilot push` does not exist in pac CLI. The pipeline YAML files in this folder
>   use it as a placeholder — replace with your deployment approach (solution import or VS Code Apply Changes via agent).
>   The `04-solution-build-and-deploy.yml` workflow is the recommended enterprise-grade approach.
> - Three environments: Dev, UAT, Production (separate Power Platform environments)
>
> **Which workflow file to use:**
> | Workflow | Trigger | What it does |
> |----------|---------|-------------|
> | `01-push-on-pr.yml` | PR to `main` | Validates YAML (no `<PLACEHOLDER>` or `_REPLACE` strings) |
> | `02-promote-dev-to-uat.yml` | Merge to `main` (agents/** changed) | Pushes agent to UAT environment |
> | `03-promote-uat-to-prod.yml` | GitHub Release published | Promotes to Production with approval gate |

Automated push and publish workflows for Copilot Studio agents using GitHub Actions and the Power Platform CLI (`pac`).

---

## Two deployment approaches

| Approach | Workflows | When to use |
|----------|-----------|------------|
| **Direct YAML push** | `01-push-on-pr.yml`, `02-promote-dev-to-uat.yml`, `03-promote-uat-to-prod.yml` | Rapid development iteration; single-agent deployments |
| **Solution-based** | `04-solution-build-and-deploy.yml` | Enterprise ALM; multi-component solutions; managed layer for Prod |

→ **Can you build solutions from CLI?** Yes. See [`05-solution-cli-guide.md`](05-solution-cli-guide.md) for the full `pac solution` command reference.

---

## Workflows — Direct YAML Push

| File | Trigger | What it does |
|------|---------|-------------|
| [`01-push-on-pr.yml`](01-push-on-pr.yml) | Pull request to `main` | Validates YAML and pushes to dev environment |
| [`02-promote-dev-to-uat.yml`](02-promote-dev-to-uat.yml) | Merge to `main` | Pushes agent to UAT environment (requires UAT environment approval) |
| [`03-promote-uat-to-prod.yml`](03-promote-uat-to-prod.yml) | GitHub Release published | Pushes and publishes to production (requires production environment approval) |

## Workflows — Solution-Based

| File | Trigger | What it does |
|------|---------|-------------|
| [`04-solution-build-and-deploy.yml`](04-solution-build-and-deploy.yml) | Push to `main` or manual dispatch | Exports managed solution from Dev → imports to UAT or Prod with approval gates |

---

## Prerequisites

### 1 — GitHub Secrets

Add these secrets to your GitHub repository (**Settings → Secrets and variables → Actions**):

| Secret name | Value |
|-------------|-------|
| `POWER_PLATFORM_DEV_URL` | Your dev environment URL (e.g. `https://org.crm.dynamics.com`) |
| `POWER_PLATFORM_PROD_URL` | Your production environment URL |
| `POWER_PLATFORM_CLIENT_ID` | Azure AD app registration client ID for the service principal |
| `POWER_PLATFORM_CLIENT_SECRET` | Client secret for the service principal |
| `POWER_PLATFORM_TENANT_ID` | Azure AD tenant ID |

### 2 — Repository Variable

Add this variable (**Settings → Secrets and variables → Actions → Variables**):

| Variable name | Value |
|---------------|-------|
| `AGENT_SCHEMA_NAME` | Your agent's `schemaName` from `settings.mcs.yml` (e.g. `hr_assistant`) |

### 3 — Service Principal Setup

The workflows authenticate using a service principal (not a user account).

1. Register an app in Azure AD
2. Generate a client secret
3. In the Power Platform environment → **Settings** → **Users** → **Application Users** → add the service principal with **System Administrator** role
4. Add the client ID, secret, and tenant ID as GitHub secrets above

### 4 — Agent location

Your agent YAML files should live in a subfolder named after the agent's `schemaName`, e.g. `agents/hr_assistant/`. The `AGENT_PATH` env var in each workflow constructs this automatically.

---

## Required GitHub Secrets and Variables

| Secret | Value |
|--------|-------|
| `POWER_PLATFORM_CLIENT_ID` | Service principal app registration client ID |
| `POWER_PLATFORM_CLIENT_SECRET` | Client secret |
| `POWER_PLATFORM_TENANT_ID` | Azure AD tenant ID |
| `POWER_PLATFORM_DEV_URL` | Dev environment URL |
| `POWER_PLATFORM_UAT_URL` | UAT environment URL |
| `POWER_PLATFORM_PROD_URL` | Production environment URL |

| Variable | Value |
|----------|-------|
| `AGENT_SCHEMA_NAME` | Agent's `schemaName` from `settings.mcs.yml` |
| `SOLUTION_NAME` | Solution unique name (solution-based workflows only) |

---

## Branching Strategy

```
feature/* ─────────────────────────────────────────────── dev branches
              ↓ PR (01-push-on-pr.yml validates + pushes to dev)
main ──────────────────────────────────────────────────── auto-promote to UAT
              ↓ (02-promote-dev-to-uat.yml — requires UAT approval)
uat ────────────────────────────────────────────────────── UAT testing
              ↓ GitHub Release (03-promote-uat-to-prod.yml — requires prod approval)
production ────────────────────────────────────────────── push + publish to prod
```

---

## Protecting Production

For the `03-promote-uat-to-prod.yml` workflow, add a GitHub **Environment** called `production` with a required reviewer:

**Settings → Environments → New environment → `production`** → add required reviewer

This means the production deploy pauses and waits for a manual approval before running.

---

## Manual Deployment (fallback)

If CI/CD is not available, deploy manually:

```bash
# Authenticate
pac auth create \
  --applicationId <CLIENT_ID> \
  --clientSecret <CLIENT_SECRET> \
  --tenant <TENANT_ID> \
  --environment <ENV_URL>

# Push YAML edits to the connected environment
# VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
# (pac copilot push does not exist — Apply Changes is the only push mechanism)

# Publish the draft live
pac copilot publish --bot "<agent display name or GUID>"
```

See [`commands/COMMANDS.md`](../commands/COMMANDS.md) for the full pac CLI reference.
