# Visual Flowcharts & Diagrams — Agent Development Process

Complete visual representation of the agent development journey, from setup to live deployment.

---

## 1. COMPLETE AGENT DEVELOPMENT WORKFLOW

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT DEVELOPER JOURNEY                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐       ┌──────────────┐       ┌──────────────┐ │
│  │   PHASE 1    │       │   PHASE 2    │       │   PHASE 3    │ │
│  │  SETUP       │──────>│ UNDERSTAND   │──────>│  CREATE      │ │
│  │              │       │              │       │              │ │
│  │ • pac CLI    │       │ • Templates  │       │ • Copy base  │ │
│  │ • VS Code    │       │ • Skills     │       │ • Replace    │ │
│  │ • Auth       │       │ • Decision   │       │ • Configure  │ │
│  │ • Repo clone │       │              │       │              │ │
│  └──────────────┘       └──────────────┘       └──────────────┘ │
│         │                      │                      │           │
│      20-30 min              15-20 min             30-40 min      │
│                                                                   │
│         ┌──────────────┐       ┌──────────────┐                 │
│         │   PHASE 4    │       │   PHASE 5    │                 │
│         │  DEPLOY      │──────>│  TEST &      │                 │
│         │              │       │  PUBLISH     │                 │
│         │ • Apply      │       │              │                 │
│         │   Changes    │       │ • Test chat  │                 │
│         │ • Verify     │       │ • Publish    │                 │
│         │   in UI      │       │ • Go live    │                 │
│         └──────────────┘       └──────────────┘                 │
│                │                      │                          │
│             5-10 min              10-15 min                      │
│                                                                   │
│                           ↓                                      │
│                                                                   │
│              ┌────────────────────────────────┐                  │
│              │     PHASE 6 (OPTIONAL)         │                  │
│              │     ENHANCE                    │                  │
│              │                                │                  │
│              │  • Add knowledge              │                  │
│              │  • Add feedback               │                  │
│              │  • Add authentication         │                  │
│              │  • Add actions                │                  │
│              │                                │                  │
│              │  Total Time: 30-90+ minutes   │                  │
│              └────────────────────────────────┘                  │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘

Total Time: 90-120+ minutes from zero to live agent
```

---

## 2. SETUP WORKFLOW (PHASE 1)

```
                      PHASE 1: SETUP
                          │
                          ▼
                ┌──────────────────────┐
                │  Install pac CLI     │
                ├──────────────────────┤
                │ $ pac --version      │
                │ ✓ v2.7.4 or higher   │
                └──────────────────────┘
                          │
                          ▼
                ┌──────────────────────┐
                │ Install VS Code +    │
                │ Extensions           │
                ├──────────────────────┤
                │ Copilot Studio (req) │
                │ YAML, GitLens (opt)  │
                └──────────────────────┘
                          │
                          ▼
                ┌──────────────────────┐
                │ Authenticate to env  │
                ├──────────────────────┤
                │ $ pac auth create    │
                │ $ pac env who        │
                │ ✓ Connected          │
                └──────────────────────┘
                          │
                          ▼
                ┌──────────────────────┐
                │ Clone repository +   │
                │ Create branch        │
                ├──────────────────────┤
                │ $ git clone          │
                │ $ git checkout -b    │
                └──────────────────────┘
                          │
                          ▼
                   ✓ PHASE 1 COMPLETE
```

---

## 3. TEMPLATE FILE STRUCTURE

```
agents/
└── my_first_agent/                    (Your agent folder)
    ├── agent.mcs.yml                  (Agent name, prompt, knowledge)
    │   ├── <AgentName>       ← Replace
    │   ├── <Agent Display Name>  ← Replace
    │   ├── <SYSTEM_PROMPT>   ← Replace
    │   └── knowledge: [SharePoint, web]
    │
    ├── settings.mcs.yml              (Auth, language, access)
    │   └── <agent_schema_name> ← Replace
    │
    ├── Greeting.topic.mcs.yml        (First message)
    │   └── "Hello! I'm here to help..."
    │
    ├── Fallback.topic.mcs.yml        (When confused)
    │   ├── <AGENT_SCHEMA>  ← Replace
    │   └── "I don't understand..."
    │
    ├── OnError.topic.mcs.yml         (Error handling)
    │   ├── <AGENT_SCHEMA>  ← Replace
    │   └── "Sorry, something went wrong"
    │
    └── .gitignore                    (Git configuration)

