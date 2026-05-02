# AI Prompts

Prompts to use with Claude, Copilot, or any AI assistant to generate, extend, and review Copilot Studio YAML files.

## When to Use Each Prompt

| Prompt | When |
|--------|------|
| [`generate-agent-instructions.md`](generate-agent-instructions.md) | You have a SOW or brief and need to write the `agent.mcs.yml` instructions field |
| [`generate-topic.md`](generate-topic.md) | You need to create a new topic YAML for a specific user scenario |
| [`review-agent.md`](review-agent.md) | You've built an agent and want an AI to audit it before publishing |

## How to Use

1. Open the prompt file
2. Copy the prompt template
3. Paste into Claude Code, Copilot, or your AI assistant of choice
4. Replace the `[BRACKET]` sections with your specifics
5. Paste the output into your YAML file and review before saving

## Tips

- **Be specific in the input** — the more detail you give, the better the output
- **Always review AI output** before using — check IDs are `_REPLACE`, placeholders are correct, and YAML indentation is valid
- **Use `review-agent.md` before every UAT** — it catches common mistakes in under 2 minutes
- **Iterate** — if the first output isn't right, paste it back and ask the AI to refine one specific section
