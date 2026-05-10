# Environment Variables Strategy

How to manage configuration, secrets, and environment-specific values across **Copilot Studio low-code** agents and **Azure pro-code** agents — covering dev, UAT, and production.

> **When to use this doc:** When you need to store a value (API URL, threshold, flag) that differs
> between Dev/UAT/Prod environments but should not be hardcoded in YAML.
> Low-code (Copilot Studio portal): use Environment Variables in Power Platform.
> Pro-code (Azure): use Azure App Configuration or Key Vault references.

---

## Why this matters

Hard-coding values (API URLs, queue names, SharePoint URLs, connection strings) into YAML or code breaks deployments across environments and creates security risks. This guide shows the correct pattern for each platform.

---

## Part 1 — Copilot Studio (Low-Code)

### 1.1 What are Power Platform environment variables?

Environment variables in Power Platform are solution-aware key/value pairs stored at the **environment level**. They are separate from agent YAML — the YAML references them by schema name, and the actual value is set per environment (Dev / UAT / Prod) in the Power Platform Admin Center or via `pac` CLI.

```
Dev environment:     SHAREPOINT_SITE_URL = https://contoso.sharepoint.com/sites/Dev-KB
UAT environment:     SHAREPOINT_SITE_URL = https://contoso.sharepoint.com/sites/UAT-KB
Prod environment:    SHAREPOINT_SITE_URL = https://contoso.sharepoint.com/sites/KB
```

The agent YAML never changes between environments — only the variable values change.

### 1.2 When to use environment variables vs. global variables

| Use this | For | Reason |
|----------|-----|--------|
| **Power Platform environment variable** | Config that differs per environment (URLs, queue names, API endpoints, feature flags) | Stored at env level; promoted with solutions; set by admins without touching YAML |
| **Global variable (`Global.*`)** | Runtime conversation state (user profile, session flags like `Global.FeedbackShown`) | Lives only for the duration of a conversation; reset each session |
| **Hard-coded literal** | Values that NEVER change across any environment (e.g. event names in telemetry: `"Topic.Started"`) | No overhead; just a string |

### 1.3 Declaring an environment variable

Create `components/variables/env-variable.variable.mcs.yml` (one per variable):

```yaml
# env-variable.variable.mcs.yml — copy once per configuration value
name: <VAR_NAME>                              # camelCase (e.g. sharepointSiteUrl)
displayName: <Human-readable name>
description: <One sentence — what does this value configure>
schemaName: <AGENT_SCHEMA>.envvar.<VAR_NAME>   # e.g. hr_assistant.envvar.sharepointSiteUrl
kind: EnvironmentVariableDefinition
type: String                                   # String | Number | Boolean | JSON | DataSource
defaultValue: <default for new environments>
```

**Supported types:**

| Type | Use case |
|------|----------|
| `String` | URLs, queue names, display text, API endpoints |
| `Number` | Thresholds, retry counts, timeout values |
| `Boolean` | Feature flags (enable/disable a capability per environment) |
| `JSON` | Structured config object (rarely needed — prefer individual variables) |
| `DataSource` | SharePoint site or Dataverse connection (set via connection reference) |

### 1.4 Reading environment variables in topics

Reference them in Power Fx with the full schema name:

```yaml
# In a SendActivity or SetVariable action:
activity: "Contact us at {<AGENT_SCHEMA>.envvar.supportEmail}"

# As a condition:
condition: =<AGENT_SCHEMA>.envvar.escalationEnabled = true

# Pass to a connector action parameter:
parameters:
  siteUrl: =<AGENT_SCHEMA>.envvar.sharepointSiteUrl
```

### 1.5 Setting values per environment

**Via Power Platform Admin Center (manual):**

1. Admin Center → Environments → `<your environment>` → Solutions → `<your solution>`
2. Find the environment variable → click to edit → set the current value
3. Repeat for each environment

**Via `pac` CLI (recommended for CI/CD):**

```bash
# Set a value in the active environment
pac env var set --name "<AGENT_SCHEMA>.envvar.sharepointSiteUrl" \
                --value "https://contoso.sharepoint.com/sites/KB"

# Verify what's set
pac env var list --environment <env-url>
```

**Via GitHub Actions (CI/CD pipeline):**

```yaml
# In promote-dev-to-uat.yml
- name: Set UAT environment variables
  run: |
    pac auth create --environment ${{ vars.UAT_ENV_URL }} \
                    --applicationId ${{ secrets.CLIENT_ID }} \
                    --clientSecret ${{ secrets.CLIENT_SECRET }} \
                    --tenant ${{ secrets.TENANT_ID }}

    pac env var set --name "hr_assistant.envvar.sharepointSiteUrl" \
                    --value "${{ vars.UAT_SHAREPOINT_URL }}"

    pac env var set --name "hr_assistant.envvar.escalationQueueName" \
                    --value "${{ vars.UAT_ESCALATION_QUEUE }}"
```

