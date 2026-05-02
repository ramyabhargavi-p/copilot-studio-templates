# Technical Discovery Checklist

Complete this with a technical contact from the client environment before development starts.
These answers determine environment setup, auth configuration, and connector availability.

---

## 1. Power Platform Environment

| Item | Value |
|------|-------|
| Environment name | |
| Environment ID | |
| Region | |
| Environment type | Production / Sandbox / Developer |
| Managed or unmanaged solutions in use? | Yes / No |

**Who has System Administrator access?**
> Name and email:

**Is `pac` CLI set up for deployments?**
- [ ] Yes — `pac auth create` configured for this environment
- [ ] No — set up needed before first push

---

## 2. Authentication

**What auth mode will this agent use?**
- [ ] `None` — anonymous, no user identity
- [ ] `ManualAzureAD` — explicit sign-in (web, external, or non-Teams channels)
- [ ] `IntegratedAzureAD` — SSO via Teams / Microsoft 365 (no sign-in prompt)

**If ManualAzureAD or IntegratedAzureAD:**

| Item | Value |
|------|-------|
| Azure AD tenant ID | |
| App registration client ID (if applicable) | |
| Required OAuth scopes | |
| Are all users in the same tenant? | Yes / No |

---

## 3. Connectors and Connection References

For each connector the agent will use, confirm it is available in the target environment.

| Connector | Logical name | Licensed? | Connection exists in env? |
|-----------|-------------|-----------|--------------------------|
| Office 365 Users | `shared_office365users` | | |
| SharePoint | `shared_sharepointonline` | | |
| Office 365 Outlook | `shared_office365` | | |
| Dataverse | `shared_commondataservice` | | |
| Microsoft Teams | `shared_teams` | | |
| ServiceNow | `shared_service_now` | | |
| _(custom)_ | | | |

**For each connector used:**
- [ ] Connection reference created in the environment
- [ ] Agent service principal has permissions (for `mode: Caller`)
- [ ] Test user has permissions (for `mode: Invoker`)

---

## 4. SharePoint Knowledge Sources

For each SharePoint path that will be a knowledge source:

| Knowledge source name | SharePoint URL | Read permission granted? |
|----------------------|----------------|------------------------|
| | | |
| | | |

**Permission model:**
- [ ] Agent service principal has read access (for `authenticationMode: None`)
- [ ] Signed-in users already have read access (for `Invoker` mode)

---

## 5. Escalation / Human Handoff

**Is there a live-agent escalation system?**
- [ ] No — show email/phone instead of `TransferConversation`
- [ ] Omnichannel for Customer Service
- [ ] Genesys
- [ ] Other: _______________

**Escalation queue name (exact):**
> Queue name: _______________

---

## 6. Telemetry and Monitoring

**Is Application Insights configured for this environment?**
- [ ] Yes — workspace: _______________
- [ ] No — set up needed

**Who will own the monitoring dashboard?**
> Name and role:

**Alert thresholds to configure at launch:**

| Metric | Alert if |
|--------|---------|
| `Agent.ErrorOccurred` | > 5 per hour |
| `Agent.FallbackTriggered` rate | > 30% of `Conversation.Started` |
| `Action.Failed` rate | > 5% |
| `Agent.EscalationTriggered` rate | Spike > 2× baseline |

---

## 7. Deployment Process

**Who can publish agents in this environment?**
> Name(s):

**Is there a CI/CD pipeline?**
- [ ] No — manual `pac copilot push` from local
- [ ] Yes — pipeline tool: _______________

**Deployment environments:**

| Environment | Purpose | Who approves deployment? |
|-------------|---------|------------------------|
| Dev | Development and unit testing | Developer |
| Test | UAT and stakeholder review | Project owner |
| Production | Live users | _______________  |

**Is there a change freeze or deployment window?**
> Details:

---

## 8. Licensing

| Item | Confirmed |
|------|-----------|
| Copilot Studio licenses assigned to agent-building users | Yes / No |
| Sufficient message capacity for expected usage | Yes / No |
| Premium connector licences available (if using non-standard connectors) | Yes / No |

---

## Pre-Development Sign-off

Complete before writing YAML:

- [ ] Environment access confirmed for all developers
- [ ] Auth mode decided and documented
- [ ] All required connectors available and tested
- [ ] SharePoint paths confirmed with read access verified
- [ ] Escalation queue name confirmed
- [ ] Application Insights workspace confirmed
- [ ] Deployment process agreed and documented
