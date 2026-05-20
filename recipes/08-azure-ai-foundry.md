# Recipe 08 — Azure AI Foundry Agent

Enterprise-grade agent built on Azure AI Foundry. Use when you need custom models, advanced tools (code interpreter, Azure AI Search, MCP servers), multi-agent orchestration, or are migrating specialist components out of Copilot Studio ("Progressive Enhancement").

---

## When to use this recipe instead of Copilot Studio

| Use Azure AI Foundry when… | Stay in Copilot Studio when… |
|---------------------------|------------------------------|
| You need > 8,000 RPM or multi-region failover | Traffic is under 8,000 RPM per environment |
| You need code interpreter, file search, memory, or MCP tools | SharePoint knowledge + connector actions are sufficient |
| You need multi-agent workflows (sequential, concurrent, hierarchical) | Hub-and-spoke orchestration with child agents is enough |
| You need a custom model from the Foundry model catalog | GPT-4o via Copilot Studio is fine |
| You need full observability via OpenTelemetry + App Insights | Standard Copilot Studio telemetry is sufficient |
| You are building a specialist component to plug into an orchestrator | You are building the orchestrator itself |

---

## Use Case

- Data analytics agent with code interpreter (runs Python to answer data questions)
- Research agent with file search + web search + memory
- Specialist sub-agent in a multi-agent architecture (plugged into a Copilot Studio orchestrator)
- Production-scale agent migrated out of Copilot Studio via Progressive Enhancement

---

## Three agent types in Foundry — pick one

| Type | How to build | Best for |
|------|-------------|---------|
| **Prompt Agent** | Foundry portal — no code | Quick prototype, instruction + tools |
| **Workflow Agent** | YAML visual builder (Preview) | Multi-step, multi-agent orchestration |
| **Hosted Agent** | Python / C# / JS code | Custom logic, custom frameworks, full control |

---

## Progressive Enhancement — the migration path from Copilot Studio

```
Stage 1 — Copilot Studio only (Copilot Studio handles everything)
    agent.mcs.yml + topics + knowledge + connector actions

Stage 2 — Foundry for a specialist component
    Copilot Studio orchestrator (recipe 05 or 06)
          └── child-agent.mcs.yml → calls Foundry specialist agent via REST

Stage 3 — Foundry as primary, Copilot Studio as a skill
    Foundry agent (orchestrates)
          └── calls Copilot Studio agent via agents-copilotstudio-client

Stage 4 — Foundry only (if Copilot Studio no longer needed)
```

**Trigger to move to Stage 2:**
- RPM consistently > 7,000/min
- Need tools not available in Copilot Studio (code interpreter, custom MCP)
- Topics growing so complex they need custom Python/C# logic

---

## Setup — Prompt Agent (no code, Foundry portal)

### Step 1 — Create Azure resources

```
Azure portal → Create resource:
  1. Azure AI Foundry Hub  (one per org/region)
  2. Azure AI Foundry Project (inside the hub)
```

### Step 2 — Deploy a model

```
Foundry portal (https://ai.azure.com)
  → Build → Models
  → Deploy model → choose: gpt-4o (recommended)
  → Deployment name: gpt-4o-prod
```

### Step 3 — Create a Prompt Agent in the portal

```
Foundry portal → Build → Agents → + New Agent

Fill in:
  Name:         IT Specialist
  Model:        gpt-4o-prod
  Instructions: You are an IT specialist. Answer only IT-related questions
                using the knowledge base provided. Always cite the source.

Tools to add:
  + Azure AI Search  → connect to your Azure AI Search index
  + File Search      → upload IT policy documents
  + Web Search       → Bing integration (optional)

Test in the playground → Save agent → note the Agent ID
```

---

## Setup — Hosted Agent (Python SDK)

### Step 1 — Install SDK

```bash
pip install "azure-ai-projects>=2.0.0"
pip install azure-identity
pip install opentelemetry-sdk    # optional — for tracing
```

### Step 2 — Create and run an agent