### 1.6 Standard environment variables — every agent should declare these

Copy these declarations into your agent, replacing `<SCHEMA>` with your schemaName:

| Variable | Type | Purpose |
|----------|------|---------|
| `<SCHEMA>.envvar.escalationQueueName` | String | Live-agent queue name for `TransferConversation` |
| `<SCHEMA>.envvar.sharepointSiteUrl` | String | Knowledge source SharePoint site |
| `<SCHEMA>.envvar.supportEmail` | String | Support contact email shown in error messages |
| `<SCHEMA>.envvar.escalationEnabled` | Boolean | Feature flag — disable escalation in non-prod if not wired |
| `<SCHEMA>.envvar.maxRetries` | Number | Fallback retry count before auto-escalation |

### 1.7 Secrets in Copilot Studio

CPS **does not have a built-in secret store**. For API keys and connection strings:

1. **Use connection references** — never put API keys in environment variables (they are visible to all solution editors). Connection references are encrypted and managed by the platform.
2. **Use Azure Key Vault** via a Power Automate flow — the flow fetches the secret at runtime and passes it to the agent via a child flow output.
3. **Use Managed Identity on connectors** where supported (e.g. SharePoint, Dataverse) — no key needed.

```yaml
# NEVER do this:
parameters:
  apiKey: =<SCHEMA>.envvar.apiKey   # apiKey stored as plain text in env var — visible to admins

# CORRECT: Use a Power Automate child flow that retrieves the key from Key Vault
- kind: InvokeConnectorAction
  connectionReference: shared_powerautomate
  operationId: RunFlow
  parameters:
    flowId: <KEY_VAULT_FLOW_ID>
  output:
    variable: init:Topic.ApiKey
```

---

## Part 2 — Azure Pro-Code Agents

### 2.1 Principle: no secrets in code or YAML

Every value that differs between dev/UAT/prod or could be a credential must come from outside the code. The hierarchy (most preferred first):

```
Managed Identity → Azure Key Vault → App Configuration → App Settings → .env (local dev only)
```

### 2.2 Local development — `.env` file

For local dev only. Never commit this file.

```bash
# agents/<name>/.env  (git-ignored)
AZURE_OPENAI_ENDPOINT=https://my-foundry.openai.azure.com/
AZURE_OPENAI_KEY=sk-...
APPINSIGHTS_INSTRUMENTATION_KEY=...
SHAREPOINT_SITE_URL=https://contoso.sharepoint.com/sites/Dev-KB
ESCALATION_QUEUE_NAME=Dev-Support-Queue
```

**.gitignore must include:**

```
.env
.env.*
!.env.example
```

**`.env.example` (commit this — documents all variables with no values):**

```bash
# agents/<name>/.env.example — copy to .env and fill in values for local dev
AZURE_OPENAI_ENDPOINT=
AZURE_OPENAI_KEY=
APPINSIGHTS_INSTRUMENTATION_KEY=
SHAREPOINT_SITE_URL=
ESCALATION_QUEUE_NAME=
```

**Load in code (TypeScript):**

```typescript
import 'dotenv/config';   // npm install dotenv

const endpoint = process.env.AZURE_OPENAI_ENDPOINT!;
const apiKey   = process.env.AZURE_OPENAI_KEY!;
```

