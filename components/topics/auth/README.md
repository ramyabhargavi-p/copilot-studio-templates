# auth — Sign-In Topic

Handles the user sign-in flow for agents that require authentication before accessing personalised or restricted data.

## When to use

| Add this topic | Don't add it |
|---|---|
| `authenticationMode: ManualAzureAD` in `settings.mcs.yml` | `authenticationMode: Integrated` — sign-in is automatic; this topic is redundant |
| Agent calls connectors that need a signed-in user identity | Anonymous agents with no personalisation |
| You need `Auth.SignInStarted` / `Auth.SignInCompleted` telemetry | — |

## Quick start

```bash
cp components/topics/auth/SignIn.topic.mcs.yml \
   agents/hr_assistant/topics/SignIn.topic.mcs.yml
```

> **Node IDs:** Replace every `_REPLACE` suffix with a unique string before use — see [QUICKSTART.md → Replace node IDs](../../../docs/QUICKSTART.md).

## Placeholders

Only `_REPLACE1–6` — no manual placeholders.

## Prerequisites checklist

- [ ] `authenticationMode: ManualAzureAD` is set in `settings.mcs.yml`
- [ ] Azure AD app registration exists with the required scopes (e.g. `User.Read`, `Files.Read`)
- [ ] App registration client ID and tenant ID are configured in the Copilot Studio authentication settings

## How it works

1. Agent detects an unauthenticated user (system fires `OnSignIn`)
2. `SignIn.topic.mcs.yml` sends an `OAuthInput` card prompting the user to sign in
3. On success: logs `Auth.SignInCompleted`; conversation continues
4. On failure: logs `Auth.SignInStarted` (no completion); user sees an error message

## Common mistakes

- **Adding to an Integrated agent** — Azure AD SSO happens automatically; this topic causes a double sign-in prompt
- **Forgetting to configure the authentication connection** in Copilot Studio settings — the `OAuthInput` node will have no connection to reference
- **Manually triggering this topic** — it should only fire via the `OnSignIn` system event, never called via `BeginDialog` from another topic

→ Full authentication recipe: [`../../../recipes/02-authenticated-agent.md`](../../../recipes/02-authenticated-agent.md)
→ Sign-in troubleshooting: [`../../../troubleshooting/README.md`](../../../troubleshooting/README.md)
