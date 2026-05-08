# Agent Developer Checklist — Complete Journey from Setup to Live

**Use this checklist to track your progress through each phase of agent development.**

Print it out or follow along digitally. Check off each step as you complete it.

---

## PHASE 1: SETUP & PREREQUISITES
**Target Time: 20–30 minutes**  
**Success Criteria: All tools installed and authenticated**

### Step 1.1: Install pac CLI
- [ ] Download/install pac CLI (`winget install Microsoft.PowerAppsCLI` or `dotnet install`)
- [ ] Verify installation: `pac --version` returns version ≥ 2.7.0
- [ ] **Success Criteria:** Terminal shows `pac (Power Apps CLI) version X.X.X`

### Step 1.2: Install VS Code & Extensions
- [ ] VS Code installed and running
- [ ] Copilot Studio extension installed (`Ctrl+Shift+X` → search "Copilot Studio")
- [ ] Recommended extensions installed (YAML, GitLens, indent-rainbow)
- [ ] **Success Criteria:** Copilot Studio icon visible in VS Code status bar

### Step 1.3: Authenticate to Power Platform
- [ ] Get environment URL from Power Platform Admin Center
- [ ] Run `pac auth create` and complete browser sign-in
- [ ] Verify: `pac env who` shows your environment
- [ ] Verify: `pac env list` shows all available environments
- [ ] **Success Criteria:** Terminal shows `Connected to: [Your Environment] | you@email.com`

### Step 1.4: Clone Repository
- [ ] Repository cloned: `git clone https://github.com/microsoft/copilot-studio-templates.git`
- [ ] Navigate to folder: `cd copilot-studio-templates`
- [ ] Feature branch created: `git checkout -b feature/my-first-agent`
- [ ] **Success Criteria:** `git branch` shows `* feature/my-first-agent`

### Phase 1 Verification
- [ ] `pac --version` works
- [ ] `pac env who` shows your environment
- [ ] VS Code has Copilot Studio extension active
- [ ] Repository cloned and feature branch created
- [ ] You can open a `.mcs.yml` file without errors

**Status:** ✓ Phase 1 Complete / ✗ Blocked (note issue): ___________

---

## PHASE 2: UNDERSTAND TEMPLATES & SKILLS
**Target Time: 15–20 minutes**  
**Success Criteria: Understand when to use templates vs. skills**

### Step 2.1: Understanding Templates
- [ ] Read what base template includes (6 files)
- [ ] Review component templates (knowledge, actions, topics)
- [ ] Review recipe templates (01-basic-faq, 02-authenticated, etc.)
- [ ] Understand: Templates = pre-built YAML files

### Step 2.2: Understanding Skills
- [ ] Know what WorkIQ skills do (gather M365 context)
- [ ] Know what Copilot Studio skills do (build agents)
- [ ] Understand skill invocation syntax: `/skill-name:sub-skill`
- [ ] Understand: Skills = shortcuts and automation

### Step 2.3: Templates vs. Skills Decision
- [ ] Chose which approach: Templates / Skills / Both
- [ ] If templates: Know which recipe to use (FAQ, Auth, Action, etc.)
- [ ] If skills: Know which skills to invoke (add-knowledge, new-topic, etc.)

**Your Choice:** [ ] Templates Only  [ ] Skills Only  [ ] Both

**Status:** ✓ Phase 2 Complete / ✗ Blocked (note issue): ___________

---

## PHASE 3: CREATE YOUR FIRST AGENT
**Target Time: 30–40 minutes**  
**Success Criteria: Agent configured locally, ready to deploy**

### Step 3.1: Choose Agent Type
- [ ] Decided what agent will do (FAQ, Auth, Action, Multi-agent, Custom)
- [ ] Selected appropriate template/recipe
- [ ] Noted agent name (e.g., `my_first_agent`)

**Agent Type:** ☐ FAQ  ☐ Authenticated  ☐ Action  ☐ Multi-agent  ☐ Custom

### Step 3.2: Copy Base Template (or use automation script)
- [ ] Ran: `cp -r base/ agents/my_agent/` (or ran setup script)
- [ ] Verified files copied: `ls agents/my_agent/`
- [ ] All 6 base files present: agent.mcs.yml, settings.mcs.yml, Greeting, Fallback, OnError, .gitignore
- [ ] **Success Criteria:** All 6 files exist in agents/my_agent folder

### Step 3.3: Replace 5 Required Placeholders
- [ ] Opened `agents/my_agent/agent.mcs.yml` in VS Code
- [ ] Replaced `<AgentName>` with schema name (e.g., `my_first_agent`)
  - Example: `my_first_agent` (lowercase, no spaces)
- [ ] Replaced `<Agent Display Name>` with display name
  - Example: `My First Agent` (spaces OK)
- [ ] Replaced `<SYSTEM_PROMPT>` with agent purpose
  - Example: `You are a helpful HR assistant...`
