# Recipe 07 — M365 Agents SDK Agent

A pro-code agent built with the Microsoft 365 Agents SDK. Gives full control over orchestration, model selection, and multi-channel deployment beyond what Copilot Studio provides.

---

## When to use this recipe instead of Copilot Studio

| Use M365 Agents SDK when… | Stay in Copilot Studio when… |
|--------------------------|------------------------------|
| You need custom orchestration logic (Semantic Kernel, LangChain) | Makers or non-developers will build/maintain the agent |
| You need fine-grained control over which model handles which request | Standard topics + knowledge + connector actions are sufficient |
| You are deploying to channels beyond Teams (custom web app, third-party) | M365 SSO and standard channels are enough |
| You are migrating from Bot Framework SDK | You want SaaS — no infrastructure to manage |
| You need to call Copilot Studio agents from pro-code orchestration | Speed of delivery matters more than code control |

---

## Use Case

- Agents that wrap Copilot Studio agents with custom pre/post processing
- Multi-channel agents (Teams + web + mobile) with shared business logic
- Agents that need custom state management (Cosmos DB, Azure Blob)
- Bot Framework SDK migrations to the modern M365 Agents SDK

---

## Languages supported

| Language | Runtime | Key package |
|----------|---------|-------------|
| TypeScript / JavaScript | Node.js v22+ | `@microsoft/agents-hosting-express` |
| C# | .NET 8.0+ | `Microsoft.Agents.Hosting.AspNetCore` |
| Python | Python 3.9+ | `microsoft-agents-hosting-aiohttp` |

---

## Project structure (TypeScript example)

```
my-agent/
├── src/
│   ├── index.mts              ← entry point, registers agent and starts server
│   └── myAgent.mts            ← agent class, handles activities
├── package.json
├── tsconfig.json
└── .env                       ← CLIENT_ID, CLIENT_SECRET, TENANT_ID
```

---

## How it connects to Copilot Studio

```
User (Teams / Web)
      │
      ▼
[M365 Agents SDK agent]          ← your pro-code logic runs here
      │
      ├─ Custom preprocessing
      ├─ Orchestration (Semantic Kernel / LangChain)
      │
      └─ @microsoft/agents-copilotstudio-client
              │
              ▼
      [Copilot Studio agent]     ← handles topics, knowledge, CSAT
              │
              └─ returns response → SDK post-processes → user
```

---

## Setup — TypeScript

### Step 1 — Scaffold with M365 Agents Toolkit (recommended)

```bash
# Install the Agents Toolkit CLI
npm install -g @microsoft/m365agentstoolkit-cli

# Scaffold a new agent project
m365agentstoolkit scaffold

# Or use the VS Code extension:
# Ctrl+Shift+P → "M365 Agents Toolkit: Create New Agent"
# Choose template: Echo Agent or Weather Agent
```

### Step 2 — Or scaffold manually

```bash
mkdir my-agent && cd my-agent
npm init -y

npm install \
  @microsoft/agents-hosting \
  @microsoft/agents-hosting-express \
  @microsoft/agents-activity \
  @microsoft/agents-copilotstudio-client
```

### Step 3 — Minimal agent (TypeScript)

```typescript
// src/myAgent.mts
import { ActivityHandler, TurnContext } from "@microsoft/agents-hosting";
import { CopilotStudioClient } from "@microsoft/agents-copilotstudio-client";

export class MyAgent extends ActivityHandler {
  private csClient: CopilotStudioClient;

  constructor() {
    super();
    this.csClient = new CopilotStudioClient({
      environmentId: process.env.CS_ENVIRONMENT_ID!,
      agentIdentifier: process.env.CS_AGENT_SCHEMA_NAME!,  // e.g. "it_helpdesk"
      tenantId: process.env.TENANT_ID!,
    });

    this.onMessage(async (context: TurnContext) => {
      // Pre-processing: add context, log, transform input
      const userMessage = context.activity.text;

      // Delegate to Copilot Studio agent
      const response = await this.csClient.sendMessage(userMessage);

      // Post-processing: format, filter, add metadata
      await context.sendActivity(response.text);
    });
  }
}
```

```typescript
// src/index.mts
import express from "express";
import { CloudAdapter, ConfigurationBotFrameworkAuthentication }
  from "@microsoft/agents-hosting-express";
import { MyAgent } from "./myAgent.mjs";

const app = express();
app.use(express.json());

const auth = new ConfigurationBotFrameworkAuthentication({
  MicrosoftAppId: process.env.CLIENT_ID,
  MicrosoftAppPassword: process.env.CLIENT_SECRET,
  MicrosoftAppTenantId: process.env.TENANT_ID,
});

const adapter = new CloudAdapter(auth);
const agent = new MyAgent();

app.post("/api/messages", async (req, res) => {
  await adapter.process(req, res, (context) => agent.run(context));
});

app.listen(3978, () => console.log("Agent running on port 3978"));
```

### Step 4 — Environment variables

