# PII Scrubbing Guide

How to prevent personally identifiable information from entering telemetry, logs, and storage in Copilot Studio agents.

> **When to use this doc:** Before connecting telemetry (Application Insights) to an agent that
> handles any user-identifiable information. Required checkpoint in the governance checklist.
> Also review when adding new topic inputs that collect names, emails, IDs, or account numbers.

---

## What Counts as PII

| Category | Examples | Risk |
|----------|----------|------|
| Identity | Display name, email, UPN, employee ID | Direct identification |
| Location | Country, city, office, home address | Indirect identification |
| Contact | Phone number, Teams ID, personal email | Direct identification |
| Financial | Salary, leave balance amounts | Sensitive personal data |
| Health | Medical leave reason, disability info | Special category (GDPR Art. 9) |
| Free text | Any `Question` node answer, feedback text | May contain any of the above |

---

## Rule 1 — Never Log These in Telemetry

These fields must never appear in any `LogCustomTelemetryEvent` `properties` block:

```yaml
# NEVER include any of these:
UserDisplayName: =Global.UserDisplayName          # PII — display name
UserEmail: =System.User.PrincipalName             # PII — email/UPN
UserCountry: =Global.UserCountry                  # PII — location
UserAnswer: =Topic.UserInput                      # PII — free-form text
FeedbackText: =Topic.TextResponse.feedbackText    # PII — free-form text
ErrorMessage: =System.Error.Message               # May contain stack traces with data

# SAFE to log:
ConversationId: =System.Conversation.Id           # Hashed session ID
Channel: =System.Activity.Channel                 # Teams / Web / DirectLine
ErrorCode: =System.Error.Code                     # Numeric code only
TimeUTC: =Text(Now(), DateTimeFormat.UTC)          # Timestamp
TopicName: "<MyTopic>"                             # Hard-coded string literal
ActionName: "<MyAction>"                           # Hard-coded string literal
```

### Safe User Identity — Hashed Only

`System.User.Id` is a hashed identifier, not a raw UPN. It is safe to log for correlation:

```yaml
properties: "={UserId: System.User.Id, ConversationId: System.Conversation.Id, Channel: System.Activity.Channel, TimeUTC: Text(Now(), DateTimeFormat.UTC)}"
```

---

## Rule 2 — Mask Free-Text Before Logging

If you must log user input (e.g. for quality sampling), apply a masking expression before logging. Never log raw `System.Activity.Text` or any `Question` node variable.

**Truncate to first 20 characters (shows intent, hides sensitive detail):**

```yaml
# Power Fx — safe preview only
UserQueryPreview: =Left(System.Activity.Text, 20)
```

**Strip digits (removes phone numbers, ID numbers, account numbers):**

> **Note:** Power Fx `Substitute` does not support regex — the pattern below is illustrative only and will not run as written. For real digit-stripping, route telemetry through a custom connector or Azure Function with a regex pipeline before writing to Application Insights.

```yaml
# Illustrative only — not valid Power Fx (Substitute does not support regex)
UserQuerySanitised: =Substitute(System.Activity.Text, "[0-9]+", "***")
```

**Best practice — log category, not content:**

```yaml
# Log the classified topic, never the raw query
IntentCategory: "<TopicName>"
```

---

## Rule 3 — Global Variable Visibility

Variables that hold PII must use `aIVisibility: Hidden`. This prevents the AI orchestrator from reading or surfacing the value in responses.

```yaml
# global-variable.variable.mcs.yml
aIVisibility: Hidden     # CORRECT — PII fields must be Hidden
# aIVisibility: UseInAIContext   # NEVER for PII fields
```

Audit all variables containing: name, email, country, address, phone, salary, balance, reason.

---

## Rule 4 — Feedback Free-Text Handling

The `Feedback.topic.mcs.yml` collects optional free-text from users. This text may contain PII.

**What to do:**

1. Log only the `feedbackCategory` (dropdown value) and `ratingScore` — never the raw `feedbackText`
2. If `feedbackText` is stored anywhere, apply a 90-day retention policy
3. Restrict access to raw feedback text to named reviewers only (not all-tenant)
4. Never include `feedbackText` in any automated dashboard or Power BI report

```yaml
# CORRECT — category and score only in automated telemetry
- kind: LogCustomTelemetryEvent
  eventName: Feedback.Text
  properties:
    feedbackCategory: =Topic.TextResponse.feedbackCategory   # dropdown value — safe
    ratingScore: =Text(Topic.RatingScore)                    # numeric — safe
    conversationId: =System.Conversation.Id
    # feedbackText deliberately omitted — may contain PII
```

---

## Application Insights Configuration

### Telemetry Processor — Strip PII Fields at Ingestion

Add a telemetry processor in your Application Insights resource to drop or hash known PII fields before they land in the data store.

