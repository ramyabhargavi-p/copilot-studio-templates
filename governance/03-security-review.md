# Security Review Checklist

> **Complete before Production deployment.** Requires sign-off from the security team.
> Focus especially on authentication mode, connector permissions, and DLP policy coverage.
> The CI/CD promote-to-production workflow checks for this file's completion.

Complete before go-live and after any change to authentication, connectors, or system prompt.

---

## 1 — Authentication and Identity

| # | Check | Notes | Pass/Fail |
|---|-------|-------|-----------|
| S1 | Azure AD app registration exists in the correct tenant | App ID: | |
| S2 | Redirect URI in Azure AD exactly matches Copilot Studio's reported URI | | |
| S3 | App registration permissions are the minimum required (least privilege) | Scopes listed: | |
| S4 | No client secrets are expiring within 90 days | Expiry date: | |
| S5 | Authentication mode in `settings.mcs.yml` is appropriate for the deployment context | Mode: | |
| S6 | Users cannot access other users' data through the agent | Test: log in as User A, verify only User A's data is returned | |

---

## 2 — Data Handling

| # | Check | Notes | Pass/Fail |
|---|-------|-------|-----------|
| D1 | PII is not written to Application Insights telemetry | Review all `LogCustomTelemetryEvent` node `customDimensions` | |
| D2 | PII is not written to conversation variables that are stored or logged | Review all `SetVariable` nodes that store user data | |
| D3 | Knowledge source documents do not contain confidential information beyond the agent's authorised audience | Review SharePoint library permissions | |
| D4 | Connector responses that contain sensitive data are not sent to users verbatim without filtering | Review all `SendActivity` nodes that reference connector outputs | |
| D5 | Global variables holding user profile data are scoped to the conversation, not the session/bot | Check `scope: Conversation` in variable declarations | |

---

## 3 — System Prompt Security

| # | Check | Notes | Pass/Fail |
|---|-------|-------|-----------|
| Sp1 | System prompt does not contain internal service names, URLs, or infrastructure details | Review `agent.mcs.yml` instructions | |
| Sp2 | System prompt does not contain passwords, API keys, or secrets | | |
| Sp3 | System prompt includes out-of-scope and refusal guidance | | |
| Sp4 | Prompt injection resistance tests I1–I5 in `02-ai-ethics-checklist.md` all pass | | |

---

## 4 — Connector and Integration Security

| # | Check | Notes | Pass/Fail |
|---|-------|-------|-----------|
| C1 | All connector connections use service accounts, not personal accounts | List connectors and their auth accounts | |
| C2 | Service accounts have MFA enabled (or are excluded from Conditional Access policies appropriately) | | |
| C3 | Connector operations used are the minimum required — no unused broad-scope operations | | |
| C4 | Custom connectors (if any) use HTTPS with a valid certificate | | |
| C5 | The Power Platform environment has a DLP policy that restricts which connectors can be used | DLP policy name: | |

---

## 5 — Channel and Deployment Security

| # | Check | Notes | Pass/Fail |
|---|-------|-------|-----------|
| Ch1 | The agent is only enabled on the channels defined in the project requirements | Enabled channels: | |
| Ch2 | If the agent is accessible on a public website channel: the domain is allowlisted to prevent embedding on unauthorised sites | Allowed domains: | |
| Ch3 | Teams app manifest has the minimum required permissions | | |
| Ch4 | The agent is deployed to the correct environment (not accidentally deployed to production from a dev machine) | Environment: | |

---

## 6 — Ongoing Security

| # | Check | Notes |
|---|-------|-------|
| O1 | App registration secret rotation is scheduled before expiry | Rotation date: |
| O2 | A reviewer is subscribed to Microsoft Security Advisories for Copilot Studio / Power Platform | |
| O3 | Security review is re-run after any change to: auth config, connectors, system prompt, or knowledge sources | |

---

## Sign-off

| Role | Name | Date |
|------|------|------|
| Developer | | |
| Security Reviewer (if available) | | |
| Project Owner | | |