**Load in code (C#):**

```csharp
// Program.cs — loads .env for local dev; in prod, App Service settings override
DotNetEnv.Env.Load();  // NuGet: DotNetEnv
builder.Configuration.AddEnvironmentVariables();

var endpoint = builder.Configuration["AZURE_OPENAI_ENDPOINT"];
```

**Load in code (Python):**

```python
from dotenv import load_dotenv   # pip install python-dotenv
import os

load_dotenv()

endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
api_key  = os.getenv("AZURE_OPENAI_KEY")
```

### 2.3 Azure App Service — application settings

In App Service (or Azure Functions), environment variables are set as **Application Settings** — they override any `.env` file and are encrypted at rest.

```bash
# Set via Azure CLI
az webapp config appsettings set \
  --resource-group my-rg \
  --name my-agent-app \
  --settings \
    AZURE_OPENAI_ENDPOINT="https://my-foundry.openai.azure.com/" \
    ESCALATION_QUEUE_NAME="Prod-Support-Queue" \
    APPINSIGHTS_INSTRUMENTATION_KEY="<key>"

# Set per deployment slot (dev/staging/prod)
az webapp config appsettings set \
  --resource-group my-rg \
  --name my-agent-app \
  --slot staging \
  --settings ESCALATION_QUEUE_NAME="Staging-Support-Queue"
```

**Never store secrets in App Settings** — use Key Vault references instead (see 2.5).

### 2.4 Azure App Configuration — centralised config store

Use App Configuration when you need a single source of truth for config shared across multiple services (e.g. an MCP server, a Foundry agent, and an API layer all reading the same config).

```bash
# Create a store
az appconfig create --name my-agent-config --resource-group my-rg --location eastus

# Set values with environment labels
az appconfig kv set --name my-agent-config --key SharePointSiteUrl \
  --value "https://contoso.sharepoint.com/sites/KB" --label prod

az appconfig kv set --name my-agent-config --key SharePointSiteUrl \
  --value "https://contoso.sharepoint.com/sites/Dev-KB" --label dev
```

**Read in C#:**

```csharp
builder.Configuration.AddAzureAppConfiguration(options =>
{
    options.Connect(builder.Configuration["AppConfigConnectionString"])
           .Select(KeyFilter.Any, LabelFilter.Null)
           .Select(KeyFilter.Any, Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"));
});

var siteUrl = builder.Configuration["SharePointSiteUrl"];
```

**Read in Python:**

```python
from azure.appconfiguration import AzureAppConfigurationClient

client = AzureAppConfigurationClient.from_connection_string(conn_str)
setting = client.get_configuration_setting(key="SharePointSiteUrl", label="prod")
site_url = setting.value
```

### 2.5 Azure Key Vault — secrets only

Key Vault is for **secrets**: API keys, connection strings, certificates, client secrets. Never store secrets anywhere else.

**Key Vault reference in App Service (recommended — no code needed):**

```bash
# Store secret in Key Vault
az keyvault secret set --vault-name my-vault --name AzureOpenAiKey --value "sk-..."

# Reference in App Service settings (the platform resolves it at runtime)
az webapp config appsettings set \
  --resource-group my-rg --name my-agent-app \
  --settings AZURE_OPENAI_KEY="@Microsoft.KeyVault(SecretUri=https://my-vault.vault.azure.net/secrets/AzureOpenAiKey/)"
```

**Read from Key Vault in code (C# — fallback when KV reference not used):**

```csharp
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var client = new SecretClient(
    new Uri("https://my-vault.vault.azure.net/"),
    new DefaultAzureCredential()    // Uses Managed Identity in Azure, developer identity locally
);

KeyVaultSecret secret = await client.GetSecretAsync("AzureOpenAiKey");
string apiKey = secret.Value;
```

**Read in Python:**

```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(vault_url="https://my-vault.vault.azure.net/", credential=credential)
api_key = client.get_secret("AzureOpenAiKey").value
```

**Read in TypeScript:**

```typescript
import { DefaultAzureCredential } from '@azure/identity';
import { SecretClient } from '@azure/keyvault-secrets';

const client = new SecretClient('https://my-vault.vault.azure.net/', new DefaultAzureCredential());
const { value: apiKey } = await client.getSecret('AzureOpenAiKey');
```

### 2.6 Managed Identity — the best approach for zero-secret code

With Managed Identity, your code authenticates to Azure services **without any credentials in code, config, or environment variables**. The Azure platform handles identity automatically.

```bash
# Enable system-assigned managed identity on your App Service
az webapp identity assign --resource-group my-rg --name my-agent-app

# Grant the identity access to Key Vault
az keyvault set-policy --name my-vault \
  --object-id $(az webapp identity show --resource-group my-rg --name my-agent-app --query principalId -o tsv) \
  --secret-permissions get list

# Grant access to Azure OpenAI (Cognitive Services User role)
az role assignment create \
  --role "Cognitive Services OpenAI User" \
  --assignee $(az webapp identity show --resource-group my-rg --name my-agent-app --query principalId -o tsv) \
  --scope /subscriptions/<sub>/resourceGroups/my-rg/providers/Microsoft.CognitiveServices/accounts/my-openai
```

**Code using `DefaultAzureCredential` (same code works locally and in Azure):**

```typescript
import { DefaultAzureCredential } from '@azure/identity';
import { OpenAIClient, AzureKeyCredential } from '@azure/openai';

// DefaultAzureCredential: Managed Identity in Azure, developer credential locally (az login)
const credential = new DefaultAzureCredential();
const openai = new OpenAIClient(process.env.AZURE_OPENAI_ENDPOINT!, credential);
// No API key needed — Managed Identity handles authentication
```

```python
from azure.identity import DefaultAzureCredential
from openai import AzureOpenAI
import azure.identity

credential = DefaultAzureCredential()
token_provider = azure.identity.get_bearer_token_provider(
    credential, "https://cognitiveservices.azure.com/.default"
)

client = AzureOpenAI(
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    azure_ad_token_provider=token_provider,
    api_version="2024-08-01-preview"
)
# No API key — token from Managed Identity
```

```csharp
using Azure.Identity;
using Azure.AI.OpenAI;

var credential = new DefaultAzureCredential();
var client = new AzureOpenAIClient(
    new Uri(configuration["AZURE_OPENAI_ENDPOINT"]!),
    credential  // No API key — Managed Identity or developer login
);
```

### 2.7 Summary — which mechanism for each value type

| Value type | Dev (local) | Azure hosted | Tool |
|-----------|------------|-------------|------|
| API keys / secrets | `.env` (git-ignored) | Key Vault reference or Managed Identity | Key Vault |
| Config (URLs, names) | `.env` | App Service settings or App Configuration | App Configuration |
| Feature flags | `.env` | App Configuration with labels | App Configuration |
| Shared config across services | `.env` | Azure App Configuration | App Configuration |
| Azure service auth | `az login` / `DefaultAzureCredential` | Managed Identity | No secret needed |
| Connection strings | `.env` | App Service connection strings (encrypted slot) | App Service |

### 2.8 Infrastructure-as-Code — declare env vars in Bicep

Never set environment variables manually in production. Declare them in Bicep so they are version-controlled and reproducible:

```bicep
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: 'my-agent-app'
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'AZURE_OPENAI_ENDPOINT'
          value: openAiEndpoint     // Bicep parameter — value differs per environment
        }
        {
          name: 'AZURE_OPENAI_KEY'
          // Key Vault reference — resolves at runtime, never stored as plaintext
          value: '@Microsoft.KeyVault(SecretUri=${keyVaultSecretUri})'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATION_KEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'ESCALATION_QUEUE_NAME'
          value: escalationQueueName   // Bicep parameter
        }
      ]
    }
  }
}
```

---

## Part 3 — Hybrid Pattern (CPS + Pro-Code MCP Server)

When CPS calls a pro-code MCP server, each layer manages its own variables independently:

```
CPS agent (Power Platform)          MCP Server (Azure App Service)
─────────────────────────           ──────────────────────────────
escalationQueueName (env var)  →    reads from App Service settings
sharepointSiteUrl (env var)    →    reads from App Configuration
(no secrets)                        AZURE_OPENAI_KEY from Key Vault reference
                                    Graph API auth via Managed Identity
```

**Neither layer hard-codes anything. The values flow from:**
- Power Platform Admin Center (for CPS env vars)
- Azure App Service settings + Key Vault (for MCP server)

Both layers are updated via their respective CI/CD pipelines, never manually.

---

## Checklist — Before Going Live

| Check | How to verify |
|-------|--------------|
| No hard-coded URLs in any `.mcs.yml` file | Windows: `Get-ChildItem -Recurse -Filter "*.mcs.yml" \| Select-String "https://"` / Mac: `grep -rn "https://" --include="*.mcs.yml" .` — review each hit |
| No hard-coded queue/email values in YAML | Windows: `Get-ChildItem -Recurse -Filter "*.mcs.yml" \| Select-String "Queue\|@"` / Mac: `grep -rn "Queue\|@" --include="*.mcs.yml" .` |
| No secrets in environment variables (CPS) | Review all env vars in Power Platform Admin Center — none should be API keys |
| `.env` is git-ignored | `git check-ignore .env` — should return `.env` |
| `.env.example` is committed | `git ls-files .env.example` — should return the path |
| Key Vault references set for all secrets | Azure Portal → App Service → Configuration → verify `@Microsoft.KeyVault(...)` syntax |
| Managed Identity assigned | `az webapp identity show --name <app> --resource-group <rg>` — must return a `principalId` |
| App Configuration labels match environments | `az appconfig kv list --name <store> --label prod` — verify prod values |

---

## Related Files

- [`PII-SCRUBBING.md`](PII-SCRUBBING.md) — never put PII in env vars or telemetry
- [`ACTION-SAFETY-PATTERNS.md`](ACTION-SAFETY-PATTERNS.md) — safety tiers for write actions that use env var config
- [`components/variables/global-variable/global-variable.variable.mcs.yml`](../components/variables/global-variable/global-variable.variable.mcs.yml) — conversation-scoped runtime state (different from env vars)
- [`ENGINEERING-PLAYBOOK.md`](../ENGINEERING-PLAYBOOK.md) Stage 4.5 — pro-code agent patterns including Key Vault and Managed Identity
