# Prompts

Two types of prompts — one for what you paste into your agent, one for what you send to Claude.

---

## Two subfolders

| Folder | What it is | Use it when… |
|--------|-----------|-------------|
| [`system-prompts/`](system-prompts/) | Ready-made agent personas — paste into `agent.mcs.yml` → `instructions` | You need a starting persona for your agent |
| [`ai-prompts/`](ai-prompts/) | Claude generation prompts — paste into Claude to auto-generate YAML | You want Claude to write topics, eval cases, or cards for you |

---

## System prompts — pick your persona

| File | Persona | Paste into |
|------|---------|-----------|
| [`system-prompts/hr-assistant.md`](system-prompts/hr-assistant.md) | HR policies, leave, benefits | `agent.mcs.yml` → `instructions` |
| [`system-prompts/it-helpdesk.md`](system-prompts/it-helpdesk.md) | IT support, password resets, service desk | `agent.mcs.yml` → `instructions` |
| [`system-prompts/customer-support.md`](system-prompts/customer-support.md) | External customer-facing service | `agent.mcs.yml` → `instructions` |
| [`system-prompts/knowledge-base.md`](system-prompts/knowledge-base.md) | Generic internal knowledge base | `agent.mcs.yml` → `instructions` |

After pasting, replace `<ORG_NAME>`, `<AGENT_NAME>`, and any other `<AngleBracket>` placeholders.

---

## AI generation prompts — send to Claude

| File | Send it when you need… | Output |
|------|----------------------|--------|
| [`ai-prompts/generate-topic.md`](ai-prompts/generate-topic.md) | A new `.topic.mcs.yml` from a plain-English scenario | Complete topic YAML |
| [`ai-prompts/generate-agent-instructions.md`](ai-prompts/generate-agent-instructions.md) | A custom system prompt for your agent | `instructions:` block |
| [`ai-prompts/generate-adaptive-card.md`](ai-prompts/generate-adaptive-card.md) | An adaptive card JSON from a description | Card JSON + YAML snippet |
| [`ai-prompts/generate-eval-cases.md`](ai-prompts/generate-eval-cases.md) | Eval test cases for routing accuracy | YAML eval test file |
| [`ai-prompts/review-agent.md`](ai-prompts/review-agent.md) | A quality review of your agent YAML | Findings + improvement list |
| [`ai-prompts/prompt-engineering-patterns.md`](ai-prompts/prompt-engineering-patterns.md) | Reference for P1–P10 system prompt patterns | Pattern reference doc |

### How to use a generation prompt

1. Open the file and copy its full contents
2. Paste into a new Claude conversation
3. Answer Claude's questions about your specific scenario
4. Copy the generated YAML back into your agent folder
5. Replace all `_REPLACE` node IDs with unique 6-char strings (see `../QUICKSTART.md`)

→ Full template inventory: [`../TEMPLATES.md`](../TEMPLATES.md)
→ How topics fit together: [`../COMPONENT-REGISTRY.md`](../COMPONENT-REGISTRY.md)
