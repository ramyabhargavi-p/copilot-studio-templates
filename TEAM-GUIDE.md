# Team Guide — Reusing These Templates

How to use this repository as a team: who uses what, how reuse works in practice, known blockers, and the complete reusable prompt reference for end-to-end delivery.

---

## Who Uses What

| Role | What to use | Starting point |
|------|-------------|---------------|
| **New to team / new to Copilot Studio** | Follow steps 1–7 in README.md in order | [README.md](README.md) → numbered table at the top |
| Experienced dev | `base/` + cherry-pick `components/` + recipe | [QUICKSTART.md](QUICKSTART.md) |
| Lead / architect | Project delivery docs + AI Decision Framework | [project-delivery/README.md](project-delivery/README.md) |
| Project manager / delivery lead | Requirements, design, UAT, launch, governance docs | [project-delivery/README.md](project-delivery/README.md) |
| QA / tester | UAT test plan + eval scenarios | [project-delivery/04-uat-test-plan.md](project-delivery/04-uat-test-plan.md) |
| DevOps / platform engineer | CI/CD workflows + alert setup | [ci-cd/README.md](ci-cd/README.md) |
| Agent owner (post-launch) | Monitoring queries + runbook + troubleshooting | [operations/README.md](operations/README.md) |
| Security / compliance reviewer | Responsible AI checklist + security review | [governance/README.md](governance/README.md) |

---

## How Reuse Works in Practice

### Starting a new agent (any dev)

```
1. Clone or copy this repo to your machine
2. Copy base/ → agents/<your-agent-name>/
3. Open the folder in VS Code (Copilot Studio extension active)
4. Replace every <PLACEHOLDER> value — VS Code highlights them in the YAML
5. Replace every _REPLACE node ID suffix — the VS Code extension auto-generates on save
6. Pick the closest recipe from recipes/ and follow it to add components
7. VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes" → test in Copilot Studio test canvas
```

**Time saved:** A dev who knows Copilot Studio can go from zero to a working agent with Greeting + Fallback + OnError + telemetry + escalation in under 30 minutes. Building from scratch without these templates typically takes 2–3 hours — and commonly misses error handling, logging, and escalation patterns entirely.

### Starting a project (lead + PM)

```
1. project-delivery/01-requirements-questionnaire.md — run with the stakeholder
2. project-delivery/02-technical-discovery.md — run with the environment admin
3. project-delivery/03-agent-design-worksheet.md — decide which recipe to use
4. project-delivery/06-content-audit.md — if using knowledge sources, assess documents first
5. Kick off the build
```

### The complete delivery sequence

```
DISCOVERY
  01-requirements-questionnaire.md  (stakeholder meeting)
  02-technical-discovery.md         (environment admin meeting)
        ↓
DESIGN
  03-agent-design-worksheet.md
  06-content-audit.md               (if knowledge sources)
  prompts/system-prompts/           (pick or generate system prompt)
        ↓
BUILD
  Copy base/ → add components/ → write custom topics
  VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes" → smoke test in test canvas
  governance/ai-ethics-checklist.md + governance/security-review.md
        ↓
EVAL
  05-eval-scenarios.md + generate-eval-cases.md prompt
  Target: >85% routing accuracy, >80% groundedness
        ↓
UAT
  04-uat-test-plan.md (with stakeholder)
  review-agent.md prompt (AI audit — fix all CRITICAL items)
  Stakeholder sign-off
        ↓
LAUNCH
  launch/launch-checklist.md        (all items must pass)
  launch/user-communication-template.md
  operations/alert-setup.md
        ↓
HYPERCARE (weeks 1–2)
  launch/hypercare-guide.md
        ↓
ONGOING OPERATIONS
  operations/monitoring-queries.md  (weekly/monthly)
  operations/runbook.md             (incident response)
```

---

## Known Blockers and Issues

These are real problems teams hit. Read them before starting.

### 1 — pac CLI blocked on corporate machines

**Likelihood:** High for teams new to Power Platform CLI.

`dotnet tool install --global Microsoft.PowerApps.CLI.Tool` requires .NET 6+ and may fail under a restricted PowerShell execution policy.