- [ ] Opened `agents/my_agent/settings.mcs.yml`
- [ ] Replaced `<agent_schema_name>` with same schema name from Step 3.3
- [ ] Opened `agents/my_agent/Fallback.topic.mcs.yml`
- [ ] Replaced `<AGENT_SCHEMA>` with same schema name from Step 3.3
- [ ] **Success Criteria:** All 5 placeholders replaced with actual values

### Step 3.4: Verify All Replacements
- [ ] Searched for remaining `<` characters (Ctrl+Shift+F in VS Code)
- [ ] Result: 0 matches found
- [ ] No error messages in VS Code Problems panel
- [ ] **Success Criteria:** Search returns no matches for `<`

### Step 3.5: Auto-Replace Node IDs
- [ ] Opened any `.mcs.yml` file in VS Code
- [ ] Saved file: `Ctrl+S`
- [ ] VS Code extension auto-replaced `_REPLACE` IDs
- [ ] Verified no `_REPLACE` remaining: search returns 0 matches
- [ ] **Success Criteria:** No red error squiggles in VS Code

### Step 3.6: Open in VS Code
- [ ] Opened agent folder in VS Code: `code agents/my_agent/`
- [ ] Verified all 6 files visible in Explorer (left side)
- [ ] Verified Copilot Studio icon in status bar (extension active)
- [ ] Verified no red squiggles (check left side line numbers)
- [ ] **Success Criteria:** Clean file structure with no errors

**Status:** ✓ Phase 3 Complete / ✗ Blocked (note issue): ___________

---

## PHASE 4: DEPLOY TO CLOUD
**Target Time: 5–10 minutes**  
**Success Criteria: Agent created in cloud as Draft**

### Step 4.1: Deploy via VS Code
- [ ] In VS Code, pressed `Ctrl+Shift+P`
- [ ] Typed: `Copilot Studio: Apply Changes`
- [ ] Pressed Enter
- [ ] Waited 10–30 seconds for deployment
- [ ] Saw success message in progress bar
- [ ] **Success Criteria:** Message shows "Creating agent in cloud..." then "Complete"

### Step 4.2: Verify Deployment
- [ ] Opened Copilot Studio: https://make.microsoft.com
- [ ] Selected correct environment (top right dropdown)
- [ ] Found agent in the list (e.g., "My First Agent")
- [ ] Status badge shows "Draft" (not "Published")
- [ ] Clicked agent to view configuration
- [ ] **Success Criteria:** Agent appears in list with Draft status

### Step 4.3: Check Agent Configuration
- [ ] Agent name is correct (e.g., "My First Agent")
- [ ] System prompt is present and correct
- [ ] Agent has base topics: Greeting, Fallback, OnError
- [ ] No obvious errors in agent configuration
- [ ] **Success Criteria:** Agent configuration looks complete and correct

**Status:** ✓ Phase 4 Complete / ✗ Blocked (note issue): ___________

---

## PHASE 5: TEST & PUBLISH
**Target Time: 10–15 minutes**  
**Success Criteria: Agent is live and responding to users**

### Step 5.1: Test Agent Locally
- [ ] In Copilot Studio, found the agent
- [ ] Clicked on agent name to open it
- [ ] Clicked "Test" pane (right side)
- [ ] Typed test message: "Hello"
- [ ] Agent responded with greeting message
- [ ] **Success Criteria:** Agent says something like "Hello! I'm here to help..."

### Step 5.2: Handle Test Issues (if needed)
- [ ] If agent didn't respond:
  - [ ] Checked `OnError.topic.mcs.yml` for schema name match
  - [ ] Re-deployed: `Ctrl+Shift+P` → Apply Changes
  - [ ] Tested again
- [ ] If agent still didn't work:
  - [ ] Checked VS Code Problems panel for YAML errors
  - [ ] Fixed any red squiggles
  - [ ] Re-deployed
- [ ] **Success Criteria:** Agent now responds to test messages

### Step 5.3: Publish Agent
- [ ] In Copilot Studio, found the agent
- [ ] Clicked "..." menu (top right) or "Publish" button
- [ ] Clicked "Publish"
- [ ] Confirmed publication when prompted
- [ ] Status badge changed from "Draft" to "Published"
- [ ] **Success Criteria:** Status now shows "Published"

### Step 5.4: Verify Agent is Live
- [ ] Refreshed Copilot Studio page
- [ ] Status still shows "Published"
- [ ] Agent is now accessible to all users in environment
- [ ] **Success Criteria:** Other users can see and access the agent

**Status:** ✓ Phase 5 Complete / ✗ Blocked (note issue): ___________

---

## PHASE 6: ADD FEATURES & ENHANCE (OPTIONAL)
**Target Time: 30–60 minutes per feature**  
**Success Criteria: Features are working and integrated**

### Step 6.1: Add Knowledge (SharePoint)
- [ ] Understood what knowledge does (agent searches documents)
- [ ] Copied knowledge component:
  - [ ] `cp components/knowledge/sharepoint/*.mcs.yml agents/my_agent/knowledge/`
- [ ] Copied knowledge search topic:
  - [ ] `cp components/topics/knowledge-search/*.mcs.yml agents/my_agent/topics/`
