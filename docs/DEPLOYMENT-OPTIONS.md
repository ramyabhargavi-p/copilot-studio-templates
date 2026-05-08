# Deployment Options: Local VS Code → Copilot Studio Cloud

**Complete comparison of deployment methods: VS Code Apply Changes vs CLI Push vs CI/CD Pipeline**

---

## Quick Answer

**YES — You can create an agent entirely in VS Code and deploy it directly to Copilot Studio without any prior cloud setup.**

There are **3 deployment approaches**:

| Approach | Method | Time | Best For |
|----------|--------|------|----------|
| **🟢 Option 1: VS Code Apply Changes** | Click button in VS Code | 5–10 min | First-time developers, rapid iteration |
| **🟡 Option 2: CLI Push (Manual)** | Run `pac copilot push` | 5–10 min | Scripting, local automation, DevOps |
| **🔵 Option 3: CI/CD Pipeline** | Git push → GitHub Actions | 2–5 min | Teams, governance, multi-environment |

---

## OPTION 1: VS Code Apply Changes (Easiest)

### Workflow

```
1. Copy base template locally
2. Edit YAML files in VS Code
3. Click "Apply Changes" button
4. Agent auto-created in cloud ✓
5. Test in Copilot Studio UI
6. Publish when ready
```

### Step-by-Step

#### Step 1: Prepare Your Agent Locally

```bash
# Copy base template
cp -r base/ agents/my_agent/

# Open in VS Code
code agents/my_agent/
```

#### Step 2: Edit Placeholders in VS Code

Files to edit (5 replacements total):
- `agent.mcs.yml`: Replace `<AgentName>`, `<Agent Display Name>`, `<SYSTEM_PROMPT>`
- `settings.mcs.yml`: Replace `<agent_schema_name>`
- `Fallback.topic.mcs.yml`: Replace `<AGENT_SCHEMA>`

```yaml
# Example: agent.mcs.yml
name: <AgentName>  ← Replace with: my_agent
displayName: <Agent Display Name>  ← Replace with: My Agent
systemPrompt: <SYSTEM_PROMPT>  ← Replace with: You are an HR assistant...
```

**VS Code Find & Replace:**
- Press `Ctrl+H`
- Find: `<AgentName>`
- Replace with: `my_agent`
- Click "Replace All"

#### Step 3: Deploy to Cloud

**Option A: Using VS Code Button (Visual)**

```
1. In VS Code, open Command Palette: Ctrl+Shift+P
2. Type: Copilot Studio: Apply Changes
3. Press Enter
4. Wait 10–30 seconds
5. See success message: "Complete"
```

Expected output:
```
✓ Validating YAML...
✓ Connecting to environment...
✓ Creating agent in cloud...
✓ Complete
```

**Option B: Using Command Line (Automated)**

```bash
# Make sure you're authenticated
pac env who
# Expected: Connected to: [Your Environment]

# Deploy (from agent folder)
cd agents/my_agent/

# Apply changes via CLI (if available)
# NOTE: The standard approach is VS Code button above
```

#### Step 4: Verify Deployment

```bash
# List agents in environment
pac copilot list
# Expected: Your agent appears with Copilot ID (GUID)

# Or verify in browser
https://make.microsoft.com
# Select environment → Find your agent
# Status should show: "Draft"
```

#### Step 5: Test Agent

```
1. Open https://make.microsoft.com
2. Select your environment
3. Find your agent in the list
4. Click agent name
5. Click "Test" pane
6. Type "Hello"
7. Agent responds with greeting ✓
```

#### Step 6: Publish Agent

```
In Copilot Studio UI:
1. Click "..." menu (top right)
2. Click "Publish"
3. Confirm
4. Status changes to "Published"
5. Agent is now LIVE ✓
```

### Advantages
✅ No setup needed beyond authentication
✅ Fast (one click from VS Code)
✅ Can test immediately in UI
✅ Best for learning and rapid development
✅ No CI/CD configuration required

### Disadvantages
❌ Manual for each deployment
❌ No governance or approval gates
❌ Hard to scale across team
❌ No audit trail of who deployed what

---

## OPTION 2: CLI Push (Manual Scripting)

### Workflow

```
1. Copy base template locally
2. Edit YAML files in VS Code
3. Run: pac copilot push
4. Agent created/updated in cloud ✓
5. Manually publish in UI (or via CLI)
```

### Step-by-Step

#### Step 1-2: Same as Option 1
Copy template and edit YAML files.

#### Step 3: Push Agent via CLI

```bash
# Navigate to agent folder
cd agents/my_agent/

# Push to cloud
pac copilot push \
  --environment "<ENVIRONMENT_URL>" \
  --agent-folder "."

# Expected output:
# Agent successfully pushed to environment
# Agent ID: <GUID>
```

