# Skills Quick Reference — How to Use Claude Skills for Agent Development

A practical guide to invoking Claude skills for building, testing, and deploying Copilot Studio agents. Each skill is mapped to a specific development task.

---

## Quick Start: The Skill Workflow

### Step 1 — Load Context (Optional but Recommended)
Before building, gather context from your organization using WorkIQ:

```
/workiq "What were the requirements discussed for the [agent name] project?"
```

This pulls emails, meeting notes, Teams messages, and decisions directly into your session.

---

### Step 2 — Create or Edit Agent
Use the appropriate Copilot Studio skill:

```
/copilot-studio:new-topic      # Add a new conversation topic
/copilot-studio:add-knowledge  # Add SharePoint / web knowledge
/copilot-studio:add-action     # Add a connector or API action
```

---

### Step 3 — Validate Before Pushing
```
/copilot-studio:validate       # Check for YAML errors
```

---

### Step 4 — Deploy and Manage
```
/copilot-studio:manage-agent   # Push to environment and publish
```

---

## Skills by Development Phase

### Phase 1: Discovery (Gather Requirements)

| Skill | Command | What to ask | When |
|-------|---------|----------|------|
| WorkIQ | `/workiq` | "What were discussed in the [project] requirements meeting?" | Before design starts |
| WorkIQ | `/workiq` | "What systems need integration for the [agent]?" | When planning actions |
| Action Item Extractor | `/workiq:action-item-extractor` | "Extract action items from the requirements meeting" | After meetings to track tasks |
| Org Chart | `/workiq:org-chart` | "Who is the manager of [person]?" | Finding approval chains |
| Site Explorer | `/workiq:site-explorer` | "Show me HR SharePoint sites" | Finding knowledge sources |

**Example usage:**
```
/workiq "What are the top 3 pain points the HR team mentioned about leave requests?"
→ Copilot retrieves Teams messages and emails from the team
→ You use this to shape your agent's features
```

---

### Phase 2: Design (Plan Architecture)

| Skill | Command | What to use it for | When |
|-------|---------|-------------------|------|
| Channel Digest | `/workiq:channel-digest` | "Summarize decisions from the engineering channel last 2 days" | Before design review |
| Detect Mode | `/copilot-studio:detect-mode` | Find the right authoring approach | Start of design |
| Clone Agent | `/copilot-studio:clone-agent` | Create a new agent from base template | When starting an agent |
| Edit Agent | `/copilot-studio:edit-agent` | Set agent name, instructions, settings | During design |
| Add Adaptive Card | `/copilot-studio:add-adaptive-card` | Create confirmation screens or forms | When designing UX |

**Example usage:**
```
/copilot-studio:detect-mode
→ Copilot identifies if you should use author mode, manage mode, or test mode
→ Recommends the right approach based on your task
```

---

### Phase 3: Build (Implement)

| Skill | Command | What to use it for | When |
|-------|---------|-------------------|---|
| New Topic | `/copilot-studio:new-topic` | Create a new conversation topic with nodes | Adding a feature |
| Add Knowledge | `/copilot-studio:add-knowledge` | Add SharePoint site or web knowledge | FAQ agents |
| Add Action | `/copilot-studio:add-action` | Add connector or MCP action | Action agents |
| Add Global Variable | `/copilot-studio:add-global-variable` | Add state variables to agent | For tracking info |
| Add Node | `/copilot-studio:add-node` | Add a specific node (Message, Card, etc.) | Mid-topic editing |
| Edit Triggers | `/copilot-studio:edit-triggers` | Update topic trigger phrases | Improving routing |
| Validate | `/copilot-studio:validate` | Check YAML for errors before pushing | Before deployment |

**Example usage:**
```
/copilot-studio:add-action "Add a connector to submit leave requests to HR system"
→ Copilot creates an action node with inputs/outputs
→ You fill in the connector details
→ Action is ready to use in topics
```

---

### Phase 4: Test (Evaluate)

