# Prompts

Two types of reusable prompts for Copilot Studio agent development.

## Folders

| Folder | Contains | Use when |
|--------|----------|---------|
| [`system-prompts/`](system-prompts/) | Ready-made `instructions` content for `agent.mcs.yml` | Starting a new agent — paste and replace `[BRACKET]` values |
| [`ai-prompts/`](ai-prompts/) | Prompts to give to Claude/Copilot to generate YAML and review agents | Generating new topics, instructions, or auditing an existing agent |

## Quick Reference

### Starting a new agent?
1. Pick the closest system prompt from `system-prompts/`
2. Paste it into `agent.mcs.yml` → `instructions`
3. Replace all `[BRACKET]` values
4. Use `ai-prompts/generate-agent-instructions.md` if you need to customise further

### Building a new topic?
1. Use `ai-prompts/generate-topic.md` to describe the scenario
2. Paste the AI output into a new `.topic.mcs.yml` file
3. Replace `_REPLACE` IDs with unique strings

### Ready to test?
1. Use `ai-prompts/review-agent.md` to audit your files
2. Run the UAT checklist from `BEST-PRACTICES.md` Section 11