5 PLACEHOLDERS TO REPLACE:
  1. <AgentName> in agent.mcs.yml
  2. <Agent Display Name> in agent.mcs.yml
  3. <SYSTEM_PROMPT> in agent.mcs.yml
  4. <agent_schema_name> in settings.mcs.yml
  5. <AGENT_SCHEMA> in Fallback.topic.mcs.yml

MUST MATCH: Schema name must be same across all 5 replacements
```

---

## 4. DEPLOYMENT PIPELINE

```
┌────────────────────────────────────────────────────────────────┐
│                    YOUR COMPUTER                               │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Local Files (YAML)                                          │
│  ├── agent.mcs.yml          ┐                                   │
│  ├── settings.mcs.yml       ├─ Your agent code                 │
│  ├── Greeting.topic.mcs.yml │                                   │
│  └── Fallback.topic.mcs.yml ┘                                   │
│                 │                                               │
│                 ▼                                               │
│  2. VS Code (Editing)                                           │
│  ├── Replace placeholders                                       │
│  ├── Fix YAML errors                                            │
│  ├── Verify with extension                                      │
│  └── Save (Ctrl+S) ← Auto-generates node IDs                   │
│                 │                                               │
│                 ▼                                               │
│  3. Deploy Command                                              │
│  └── Ctrl+Shift+P → "Copilot Studio: Apply Changes"           │
│                 │                                               │
│                 ▼                                               │
├────────────────────────────────────────────────────────────────┤
│                  AZURE CLOUD                                    │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  4. Cloud Deployment                                            │
│  ├── YAML validated                                             │
│  ├── Agent created (first time)    OR                          │
│  ├── Agent updated (subsequent times)                           │
│  └── Status: DRAFT                                              │
│                 │                                               │
│                 ▼                                               │
│  5. Copilot Studio (Web UI)                                     │
│  ├── https://make.microsoft.com                                 │
│  ├── Your Environment                                           │
│  ├── Find Your Agent                                            │
│  ├── Status: Draft Badge                                        │
│  └── Ready to test                                              │
│                 │                                               │
│                 ▼                                               │
│  6. Test & Publish                                              │
│  ├── Click "Test" pane → chat with agent                       │
│  ├── Click "Publish"                                            │
│  ├── Status: Published Badge                                    │
│  └── Agent now LIVE for all users                              │
│                                                                  │
└────────────────────────────────────────────────────────────────┘

KEY: "Apply Changes" automates steps 4-5. No manual API calls needed.
```

---

## 5. SKILLS DECISION TREE

```
                    Do you want to:

                ┌─────────────────────────┐
                │  Load Context?          │
                │  (Emails, Teams, etc)   │
                └─────────────────────────┘
                         │
                    YES  ▼   NO
                    ┌────┴────┐
                    │          │
              /workiq        Continue
              (Load context)   (Skip)
                    │          │
                    └──────────┴─────────────┐
                                             │
                                    ┌────────▼─────────┐
                                    │ Copy template or │
                                    │ use skills?      │
                                    └───────┬──────────┘
                                            │
                  ┌─────────────────────────┼──────────────────────┐
                  │                         │                      │
            COPY TEMPLATE            USE SKILLS            BOTH
            (Manual)                 (Automated)       (Recommended)
                  │                         │                      │
         • cp base/               /copilot-studio:    • Use skills
         • Manual edits            clone-agent         • Verify
         • Full control          /copilot-studio:      with templates
         • More steps              add-knowledge
                  │             /copilot-studio:       │
                  │               add-action           │
                  │             /copilot-studio:       │
                  │               validate             │
                  │                 │                  │
                  └─────────────────┼──────────────────┘
                                    │
                           ┌────────▼────────┐
                           │ Review & Test   │
                           │ Ctrl+Shift+P    │
                           │ Apply Changes   │
                           └─────────────────┘