```python
# agent.py
import os
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import (
    Agent,
    AgentThread,
    MessageRole,
    FileSearchTool,
    AzureAISearchTool,
)

# Connect to your Foundry project
client = AIProjectClient(
    endpoint=os.environ["AZURE_AI_FOUNDRY_ENDPOINT"],
    # Format: https://<resource-name>.services.ai.azure.com/api/projects/<project-name>
    credential=DefaultAzureCredential(),
)

openai_client = client.get_openai_client()

# Create the agent (once — save the agent_id for reuse)
agent = openai_client.beta.agents.create(
    model="gpt-4o-prod",
    name="IT Specialist",
    instructions="""
        You are an IT specialist for Contoso. Answer IT questions using the
        knowledge base. Always cite your source. If you cannot answer, say so
        and offer to raise a support ticket.
    """,
    tools=[
        AzureAISearchTool(
            index_connection_name="contoso-it-search",
            index_name="it-docs-index",
        ).as_dict(),
    ],
)
print(f"Agent created: {agent.id}")  # save this → FOUNDRY_AGENT_ID

# Run a conversation
def ask(user_message: str, thread_id: str = None) -> str:
    # Create or reuse thread
    thread = (openai_client.beta.threads.retrieve(thread_id)
              if thread_id
              else openai_client.beta.threads.create())

    # Add user message
    openai_client.beta.threads.messages.create(
        thread_id=thread.id,
        role=MessageRole.USER,
        content=user_message,
    )

    # Run and wait for completion
    run = openai_client.beta.threads.runs.create_and_poll(
        thread_id=thread.id,
        assistant_id=os.environ["FOUNDRY_AGENT_ID"],
    )

    # Get response
    messages = openai_client.beta.threads.messages.list(thread_id=thread.id)
    for msg in messages.data:
        if msg.role == MessageRole.ASSISTANT:
            return msg.content[0].text.value, thread.id

    return "No response", thread.id


# Example usage
response, thread_id = ask("How do I reset my VPN credentials?")
print(response)

# Continue same conversation
response2, _ = ask("What if that doesn't work?", thread_id=thread_id)
print(response2)
```

### Step 3 — Environment variables

```bash
# .env
AZURE_AI_FOUNDRY_ENDPOINT=https://<resource>.services.ai.azure.com/api/projects/<project>
FOUNDRY_AGENT_ID=asst_xxxxxxxxxxxxxxxxxxxx
AZURE_CLIENT_ID=<service principal or managed identity>
```

---

## Setup — Azure AI Search (knowledge source)

```bash
pip install azure-search-documents azure-storage-blob
```

```python
# index_documents.py — run once to index your SharePoint/blob content
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (
    SearchIndex, SimpleField, SearchableField, SearchFieldDataType
)
from azure.identity import DefaultAzureCredential

index_client = SearchIndexClient(
    endpoint=os.environ["AZURE_SEARCH_ENDPOINT"],
    credential=DefaultAzureCredential(),
)

# Create index schema
index = SearchIndex(
    name="it-docs-index",
    fields=[
        SimpleField(name="id", type=SearchFieldDataType.String, key=True),
        SearchableField(name="content", type=SearchFieldDataType.String),
        SearchableField(name="title", type=SearchFieldDataType.String),
        SimpleField(name="source_url", type=SearchFieldDataType.String),
    ],
)
index_client.create_or_update_index(index)
print("Index created: it-docs-index")
```

---

## Multi-Agent Orchestration (Workflow Agent)

```python
# orchestrator.py — routes to specialist agents
from azure.ai.projects import AIProjectClient

client = AIProjectClient(
    endpoint=os.environ["AZURE_AI_FOUNDRY_ENDPOINT"],
    credential=DefaultAzureCredential(),
)

# Define specialist agents (created separately in Foundry)
AGENTS = {
    "IT":      os.environ["FOUNDRY_IT_AGENT_ID"],
    "HR":      os.environ["FOUNDRY_HR_AGENT_ID"],
    "Finance": os.environ["FOUNDRY_FINANCE_AGENT_ID"],
}

def classify_intent(message: str) -> str:
    # Use a lightweight call to classify which specialist should handle this
    openai_client = client.get_openai_client()
    result = openai_client.chat.completions.create(
        model="gpt-4o-prod",
        messages=[
            {"role": "system", "content":
             "Classify the intent as: IT, HR, Finance, or Unknown. Reply with one word only."},
            {"role": "user", "content": message},
        ],
        max_tokens=5,
    )
    return result.choices[0].message.content.strip()

def orchestrate(user_message: str) -> str:
    intent = classify_intent(user_message)
    agent_id = AGENTS.get(intent)

    if not agent_id:
        return "I can help with IT, HR, or Finance questions. Which area is your question about?"

    # Route to specialist
    openai_client = client.get_openai_client()
    thread = openai_client.beta.threads.create()
    openai_client.beta.threads.messages.create(
        thread_id=thread.id,
        role="user",
        content=user_message,
    )
    run = openai_client.beta.threads.runs.create_and_poll(
        thread_id=thread.id,
        assistant_id=agent_id,
    )
    messages = openai_client.beta.threads.messages.list(thread_id=thread.id)
    return messages.data[0].content[0].text.value
```

---

## Observability and tracing

```python
# Enable full tracing to Application Insights
import os
os.environ["AZURE_EXPERIMENTAL_ENABLE_GENAI_TRACING"] = "true"

from azure.ai.projects.telemetry import AIProjectInstrumentor
AIProjectInstrumentor().instrument()

# All agent runs now emit spans to Application Insights
# View in: Azure Portal → App Insights → Investigate → Transaction search
```

---

## Connect Foundry agent to Copilot Studio (Stage 2 Progressive Enhancement)

### Option A — Copilot Studio calls Foundry via connector action

