# Real-World Examples

Complete end-to-end walkthroughs with real project values filled in (no `<PLACEHOLDER>` style).

---

## Available Examples

### IT Helpdesk (Full-Featured)

**Scenario:** Contoso IT Support Bot in Teams

**Features:**
- ✅ FAQ bot (search SharePoint knowledge base)
- ✅ User authentication (sign-in required)
- ✅ Integration with ServiceNow (create + track tickets)
- ✅ CSAT feedback (rate the response)
- ✅ Multi-topic disambiguation (what do you need help with?)
- ✅ Escalation to human (hand-off workflow)

**Recipe Used:** `06-full-featured-agent`

**Users:** IT staff + employees across Contoso

**Time to Live:** 2–3 hours (full setup + testing)

**What's Included:**
- ✅ Architecture diagram
- ✅ All requirements answered
- ✅ All decisions explained
- ✅ Real YAML files (ready to copy & customize)
- ✅ Setup & test checklist (with expected outputs)
- ✅ Deploy commands (Dev → UAT → Prod)
- ✅ Week 2 monitoring results

**Start Here:** [`it-helpdesk/walkthrough.md`](it-helpdesk/walkthrough.md)

---

## How to Use This Example

### Path 1: Learn How It Works
1. Read the walkthrough top-to-bottom
2. Understand each component
3. See how pieces fit together
4. Use as reference for your own agent

### Path 2: Copy & Customize (Fastest)
1. Copy example YAML files
2. Replace Contoso references with your org
3. Update SharePoint/ServiceNow URLs
4. Deploy and test
5. Go live

### Path 3: Compare to Your Agent
1. Read example workflow
2. Compare to your needs
3. Add/remove components as needed
4. Deploy custom version

---

## How to Adapt This Example

### Change to HR Agent (from IT)
1. Keep the structure (same 6 topics)
2. Replace knowledge source (HR wiki instead of IT KB)
3. Replace actions (HR system instead of ServiceNow)
4. Update system prompt & greeting
5. Change authentication (if needed)

### Change to Your Organization (from Contoso)
1. Replace org name everywhere (Contoso → YourCorp)
2. Update SharePoint site URLs
3. Update system URLs (ServiceNow org)
4. Update Azure AD tenant ID
5. Update teams/security groups

### Add More Features
1. Use `components/` folder for ideas
2. Add knowledge sources (web search, documents)
3. Add more connector actions (Salesforce, Jira, etc.)
4. Add feedback topics (NPS, sentiment)
5. Test & deploy

---

## Learning Path

1. **Read:** [`../docs/AGENT-DEVELOPER-JOURNEY.md`](../docs/AGENT-DEVELOPER-JOURNEY.md) (full tutorial)
2. **Pick recipe:** [`../recipes/`](../recipes/) matching your type
3. **Compare to:** This example (IT Helpdesk)
4. **Copy & customize:** Use example files as templates
5. **Deploy & test:** Follow example's checklist
6. **Monitor:** Use [`../operations/`](../operations/) queries

---

## What You'll Learn

By studying this example, you'll understand:
- ✅ How to structure a production agent
- ✅ When to add each component
- ✅ How to integrate with business systems
- ✅ How to test before going live
- ✅ How to monitor post-launch
- ✅ How to iterate & improve

---

## Next Steps

- **Ready to build?** Copy this example and customize
- **Need variations?** See `../recipes/01–06` for simpler/complex patterns
- **Troubleshooting?** See `../troubleshooting/README.md`
- **Best practices?** See `../docs/BEST-PRACTICES.md`