**Fix:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```
Or use the MSI installer (no PowerShell policy issue). See [TOOLS-AND-PLUGINS.md](TOOLS-AND-PLUGINS.md).

---

### 2 — Forgotten `_REPLACE` node IDs break the push

**Likelihood:** Very high for first-time users.

Even one unreplaced `_REPLACE` suffix causes the apply operation (VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"`) to fail with a schema error. New devs often can't read the error message (it shows a line number, not the ID name).

**Prevention — run before every push:**
```bash
grep -r "_REPLACE" . --include="*.yml"
grep -r "<" . --include="*.yml"
```

The CI/CD workflow (`ci-cd/push-on-pr.yml`) runs this check automatically on every PR — any `_REPLACE` found fails the build before it reaches the environment.

**VS Code fix:** The Copilot Studio extension auto-replaces `_REPLACE` suffixes when you save — but only if the extension is installed and active (check the status bar for the Copilot Studio icon).

---

### 3 — `schemaName` conflicts between team members

**Likelihood:** Medium when multiple devs work in the same environment.

Every agent in a Power Platform environment must have a unique `schemaName`. If two devs copy `base/` and both forget to change it, the second push will overwrite the first.

**Rule:** Change `schemaName` in `settings.mcs.yml` immediately after copying `base/`, before sharing files with anyone. Format: `projectcode_agentname` (lowercase, underscores, no spaces).

---

### 4 — VS Code extension fails silently behind corporate proxy

**Likelihood:** Medium in enterprise environments.

The extension downloads the YAML schema from Microsoft's CDN on first use. A strict firewall can block this silently — the extension appears installed but gives no IntelliSense or schema validation.

**Fix:** Ensure `*.cdn.office.net` and `*.microsoft.com` are allowlisted, or configure VS Code's proxy settings in `settings.json`:
```json
"http.proxy": "http://your-proxy:port",
"http.proxyStrictSSL": false
```

---

### 5 — Connection references differ between environments

**Likelihood:** Medium when promoting agents from dev to test to production.

The connector logical name `shared_office365users` that works in your dev environment may not exist in the UAT or production environment. The push succeeds but the connector call fails at runtime.

**Fix:** `project-delivery/02-technical-discovery.md` has a table for the environment admin to fill in the correct logical names per environment. Devs must use those exact names in their YAML — not assume they match across environments.

---

### 6 — Adaptive cards behave differently in test canvas vs Teams

**Likelihood:** Medium for agents using `components/adaptive-cards/`.

`Action.Submit` on cards works correctly in Teams and Copilot for M365. The Copilot Studio test canvas simulates card behaviour but does not replicate it exactly — a card that looks fine in the canvas may not submit correctly in Teams.

**Rule:** Always test any topic that uses an adaptive card in the actual Teams channel before UAT.

---

### 7 — `pac copilot publish` not available in all CLI versions

**Likelihood:** Low currently, will increase as teams use older CLI versions.

The `ci-cd/publish-on-release.yml` workflow calls `pac copilot publish`. This command was added in a recent pac release. If the runner has an older version installed, the publish step will fail.

**Fallback:** Push via CI/CD; publish manually in the Copilot Studio UI. The CI/CD README documents this fallback.

---

### 8 — Application Insights telemetry has a 2–5 minute lag

**Likelihood:** Low for production issues, high for confusion during development.

`LogCustomTelemetryEvent` nodes fire correctly but events take 2–5 minutes to appear in Application Insights. New devs testing telemetry for the first time assume the nodes are broken and delete them.

**Rule:** After testing a topic that fires telemetry, wait 5 minutes before checking App Insights. Do not remove telemetry nodes because they appear to not work — they do work.

See [troubleshooting/README.md](troubleshooting/README.md) Section 7 for the full telemetry troubleshooting guide.

---

## Reusable Prompts — End-to-End Reference

Use these prompts with Claude, Microsoft Copilot, or ChatGPT at the relevant phase.

---

### Phase 2 — Design: Generate the agent's system prompt

**File:** `prompts/ai-prompts/generate-agent-instructions.md`

Paste in answers from `01-requirements-questionnaire.md`. Returns a complete `agent.mcs.yml` `instructions` block with scope, out-of-scope, escalation, and tone sections.