**Azure Function telemetry processor (C#):**

```csharp
public class PiiScrubProcessor : ITelemetryProcessor
{
    private static readonly HashSet<string> _piiFields = new()
    {
        "UserDisplayName", "UserEmail", "UserCountry",
        "UserAnswer", "FeedbackText", "ErrorMessage"
    };

    public void Process(ITelemetry item)
    {
        if (item is EventTelemetry evt)
        {
            foreach (var field in _piiFields)
            {
                if (evt.Properties.ContainsKey(field))
                    evt.Properties.Remove(field);
            }
        }
        Next.Process(item);
    }
}
```

**Register in Startup.cs:**

```csharp
services.AddApplicationInsightsTelemetryProcessor<PiiScrubProcessor>();
```

### Workspace-Level Data Masking (Log Analytics)

In your Log Analytics workspace, use **Workspace transformation rules** to mask columns before storage:

```kql
// Transformation rule on customEvents table
customEvents
| extend properties = bag_remove_keys(properties, dynamic(["UserDisplayName","UserEmail","UserCountry"]))
```

Set this in Azure Portal: **Log Analytics workspace → Tables → customEvents → Edit transformation**.

### Data Export Exclusions

When configuring continuous export from Application Insights to a storage account or Event Hub, exclude the `customDimensions` fields flagged as PII by creating a custom export rule that filters those columns.

---

## Power Platform DLP Policies

Data Loss Prevention (DLP) policies enforce which connectors can share data with each other, preventing PII from flowing between systems without authorisation.

### Recommended DLP Configuration

**Block these cross-boundary flows for agents handling personal data:**

| Connector | Business Group | Why |
|-----------|---------------|-----|
| Office 365 Users | Business | Contains user profile data |
| SharePoint | Business | May contain HR/financial docs |
| HTTP (custom) | Non-Business | Prevent arbitrary data exfiltration |
| Email (Outlook) | Business | Can exfiltrate free-form content |

**Set in Power Platform Admin Center:**

1. Admin Center → **Data policies** → **New policy**
2. Name: `<AgentName> — PII Boundary`
3. Move `Office 365 Users`, `SharePoint`, `Dataverse` to **Business** group
4. Move `HTTP`, `Azure Blob Storage` to **Non-Business** (blocks cross-boundary sharing)
5. Apply to the agent's environment

### Block User Profile Data Leaving the Tenant

```
Admin Center → Environments → <your env> → Data policies → Assign policy
```

This prevents the Office 365 Users connector from sharing profile data with non-business connectors.

---

## Audit Commands

Run these to find PII risks before every release:

```powershell
# Windows PowerShell
Get-ChildItem -Recurse -Filter "*.mcs.yml" | Select-String "UserDisplayName|UserEmail|UserCountry|\.country|\.mail|\.displayName" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" | Select-String "System\.Activity\.Text|Topic\.\w*[Ii]nput|Topic\.\w*[Aa]nswer" | Where-Object { $_ -notmatch "TopicName|ActionName" } | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" | Select-String "System\.Error\.Message|Error\.Message" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" | Select-String "aIVisibility: UseInAIContext" | Select-Object Filename, LineNumber, Line
Get-ChildItem -Recurse -Filter "*.mcs.yml" | Select-String "feedbackText|TextResponse" | Where-Object { $_ -notmatch "feedbackCategory" } | Select-Object Filename, LineNumber, Line
```

```bash
# Mac / Linux
grep -rn "UserDisplayName\|UserEmail\|UserCountry\|\.country\|\.mail\|\.displayName" --include="*.mcs.yml" .
grep -rn "System.Activity.Text\|Topic\.\w*[Ii]nput\|Topic\.\w*[Aa]nswer" --include="*.mcs.yml" . | grep -v "TopicName\|ActionName"
grep -rn "System.Error.Message\|Error\.Message" --include="*.mcs.yml" .
grep -rn "aIVisibility: UseInAIContext" --include="*.mcs.yml" .
grep -rn "feedbackText\|TextResponse" --include="*.mcs.yml" . | grep -v "feedbackCategory"
```

**Expected results:**
- Lines 1–3: zero matches (any match is a PII leak)
- Line 4: review each match — confirm it's a non-PII variable
- Line 5: confirm `feedbackText` never appears in `LogCustomTelemetryEvent`

---

## Checklist — Before Going Live

| Check | How |
|-------|-----|
| No user profile fields in telemetry | Run audit command 1 above |
| No raw user input in telemetry | Run audit command 2 above |
| `System.Error.Code` used (not `.Message`) | Run audit command 3 above |
| All PII global variables set to `aIVisibility: Hidden` | Run audit command 4 above |
| `feedbackText` excluded from telemetry events | Run audit command 5 above |
| DLP policy applied to agent environment | Power Platform Admin Center |
| Application Insights telemetry processor deployed | Azure Portal |
| Feedback free-text access restricted to named reviewers | Azure RBAC on Log Analytics |
| Retention policy ≤ 90 days on feedback raw data | Log Analytics → Retention settings |

---

## Related Files

- [`base/topics/OnError.topic.mcs.yml`](../base/topics/OnError.topic.mcs.yml) — uses `System.Error.Code` (not `.Message`)
- [`components/topics/conversation-init/ConversationInit.topic.mcs.yml`](../components/topics/conversation-init/ConversationInit.topic.mcs.yml) — profile fields stored in global vars but not logged
- [`components/topics/feedback/Feedback.topic.mcs.yml`](../components/topics/feedback/Feedback.topic.mcs.yml) — feedbackText not logged to Application Insights; only feedbackCategory (dropdown value) is captured in telemetry
- [`components/variables/global-variable/global-variable.variable.mcs.yml`](../components/variables/global-variable/global-variable.variable.mcs.yml) — default `aIVisibility: Hidden`
- [`ACTION-SAFETY-PATTERNS.md`](ACTION-SAFETY-PATTERNS.md) — safety tiers for write/destructive actions
