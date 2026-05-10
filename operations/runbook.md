# Operational Runbook

Procedures for the on-call agent owner. Use this when something goes wrong in production.

---

## Incident Severity Levels

| Level | Definition | Response time | Example |
|-------|-----------|---------------|---------|
| P1 — Critical | Agent is completely down or returning errors to all users | Immediate | All conversations failing with errors |
| P2 — High | Major feature broken for many users | 1 hour | Knowledge search returning nothing; all actions failing |
| P3 — Medium | Partial degradation, some users affected | 4 hours | One topic not routing correctly; single action failing |
| P4 — Low | Cosmetic or minor accuracy issue | Next business day | Citation markers appearing; slightly off-scope routing |

---

## On-Call Checklist

When an alert fires:

1. Open Application Insights → check [monitoring-queries.md](monitoring-queries.md) **Error frequency** query
2. Identify the ConversationId from the error event
3. Run the **Trace a single conversation** query to reconstruct the failure
4. Check Power Platform Service Health: `https://admin.powerplatform.microsoft.com/servicestatus`
5. Check Microsoft 365 Service Health (if auth or connector affected): `https://admin.microsoft.com/servicestatus`
6. Apply the relevant procedure below

---

## Procedures

### P1-A — Agent returning errors to all users

**Symptoms:** `Agent.ErrorOccurred` alert firing repeatedly; `IsTestMode = false`

**Steps:**
1. Check Power Platform Service Health — if there's an active incident, wait and monitor
2. Open the agent in Copilot Studio test canvas — does the error reproduce there?
3. Check the error code in Application Insights (`ErrorCode` dimension):
   - `404` → topic or dialog reference broken — check for a missing topic (especially if a recent publish deleted a component)
   - `401/403` → authentication configuration changed — check Azure AD app registration
   - `500` → connector or backend service failure — check the connector status
4. If the error is in a recent publish: roll back (see **Rolling Back a Publish** below)
5. If the connector backend is down: temporarily disable the action topic (set trigger to disabled in YAML, push, publish)

### P1-B — Agent completely unresponsive

**Symptoms:** No `Conversation.Started` events for 2+ hours; **Zero conversations** alert firing

**Steps:**
1. Check the published agent channel URL — does it load?
2. Check the Power Platform environment health
3. Check if the agent channel (Teams, website) has been deprovisioned or the app removed
4. In Copilot Studio, verify the agent is published (not in draft only)
5. If Teams app: verify the app is still installed and not blocked by tenant policies

### P2-A — Knowledge search returning no answers

**Symptoms:** `Knowledge.AnswerNotFound` rate > 80%; `Knowledge.SearchInvoked` events present

**Steps:**
1. Run **Knowledge search answer rate** query — confirm the drop is real, not a spike
2. In Copilot Studio, test a known question from the knowledge base manually
3. Check SharePoint source site — is the document library accessible? Are documents checked in?
4. Check if SharePoint indexing has been disrupted (re-indexing can cause temporary gaps)
5. Check if the SharePoint connection reference is still valid (not expired/revoked)
6. If documents were recently moved or renamed: re-add the knowledge source in Copilot Studio and re-publish

### P2-B — Connector action failing for all users

**Symptoms:** `Action.Failed` alert firing; all users getting the "safe error message"

**Steps:**
1. Run the **Action success / failure rate** query — identify which action is failing
2. In Copilot Studio, invoke the action in the test canvas
3. Check Power Platform connections — navigate to **Connections** in the environment and verify the connection is not in error state
4. Check the backend service (the API or data source the connector calls)
5. If the connection expired: re-authenticate the connection in the Power Platform admin center
6. If the backend is down: add an out-of-service message temporarily (see **Temporary Out-of-Service** below)

### P3-A — Topic routing accuracy degraded

**Symptoms:** High fallback rate; users complaining the agent doesn't understand them

**Steps:**
1. Run the **Out-of-scope topics** and **Unanswered questions** queries
2. Identify patterns in the queries that aren't being matched
3. Add trigger phrase variants to the affected topics in YAML
4. Run eval against the affected topics before publishing: `pac copilot eval run --eval-file evals/<agent>-eval.csv`
5. If routing accuracy is acceptable (>85%): publish; otherwise, iterate on trigger phrases

### P3-B — Authentication sign-in loop

**Symptoms:** Users repeatedly prompted to sign in; `Auth.SignInStarted` fires multiple times per conversation

**Steps:**
1. In Copilot Studio, test sign-in manually in the test canvas
2. Check the Azure AD app registration — verify the redirect URI is correct for the channel
3. Check the token expiration settings — if the token lifetime is very short, users will be re-prompted
4. Verify the `OAuthInput` node's connection reference points to the correct app registration
5. Check if the Teams app manifest has the correct scope permissions

---

## Rolling Back a Publish

Copilot Studio does not have a one-click rollback. To roll back:

1. Identify the last good commit in the git repository
2. Check out that commit: `git checkout <commit-hash> -- .`
3. Apply the files: VS Code → "Copilot Studio: Apply Changes" (ensure VS Code is connected to the target environment's cloned agent folder)
4. Publish in Copilot Studio UI (or via `pac copilot publish`)
5. Verify in test canvas
6. Revert the git checkout: `git checkout HEAD -- .`
7. Create a branch and fix the issue properly before re-deploying

---

## Temporary Out-of-Service

When an integration (connector, knowledge source) is down and you need to stop users from hitting errors:

1. Locate the affected topic YAML file
2. Comment out the action call nodes
3. Add a `SendActivity` node with a temporary message:
   ```
   I'm currently unable to help with <FEATURE> due to a technical issue. 
   Please try again later or contact <CONTACT> directly.
   ```
4. Push and publish
5. Monitor — revert once the underlying service recovers

---

## Contacts

| Role | Contact | When to involve |
|------|---------|----------------|
| Agent owner | | P1, P2 — all incidents |
| Power Platform admin | | P1, P2 — environment/connector issues |
| Azure AD admin | | Auth issues |
| SharePoint admin | | Knowledge source issues |
| Microsoft support | `https://admin.microsoft.com/support` | P1 if Microsoft service is down |

---

## Post-Incident Review Template

After every P1/P2 incident, fill this in and share with the team:

```
Date:
Duration:
Severity:
User impact:

Timeline:
  HH:MM — Alert fired / first report
  HH:MM — Investigation started
  HH:MM — Root cause identified
  HH:MM — Fix applied
  HH:MM — Incident resolved

Root cause:

Fix applied:

Preventative action:
  [ ] Add/update monitoring alert
  [ ] Add regression test to eval CSV
  [ ] Update this runbook
  [ ] Other:
```
