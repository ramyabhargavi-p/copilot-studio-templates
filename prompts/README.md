# Prompts

> **Two types of prompts — pick based on how much customisation you need:**
>
> | Folder | What it is | When to use |
> |--------|-----------|------------|
> | `system-prompts/` | Ready-made personas — copy and paste directly into `agent.mcs.yml` | Starting from a known agent type (HR, IT, customer support, knowledge base) — fastest option |
> | `ai-prompts/` | Prompts you send to Claude to generate custom YAML | Agent doesn't fit a template, or you want instructions tailored to your exact SOW/brief |

---

## How to use system-prompts (5 minutes)

1. Open the matching file — e.g. `system-prompts/hr-assistant.md`
2. Copy everything inside the triple backticks (the full prompt text)
3. In your cloned agent folder, open `agent.mcs.yml`
4. Replace the entire `instructions: |` block with what you copied
5. Replace every `[BRACKET]` value with your real values:
   - `[Company Name]` → e.g. Graybar
   - `payroll@[company].com` → real contact email
   - `[IT helpdesk link or email]` → real helpdesk link
6. Save — then VS Code → Apply Changes

**UI alternative:** Copilot Studio portal → your agent → Settings → Instructions → paste the text → Save

---

## How to use ai-prompts to generate custom instructions (10 minutes)

Use `ai-prompts/generate-agent-instructions.md` when the ready-made personas don't fit your project.

**Step 1** — Open `ai-prompts/generate-agent-instructions.md` and copy the prompt template block.

**Step 2** — Paste it into Claude (this Claude Code session, or claude.ai) and fill in the blanks:

```
Project brief:
---
[3–5 sentences: what the agent does, who uses it, what it must NOT handle,
where out-of-scope topics should redirect, any compliance or tone requirements]
---

Agent name: HR Assistant
Primary users: internal employees
Authentication: ManualAzureAD
Tone: Empathetic
```

**Step 3** — Claude returns a ready-to-paste `instructions: |` block. Copy the output.

**Step 4** — Paste it into `agent.mcs.yml` replacing the `instructions: |` block. Save.

**Step 5** — VS Code → Apply Changes.

> **Tip:** You can also ask Claude to refine an existing instructions block. Open the "Variations" section in `generate-agent-instructions.md` for the refine and add-date-context prompts.

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

→ Full template inventory: [`../docs/TEMPLATES.md`](../docs/TEMPLATES.md)
→ How topics fit together: [`../docs/COMPONENT-REGISTRY.md`](../docs/COMPONENT-REGISTRY.md)
