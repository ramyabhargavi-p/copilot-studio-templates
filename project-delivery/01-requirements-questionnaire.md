# Requirements Questionnaire

Run this with the project stakeholder before writing a single line of YAML.
Each answer maps directly to a template decision. Unanswered questions become risks.

---

## Section 1 — Business Context

**1. What is the primary purpose of this agent?**
Write one sentence that starts with "This agent helps [users] to [do what]."
> Answer:

**2. Who are the primary users?**
- [ ] All employees (internal)
- [ ] Specific department: _______________
- [ ] External customers
- [ ] Partners or vendors
- [ ] Mixed audience: _______________

**3. What channel(s) will the agent be deployed to?**
- [ ] Microsoft Teams
- [ ] SharePoint page (embedded)
- [ ] Public website
- [ ] Power Pages
- [ ] Custom channel / API

**4. What are the 5 most common questions or tasks the agent must handle?**
These become your first topics and trigger phrases.

| # | Question or task | Priority |
|---|-----------------|---------|
| 1 | | High |
| 2 | | High |
| 3 | | High |
| 4 | | Medium |
| 5 | | Medium |

**5. What are 5 things users might ask that the agent should NOT handle?**
These go into the agent instructions as out-of-scope with redirect targets.

| Out-of-scope topic | Redirect to (team, email, link) |
|--------------------|--------------------------------|
| | |
| | |
| | |
| | |
| | |

**6. What is the escalation path when the agent cannot help?**
- [ ] Transfer to live agent (Omnichannel / Genesys / other): Queue name: _______________
- [ ] Show an email address: _______________
- [ ] Show a phone number: _______________
- [ ] No escalation needed

**7. Does the agent need to know who the user is?**
- [ ] No — anonymous usage, no personalisation needed
- [ ] Yes — greet by name / personalise responses (needs auth)
- [ ] Yes — and also check the user's permissions or role before answering

**8. Who owns and maintains this agent after launch?**
> Owner name and team:

---

## Section 2 — Content and Knowledge

**9. What documents or content should the agent answer from?**
List SharePoint library paths, website URLs, or document names.

| Content source | Type (SharePoint / Website / Document) | URL or path |
|----------------|----------------------------------------|-------------|
| | | |
| | | |
| | | |

**10. How often does the source content change?**
- [ ] Rarely (once a year or less)
- [ ] Occasionally (monthly)
- [ ] Frequently (weekly or more) → flag: consider content freshness SLA

**11. Are there compliance or legal constraints on responses?**
- [ ] No restrictions
- [ ] Responses must not constitute legal advice
- [ ] Responses must not constitute financial advice
- [ ] Regulatory requirement: _______________
- [ ] PII handling requirement: _______________

Add to agent instructions: _______________

**12. Should AI responses show citation markers (e.g. [1][2]) to end users?**
- [ ] Yes — show citations (users benefit from source links)
- [ ] No — remove citations → add `remove-citations` component

**13. Does the agent need to support multiple languages?**
- [ ] English only (language: 1033)
- [ ] Multiple languages: _______________ → requires separate agents or language detection logic

**14. What tone should the agent use?**
- [ ] Formal (corporate, policy-style)
- [ ] Conversational (friendly, approachable)
- [ ] Technical (precise, jargon-appropriate)
- [ ] Empathetic (support/HR use cases)

---

## Section 3 — Actions and Integrations

**15. Does the agent need to READ data from any system?**

| System | What data | Connector available? |
|--------|-----------|---------------------|
| | | Yes / No |
| | | Yes / No |

**16. Does the agent need to WRITE or SUBMIT data to any system?**

| System | What action | Connector available? |
|--------|-------------|---------------------|
| | | Yes / No |
| | | Yes / No |

**17. Are there any MCP servers or external APIs to integrate?**
- [ ] No
- [ ] Yes: _______________

---

## Section 4 — Success Criteria

**18. How will you measure success at 3 months?**

| Metric | Target |
|--------|--------|
| Monthly active conversations | |
| Fallback rate (unanswered questions) | < ___% |
| Escalation rate | < ___% |
| User satisfaction score (CSAT) | > ___ |
| Knowledge search hit rate | > ___% |

**19. What is the go-live date?**
> Date:

**20. Who signs off on UAT before go-live?**
> Name and role:

---

## SOW → Template Mapping

Once answers are complete, use this table to select components:

| Answer | Component to include |
|--------|---------------------|
| Users need to sign in | `base/settings.mcs.yml` → `authenticationMode: ManualAzureAD` + `auth` component |
| Agent needs user's name/country | `conversation-init` + `global-variable` (UserDisplayName, UserCountry) |
| Agent answers from SharePoint | `knowledge/sharepoint` + `topics/knowledge-search` |
| Agent answers from a website | `knowledge/public-website` + `topics/knowledge-search` |
| Citations should be hidden | `topics/remove-citations` |
| Agent calls a connector | `actions/connector` + `topics/action-invoke` |
| Agent calls an MCP server | `actions/mcp` + `topics/action-invoke` |
| Multiple intents are likely to overlap | `topics/disambiguation` |
| Known out-of-scope areas | `topics/out-of-scope` |
| Human escalation needed | `topics/escalation` |
| Multi-domain / multiple teams | `components/agents/child-agent` (orchestrator pattern) |
| Date-sensitive content | Add `Date: {Text(Today(),DateTimeFormat.LongDate)}` to agent instructions |
