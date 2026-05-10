# AI Prompt: Generate a Topic YAML

Use this prompt to generate a complete `.topic.mcs.yml` file from a user scenario description.

---

## Prompt Template

```
You are a Copilot Studio YAML specialist. Generate a complete `.topic.mcs.yml` file for the scenario below.

Rules:
- Use the `AdaptiveDialog` kind with `OnRecognizedIntent` trigger
- Include a minimum of 6 trigger phrases covering formal, informal, and abbreviated phrasings
- Use the `action-invoke` pattern if the topic needs to call a connector action:
  - BeginDialog to invoke the action
  - ConditionGroup checking !IsBlank(Topic.ActionResponse) for success/failure branches
  - LogCustomTelemetryEvent at topic start, action success, and action failure
- Use the `question-branch` pattern if the topic only collects input and branches on the answer
- Replace all IDs with `_REPLACE` suffix (the developer will generate unique IDs)
- Replace all content-specific values with `<PLACEHOLDER>` in angle brackets
- Add YAML comments (# lines) explaining each major section
- Include `LogCustomTelemetryEvent` at the start of the topic (eventName: Topic.Started)

Scenario:
[DESCRIBE THE USER SCENARIO IN PLAIN ENGLISH]

Topic name: [display name for the topic]
Action needed: [Yes — describe the connector action / No — just collect and respond]
Auth mode: [None / ManualAzureAD / IntegratedAzureAD]
Agent schema name: [schemaName from settings.mcs.yml]
```

---

## Example Input

```
Scenario: An employee wants to check their remaining annual leave balance.
The agent should ask for confirmation ("your leave as of today"), then call the HR system to get the balance and show it.

Topic name: Get Leave Balance
Action needed: Yes — InvokeConnectorAction on Dataverse to read leave balance
Auth mode: IntegratedAzureAD
Agent schema name: hr_assistant
```

## Example Output

```yaml
# Name: Get Leave Balance
# Trigger: User asks how much annual leave they have remaining
# Purpose: Retrieves the signed-in employee's leave balance from Dataverse and displays it
# NOTE: Replace all _REPLACE suffixes with unique random strings before use
kind: AdaptiveDialog
beginDialog:
  kind: OnRecognizedIntent
  id: main
  intent:
    displayName: Get Leave Balance
    triggerQueries:
      - how many days of leave do I have left
      - what is my leave balance
      - check my annual leave
      - how much holiday do I have
      - remaining leave days
      - leave entitlement

  actions:
    - kind: LogCustomTelemetryEvent
      id: logTopicStarted_REPLACE1
      eventName: Topic.Started
      properties: "={TopicName: \"Get Leave Balance\", UserQuery: System.Activity.Text, ConversationId: System.Conversation.Id, TimeUTC: Text(Now(), DateTimeFormat.UTC)}"

    - kind: SendActivity
      id: sendWorking_REPLACE2
      activity: Let me check your leave balance...

    - kind: BeginDialog
      id: invokeAction_REPLACE3
      dialog: hr_assistant.topic.GetLeaveBalance
      output:
        binding:
          Response: Topic.ActionResponse

    - kind: ConditionGroup
      id: conditionGroup_REPLACE4
      conditions:
        - id: conditionItem_REPLACE5
          condition: =!IsBlank(Topic.ActionResponse)
          actions:
            - kind: SendActivity
              id: sendSuccess_REPLACE6
              activity: "Here's your leave balance: {Topic.ActionResponse}"

            - kind: LogCustomTelemetryEvent
              id: logSuccess_REPLACE7
              eventName: Action.Succeeded
              properties: "={TopicName: \"Get Leave Balance\", ConversationId: System.Conversation.Id, TimeUTC: Text(Now(), DateTimeFormat.UTC)}"

      elseActions:
        - kind: SendActivity
          id: sendError_REPLACE8
          activity: I wasn't able to retrieve your leave balance right now. Please try again or contact HR directly.

        - kind: LogCustomTelemetryEvent
          id: logFailed_REPLACE9
          eventName: Action.Failed
          properties: "={TopicName: \"Get Leave Balance\", ConversationId: System.Conversation.Id, TimeUTC: Text(Now(), DateTimeFormat.UTC)}"
```

---

## Prompt Variation: Generate trigger phrases only

```
Generate 10 trigger phrases for a Copilot Studio topic named "[Topic Name]".
The topic handles: [describe what the topic does in one sentence].
Include: formal phrasings, casual phrasings, abbreviated phrasings, and question variations.
Output as a YAML list (- phrase format).
```

## Prompt Variation: Generate conversation starters

```
Generate 4 conversation starter buttons for a Copilot Studio agent.
The agent handles: [describe the agent's domain].
The most common user tasks are: [list 4 tasks].
Format:
- title: [short button label, max 4 words]
  text: [the message sent when clicked, natural language, 5-10 words]
```