**Or use a ready-made system prompt (no generation needed):**

| File | Use for |
|------|---------|
| `prompts/system-prompts/hr-assistant.md` | HR self-service — leave, policies, onboarding |
| `prompts/system-prompts/it-helpdesk.md` | IT support — passwords, M365, VPN, hardware |
| `prompts/system-prompts/customer-support.md` | Customer-facing support |
| `prompts/system-prompts/knowledge-base.md` | Internal knowledge / FAQ |

---

### Phase 3 — Build: Generate a topic from a scenario

**File:** `prompts/ai-prompts/generate-topic.md`

Describe what the topic should do in plain English. Returns a complete `.topic.mcs.yml` file with trigger phrases, nodes, error handling, and telemetry. Replace `_REPLACE` IDs after generating.

**Build: Generate an Adaptive Card**

**File:** `prompts/ai-prompts/generate-adaptive-card.md`

Describe the card's purpose and the data fields available. Returns Teams-compatible Adaptive Card JSON ready to embed in a `SendActivity` node.

---

### Phase 4 — Eval: Generate the eval CSV

**File:** `prompts/ai-prompts/generate-eval-cases.md`

Input: topic list + trigger phrases + out-of-scope areas + knowledge source subject.
Output: CSV with `utterance,expectedTopic,expectedResponse,notes` — 3 utterances per topic, system paths, knowledge search rows, and negative cases.

**After running eval — fix a weak topic:**

Use the targeted prompt in the same file:
```
My Copilot Studio eval shows low routing accuracy for the topic "[Topic Name]" (current accuracy: X%).
The current trigger phrases are:
[LIST CURRENT TRIGGER PHRASES]

Generate 10 additional trigger phrases that cover:
- Different vocabulary (synonyms, informal language)
- Different question structures (how do I / what is / can you / I need to)
- Different levels of specificity (very specific to very vague)
- Common misspellings or abbreviations

Output as a YAML list.
```

**Find coverage gaps in your eval CSV:**

Use the coverage gap prompt in the same file — paste your CSV and get back a list of missing topics, missing system paths, and negative test gaps.

---

### Phase 5 — UAT: AI audit before the stakeholder session

**File:** `prompts/ai-prompts/review-agent.md`

Run this on every YAML file before handing to the stakeholder. Returns three tiers:
- **CRITICAL** — agent will break or behave badly in production; fix before UAT
- **HIGH** — significant quality issue; fix before UAT if possible
- **GOOD TO HAVE** — improvement; can be a follow-up item

Also includes: single-file spot check, instructions quality review, UAT checklist generator.

---

### Phase 7 — Ongoing: Investigate knowledge gaps from telemetry

After running the "Unanswered questions" KQL query from `operations/monitoring-queries.md`, feed the output into this prompt:

```
My Copilot Studio knowledge search is not answering these user questions:
[PASTE LIST FROM KQL OUTPUT]

The knowledge source covers: [DESCRIBE SUBJECT]

Which of these indicate a genuine gap in the documents vs. which are out of scope?
For the genuine gaps, what document content should I add to fix them?
```

---

### Phase 7 — Ongoing: Improve routing after accuracy drop

Re-use the "Expand weak topics" prompt from `generate-eval-cases.md` whenever monthly monitoring shows a topic's accuracy declining. Add the generated trigger phrases to the topic YAML and re-run eval before publishing.

---

## The One-Page Onboarding for a New Team Member

Share this with anyone joining the team for the first time:

```
1. Read GETTING-STARTED.md (15 minutes)
2. Install tools from TOOLS-AND-PLUGINS.md
3. Read INDUSTRY-GUIDELINES.md Section 1–6 (the non-negotiables)
4. For your first agent: follow the closest recipe in recipes/
5. Use prompts/ai-prompts/ to generate YAML you're not sure how to write
6. Before any push: grep -r "_REPLACE" . --include="*.yml"
7. Before UAT: run prompts/ai-prompts/review-agent.md on every file
8. Before go-live: complete launch/launch-checklist.md
9. After go-live: set up alerts from operations/alert-setup.md
10. Something broken? Check troubleshooting/README.md first
```
