# Topic Components

Each folder is an independent topic that you add to your agent as needed.

## Available Topics

| Component | Trigger | What it does |
|-----------|---------|-------------|
| [`action-invoke/`](action-invoke/) | `OnRecognizedIntent` | Calls an action with output validation and telemetry |
| [`auth/`](auth/) | `OnSignIn` | OAuth sign-in flow with telemetry |
| [`conversation-init/`](conversation-init/) | `OnActivity` (first message) | Loads M365 user profile with safe fallback defaults |
| [`disambiguation/`](disambiguation/) | `OnSelectIntent` | Asks the user to clarify when multiple topics match |
| [`escalation/`](escalation/) | `OnRecognizedIntent` | Human handoff via `TransferConversation` |
| [`knowledge-search/`](knowledge-search/) | `OnUnknownIntent` | Generative answers from knowledge sources |
| [`out-of-scope/`](out-of-scope/) | `OnRecognizedIntent` | Redirects clearly out-of-scope queries |
| [`question-branch/`](question-branch/) | `OnRecognizedIntent` | Collects user input and branches the conversation |
| [`remove-citations/`](remove-citations/) | `OnGeneratedResponse` | Strips `[1][2]` citation markers from AI responses |

## How to add a topic to your agent

1. Copy the component folder into your agent project
2. Replace all `<PLACEHOLDER>` values
3. Replace all `_REPLACE` node ID suffixes with unique 6-character strings
4. Replace `<AGENT_SCHEMA>` with your agent's `schemaName` from `settings.mcs.yml`
5. Push with `pac copilot push`

Each component has its own README with specific setup instructions.