```bash
# .env
CLIENT_ID=<your Azure AD app client ID>
CLIENT_SECRET=<your Azure AD app client secret>
TENANT_ID=<your tenant ID>
CS_ENVIRONMENT_ID=<Power Platform environment ID>
CS_AGENT_SCHEMA_NAME=it_helpdesk
```

### Step 5 — Test locally

```bash
# Install and start the Agents Playground
npm install -D @microsoft/m365agentsplayground
npx agentsplayground

# In a separate terminal
npm run dev

# Open browser: http://localhost:56150 → connect to http://localhost:3978/api/messages
```

---

## Setup — C# (.NET 8)

```bash
dotnet new web -n MyAgent
cd MyAgent
dotnet add package Microsoft.Agents.Hosting.AspNetCore
dotnet add package Microsoft.Agents.Authentication.Msal
```

```csharp
// Program.cs
using Microsoft.Agents.Builder;
using Microsoft.Agents.Hosting.AspNetCore;

var builder = WebApplication.CreateBuilder(args);
builder.AddAgentApplicationOptions();
builder.Services.AddAgent<MyAgent>();

var app = builder.Build();
app.MapPost("/api/messages", app.Services.GetRequiredService<IAgentHttpAdapter>()
                                          .ProcessAsync);
app.Run();
```

---

## Setup — Python

```bash
python -m venv .venv
.venv\Scripts\activate        # Windows
pip install microsoft-agents-hosting-aiohttp
pip install azure-identity
```

```python
# app.py
from agents.hosting.aiohttp import AgentHttpAdapter
from agents.builder import ActivityHandler, TurnContext
from aiohttp import web

class MyAgent(ActivityHandler):
    async def on_message_activity(self, turn_context: TurnContext):
        await turn_context.send_activity(f"You said: {turn_context.activity.text}")

adapter = AgentHttpAdapter(client_id="<CLIENT_ID>", client_secret="<SECRET>")
agent = MyAgent()

async def messages(req):
    return await adapter.process(req, agent)

app = web.Application()
app.router.add_post("/api/messages", messages)
web.run_app(app, port=3978)
```

---

## Authentication — M365 SSO in Teams

```typescript
// Add Teams SSO support
npm install @microsoft/agents-hosting-extensions-teams

// In your agent:
import { TeamsActivityHandler } from "@microsoft/agents-hosting-extensions-teams";

export class MyAgent extends TeamsActivityHandler {
  async handleTeamsSigninVerifyState(context: TurnContext, query: any) {
    // SSO token available here
    const token = query.token;
    // Use token for OBO flow to call Graph API
  }
}
```

---

## Azure deployment

### Required Azure resources

```
Azure Bot Service        ← handles channel connections (Teams, Web Chat)
Azure App Service        ← hosts your agent code
Azure AD App Registration ← CLIENT_ID + CLIENT_SECRET
```

### Deploy commands

```bash
# Build
npm run build

# Deploy to Azure App Service
az webapp up --name my-agent-app --resource-group my-rg --runtime "NODE:22-lts"

# Register with Azure Bot Service
az bot create \
  --name my-agent-bot \
  --resource-group my-rg \
  --app-type SingleTenant \
  --appid <CLIENT_ID> \
  --endpoint https://my-agent-app.azurewebsites.net/api/messages
```

---

## How this recipe relates to the Copilot Studio templates

| Template | Role in this recipe |
|----------|-------------------|
| `base/agent.mcs.yml` | The Copilot Studio agent that this SDK agent calls via `agents-copilotstudio-client` |
| `components/topics/_scaffold/` | Topics in the underlying Copilot Studio agent |
| `project-delivery/09-technical-design-document.md` | Document the SDK ↔ Copilot Studio boundary |
| `governance/03-security-review.md` | Additional section needed for Azure Bot Service + App Service security |

---

## Setup Checklist

- [ ] Choose language (TypeScript / C# / Python)
- [ ] Scaffold project via M365 Agents Toolkit or manually
- [ ] Create Azure AD app registration → save `CLIENT_ID`, `CLIENT_SECRET`, `TENANT_ID`
- [ ] Fill in `.env` with credentials and Copilot Studio environment ID
- [ ] Test locally with `npx agentsplayground`
- [ ] Create Azure Bot Service + Azure App Service
- [ ] Deploy and register the messaging endpoint
- [ ] Add Teams channel in Azure Bot Service → publish to Teams app catalog

---

## Key links

| Resource | URL |
|----------|-----|
| M365 Agents SDK docs | https://learn.microsoft.com/microsoft-365/agents-sdk/ |
| Agents Toolkit | https://learn.microsoft.com/microsoftteams/platform/toolkit/overview-agents-toolkit |
| SDK GitHub repo | https://github.com/microsoft/Agents |
| Copilot Studio integration | https://learn.microsoft.com/microsoft-365/agents-sdk/integrate-with-mcs |
| Node.js samples | https://github.com/microsoft/Agents/tree/main/samples/nodejs |