```

---

## 6. AGENT TYPE SELECTION

```
                    What type of agent?

    ┌────────────────────┬────────────────────┬────────────────────┐
    │                    │                    │                    │
    ▼                    ▼                    ▼                    ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌──────────────┐
│   FAQ BOT   │   │  + AUTH BOT  │   │ ACTION BOT  │   │ MULTI-AGENT  │
│             │   │             │   │             │   │              │
│ Answers     │   │ FAQ +       │   │ Submits     │   │ Multiple     │
│ questions   │   │ User sign-in │  │ data to     │   │ agents work  │
│             │   │             │   │ systems     │   │ together     │
│ 30 min      │   │ 45 min      │   │ 60 min      │   │ 2+ hours     │
│ Simplest    │   │ Medium      │   │ Complex     │   │ Advanced     │
└─────────────┘   └─────────────┘   └─────────────┘   └──────────────┘

Recipe:         Recipe:              Recipe:           Recipe:
01-basic-faq    02-authenticated     03-connector      05-orchestrator

Best for:       Best for:            Best for:         Best for:
• Help desk     • Customer portal    • Ticketing       • Enterprise
• FAQs          • HR portal          • Leave requests  • Multiple teams
• Docs          • Internal tools     • Data entry      • Complex flows
```

---

## 7. DEPLOYMENT DECISION TREE

```
                  Is this your first time?

                    YES             NO
                     │               │
                     ▼               ▼
            ┌──────────────────┐  Continue
            │ Read             │  (You know
            │ AGENT-DEVELOPER  │   the process)
            │ -JOURNEY.md      │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Phase 1: Setup   │
            │ (20-30 min)      │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Phase 2:         │
            │ Understand       │
            │ (15-20 min)      │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Phase 3: Create  │
            │ (30-40 min)      │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Copy template    │
            │ Replace 5 values │
            │ Open in VS Code  │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Phase 4: Deploy  │
            │ (5-10 min)       │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Ctrl+Shift+P ──┐ │
            │ Apply Changes  │ │
            │ ✓ Agent created │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Phase 5: Test &  │
            │ Publish (10-15m) │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Test in UI       │
            │ Click Publish    │
            │ Agent is LIVE!   │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │ Phase 6: Enhance │
            │ (Optional)       │
            └──────────────────┘

TOTAL TIME: 90-120 minutes (or 5 min if experienced)
```

---

## 8. TROUBLESHOOTING DECISION TREE

```
                    Something's broken?

                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
    ERROR IN         AGENT NOT FOUND    AGENT WON'T
    VS CODE          IN COPILOT STUDIO  RESPOND
        │                  │                  │
        ▼                  ▼                  ▼
  Check Problems    Refresh browser    Check OnError
  panel for red     ┌─────────────┐    topic for
  squiggles         │ Check env   │    schema name
        │           │ (top right) │    match
        ▼           └──────┬──────┘
  Fix indentation          │
  or YAML syntax     ┌─────▼──────┐
        │            │ pac copilot │
        ▼            │ list        │
  Save & retry    └─────┬──────┘
        │               │
        │         If not there:
        │               │
        │         Re-deploy:
        │         Apply Changes
        │
        ▼
  Try again
  
  Still broken?
  See: troubleshooting/README.md