- [ ] Updated SharePoint URL in knowledge file
- [ ] Re-deployed: `Ctrl+Shift+P` → Apply Changes
- [ ] Tested: Asked agent a question about SharePoint content
- [ ] **Success Criteria:** Agent searches and returns results from SharePoint

### Step 6.2: Add Feedback Collection
- [ ] Copied feedback component:
  - [ ] `cp -r components/topics/feedback/ agents/my_agent/topics/`
- [ ] Re-deployed
- [ ] Tested: After a response, user sees feedback buttons
- [ ] **Success Criteria:** Users can rate agent responses

### Step 6.3: Add User Authentication
- [ ] Read: `recipes/02-authenticated-agent.md`
- [ ] Followed recipe to implement sign-in
- [ ] Tested: User must sign in before chatting
- [ ] Re-deployed
- [ ] **Success Criteria:** Agent requires sign-in before use

### Step 6.4: Add Actions (Submit Data)
- [ ] Read: `recipes/03-connector-action-agent.md`
- [ ] Followed recipe to add action/connector
- [ ] Configured action to connect to target system
- [ ] Tested: User can submit data through agent
- [ ] Re-deployed
- [ ] **Success Criteria:** Data successfully submitted to system

### Step 6.5: Use Claude Skills for Features
- [ ] Invoked skill: `/copilot-studio:add-knowledge "Add HR policies"`
- [ ] Copilot generated knowledge configuration
- [ ] Invoked skill: `/copilot-studio:new-topic "Create leave inquiry topic"`
- [ ] Copilot generated topic with triggers and nodes
- [ ] Invoked skill: `/copilot-studio:validate` to check for errors
- [ ] **Success Criteria:** Features generated by skills are working

**Features Added:**
- [ ] Knowledge sources (SharePoint, web)
- [ ] Feedback collection
- [ ] User authentication
- [ ] Actions/connectors
- [ ] New topics and flows
- [ ] Advanced patterns

**Status:** ✓ Phase 6 Complete / ✗ Skipped / ✗ Blocked (note issue): ___________

---

## TROUBLESHOOTING LOG

Use this section to track any issues encountered and how you resolved them:

| Issue | Phase | Resolution | Status |
|-------|-------|-----------|--------|
| Example: Extension not found | 1 | Reloaded VS Code | ✓ Resolved |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

---

## FINAL VERIFICATION

Before considering your agent "production-ready," verify these final items:

### Agent Configuration
- [ ] Agent name and display name are correct
- [ ] System prompt accurately describes agent's purpose
- [ ] Auth mode is appropriate (public or authenticated)
- [ ] Language setting is correct (English or other)

### Functionality
- [ ] Agent responds to basic questions
- [ ] Greeting topic works
- [ ] Fallback triggers when agent doesn't understand
- [ ] Knowledge sources are accessible and working
- [ ] Actions/connectors submit data correctly

### User Experience
- [ ] Agent is easy to find in Copilot Studio
- [ ] Agent responses are clear and helpful
- [ ] Error messages are user-friendly
- [ ] Feedback collection is working

### Governance (If Required)
- [ ] Completed AI ethics checklist (governance/ai-ethics-checklist.md)
- [ ] Completed security review (governance/security-review-checklist.md)
- [ ] PII handling reviewed (docs/PII-SCRUBBING.md)
- [ ] Action safety patterns reviewed (docs/ACTION-SAFETY-PATTERNS.md)

**All items verified:** [ ] YES / [ ] NO

---

## COMPLETION SUMMARY

**Start Date:** ___________  
**Completion Date:** ___________  
**Total Time:** ___________

**Agent Name:** ___________  
**Agent Status:** [ ] Draft / [ ] Published / [ ] In Production

**Phases Completed:**
- [ ] Phase 1: Setup ✓
- [ ] Phase 2: Understanding ✓
- [ ] Phase 3: Create ✓
- [ ] Phase 4: Deploy ✓
- [ ] Phase 5: Test & Publish ✓
- [ ] Phase 6: Enhance (Optional) ✓

**Features Implemented:**
- [ ] Knowledge sources
- [ ] Feedback collection
- [ ] User authentication
- [ ] Actions/connectors
- [ ] Custom topics
- [ ] Advanced patterns

**Notes & Observations:**

___________________________________________________________________________

___________________________________________________________________________

___________________________________________________________________________

---

## NEXT STEPS

- [ ] **Monitor:** Check user feedback in Copilot Studio
- [ ] **Enhance:** Add more knowledge or actions
- [ ] **Improve:** Run evaluation to test accuracy
- [ ] **Scale:** Create additional agents
- [ ] **Automate:** Set up CI/CD for deployments
- [ ] **Document:** Create runbook for agent operations

---

**Congratulations on deploying your first Copilot Studio agent! 🎉**

For questions or issues, see:
- [AGENT-DEVELOPER-JOURNEY.md](docs/AGENT-DEVELOPER-JOURNEY.md) — Detailed walkthrough
- [FAQ.md](docs/FAQ.md) — Common questions
- [troubleshooting/README.md](troubleshooting/README.md) — Troubleshooting guide
