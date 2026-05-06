# Troubleshooting Guide

Practical fixes for the most common issues encountered when building, testing, and deploying Copilot Studio agents.

---

## Table of Contents

1. [Agent Not Appearing / Not Working After Publishing to Teams or Copilot](#1--agent-not-appearing--not-working-after-publishing-to-teams-or-copilot)
2. [Apply Changes Errors](#2--apply-changes-errors)
3. [Topics Not Triggering Correctly](#3--topics-not-triggering-correctly)
4. [Knowledge Search Not Returning Answers](#4--knowledge-search-not-returning-answers)
5. [Connector / Action Failures](#5--connector--action-failures)
6. [Authentication and Sign-in Issues](#6--authentication-and-sign-in-issues)
7. [Telemetry Not Appearing in Application Insights](#7--telemetry-not-appearing-in-application-insights)
8. [YAML Validation Errors](#8--yaml-validation-errors)
9. [Test Canvas vs Published Behaviour Differs](#9--test-canvas-vs-published-behaviour-differs)
10. [General Tips and Diagnostics](#10--general-tips-and-diagnostics)

---

## 1 — Agent Not Appearing / Not Working After Publishing to Teams or Copilot

This is the most common post-publish issue. Work through these checks in order.

### 1a — Agent appears in Teams but shows "Sorry, something went wrong"

| Check | How to verify | Fix |
|-------|--------------|-----|
| Agent is published (not just saved) | Copilot Studio → your agent → **Publish** tab — check last published date | Click **Publish** and wait for success |
| Correct channel is enabled | **Channels** tab → Teams channel enabled | Enable Teams channel; re-publish |
| App registration not expired | Azure portal → App registrations → check token/secret expiry | Rotate the secret; update in Copilot Studio |
| Connection reference valid | Power Platform admin → Connections → look for error state | Re-authenticate the broken connection |
| Published version has no critical error | Check Application Insights `Agent.ErrorOccurred` events with `IsTestMode=false` | Fix root cause; push and re-publish |

### 1b — Agent does not appear in Teams at all

| Check | How to verify | Fix |
|-------|--------------|-----|
| Teams app is deployed by admin | Microsoft 365 admin center → **Teams apps** → **Manage apps** | Admin: approve and deploy the app |
| App is published to the correct Teams tenant | Copilot Studio → Teams channel → check tenant ID | Update channel configuration |
| Agent is in the correct Power Platform environment | `pac env list` to verify active environment | Switch environment: `pac auth switch` |
| Teams app cache | User's Teams client showing stale state | User: sign out and back in; or clear Teams cache |

### 1c — Agent works in test canvas but not in Microsoft Copilot (m365.cloud.microsoft)

| Check | How to verify | Fix |
|-------|--------------|-----|
| Microsoft Copilot channel is enabled | Copilot Studio → **Channels** → look for **Microsoft Copilot** | Enable the channel; re-publish |
| Agent is set to **Copilot for Microsoft 365** availability | Copilot Studio → **Settings** → check availability | Set to **Available in Copilot for Microsoft 365** |
| User has a Microsoft 365 Copilot licence | Microsoft 365 admin center → Licences | Assign licence or test with a licensed account |
| Agent not yet rolled out to all users | Admin has set staged rollout | Wait, or add your account to the preview group |
| DLP policy blocking the agent | Power Platform admin → DLP policies | Work with your admin to add an exception |

### 1d — Agent is in Teams but doesn't respond to messages

| Check | How to verify | Fix |
|-------|--------------|-----|
| Bot endpoint is reachable | Check Power Platform service health | Wait for Microsoft to resolve the incident |
| Agent has a published version (not draft only) | Copilot Studio → **Publish** shows success | Re-publish |
| Conversation not stuck in a broken topic | Try clearing the conversation (`/start` or starting a new chat) | Start a fresh conversation |
| Bot framework app ID mismatch | Copilot Studio → **Settings** → App ID matches Azure app registration | Re-register or correct the App ID |

---

## 2 — Apply Changes Errors

> These errors occur when using VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"` to push agent YAML.

### "Not authenticated" / 401

```
Error: Authentication failed
```

Fix:
```bash
pac auth clear
pac auth create --environment <env-url>
# Complete the browser login that opens
# Then apply changes: VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

### "Environment not found" / Wrong environment

```
Error: The specified environment could not be found
```

Fix:
```bash
pac env list                          # find your environment
pac auth switch --index <N>           # switch to the right auth profile
# Then apply changes: VS Code: Ctrl+Shift+P → "Copilot Studio: Apply Changes"
```

### "Schema validation failed" / YAML parse error

```
Error: Invalid YAML — unexpected token at line X
```

Common causes and fixes:

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Error on a line with `<PLACEHOLDER>` | Forgot to replace a placeholder | Search for `<` in all YAML files |
| `_REPLACE` in node ID | Forgot to replace ID suffix | Search for `_REPLACE` across all files |
| Unexpected indent | Tab character mixed with spaces | Use the VS Code YAML extension to show whitespace |
| Duplicate `id:` value | Copy-pasted a node without changing the ID | Make every node ID unique within the agent |

### "Conflict" / File already exists

```
Error: A component with this name already exists
```

Fix: The `schemaName` already exists in the environment with different content.
- Check with `pac copilot list` if another agent has the same schemaName
- Change the `schemaName` in `settings.mcs.yml` and all component files, then push again

### Push succeeds but changes don't appear in Copilot Studio

- Hard-refresh Copilot Studio (Ctrl+Shift+R)
- Wait 30–60 seconds — the sync can be slightly delayed
- Check `pac copilot list` to confirm the push registered the new version

---

## 3 — Topics Not Triggering Correctly

### Wrong topic fires

1. In the test canvas, type the failing utterance
2. Check the **Activity log** (bottom panel) to see which topic was triggered and why
3. If the wrong topic fired: its trigger phrases are likely too broad — narrow them
4. If no topic fired (Fallback): the trigger phrases don't cover this utterance variation — add more

### Fallback fires for everything

1. Check if the `recognizer` in `settings.mcs.yml` is set — it should be `NLU.MultiIntent`
2. Verify trigger phrases are formatted correctly — each phrase on its own line under `entities`
3. Check `GenerativeActionsEnabled` is not set to `false` if you expect intent matching to work

### Topic triggers but immediately ends with no response

1. Check the topic YAML for `SendActivity` nodes — ensure they have `activity.text` populated
2. Look for a `BeginDialog` pointing to a non-existent dialog name — the topic silently fails
3. Check for a `ConditionGroup` where all branches send nothing (no fallback `elseActions`)

### OnError topic fires when a topic starts (not just on system errors)

This usually means a node in your topic YAML has a structural error that causes a runtime exception.

1. Check the triggering node in the Activity log
2. Look for: null variable references, malformed Power FX expressions, missing required properties on action nodes
3. Test the Power FX expression in the test canvas expression evaluator

---

## 4 — Knowledge Search Not Returning Answers

### "I couldn't find the answer" on every question

| Check | Fix |
|-------|-----|
| Knowledge source is added to the agent | Copilot Studio → **Knowledge** — verify the source appears |
| SharePoint site is indexed | Check the SharePoint site's search settings; trigger a re-index if needed |
| SharePoint connection not expired | Power Platform → Connections → re-authenticate if in error state |
| Documents are checked in (not draft) | SharePoint → check each document's version status |
| Knowledge source URL is correct | Compare the URL in the knowledge source config with the actual SharePoint path |

### Answers appear in test but not after publish

- The test canvas uses draft knowledge; published uses the last published snapshot
- Re-publish the agent after adding or updating knowledge sources
- Allow 10–15 minutes for the publish to propagate

### Answers contain `[1][2]` citation markers

The `remove-citations` topic component is not added to this agent.
- Add it from `components/topics/remove-citations/`
- It triggers on `OnGeneratedResponse` and strips citation markers from all AI responses

### Knowledge answers are hallucinated (not grounded in documents)

1. Check the `instructions` in `agent.mcs.yml` — add explicit grounding instructions:
   ```
   Only answer questions based on the knowledge sources provided. If you cannot find 
   the answer in the available documents, say so and do not speculate.
   ```
2. Check `GenerativeActionsEnabled` — if enabled, the agent may use general AI knowledge; disable if strict grounding is required
3. Review the actual document content — the answer may exist in the documents but be poorly worded

---

## 5 — Connector / Action Failures

### Action always returns empty / null

1. In the test canvas, check the Activity log after the action fires — look for the connector response
2. Check the Power Platform connection for that connector — is it in error state?
3. Test the connector directly in Power Automate or the Power Platform admin center
4. Check the connector operation name and parameters in the YAML — a misspelled operation name silently returns null

### Action returns data but the topic shows an error message

Your `ConditionGroup` in the `action-invoke` topic checks `!IsBlank(Topic.ActionResponse)`.
If the response is technically not blank but is `{}` or `null`, the condition evaluates unexpectedly.

Fix the condition:
```yaml
condition: =!IsBlank(Topic.ActionResponse) && !IsBlank(Topic.ActionResponse.value)
```

Adjust `value` to the actual property name in the connector response.

### "Connection not found" after a recent environment change

When moving an agent between environments, connection references need to be re-mapped.

Fix:
1. In the target environment → Power Platform admin → **Solutions** → open the agent's solution
2. Go to **Connection References** → re-authenticate each connection
3. Apply changes again: VS Code: `Ctrl+Shift+P → "Copilot Studio: Apply Changes"`

---

## 6 — Authentication and Sign-in Issues

### Sign-in prompt never appears

1. Check `settings.mcs.yml` — `authenticationMode` must be `ManualAzureAD` or `IntegratedAzureAD`
2. Check the `auth` topic component is added — the `OAuthInput` node triggers the sign-in card
3. In Teams, check the Teams app has the `webApplicationInfo` section in its manifest with the correct app ID

### Sign-in completes but user name is wrong / blank

1. The `conversation-init` component reads from `Office365Users.UserProfileV2()` — verify the connection has `User.Read` scope
2. Check `Global.UserDisplayName` in the test canvas after sign-in — if blank, the M365 API call failed silently
3. Review the `ConversationInit.ProfileLoadFailed` telemetry event in Application Insights

### Sign-in loop — user is prompted to sign in again after a few minutes

- The OAuth token lifetime is too short
- In Azure AD app registration → **Token configuration** → increase access token lifetime
- Or configure **Continuous Access Evaluation** to avoid re-prompting

### "AADSTS50011: The redirect URI specified in the request does not match" error

The redirect URI configured in Azure AD doesn't match what Copilot Studio is sending.

Fix:
1. Copy the redirect URI from Copilot Studio → **Settings** → **Authentication** → **Redirect URL**
2. In Azure portal → App Registration → **Authentication** → add that exact URI
3. Save in Azure portal; return to Copilot Studio and re-save authentication settings

---

## 7 — Telemetry Not Appearing in Application Insights

### No events visible at all

1. Check the Application Insights **connection string** in Copilot Studio → **Settings** → **Telemetry**
2. Telemetry has a 2–5 minute delay — wait and refresh
3. Run a simple test conversation to generate events, then check

### Custom events not appearing (standard events are fine)

Our `LogCustomTelemetryEvent` nodes fire application-level custom events. If they're missing:

1. Verify the node `kind: LogCustomTelemetryEvent` is present in the topic YAML
2. Check the `eventName` field is populated — blank event names are silently dropped
3. Check that `customDimensions` entries use `=` prefix for dynamic values:
   ```yaml
   value: =System.Activity.Text   # correct
   value: System.Activity.Text    # wrong — sends the string literal
   ```

### `ConversationId` is empty in custom events

The `System.Conversation.Id` variable must be referenced in the `customDimensions` block. Check the event node in YAML:
```yaml
- name: ConversationId
  value: =System.Conversation.Id
```

---

## 8 — YAML Validation Errors

### "Unexpected key" or "Schema violation"

The VS Code Copilot Studio extension highlights schema errors. Common causes:

| Error | Cause | Fix |
|-------|-------|-----|
| Unknown key `xxx` | Typo in a node property name | Check spelling against the template |
| Missing required property | A required field (e.g., `id`, `kind`) is absent | Add the missing field |
| Wrong value type | e.g., a boolean where a string is expected | Check the template for the expected type |
| Duplicate ID | Two nodes share the same `id` value | Make the second one unique |

### Node IDs still containing `_REPLACE`

The templates ship with `_REPLACE` suffixes as placeholders. These must be replaced before pushing.

Search and replace in VS Code:
1. **Ctrl+Shift+F** → search `_REPLACE` → check all `.yml` files
2. Replace each one with a unique 6-character alphanumeric string
3. Ensure no two nodes across the entire agent share the same ID

Generate IDs:
```powershell
[System.Web.Security.Membership]::GeneratePassword(6, 0)
```

### `<PLACEHOLDER>` values still present

```bash
grep -r "<" /path/to/your/agent --include="*.yml"
```

Fix every match before pushing.

---

## 9 — Test Canvas vs Published Behaviour Differs

This is a frequent source of confusion. Key differences:

| Behaviour | Test canvas | Published |
|-----------|------------|-----------|
| Agent content | Latest saved (draft) | Last published snapshot |
| Knowledge source | Draft index | Published index |
| Variables | Reset each conversation | Reset each conversation |
| Error display | Full error details (`IsTestMode=true`) | Safe message + Reference ID only |
| Authentication | Simulated (may skip real OAuth) | Full OAuth flow |
| Channels | Copilot Studio web frame | Teams, website, Copilot, etc. |

**Always publish before testing in the real channel.** A common mistake is fixing something in the test canvas and assuming it's fixed — the published version is still broken until you publish.

---

## 10 — General Tips and Diagnostics

### Before raising a support ticket

1. Reproduce the issue in the test canvas — if it doesn't reproduce there, it's likely a channel-specific issue
2. Collect the `ConversationId` from the error (shown in test canvas or Application Insights)
3. Run the **Trace a single conversation** query in Application Insights to get the full event sequence
4. Check [Power Platform Service Health](https://admin.powerplatform.microsoft.com/servicestatus) and [Microsoft 365 Service Health](https://admin.microsoft.com/servicestatus) — many issues are Microsoft-side incidents

### Useful diagnostic commands

```bash
# Check which environment you're targeting
pac auth list

# List agents in the environment
pac copilot list --environment <env-url>

# Validate YAML without pushing
pac copilot push --dry-run  # (validation only — checks YAML schema without uploading)

# Check the published version number
pac copilot show --name <agent-schema-name>
```

### Quick health check after any publish

1. Open test canvas → type the greeting trigger phrase → confirm Greeting topic fires
2. Type `asdfghjkl` → confirm Fallback fires with the retry message
3. Type `speak to a human` → confirm Escalation fires
4. Open Application Insights → run the **Monthly Health Report** query → verify `Conversation.Started` events appear

### Getting help

| Resource | URL |
|----------|-----|
| Copilot Studio documentation | https://learn.microsoft.com/copilot-studio |
| Power Platform Community | https://community.powerplatform.com |
| Power Platform Service Health | https://admin.powerplatform.microsoft.com/servicestatus |
| Microsoft 365 Service Health | https://admin.microsoft.com/servicestatus |
| GitHub Issues (this repo) | *(your repo URL)* |