```yaml
# components/actions/connector/connector-action.mcs.yml adapted for Foundry REST API
# SAFETY TIER: Low
# GUARDRAIL:   None
# REASON:      Read-only knowledge retrieval from Foundry agent

kind: TaskDialog
schema: 2.0.0
schemaName: <SCHEMA>_foundry_specialist
displayName: Ask IT Specialist (Foundry)
actionType: InvokeConnectorTaskAction
connectorId: shared_httpclient
operationId: InvokeHTTP
parameters:
  - name: url
    value: https://<resource>.services.ai.azure.com/api/projects/<project>/agents/runs
  - name: method
    value: POST
  - name: body
    value: ="{\"assistant_id\": \"<FOUNDRY_AGENT_ID>\", \"thread\": {\"messages\": [{\"role\": \"user\", \"content\": \"" & Topic.UserMessage & "\"}]}}"
```

### Option B — M365 Agents SDK orchestrates both

```typescript
// The SDK agent calls both:
import { CopilotStudioClient } from "@microsoft/agents-copilotstudio-client";
import { AIProjectClient } from "@azure/ai-projects";

// Route simple topics → Copilot Studio
// Route complex analytical tasks → Foundry
if (intent === "data_analysis") {
  return await foundryClient.ask(message);
} else {
  return await copilotStudioClient.sendMessage(message);
}
```

---

## C# SDK quickstart

```bash
dotnet new console -n FoundryAgent
cd FoundryAgent
dotnet add package Azure.AI.Projects
dotnet add package Azure.Identity
```

```csharp
using Azure.AI.Projects;
using Azure.Identity;

var client = new AIProjectClient(
    new Uri(Environment.GetEnvironmentVariable("AZURE_AI_FOUNDRY_ENDPOINT")!),
    new DefaultAzureCredential()
);

var openAIClient = client.GetOpenAIClient();

// Create thread and run
var thread = await openAIClient.Beta.Threads.CreateAsync();
await openAIClient.Beta.Threads.Messages.CreateAsync(
    thread.Id, MessageRole.User, "How do I reset my VPN?"
);

var run = await openAIClient.Beta.Threads.Runs.CreateAndPollAsync(
    thread.Id,
    new RunCreationOptions { AssistantId = Environment.GetEnvironmentVariable("FOUNDRY_AGENT_ID")! }
);

var messages = await openAIClient.Beta.Threads.Messages.ListAsync(thread.Id);
Console.WriteLine(messages.Data[0].Content[0].Text.Value);
```

---

## How this recipe relates to the Copilot Studio templates

| Template | Role in this recipe |
|----------|-------------------|
| `recipes/05-orchestrator-agent.md` | The Copilot Studio orchestrator that routes to this Foundry agent |
| `components/actions/connector/` | Connector action that Copilot Studio uses to call the Foundry REST API |
| `project-delivery/00-ai-decision-framework.md` | Step 6 scale limits section — triggers the move to Foundry |
| `project-delivery/09-technical-design-document.md` | Documents the Copilot Studio ↔ Foundry boundary and data flow |
| `project-delivery/11-ai-engineer-realtime-guide.md` | Post-launch progressive enhancement decision card |

---

## Setup Checklist

### Azure resources
- [ ] Create Azure AI Foundry Hub (portal: https://ai.azure.com)
- [ ] Create Azure AI Foundry Project inside the hub
- [ ] Deploy model: `gpt-4o` recommended → note deployment name
- [ ] Create Azure AI Search resource + index (if using knowledge grounding)
- [ ] Configure connections in Foundry: Azure AI Search, Blob Storage, etc.

### Agent creation
- [ ] Create agent in portal OR via SDK → note `FOUNDRY_AGENT_ID`
- [ ] Set instructions (system prompt) scoped to the specialist domain
- [ ] Add tools: Azure AI Search, File Search, Code Interpreter as needed
- [ ] Test in Foundry playground

### Integration with Copilot Studio (if Stage 2)
- [ ] Add connector action to Copilot Studio agent that calls Foundry REST API
- [ ] Set connector action safety tier (usually Low — retrieval only)
- [ ] Test end-to-end: Copilot Studio topic → connector action → Foundry → response

### Observability
- [ ] Enable tracing: `AZURE_EXPERIMENTAL_ENABLE_GENAI_TRACING=true`
- [ ] Connect to Application Insights workspace
- [ ] Add to `operations/02-monitoring-queries.md` — Foundry-specific KQL queries

---

## Key links

| Resource | URL |
|----------|-----|
| Foundry portal | https://ai.azure.com |
| Foundry Agent Service overview | https://learn.microsoft.com/azure/foundry/agents/overview |
| Python SDK quickstart | https://learn.microsoft.com/azure/foundry/quickstarts/get-started-code |
| Azure AI Search tool | https://learn.microsoft.com/azure/foundry/agents/how-to/tools/ai-search |
| Hosted Agents (Preview) | https://learn.microsoft.com/azure/foundry/agents/quickstarts/quickstart-hosted-agent |
| Agent Framework (open-source) | https://github.com/microsoft/agent-framework |
| SDK overview | https://learn.microsoft.com/azure/foundry/how-to/develop/sdk-overview |
