# Skills Reference — Claude Skills Mapped to This Project

This document maps every installed Claude skill to its use in the Copilot Studio agent build process.
Invoke any skill by typing its slash command in your Claude session.

**Quick navigation:** [Copilot Studio Skills](#copilot-studio-skills) · [Superpowers Skills](#superpowers-skills) · [Other Plugins](#other-plugins) · [By Phase](#skills-by-phase)

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
| `workiq` | `/workiq` | Work IQ tools for task and productivity management | Any — task tracking |

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
| `/brainstorming` | Steps 3 and 5 — turn a requirements session into a structured spec |
| `/microsoft-docs` | Any point — look up Microsoft licensing, connector, or environment docs |

### Phase 3 — Design
| Skill | When |
|-------|------|
| `/brainstorming` | Steps 8, 9, 10 — design FDD, conversation flows, technical architecture |
| `/copilot-studio:best-practices` | Steps 6, 11 — validate component selection and prompt patterns |
| `/optibot` | Step 11 — optimise the agent system prompt |
| `/microsoft-docs` | Any point — fetch official docs on specific capabilities |

### Phase 4 — Build
| Skill | When |
|-------|------|
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
| `/copilot-studio:validate` | Step 21 — final pre-launch validation |
| `/copilot-studio:manage-agent` | Step 21 — push and publish to production |
| `/verification-before-completion` | Step 21 — final completeness check |

### Phase 7 — Operate
| Skill | When |
|-------|------|
| `/copilot-studio:analyze-evals` | Steps 24, 25, 26 — read monitoring data and identify gaps |
| `/systematic-debugging` | Step 27 — structured incident investigation |
| `/copilot-studio:best-practices` | Step 28 — quarterly agent health review |
| `/copilot-studio:known-issues` | Step 27 — check against known bugs when something breaks |
