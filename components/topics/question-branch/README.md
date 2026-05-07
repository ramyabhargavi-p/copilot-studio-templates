# Question Branch Topic

**Trigger:** `OnRecognizedIntent`
**Telemetry:** `Topic.Started` (via scaffold)

Collects one or more inputs from the user and branches the conversation based on the answers. Use for multi-path flows — e.g., "Do you need to reset a password or report a hardware issue?"

## Files

| File | Purpose |
|------|---------|
| `QuestionBranch.topic.mcs.yml` | Question node + ConditionGroup branching + telemetry |

## Quick start

```bash
cp components/topics/question-branch/QuestionBranch.topic.mcs.yml \
   agents/<your-agent>/topics/<TopicName>.topic.mcs.yml
```

Edit the `Question` node for your input and update the `ConditionGroup` branches for each answer path.