#### Step 4: Verify Push

```bash
# List agents
pac copilot list

# Get agent details
pac copilot info --bot "my_agent"
```

#### Step 5: Publish (Manual or CLI)

**Option A: Publish via UI**
```
1. Open https://make.microsoft.com
2. Find agent
3. Click "..." → "Publish"
```

**Option B: Publish via CLI** (if available)
```bash
pac copilot publish --bot "my_agent"
```

### Advantages
✅ Scriptable (can automate)
✅ Can integrate with local CI/CD tools
✅ Full control over deployment
✅ Better for DevOps workflows

### Disadvantages
❌ Requires pac CLI configuration
❌ Still manual unless scripted
❌ Less built-in than VS Code approach

---

## OPTION 3: CI/CD Pipeline (Fully Automated)

### Workflow

```
1. Edit YAML in feature branch
2. Create Pull Request
3. GitHub Actions validates + deploys to Dev
4. Merge to main → Promote to UAT
5. Create Release → Deploy + Publish to Prod
```

### Prerequisites

Before using CI/CD, you need:

```
1. GitHub Secrets (Settings → Secrets and variables → Actions):
   - POWER_PLATFORM_DEV_URL
   - POWER_PLATFORM_PROD_URL
   - POWER_PLATFORM_CLIENT_ID
   - POWER_PLATFORM_CLIENT_SECRET
   - POWER_PLATFORM_TENANT_ID

2. GitHub Variables (Settings → Secrets and variables → Variables):
   - AGENT_SCHEMA_NAME (your agent's schemaName)

3. Service Principal Setup:
   - Register app in Azure AD
   - Generate client secret
   - Add as Application User (System Administrator role) in Power Platform environment

4. (Optional) Production approval environment:
   - Settings → Environments → New → "production"
   - Add required reviewer for manual approval
```

### Step-by-Step

#### Step 1: Setup GitHub Secrets

```
Settings → Secrets and variables → Actions → New repository secret

Name: POWER_PLATFORM_CLIENT_ID
Value: <Your service principal client ID>

Name: POWER_PLATFORM_CLIENT_SECRET
Value: <Your service principal client secret>

Name: POWER_PLATFORM_TENANT_ID
Value: <Your Azure AD tenant ID>

Name: POWER_PLATFORM_DEV_URL
Value: https://org.crm.dynamics.com

Name: POWER_PLATFORM_PROD_URL
Value: https://prod-org.crm.dynamics.com
```

#### Step 2: Setup GitHub Variables

```
Settings → Secrets and variables → Variables → New repository variable

Name: AGENT_SCHEMA_NAME
Value: my_agent
```

#### Step 3: Create Feature Branch

```bash
git checkout -b feature/my-agent
# Edit YAML files
git add .
git commit -m "Create my_agent"
git push origin feature/my-agent
```

#### Step 4: Create Pull Request

```bash
# GitHub will automatically run: push-on-pr.yml
# This validates YAML and deploys to Dev environment
# You can see deployment status in PR checks
```

Expected: Pull request shows ✅ "Workflow passed"

#### Step 5: Merge to Main

```bash
# Click "Merge pull request" in GitHub UI
# GitHub will automatically run: promote-dev-to-uat.yml
# Waits for UAT approval (if configured)
```

#### Step 6: Create Release (for Production)

```bash
# In GitHub: Releases → New release
# Tag: v1.0.0
# GitHub will automatically run: promote-uat-to-prod.yml
# Waits for production approval (if configured)
```

### How CI/CD Workflows Work

#### `push-on-pr.yml` (On Pull Request)
```
Trigger: Pull request to main
Actions:
  1. Validate YAML syntax
  2. Authenticate using service principal
  3. Push agent to Dev environment
  4. Report status in PR
Result: Dev environment has latest version
```

#### `promote-dev-to-uat.yml` (On Merge to Main)
```
Trigger: Merge to main
Actions:
  1. Promote agent from Dev → UAT
  2. Requires approval (if configured)
  3. Publish in UAT (optional)
Result: UAT environment has tested version
```

#### `promote-uat-to-prod.yml` (On Release)
```
Trigger: GitHub Release published
Actions:
  1. Promote agent from UAT → Production
  2. Requires approval (if configured)
  3. Publish in Production
  4. Send success notification
Result: Production environment has published version
```

### Advantages
✅ Fully automated (no manual deployment)
✅ Built-in approval gates for governance
✅ Multi-environment support (Dev → UAT → Prod)
✅ Audit trail (who deployed what, when)
✅ Teams can collaborate with pull requests
✅ Scale to enterprise workflows

