# CI/CD Pipelines

Automated push and publish workflows for Copilot Studio agents using GitHub Actions and the Power Platform CLI (`pac`).

---

## Workflows

| File | Trigger | What it does |
|------|---------|-------------|
| [`push-on-pr.yml`](push-on-pr.yml) | Pull request to `main` | Validates YAML and pushes to dev/test environment |
| [`publish-on-release.yml`](publish-on-release.yml) | GitHub Release created | Pushes and publishes to production environment |

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

## Branching Strategy

```
feature/* ─────────────────────────────────────────────── dev branches
              ↓ PR
main ──────────────────────────────────────────────────── push to dev/test env
              ↓ GitHub Release
production ────────────────────────────────────────────── push + publish to prod
```

---

## Protecting Production

For the `publish-on-release.yml` workflow, add a GitHub **Environment** called `production` with a required reviewer:

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

# Push
pac copilot push --environment <ENV_URL>

# Publish in Copilot Studio UI, or via:
# pac copilot publish (not available in all pac CLI versions)
```

See `TOOLS-AND-PLUGINS.md` for `pac` installation instructions.