```

---

## 9. AUTHENTICATION FLOW

```
┌─────────────────────────────────────────────────┐
│          FIRST-TIME AUTHENTICATION               │
├─────────────────────────────────────────────────┤
│                                                   │
│  1. You run: pac auth create                    │
│             │                                    │
│             ▼                                    │
│  2. Browser opens → Microsoft sign-in page     │
│             │                                    │
│             ▼                                    │
│  3. You sign in with work account              │
│             │                                    │
│             ▼                                    │
│  4. Browser redirects back to terminal         │
│             │                                    │
│             ▼                                    │
│  5. Terminal shows: "Auth successful"          │
│             │                                    │
│             ▼                                    │
│  6. Credentials saved locally                   │
│             │                                    │
│             ▼                                    │
│  7. Ready to deploy!                            │
│                                                   │
├─────────────────────────────────────────────────┤
│           SUBSEQUENT DEPLOYMENTS                 │
├─────────────────────────────────────────────────┤
│                                                   │
│  1. You run: Ctrl+Shift+P → Apply Changes      │
│             │                                    │
│             ▼                                    │
│  2. VS Code uses saved credentials             │
│             │                                    │
│             ▼                                    │
│  3. Connects to Power Platform                  │
│             │                                    │
│             ▼                                    │
│  4. Agent deploys automatically                 │
│             │                                    │
│             ▼                                    │
│  5. No additional login needed!                 │
│                                                   │
└─────────────────────────────────────────────────┘
```

---

## 10. AGENT LIFECYCLE

```
                    AGENT LIFECYCLE

        ┌───────────────────────────────┐
        │ 1. CREATED (First deployment)  │
        │                               │
        │ Status: DRAFT                 │
        │ Users: Can't see it           │
        │ Location: Cloud (Azure)       │
        │ Can edit: YES                 │
        └───────┬───────────────────────┘
                │
                │ You click "Publish"
                ▼
        ┌───────────────────────────────┐
        │ 2. PUBLISHED (Live for users)  │
        │                               │
        │ Status: PUBLISHED             │
        │ Users: Can see & use it       │
        │ Location: Cloud (Azure)       │
        │ Can edit: YES (then update)   │
        └───────┬───────────────────────┘
                │
        ┌───────┴─────────┬──────────────┐
        │                 │              │
        │ You edit &      │ Time to      │ Agent fails
        │ redeploy        │ enhance?     │ (OnError)
        │                 │              │
        ▼                 ▼              ▼
    UPDATED           ENHANCED       HANDLED
    (Reusable)       (More features)  (Safe)
        │                 │              │
        └─────────┬───────┴──────────────┘
                  │
                  │ Agent serves users
                  │
                  ▼
        ┌───────────────────────────────┐
        │ 3. OPERATIONAL (Serving users) │
        │                               │
        │ Monitor: Check usage logs     │
        │ Maintain: Update knowledge    │
        │ Improve: Add features        │
        │ Support: Fix issues          │
        └───────────────────────────────┘
```

---

## 11. COMPONENTS & FEATURES YOU CAN ADD

```
COMPONENTS & FEATURES MATRIX

Agent Base
├── Greeting         (Always included)
├── Fallback         (Always included)
└── OnError          (Always included)

+ Can Add:
├── Knowledge Sources
│   ├── SharePoint
│   ├── Web (URLs)
│   └── Documents
│
├── Topics
│   ├── Conversation flows
│   ├── Trigger phrases
│   └── Response logic
│
├── Actions
│   ├── Connectors (Power Automate)
│   ├── HTTP calls
│   └── System integrations
│
├── Authentication
│   ├── User sign-in required
│   ├── ID verification
│   └── Personalization
│
├── Feedback
│   ├── User ratings
│   ├── Satisfaction tracking
│   └── Improvement data
│
├── Advanced Features
│   ├── Orchestration (multiple agents)
│   ├── Adaptive cards (UI)
│   ├── Hand-off to human
│   └── Custom logic

TIME TO ADD EACH:
Knowledge:      5-10 min
Feedback:       5 min
Actions:        30-60 min
Authentication: 30 min
Topics:         10-20 min
Orchestration:  2+ hours
```

---

**Use these diagrams to visualize your journey through agent development. Print them out or bookmark for reference!**