| Skill | Command | What to use it for | When |
|-------|---------|-------------------|---|
| Run Eval | `/copilot-studio:run-eval` | Test agent accuracy on scenarios | Before launch |
| Chat with Agent | `/copilot-studio:chat-with-agent` | Test agent in a conversation | During development |

**Example usage:**
```
/copilot-studio:run-eval "Test the agent on 10 leave request scenarios"
→ Copilot runs your agent against test cases
→ Reports accuracy and failure cases
→ You fix and re-test
```

---

### Phase 5: Deploy & Go Live

| Skill | Command | What to use it for | When |
|-------|---------|-------------------|---|
| Manage Agent | `/copilot-studio:manage-agent` | Push to cloud, publish, manage across environments | Launch and post-launch |

**Example usage:**
```
/copilot-studio:manage-agent "Promote to UAT and publish"
→ Copilot handles environment switching and publishing
→ Agent goes live for testers
```

---

## Skill Reference by Task

### "I need to create a new agent from scratch"
```
1. /workiq "What are the requirements for this agent?"
2. /copilot-studio:detect-mode
3. /copilot-studio:clone-agent
4. /copilot-studio:edit-agent "Set name and system prompt"
```

### "I need to add a knowledge source (FAQ)"
```
1. /copilot-studio:add-knowledge "Add SharePoint HR policies"
   → Choose: SharePoint site
   → Provide: Site URL and list name
   → Done! Agent now searches that site
```

### "I need to add an action (submit to system)"
```
1. /copilot-studio:add-action "Add connector to submit leave requests"
   → Choose: Power Automate connector or MCP
   → Map: Agent fields → System fields
   → Done! Users can now submit data
```

### "I need to validate before pushing to cloud"
```
1. /copilot-studio:validate
→ Shows any YAML syntax errors
→ Fix errors and validate again
→ Ready to deploy when "0 errors"
```

### "I need to test the agent before launch"
```
1. /copilot-studio:chat-with-agent "Ask it questions"
→ Have a conversation to test routing
→ Check if fallback triggers correctly
→ Verify actions work

2. /copilot-studio:run-eval "Test on 20 scenarios"
→ Copilot tests accuracy systematically
→ Reports % correct and failure cases
→ Use to improve prompts
```

### "I need to fix a routing issue (users get wrong topic)"
```
1. /workiq:channel-digest "What feedback did testers give about routing?"
→ Gather feedback about misroutes

2. /copilot-studio:edit-triggers "Update topic trigger phrases"
→ Improve phrases to match user language
→ Re-test with /copilot-studio:run-eval
```

### "I need to look up who owns a system"
```
/workiq:org-chart "Show org chart for [person name]"
→ See who manages the system you're integrating with
→ Use for questions or escalations
```

### "I need context for a meeting about the agent"
```
/workiq:daily-outlook-triage
→ See your calendar and emails
→ Understand what needs to be discussed

/workiq:action-item-extractor "Extract action items from the requirements meeting"
→ Turn meeting chat into tracked tasks
```

---

## Common Mistakes & How to Avoid Them

| Mistake | What happens | Fix |
|---------|-------------|-----|
| Skip `/workiq` and start coding | Agent doesn't match actual requirements | Always start with `/workiq` to load context |
| Don't validate before pushing | Agent fails in the cloud with cryptic errors | Always run `/copilot-studio:validate` first |
| Use `/copilot-studio:validate` when you mean `/copilot-studio:clone-agent` | Nothing happens | Read the skill description before calling |
| Try to add action without understanding the system | Action fails at runtime | Use `/workiq "What does this system API expect?"` first |
| Skip testing before launch | Users hit bugs immediately | Always run `/copilot-studio:run-eval` before go-live |

---

## Skill Invocation Syntax

### Basic Format
```
/<skill-namespace>:<skill-name> "<description or question>"
```

**Examples:**
```
/copilot-studio:add-knowledge "Add HR policies from SharePoint"
/workiq "What were discussed in meetings about this agent?"
/copilot-studio:run-eval "Test the agent accuracy"
```

### Multi-step Tasks
Some skills launch a multi-step process. After invoking, Copilot will:
1. Ask clarifying questions
2. Gather information from you
3. Generate the component
4. Insert it into your agent

