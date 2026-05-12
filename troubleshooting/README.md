# Troubleshooting Guide

> **How to use this guide:** Find the symptom in the section headers below.
> Each section has the most common cause first, with a fix command or step.
> If your issue isn't listed, check Application Insights → Traces for the exact error message,
> then search this file for keywords from that message.

Practical fixes for the most common issues encountered when building, testing, and deploying Copilot Studio agents.

---

## Table of Contents

1. [Agent Not Appearing / Not Working After Publishing to Teams or Copilot](#1--agent-not-appearing--not-working-after-publishing-to-teams-or-copilot) — includes [1e: "You don't have access to talk to this bot"](#1e--intermittent-you-dont-have-access-to-talk-to-this-bot-in-teams)
2. [Apply Changes / YAML Push Errors](#2--apply-changes--yaml-push-errors) — includes [2a: Duplicate component after copying templates](#2a--duplicate-component-error-after-copying-template-files-into-a-cloned-folder)
3. [Topics Not Triggering Correctly](#3--topics-not-triggering-correctly)
4. [Knowledge Search Not Returning Answers](#4--knowledge-search-not-returning-answers)
5. [Connector / Action Failures](#5--connector--action-failures)
6. [Authentication and Sign-in Issues](#6--authentication-and-sign-in-issues)
7. [Telemetry Not Appearing in Application Insights](#7--telemetry-not-appearing-in-application-insights)
8. [YAML Validation Errors](#8--yaml-validation-errors)
9. [Portal Canvas Rendering Issues](#9--portal-canvas-rendering-issues)
10. [Test Canvas vs Published Behaviour Differs](#10--test-canvas-vs-published-behaviour-differs)
11. [General Tips and Diagnostics](#11--general-tips-and-diagnostics)
12. [pac CLI Common Errors](#pac-cli-common-errors)

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

### 1e — Intermittent "You don't have access to talk to this bot" in Teams

**Symptoms:** Agent worked fine for months with no config changes. Error is intermittent — not all users, not every time. No conversation transcript generated in Copilot Studio when it fails. Failures often coincide with inactivity timeout messages being sent.

**Why this happens:** Three separate root causes produce identical symptoms. Work through them in order.

#### Root cause 1 — Azure AD app registration client secret expired (most common)

When the secret expires, auth token refresh fails for some users before others depending on cached token state — which explains the intermittent pattern.

| How to verify | Fix |
|---|---|
| Azure portal → **App registrations** → your bot app → **Certificates & secrets** → check expiry date | Rotate the secret; update it in Copilot Studio → **Settings** → **Security** → **Authentication** |

#### Root cause 2 — Inactivity message sent to an expired user session

When the agent sends a proactive inactivity message and the user's Teams session has expired (or the bot lacks proactive messaging Graph permissions), Teams rejects the message with this error. No transcript is generated because the session was never re-established.

| How to verify | Fix |
|---|---|
| Failures only happen after a period of user inactivity | Check the Azure AD app registration has `TeamsAppInstallation.ReadWriteSelfForUser.All` Graph permission granted (required for proactive messaging in Teams) |
| Check Azure AD → Enterprise applications → your bot → Permissions — look for proactive messaging scopes | Add the permission and grant admin consent; re-publish the agent |

#### Root cause 3 — Teams app assignment caching / propagation delay

App assignments in Teams Admin Center can take up to 24 hours to propagate. Users added to the assignment group recently may see this error until propagation completes.

| How to verify | Fix |
|---|---|
| Affected users were recently added to the assignment group | Wait up to 24 hours; ask affected users to sign out of Teams and back in to force a policy refresh |
| Check if affected users share a common attribute (new joiners, specific AAD group, geography) | If a specific group is consistently affected, re-check the app permission policy applied to that group in Teams Admin Center |

#### Root cause 4 — Teams channel connection needs re-authorisation

After prolonged inactivity or a service-side token rotation, the Teams channel OAuth connection in Copilot Studio can silently expire.

| How to verify | Fix |
|---|---|
| Go to Copilot Studio → **Channels** → **Microsoft Teams** → edit the channel | Re-authorise the connection; re-publish |

#### If none of the above resolve it

- Check **Microsoft 365 Service Health** (admin.microsoft.com → Health → Service health) for any Teams or Power Platform advisories at the time failures occur
- Raise a Microsoft Support ticket with: the bot's App ID (from Azure), affected user UPNs, and approximate timestamps of failures — intermittent auth errors at this level often require Microsoft to inspect their token service logs

---

## 2 — Apply Changes / YAML Push Errors

**Applies to:** VS Code → "Copilot Studio: Apply Changes"

> `pac copilot push` does not exist in the standard pac CLI. To push multi-file YAML, use the VS Code Copilot Studio extension "Apply Changes" command.

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| "Apply Changes" shows no environments | Not signed in to the extension | Click the Copilot Studio icon in the VS Code activity bar → Sign In |
| "Apply Changes" fails with auth error | Token expired | Sign out and sign back in via the Copilot Studio extension pane |
| "Apply Changes" hangs | Large YAML file / slow connection | Wait up to 2 minutes; if still hanging, check VS Code Output panel → "Copilot Studio" channel |
| YAML validation error on apply | Schema error in one of the `.mcs.yml` files | Check the VS Code Problems panel for red underlines; fix the flagged file first |
| "Agent not found" on Apply Changes | Schema name mismatch between local files and the agent in cloud | Verify `schemaName` in `settings.mcs.yml` matches exactly what's in the Copilot Studio portal |
| Changes applied but not visible in portal | Draft vs published | Changes go to the draft — test in the Test pane; click Publish to go live |
| Published but changes not reflected in UI | Apply Changes was skipped — published the old draft | Run VS Code → Apply Changes first, THEN publish. Publish only makes the current draft live — it does not push local YAML |
| Apply Changes reports success but topic canvas still shows old content | Portal has cached the previous version of the topic | Hard-refresh the portal tab (`Ctrl+Shift+R`), or navigate away from the topic and back. If still stale, open the topic in an incognito window to bypass all portal cache. The data is in the cloud — this is a portal rendering cache issue only. |
| **"Error cloning agent: Server was requested to shut down"** | VS Code Copilot Studio extension language server crashed | 1. `Ctrl+Shift+P` → **Developer: Reload Window** — wait 10 seconds for extension to reconnect, then retry Clone Agent. 2. If still failing: `Ctrl+Shift+P` → **Copilot Studio: Sign Out** → **Sign In** → retry. 3. If still failing: close and reopen VS Code |
| **"Missing conn.json, please clone again"** | `conn.json` (extension connection metadata) is missing — files were copied/moved manually instead of cloned, OR Apply Changes is being run from the wrong folder | Re-clone: `Ctrl+Shift+P` → **Copilot Studio: Clone Agent** → select agent → output folder: `agents\`. The extension creates `agents\<display name>\` containing `.mcs\conn.json` — **this subfolder is your working folder**, not the parent. After cloning, copy your edited YAML files into `agents\<display name>\`, then run Apply Changes from there. Never manually copy files into the folder or move it — `conn.json` uses absolute paths and breaks if moved. |
| **`[0x800608ad:ExportKeyAttributeInvalidPrefix]` — "schemaname for component botcomponent must start with a valid customization prefix"** | A `.variable.mcs.yml` file in `variables/` is being pushed as a new cloud component for the first time. The schema name must start with your environment's publisher customization prefix (e.g. `hr_`), which the VS Code extension validates on first creation. | **Workaround**: Delete the `.variable.mcs.yml` file(s) from your agent's `variables/` folder → run Apply Changes to push topics and settings → then re-add the variable file(s) and run Apply Changes again. Global variables work at runtime without the declaration file — `SetVariable` actions create them dynamically. The `.variable.mcs.yml` file is needed only for VS Code IntelliSense. |

### 2a — Duplicate component error after copying template files into a cloned folder

**Symptom:** Apply Changes fails with a duplicate component error, or extra unexpected topics appear after copying files from `base/` or `components/` into a cloned agent folder.

**Root cause — naming mismatch between Clone Agent output and templates:**

Clone Agent downloads topics without the `.topic.` prefix:

```
agents/HR Assistant/topics/Greeting.mcs.yml       ← what Clone Agent creates
base/topics/Greeting.topic.mcs.yml                ← what the templates use
```

A plain `cp base/topics/Greeting.topic.mcs.yml agents/HR Assistant/topics/` creates a NEW file alongside the existing `Greeting.mcs.yml`. Both files contain `mcs.metadata.componentName: Greeting`. Apply Changes sees two local definitions for the same cloud topic and errors.

**What conn.json has to do with it:** `conn.json` lives at `.mcs/conn.json` and is NOT overwritten by `cp` commands that only copy `.mcs.yml` files. The issue is the YAML component naming. The one scenario that DOES break `conn.json` is renaming or moving the entire clone folder — `conn.json` stores absolute paths and becomes invalid if the path changes. Fix: re-clone to get a fresh `conn.json` at the new path.

**Fix — copy topic files with rename (.topic.mcs.yml → .mcs.yml):**

```powershell
# PowerShell — replace "HR Assistant" with your agent's display name
$src   = "base\topics"
$clone = "agents\HR Assistant\topics"
Get-ChildItem "$src\*.topic.mcs.yml" | ForEach-Object {
    $dest = Join-Path $clone ($_.Name -replace '\.topic\.mcs\.yml', '.mcs.yml')
    Copy-Item $_.FullName $dest -Force
}
```

```bash
# Mac / Linux
src="base/topics"
clone="agents/HR Assistant/topics"
for f in "$src"/*.topic.mcs.yml; do
    base=$(basename "$f" .topic.mcs.yml)
    cp "$f" "$clone/$base.mcs.yml"
done
```

**Alternative — delete cloned topic files first, then copy:**
```powershell
Remove-Item "agents\HR Assistant\topics\*.mcs.yml" -Force
Copy-Item "base\topics\*.topic.mcs.yml" "agents\HR Assistant\topics\" -Force
```

**Files NOT affected by this issue:**
- `agent.mcs.yml` and `settings.mcs.yml` — same filenames in clone and templates, plain `cp` overwrites correctly
- Knowledge sources, actions, variables, new custom topics — Clone Agent does not download these, so there is no existing file to conflict with; plain `cp` works

**pac copilot create and conn.json:**
`pac copilot create` creates the agent in the cloud but does NOT create the local `.mcs/conn.json`. You must run Clone Agent afterward to establish the local connection. If `pac copilot create` succeeded but you skipped Clone Agent: `Ctrl+Shift+P` → "Copilot Studio: Clone Agent" → select the newly created agent.

---

## 3 — Topics Not Triggering Correctly

### Unexpected card or prompt appears at the start of every conversation

**Cause:** An `AdaptiveCardPrompt` or `Question` node was left in the `ConversationStart.mcs.yml` topic — usually added during testing and not removed. Because `ConversationStart` fires `OnConversationStart` (every new conversation), any prompt node inside it fires every single time.

**Fix:** Open `topics/ConversationStart.mcs.yml` and remove everything after the `SendActivity` greeting node. The topic should contain only the welcome message:

```yaml
beginDialog:
  kind: OnConversationStart
  id: main
  actions:
    - kind: SendActivity
      id: sendMessage_xxxxxx
      activity:
        text:
          - Hello, I'm {System.Bot.Name}. How can I help?
```

Remove any `AdaptiveCardPrompt`, `Question`, or other nodes below it. Run Apply Changes.

---

### Greeting does not appear automatically when chat opens

**Cause:** The Greeting topic uses `kind: OnRecognizedIntent` (fires when user types "Hello") instead of `kind: OnConversationStart` (fires automatically when the conversation begins).

Check your `Greeting.topic.mcs.yml` line 6. If it says `OnRecognizedIntent`, change it to `OnConversationStart` and remove the `intent:` and `triggerQueries:` blocks — they are not needed for a conversation-start trigger. Example:

```yaml
beginDialog:
  kind: OnConversationStart   # ← was OnRecognizedIntent
  id: main
  actions:
    - kind: SendActivity
      ...
```

Then run VS Code → Apply Changes.

---

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
3. Apply changes via VS Code → "Copilot Studio: Apply Changes"

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

## 9 — Portal Canvas Rendering Issues

These are cases where the YAML is valid and the data is correctly stored in the cloud, but the Copilot Studio portal visual canvas does not render nodes correctly.

---

### Topic actions stop rendering after a `LogCustomTelemetryEvent` node — subsequent nodes (ConditionGroup, SendActivity, etc.) are invisible on the canvas

**Cause:** The `properties` field on `LogCustomTelemetryEvent` uses a YAML folded block scalar (`>-`). The Copilot Studio portal canvas renderer cannot determine where the scalar ends and silently drops all subsequent action nodes from the visual canvas. The data IS correctly stored in the cloud — `botdefinition.json` will show the full content — but the canvas shows only the telemetry node and nothing after it.

This affects any topic where `LogCustomTelemetryEvent` is **not** the last action node.

**Symptom:** Canvas shows: `Trigger → Log telemetry → ○ (end)` — everything after the telemetry node is invisible.

**Diagnosis:** Check your topic YAML for this pattern:

```yaml
- kind: LogCustomTelemetryEvent
  id: logXxx_xxxxxx
  eventName: Agent.SomeEvent
  properties: >-        ← THIS causes the rendering bug
    ={
      Key: Value,
      ...
    }

- kind: ConditionGroup  ← this and everything below won't render
```

**Fix:** Convert `properties: >-` to a single-line double-quoted string:

```yaml
- kind: LogCustomTelemetryEvent
  id: logXxx_xxxxxx
  eventName: Agent.SomeEvent
  properties: "={Key: Value, Key2: Value2, Key3: Value3}"   ← single line, double-quoted
```

Then run Apply Changes. The canvas will render all nodes correctly after the push.

> **Note:** The base/ templates have been updated to use the single-line format. If you copied a topic from an older version of the templates, check for `properties: >-` in any `LogCustomTelemetryEvent` node.

---

### `agent.mcs.yml` — instructions, conversation starters, or AI model not appearing in the Copilot Studio UI

**Cause:** The `instructions:`, `conversationStarters:`, and `aISettings:` fields in `agent.mcs.yml` are indented (e.g. 2 spaces) instead of being at the root level (0 spaces). The Copilot Studio parser reads `kind: GptComponentMetadata` and looks for `instructions` at the root mapping level. If it is indented, the parser silently ignores it — no error is raised, and the UI shows blank instructions.

**Symptom:** The Overview tab in the portal shows no instructions text. Conversation starters are missing. AI model setting appears to be default regardless of what's in the file.

**Diagnosis:** Open `agent.mcs.yml` and check indentation:

```yaml
# BROKEN — instructions is at 2-space indent, parser ignores it
kind: GptComponentMetadata

  instructions: |       ← 2 spaces — WRONG
    Your prompt...

  conversationStarters: ← 2 spaces — WRONG
    - title: ...

# CORRECT — all fields at column 0
kind: GptComponentMetadata

instructions: |         ← 0 spaces — correct
  Your prompt...

conversationStarters:   ← 0 spaces — correct
  - title: ...
```

**Fix:** Ensure `instructions:`, `conversationStarters:`, and `aISettings:` are all at column 0 (no leading spaces). The block content under `instructions: |` should be indented 2 spaces relative to the key. Run Apply Changes after fixing.

Also check for line-wrap bugs inside the `instructions` block — if a sentence wraps to a line with less indentation than the block content level, YAML terminates the block early and the rest of the instructions are truncated.

---

## 10 — Test Canvas vs Published Behaviour Differs

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

## 11 — General Tips and Diagnostics

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

---

## pac CLI Common Errors

### `pac copilot publish` — "Copilot with ID 'x' not found"

**Cause:** `--bot` does not accept the schema name (e.g. `hr_assistant`). It requires the **display name** or **Copilot ID**.

```powershell
pac copilot list                          # find the display name and Copilot ID
pac copilot publish --bot "HR Assistant"  # use display name (quote if it has spaces)
# or
pac copilot publish --bot "39cf38ed-3416-456d-be4e-b2cc9d426bbb"  # use Copilot ID
```

---

### `pac copilot extract-template` — "No bots were found using search pattern 'HR Assistant'"

**Cause:** `--bot` on `extract-template` also does NOT accept the display name. It requires the **schema name** or **Copilot ID**.

```powershell
pac copilot list                          # find the Copilot ID column
pac copilot extract-template --bot "f1714949-c144-f111-88b5-00224809a00b" --templateFileName "agents\hr_assistant\template.yaml"
```

---

### `pac copilot create` — template file not found

**Cause 1 — Wrong working directory.** The command resolves the path relative to where you run it.
```powershell
# Run from repo root:
cd C:\projects\templates\copilot-studio-templates
pac copilot create --displayName "HR Assistant" --schemaName "hr_assistant" --solution "Default" --templateFileName "agents\hr_assistant\template.yaml"
```

**Cause 2 — Output folder doesn't exist yet.** Create it before extracting:
```powershell
New-Item -ItemType Directory -Force -Path "agents\hr_assistant"
pac copilot extract-template --bot "<copilot-id>" --templateFileName "agents\hr_assistant\template.yaml"
```

**Cause 3 — No existing agent to extract from.** `pac copilot create` requires a template extracted from an existing agent. If you have no agents yet, create the first one via browser: make.preview.microsoft.com → Create → New blank agent.

---

### `pac copilot create` — backslash line continuation fails

**Cause:** PowerShell uses backtick (`` ` ``) for line continuation, not backslash (`\`). Keep the command on one line:
```powershell
pac copilot create --displayName "HR Assistant" --schemaName "hr_assistant" --solution "Default" --templateFileName "agents\hr_assistant\template.yaml"
```

---

### PowerShell node ID script — infinite loop / `-replace` error

**Cause:** PowerShell's `-replace` operator only takes 2 arguments, not 3. Using `-replace pattern, replacement, count` causes an error or infinite loop.

**Fix:** Use `[regex]::Replace()` for count-limited replacement:
```powershell
$content = [regex]::Replace($content, '_REPLACE\d*', "_$id", 1)   # replaces ONE match at a time
```
Not:
```powershell
$content = $content -replace '_REPLACE\d*', "_$id", 1   # ERROR — 3 args not supported
```

---

### `grep` not found on Windows

**Cause:** `grep` is a Linux/Mac command. Use `Select-String` in PowerShell instead:
```powershell
# Windows equivalent of: grep -rn "_REPLACE" agents/hr_assistant --include="*.mcs.yml"
Get-ChildItem -Recurse -Filter "*.mcs.yml" -Path "agents\hr_assistant" | Select-String "_REPLACE" | Select-Object Filename, LineNumber, Line
```

---

## `pac copilot push` Does Not Exist

**Cause:** `pac copilot push` is not a pac CLI command. There is no npm package that adds it.

**What to use instead:**
- To push YAML edits to an existing agent: **VS Code → Ctrl+Shift+P → "Copilot Studio: Apply Changes"**
- To create a new agent from a template YAML: `pac copilot create --displayName "X" --schemaName "x" --solution "Default" --templateFileName file.yaml`
- To publish a draft to live: `pac copilot publish --bot "<display name or Copilot ID>"`
