# Recipes: Step-by-Step Agent Builds

Eight complete guides for the most common agent types. Pick one, follow it, done.

---

## 🎯 Which Recipe for You?

**Step 1:** Does the agent need to sign in users?
- **No** → Go to Step 2
- **Yes** → Use **Recipe 02** (Authenticated Agent)

**Step 2:** Does the agent need to read/write business data?
- **No** → Use **Recipe 01** (Basic FAQ)
- **Yes** → Go to Step 3

**Step 3:** Where is the data stored?
- **SharePoint, Dataverse, ServiceNow** → Use **Recipe 03** (Connector Actions)
- **Custom API** → Use **Recipe 04** (MCP Actions)

**Step 4:** Does the agent need to route across multiple sub-agents?
- **No** → Use recipe from above
- **Yes** → Use **Recipe 05** (Orchestrator)

**Step 5:** Do you need everything (Auth + Knowledge + Actions + Feedback)?
- **Yes** → Use **Recipe 06** (Full Featured)

**Need custom pro-code logic?**
- **Yes** → Use **Recipe 07** (M365 Agents SDK) or **Recipe 08** (Azure AI Foundry)

---

## 📖 All 8 Recipes at a Glance

### Copilot Studio (Low-Code YAML)

| Recipe | For | Complexity | Time | Files |
|--------|-----|-----------|------|-------|
| **01-basic-faq** | Questions answered in docs | ⭐ Easy | 30 min | 3 |
| **02-authenticated** | Users sign in first | ⭐⭐ Medium | 45 min | 5 |
| **03-connector-actions** | Read/write business systems | ⭐⭐ Medium | 60 min | 6 |
| **04-mcp-actions** | Call external APIs | ⭐⭐ Medium | 60 min | 5 |
| **05-orchestrator** | Route across sub-agents | ⭐⭐⭐ Hard | 2+ hr | 8 |
| **06-full-featured** | Everything combined | ⭐⭐⭐ Hard | 2+ hr | 10 |

### Pro-Code (SDK)

| Recipe | For | Complexity | Time | Language |
|--------|-----|-----------|------|----------|
| **07-m365-sdk** | Custom orchestration, fine-grained control | ⭐⭐⭐ Hard | 2+ hr | C#/TS/Python |
| **08-foundry** | Code execution, scaling, custom models | ⭐⭐⭐ Hard | 3+ hr | Python |

---

## 📋 How to Use Each Recipe

### For Recipes 01–06 (Copilot Studio YAML)

Each recipe includes:
1. **Decision matrix** — When to use this vs others
2. **Files checklist** — Exactly what to copy
3. **Find & Replace table** — What values to change where
4. **Setup commands** — Copy-paste ready
5. **Test checklist** — Verify before deploying
6. **Expected results** — What success looks like

### For Recipes 07–08 (Pro-Code)

Each includes:
1. **When to use** — Decision vs Copilot Studio
2. **Dev setup** — Environment requirements
3. **Code template** — Start here
4. **Deploy** — Integration with Copilot Studio
5. **Test** — Verification steps

---

## ✅ Typical Workflow

```
1. Pick your recipe (01–08) ← You are here
2. Open recipe file
3. Copy component files (use provided bash commands)
4. Replace find/replace values (use provided table)
5. Deploy to cloud
6. Test in Copilot Studio
7. Iterate & enhance
```

---

## 💡 Pro Tips

- **Start with 01 or 02** if you're new — simplest, fastest
- **Use 03/04** when you have business data — reading/writing systems
- **Use 05/06** when handling multiple domains — specialized agents
- **Use 07/08** when Copilot Studio can't do what you need — custom logic
- **Combine recipes** — Start with 01, add auth from 02, add actions from 03

---

## Need More Help?

- **Full tutorial?** See [`../docs/QUICKSTART.md`](../docs/QUICKSTART.md)
- **Real example?** See [`../examples/it-helpdesk/`](../examples/)
- **Component details?** See [`../components/`](../components/)
- **Something broken?** See [`../troubleshooting/README.md`](../troubleshooting/README.md)