### Disadvantages
❌ Complex setup (secrets, service principal, GitHub environments)
❌ Requires Azure AD and service principal
❌ Longer first deployment time
❌ Extra configuration needed

---

## COMPARISON TABLE

| Aspect | VS Code Apply Changes | CLI Push | CI/CD Pipeline |
|--------|----------------------|----------|-----------------|
| **Setup Time** | 5 min | 15 min | 30–60 min |
| **Deploy Time** | 5–10 min | 5–10 min | 2–5 min (automated) |
| **Learning Curve** | Easy | Medium | Hard |
| **Suitable For** | Developers | Automation | Enterprise |
| **Approval Gates** | None | None | Yes ✓ |
| **Multi-Environment** | Single | Single | Multiple ✓ |
| **Audit Trail** | No | No | Yes ✓ |
| **Governance** | No | No | Yes ✓ |
| **Team Collaboration** | Limited | Limited | Full ✓ |
| **Automation** | Manual | Can script | Full automation |

---

## DECISION TREE: Which Option Should I Use?

```
                Are you a developer
                testing locally?
                    YES
                    ↓
            Use OPTION 1:
            VS Code Apply Changes
            (Easiest, fastest)
                    
                    NO
                    ↓
            Do you need approval gates
            or multi-environment?
                    NO
                    ↓
            Use OPTION 2:
            CLI Push (Manual)
            (More control, scriptable)
            
                    YES
                    ↓
            Use OPTION 3:
            CI/CD Pipeline
            (Full automation, governance)
```

---

## Common Scenarios

### Scenario 1: "I'm New, Learning Copilot Studio"
```
Use: OPTION 1 (VS Code Apply Changes)
Reason: Simplest, no extra setup, fast feedback loop
Time: 5 min to first deployment
```

### Scenario 2: "I'm Building Multiple Agents with My Team"
```
Use: OPTION 3 (CI/CD Pipeline)
Reason: Full governance, approval gates, audit trail
Time: 30–60 min setup, then fully automated
```

### Scenario 3: "I'm Automating Deployments Locally"
```
Use: OPTION 2 (CLI Push)
Reason: Can script/call from other tools
Time: 5–10 min per deployment
```

### Scenario 4: "I Need Multi-Environment (Dev→UAT→Prod)"
```
Use: OPTION 3 (CI/CD Pipeline)
Reason: Only option that supports multi-environment automation
Time: 30–60 min setup, fully automated after
```

### Scenario 5: "My Team Uses GitHub, I Need Governance"
```
Use: OPTION 3 (CI/CD Pipeline)
Reason: Built-in approval gates, audit trail, PR-based workflow
Time: 30–60 min setup, then fully automated
```

---

## FAQ

**Q: Do I need to create the agent in Copilot Studio UI first?**

A: **No.** All three options create the agent automatically. The local YAML files are the source of truth. On first deployment, the agent is created in cloud. On subsequent deployments, it's updated.

---

**Q: Which option is recommended for beginners?**

A: **Option 1 (VS Code Apply Changes).** It's the simplest and requires zero additional setup beyond authentication.

---

**Q: Can I use Option 1 for team development?**

A: **No, not recommended.** Multiple developers deploying simultaneously can cause conflicts. Use Option 3 (CI/CD) for teams.

---

**Q: If I use Option 3, do I still need to understand Options 1 and 2?**

A: **Yes, briefly.** Understanding the underlying flow (YAML → Authentication → Cloud) helps when debugging CI/CD issues.

---

**Q: Can I switch between options?**

A: **Yes.** The deployment methods don't lock you in. You can test with Option 1, then switch to Option 3 later.

---

**Q: What happens if I deploy the same agent twice?**

A: **Option 1 & 2:** Agent is updated (no duplicate created).
**Option 3:** Same — updates existing agent.

---

**Q: Is there a way to deploy without authentication each time?**

A: **Yes.**
- Option 1: Authentication saved locally after first `pac auth create`
- Option 2: Use service principal (non-interactive)
- Option 3: Service principal in GitHub Secrets (fully automated)

---

## Next Steps

1. **Choose your option** based on your scenario
2. **For Option 1:** Follow [AGENT-DEVELOPER-JOURNEY.md](docs/AGENT-DEVELOPER-JOURNEY.md) Phase 4
3. **For Option 2:** See [CI/CD README](ci-cd/README.md) → Manual Deployment section
4. **For Option 3:** See [CI/CD README](ci-cd/README.md) → Full setup guide

---

**Ready to deploy? Start with the guide for your chosen option above, or begin with [AGENT-DEVELOPER-JOURNEY.md](docs/AGENT-DEVELOPER-JOURNEY.md) for the complete walkthrough.**