**Example:**
```
/copilot-studio:new-topic "Create a topic for leave requests"
→ Copilot asks: "What should trigger this topic?"
→ You answer: "When user says 'I want to request leave'"
→ Copilot creates the topic with trigger phrases and nodes
```

---

## Troubleshooting Skills

### Skill returns "Not found" error
**Cause:** You invoked the skill incorrectly  
**Fix:** Check the exact command in this guide and make sure:
- You used `/` not `\`
- You used `:` between namespace and skill name
- Spell matches exactly (case-sensitive)

**Example of correct vs wrong:**
```
✅ /copilot-studio:add-knowledge
❌ /copilot-studio-add-knowledge
❌ /copilot-studio:addKnowledge
```

---

### Skill asks for input but you don't know what to provide
**Cause:** You skipped a prerequisite step  
**Fix:** Before invoking the skill, do the prerequisite:

| Skill | Prerequisite |
|-------|-------------|
| `/copilot-studio:add-action` | Know the system URL and API credentials |
| `/copilot-studio:add-knowledge` | Know the SharePoint site URL |
| `/copilot-studio:new-topic` | Have defined trigger phrases for the topic |
| `/copilot-studio:run-eval` | Have created test scenarios |

---

### Skill output doesn't match what you expected
**Cause:** You used the wrong skill or provided ambiguous input  
**Fix:** 
1. Check you called the right skill (see "Skill Reference by Task" above)
2. Ask WorkIQ first to load context: `/workiq "What is the requirement?"`
3. Then invoke the skill with specific details: `/copilot-studio:add-action "Add SharePoint connector to submit requests"`

---

## Advanced: Combining Skills

### Workflow 1: Build a FAQ Agent End-to-End
```
1. /workiq "What are the top FAQ questions?"
   → Gather requirements

2. /copilot-studio:clone-agent
   → Create new agent

3. /copilot-studio:edit-agent "Set name to FAQ Bot"
   → Configure agent

4. /copilot-studio:add-knowledge "Add HR SharePoint site"
   → Add FAQ content

5. /copilot-studio:validate
   → Check for errors

6. /copilot-studio:manage-agent "Push to dev environment"
   → Deploy

7. /copilot-studio:chat-with-agent "Test FAQ responses"
   → Verify it works

8. /copilot-studio:manage-agent "Publish to users"
   → Go live
```

### Workflow 2: Build an Action Agent (Data Submission)
```
1. /workiq "What system are we integrating with?"
   → Understand the backend

2. /workiq:site-explorer "Find API documentation"
   → Locate technical details

3. /copilot-studio:new-topic "Create leave request topic"
   → Plan the conversation

4. /copilot-studio:add-action "Add leave submission action"
   → Connect to the system

5. /copilot-studio:add-adaptive-card "Create confirmation card"
   → Build the UX

6. /copilot-studio:validate
   → Check errors

7. /copilot-studio:run-eval "Test 10 leave request scenarios"
   → Verify accuracy

8. /copilot-studio:manage-agent "Publish"
   → Go live
```

---

## When to Use vs. When NOT to Use Each Skill

| Skill | ✅ Use when | ❌ Don't use when |
|-------|-----------|-----------------|
| `/workiq` | You need context from emails, Teams, meetings | You already have all requirements documented |
| `/copilot-studio:clone-agent` | Starting a new agent | Editing an existing agent (use VS Code instead) |
| `/copilot-studio:validate` | Before pushing to any environment | After every single change (only needed before deploy) |
| `/copilot-studio:run-eval` | Before launch or after major changes | Testing individual user queries (use chat instead) |
| `/copilot-studio:chat-with-agent` | Manually testing a feature | Systematic accuracy testing (use run-eval) |

---

## Next Steps

- **Learn skills in action:** See `recipes/` folder for end-to-end examples
- **Full command reference:** See `commands/` folder for pac CLI commands
- **Troubleshooting:** See `troubleshooting/` folder if something breaks

---

**Ready to build? Start with `/workiq` to load context, then invoke the skill for your task. Happy building! 🚀**
