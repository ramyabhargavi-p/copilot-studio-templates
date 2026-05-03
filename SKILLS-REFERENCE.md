# Skills Reference — Claude Skills Mapped to This Project

This document maps every installed Claude skill to its use in the Copilot Studio agent build process.
Invoke any skill by typing its slash command in your Claude session.

**Quick navigation:** [WorkIQ — M365 Context](#workiq--m365-context) · [Copilot Studio Skills](#copilot-studio-skills) · [Superpowers Skills](#superpowers-skills) · [Other Plugins](#other-plugins) · [By Phase](#skills-by-phase) · [Developer Cheat Sheet](#developer-cheat-sheet)

---

## WorkIQ — M365 Context

WorkIQ reads your Microsoft 365 data — attended meetings, Teams chats, emails, SharePoint, calendar, and Planner — and feeds that context directly into your development work. Instead of hunting through notes or asking colleagues what was decided, you ask WorkIQ and it pulls the answer from your actual M365 activity.

**The core pattern:** Ask WorkIQ first to load context → then use that context to drive the next dev action.

### Plugin: `workiq` — Natural language M365 queries

| Command | What it does | Developer use case |
|---------|-------------|-------------------|
| `/workiq` | Query any M365 data in plain English — emails, meetings, chats, documents, people | Use before any task where the requirement came from a meeting or Teams conversation |

**Example questions to ask via `/workiq`:**

| You want to know | Ask WorkIQ |
|-----------------|-----------|
| What was agreed in the requirements meeting | "What decisions were made in the [agent name] requirements meeting?" |
| What connectors were discussed | "What did the team discuss about connectors for the HR agent in Teams?" |
| What the stakeholder emailed about scope | "Any emails from [stakeholder] about what the agent should handle?" |
| Who owns the SharePoint site you need | "Who manages the HR SharePoint site?" |
| What environment URLs were shared | "What Power Platform environment URLs were shared in emails this week?" |
| What test feedback came in | "What did [tester] say about the agent UAT results?" |
| What broke in production | "Any Teams messages or emails about the agent not working today?" |
| What action items came out of sprint planning | "What action items were assigned to me in the sprint planning meeting?" |

### Plugin: `workiq-productivity` — Structured M365 productivity skills

| Command | What it does | Developer use case |
|---------|-------------|-------------------|
| `/workiq:action-item-extractor` | Extracts action items with owners, deadlines, and priorities from a meeting | After every project meeting — turn meeting chat into a tracked task list |
| `/workiq:channel-digest` | Consolidated summary of activity across Teams channels — decisions, action items, mentions | Morning standup prep; catching up after time off; pre-build context |
| `/workiq:daily-outlook-triage` | Summary of today's inbox and calendar | Start of day — understand what needs attention before coding |
| `/workiq:multi-plan-search` | Search tasks across all Planner plans | Find outstanding tasks for the agent project across all boards |
| `/workiq:site-explorer` | Browse SharePoint sites, lists, and document libraries | Discovering available knowledge sources before Step 7 (content audit) |
| `/workiq:email-analytics` | Email volume, senders, response patterns | Understanding stakeholder communication load; finding who is active on a project |
| `/workiq:org-chart` | Visual org chart for any person | Finding who owns a system or approves a connector |
| `/workiq:channel-audit` | Audit Teams channels for inactivity | Identifying the right channels to monitor for agent feedback |
| `/workiq:meeting-cost-calculator` | Time and money cost of meetings | Quantifying the time cost that an agent could deflect |

### WorkIQ aligned to the build lifecycle

| Phase | What you use WorkIQ for | Command |
|-------|------------------------|---------|
| **Discovery — Step 3** | Pull context from requirements meetings before filling in the questionnaire | `/workiq` → "What was discussed in the [project] kick-off meeting?" |
| **Discovery — Step 3** | Extract action items from the requirements session | `/workiq:action-item-extractor` → meeting: "requirements" |
| **Discovery — Step 4** | Find environment URLs, connector details, auth config shared in emails | `/workiq` → "What environment URLs were shared for the HR agent project?" |
| **Discovery — Step 5** | Understand current user workflows from Teams discussions | `/workiq` → "What did [team] say about how they submit leave requests today?" |
| **Design — Step 8** | Check what use cases were agreed in design workshops | `/workiq` → "What use cases were finalised in the agent design meeting?" |
| **Design — Step 10** | Find security requirements from emails or security review meetings | `/workiq` → "Any emails from security team about agent data handling requirements?" |
| **Build — Step 14** | Look up connector details, API endpoints, SharePoint site structure | `/workiq` → "What SharePoint sites were mentioned for the knowledge source?" |
| **Build — Step 14** | Find who to contact when a connector or system is unclear | `/workiq` → "Who owns the leave management API?" |
| **Build — Steps 14–15** | Stay current with team decisions without leaving your dev session | `/workiq:channel-digest` → Engineering channel, last 24h |
| **Test — Step 20** | Pull UAT feedback from Teams or email before fixing | `/workiq` → "What feedback did [tester] share about the agent in Teams?" |
| **Test — Step 20** | Extract action items from UAT sessions | `/workiq:action-item-extractor` → meeting: "UAT session" |
| **Operate — Step 27** | Check if incident was discussed in Teams before investigating | `/workiq` → "Any Teams messages about the HR agent failing today?" |
| **Operate — Step 26** | Catch up on agent-related channel activity | `/workiq:channel-digest` → agent support channel |
| **Any phase** | Find relevant SharePoint knowledge sources | `/workiq:site-explorer` |
| **Any phase** | Know your tasks and priorities for the day | `/workiq:daily-outlook-triage` |

---

## Copilot Studio Skills

These skills directly operate on your Copilot Studio agent — they read and write YAML, push to environments, run tests, and validate configuration.

### Author — Building and Editing

| Skill | Command | What it does | Use at step |
|-------|---------|-------------|-------------|
| `detect-mode` | `/copilot-studio:detect-mode` | Identifies the right authoring mode (Author / Manage / Test / Troubleshoot) for your current task | 12 — before starting any build work |
| `clone-agent` | `/copilot-studio:clone-agent` | Creates a new agent from the base template with correct IDs and schemaName | 13 — setting up a new agent |
| `edit-agent` | `/copilot-studio:edit-agent` | Edits agent-level configuration: display name, instructions, conversation starters, settings | 13, 15 — agent config |
| `new-topic` | `/copilot-studio:new-topic` | Creates a new topic YAML file with correct trigger, nodes, and telemetry scaffold | 14 — adding topics |
| `add-action` | `/copilot-studio:add-action` | Adds a connector or MCP action to the agent | 14 — adding actions |
| `add-knowledge` | `/copilot-studio:add-knowledge` | Adds a SharePoint or web knowledge source | 14 — adding knowledge sources |
| `add-adaptive-card` | `/copilot-studio:add-adaptive-card` | Generates an adaptive card JSON for confirmation, status, or form use cases | 14 — building cards |
| `add-global-variable` | `/copilot-studio:add-global-variable` | Adds a global variable definition to the agent | 14 — state management |
| `add-node` | `/copilot-studio:add-node` | Adds a specific node kind to an existing topic | 14, 15 — mid-topic edits |
| `add-other-agents` | `/copilot-studio:add-other-agents` | Wires a child agent into an orchestrator topic | 14 — multi-agent patterns |
| `edit-action` | `/copilot-studio:edit-action` | Modifies an existing action's inputs, outputs, or error handling | 15 — build refinements |
| `edit-triggers` | `/copilot-studio:edit-triggers` | Updates trigger phrases on an existing topic | 15 — improving routing |

### Manage — Deploying and Publishing

| Skill | Command | What it does | Use at step |
|-------|---------|-------------|-------------|
| `manage-agent` | `/copilot-studio:manage-agent` | Push, publish, and manage agent lifecycle across environments | 21 — launch, and ongoing |
| `clone-agent` | `/copilot-studio:clone-agent` | Also used to promote an agent to a new environment | 16 — first-time env setup |

### Test — Running and Evaluating

| Skill | Command | What it does | Use at step |
|-------|---------|-------------|-------------|
| `create-eval` | `/copilot-studio:create-eval` | Creates an eval CSV file from your topic list and scenarios | 17 — building test suite |
| `create-eval-set` | `/copilot-studio:create-eval-set` | Creates a batch eval set for running multiple test scenarios | 17 — batch testing |
| `run-eval` | `/copilot-studio:run-eval` | Runs the eval suite against the current draft agent | 17 — measuring routing accuracy |
| `analyze-evals` | `/copilot-studio:analyze-evals` | Reads eval results and identifies low-accuracy topics to fix | 17, 24, 25, 26 — post-eval analysis |
| `run-tests-kit` | `/copilot-studio:run-tests-kit` | Runs the full UAT test kit against the agent | 20 — UAT execution |
| `chat-with-agent` | `/copilot-studio:chat-with-agent` | Opens a test conversation with the draft agent without publishing | 20 — exploratory UAT |
| `chat-directline` | `/copilot-studio:chat-directline` | Tests via DirectLine channel (matches published channel behaviour) | 20 — channel-accurate testing |
| `chat-sdk` | `/copilot-studio:chat-sdk` | Tests using the SDK interface | 20 — SDK integration testing |
| `test-auth` | `/copilot-studio:test-auth` | Tests the authentication flow end-to-end | 20 — sign-in testing |
| `directline-chat` | `/copilot-studio:directline-chat` | Alternative DirectLine test interface | 20 — Teams behaviour testing |

### Troubleshoot — Validating and Debugging

| Skill | Command | What it does | Use at step |
|-------|---------|-------------|-------------|
| `validate` | `/copilot-studio:validate` | Validates YAML schema, checks for broken references and missing IDs | 18, 19, 21 — pre-launch checks |
| `known-issues` | `/copilot-studio:known-issues` | Checks the agent against a list of known Copilot Studio bugs and patterns | 19 — security and sanity check |
| `lookup-schema` | `/copilot-studio:lookup-schema` | Returns the full YAML schema for any node kind or component type | 14, 15 — when writing YAML manually |
| `list-topics` | `/copilot-studio:list-topics` | Lists all topics in the agent with their triggers and status | 15 — reviewing coverage |
| `list-kinds` | `/copilot-studio:list-kinds` | Lists all valid node kinds available in the current SDK version | 14 — checking what nodes exist |
| `best-practices` | `/copilot-studio:best-practices` | Audits the agent against Copilot Studio best practices and flags issues | 6, 11, 18, 28 — design + ongoing reviews |

---

## Superpowers Skills

These skills guide the development process — how to plan, build, test, and review work.

| Skill | Command | What it does | Use at step |
|-------|---------|-------------|-------------|
| `brainstorming` | `/brainstorming` | Structured design session: asks clarifying questions, proposes approaches, writes a spec | 3, 5, 8, 9, 10 — discovery and design |
| `writing-plans` | `/writing-plans` | Breaks an approved spec into a numbered, ordered implementation plan | 15 — before starting build |
| `executing-plans` | `/executing-plans` | Works through a written implementation plan step by step, tracking progress | 15 — during build |
| `systematic-debugging` | `/systematic-debugging` | Structured debugging: form hypothesis, isolate cause, verify fix | 27 — incident response |
| `test-driven-development` | `/test-driven-development` | TDD workflow: write test cases before implementing, verify each passes | 15 — when building action topics |
| `requesting-code-review` | `/requesting-code-review` | Prepares YAML for peer review with context and change summary | After step 15 — before PR |
| `receiving-code-review` | `/receiving-code-review` | Processes review feedback and applies fixes systematically | After step 15 — addressing review comments |
| `finishing-a-development-branch` | `/finishing-a-development-branch` | Wraps up a feature branch: final checks, commit, PR prep | After step 15 — before merging |
| `subagent-driven-development` | `/subagent-driven-development` | Coordinates parallel work across multiple agent topics or features | 14, 15 — large builds with many topics |
| `dispatching-parallel-agents` | `/dispatching-parallel-agents` | Runs multiple sub-tasks concurrently to speed up build | 14 — when building many components |
| `using-git-worktrees` | `/using-git-worktrees` | Isolates feature work in a git worktree (prevents main branch interference) | 14, 15 — parallel topic development |
| `verification-before-completion` | `/verification-before-completion` | Final pre-completion check before marking a task done | End of each phase |

---

## Other Plugins

| Plugin | Command | What it does | Use at step |
|--------|---------|-------------|-------------|
| `microsoft-docs` | `/microsoft-docs` | Searches and fetches official Microsoft Learn documentation | Any — when you need official docs |
| `code-review` | `/code-review` | Full code review of YAML files against quality standards | After step 15 — YAML review |
| `code-simplifier` | `/code-simplifier` | Simplifies complex or repetitive YAML | 15 — after build, before PR |
| `feature-dev` | `/feature-dev` | Structured feature development with explore → architect → review agents | 14, 15 — complex feature topics |
| `optibot` | `/optibot` | Optimises prompts and agent instructions for clarity and performance | 11 — writing system prompts |
| `context7` | `/context7` | Pulls in up-to-date library and SDK documentation as context | 14, 15 — when working with connectors or MCP |
| `skill-creator` | `/skill-creator` | Creates new custom skills for repeated project-specific tasks | When you want to automate a recurring workflow |
| `claude-md-management` | `/claude-md-management` | Creates and updates CLAUDE.md files for project-specific Claude behaviour | Project setup — define coding standards |
| `workiq` | `/workiq` | Query M365 data — emails, meetings, Teams chats, documents, people | Any — load M365 context before any task |
| `workiq-productivity` | `/workiq:action-item-extractor` | Extract action items from meeting content | After requirements, design, UAT meetings |
| `workiq-productivity` | `/workiq:channel-digest` | Summarise Teams channel activity — decisions, action items, mentions | Start of day, pre-standup, catching up |
| `workiq-productivity` | `/workiq:daily-outlook-triage` | Today's inbox and calendar summary | Start of each dev day |
| `workiq-productivity` | `/workiq:multi-plan-search` | Search tasks across all Planner plans | Tracking project tasks |
| `workiq-productivity` | `/workiq:site-explorer` | Browse SharePoint sites and libraries | Step 7 — content audit, knowledge source discovery |

---

## Skills by Phase

A quick-reference summary of which skills are most useful at each phase.

### Phase 0 — Tools Setup
No skills required. Follow `TOOLS-AND-PLUGINS.md` directly.

### Phase 1 — Decision
No skills required. Complete the assessment documents manually.

### Phase 2 — Discovery
| Skill | When |
|-------|------|
| `/workiq` | Step 3 — pull context from requirements meetings before filling in the questionnaire |
| `/workiq:action-item-extractor` | Step 3 — extract action items from the requirements session |
| `/workiq` | Step 4 — find environment URLs, connector details, auth config from emails |
| `/workiq` | Step 5 — understand current user workflows from Teams discussions |
| `/workiq:site-explorer` | Step 5 — discover SharePoint sites users work with today |
| `/brainstorming` | Steps 3 and 5 — turn requirements into a structured spec |
| `/microsoft-docs` | Any point — look up Microsoft licensing, connector, or environment docs |

### Phase 3 — Design
| Skill | When |
|-------|------|
| `/workiq` | Step 8 — check what use cases were agreed in design workshops |
| `/workiq` | Step 10 — find security requirements from emails or security review meetings |
| `/workiq:org-chart` | Step 10 — identify who approves connectors and security decisions |
| `/brainstorming` | Steps 8, 9, 10 — design FDD, conversation flows, technical architecture |
| `/copilot-studio:best-practices` | Steps 6, 11 — validate component selection and prompt patterns |
| `/optibot` | Step 11 — optimise the agent system prompt |
| `/microsoft-docs` | Any point — fetch official docs on specific capabilities |

### Phase 4 — Build
| Skill | When |
|-------|------|
| `/workiq:channel-digest` | Start of each build session — catch up on what was discussed overnight |
| `/workiq` | Step 14 — look up connector details, API endpoints, SharePoint structure shared in chats/emails |
| `/workiq` | Step 14 — find who to ask when a connector or system requirement is unclear |
| `/copilot-studio:detect-mode` | Step 12 — determine correct build mode before starting |
| `/copilot-studio:clone-agent` | Step 13 — scaffold new agent from base |
| `/copilot-studio:new-topic` | Step 14 — every new topic you add |
| `/copilot-studio:add-action` | Step 14 — adding connector or MCP actions |
| `/copilot-studio:add-knowledge` | Step 14 — adding SharePoint or web knowledge sources |
| `/copilot-studio:add-adaptive-card` | Step 14 — confirmation, status, and form cards |
| `/copilot-studio:add-global-variable` | Step 14 — user profile, locale, flags |
| `/copilot-studio:add-node` | Step 14, 15 — adding individual nodes within topics |
| `/copilot-studio:lookup-schema` | Step 14, 15 — checking valid YAML schema for any node |
| `/copilot-studio:list-kinds` | Step 14 — checking available node kinds |
| `/copilot-studio:edit-triggers` | Step 15 — improving trigger phrase coverage |
| `/writing-plans` | Step 15 — break build spec into ordered tasks |
| `/executing-plans` | Step 15 — work through the plan step by step |
| `/test-driven-development` | Step 15 — write eval cases before implementing action topics |
| `/code-simplifier` | Step 15 — simplify complex or repetitive YAML |
| `/feature-dev` | Step 14, 15 — complex features with multiple connected topics |
| `/context7` | Step 14 — when working with specific connectors or MCP servers |
| `/finishing-a-development-branch` | After step 15 — wrap up before PR |

### Phase 5 — Test and Review
| Skill | When |
|-------|------|
| `/workiq` | Step 20 — pull UAT feedback from Teams or email before fixing bugs |
| `/workiq:action-item-extractor` | Step 20 — extract action items from UAT session meeting |
| `/copilot-studio:create-eval` | Step 17 — build the eval test suite |
| `/copilot-studio:run-eval` | Step 17 — run routing accuracy tests |
| `/copilot-studio:analyze-evals` | Step 17 — identify and fix low-accuracy topics |
| `/copilot-studio:validate` | Steps 18, 19 — YAML schema and reference validation |
| `/copilot-studio:known-issues` | Step 19 — security and known-bug check |
| `/copilot-studio:best-practices` | Step 18 — Responsible AI audit |
| `/copilot-studio:run-tests-kit` | Step 20 — run full UAT test kit |
| `/copilot-studio:chat-with-agent` | Step 20 — manual exploratory testing |
| `/copilot-studio:test-auth` | Step 20 — verify sign-in flows |
| `/code-review` | After step 15, before step 17 — YAML peer review |

### Phase 6 — Launch
| Skill | When |
|-------|------|
| `/workiq` | Step 21 — confirm go/no-go decisions from stakeholder emails or chats |
| `/copilot-studio:validate` | Step 21 — final pre-launch validation |
| `/copilot-studio:manage-agent` | Step 21 — push and publish to production |
| `/verification-before-completion` | Step 21 — final completeness check |

### Phase 7 — Operate
| Skill | When |
|-------|------|
| `/workiq` | Step 27 — check Teams/email for incident reports before investigating |
| `/workiq:channel-digest` | Steps 25, 26 — catch up on agent support channel activity |
| `/workiq:action-item-extractor` | After incident reviews — extract follow-up actions from the meeting |
| `/copilot-studio:analyze-evals` | Steps 24, 25, 26 — read monitoring data and identify gaps |
| `/systematic-debugging` | Step 27 — structured incident investigation |
| `/copilot-studio:best-practices` | Step 28 — quarterly agent health review |
| `/copilot-studio:known-issues` | Step 27 — check against known bugs when something breaks |

---

## Developer Cheat Sheet

The fastest way to use your installed skills together as a developer.

### Starting a new day

```
1. /workiq:daily-outlook-triage        → what's in my inbox and calendar today
2. /workiq:channel-digest              → what was discussed in project channels overnight
3. /workiq:multi-plan-search           → what tasks are assigned to me across Planner boards
```

### Starting a new agent project

```
1. /workiq → "What was discussed in the [project] kick-off meeting?"
2. /workiq:action-item-extractor       → pull action items from that meeting
3. /brainstorming                      → structure requirements into a spec
4. /copilot-studio:detect-mode         → confirm authoring mode
5. /copilot-studio:clone-agent         → scaffold the agent
```

### Building a new topic

```
1. /workiq → "What did [stakeholder] say about [use case] in Teams?"
2. /copilot-studio:new-topic           → scaffold the topic YAML
3. /copilot-studio:lookup-schema       → check node schema if unsure
4. /copilot-studio:add-node            → add nodes as you build
5. /copilot-studio:chat-with-agent     → test immediately after each topic
```

### Adding a knowledge source

```
1. /workiq:site-explorer               → discover available SharePoint sites
2. /workiq → "Who manages the [team] SharePoint site?"
3. /copilot-studio:add-knowledge       → wire it into the agent
4. /copilot-studio:chat-with-agent     → test a question against the knowledge source
```

### Before raising a PR

```
1. /copilot-studio:validate            → catch YAML errors
2. /copilot-studio:list-topics         → confirm all topics are present
3. /code-review                        → quality review of YAML
4. /code-simplifier                    → clean up repetitive patterns
5. /finishing-a-development-branch     → commit, PR prep
```

### Running eval and UAT

```
1. /copilot-studio:create-eval         → build test suite from topic list
2. /copilot-studio:run-eval            → run routing accuracy
3. /copilot-studio:analyze-evals       → find low-accuracy topics to fix
4. /copilot-studio:run-tests-kit       → full UAT kit
5. /workiq → "What feedback did [tester] share about the agent?"
6. /workiq:action-item-extractor       → extract fixes from UAT meeting
```

### When something breaks in production

```
1. /workiq → "Any Teams messages or emails about the agent failing?"
2. /workiq:channel-digest              → check the agent support channel
3. /systematic-debugging              → structured investigation
4. /copilot-studio:known-issues        → check against known bugs
5. /copilot-studio:validate            → confirm YAML is still valid
6. /copilot-studio:manage-agent        → push a fix
```
