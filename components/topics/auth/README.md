# Auth Topic

**Trigger:** `OnSignIn`
**Telemetry:** `Auth.SignInStarted`, `Auth.SignInCompleted`

Handles the sign-in flow. Fires when the user needs to authenticate before accessing a personalised or restricted capability.

## Files

| File | Purpose |
|------|---------|
| `SignIn.topic.mcs.yml` | Sign-in topic with OAuthInput node and telemetry |

## Quick start

```bash
cp components/topics/auth/SignIn.topic.mcs.yml \
   agents/<your-agent>/topics/SignIn.topic.mcs.yml
```

**Requires:** `authenticationMode: ManualAzureAD` or `IntegratedAzureAD` in `settings.mcs.yml`.

→ Full authentication recipe: [`../../../recipes/02-authenticated-agent.md`](../../../recipes/02-authenticated-agent.md)
→ Sign-in troubleshooting: [`../../../troubleshooting/README.md`](../../../troubleshooting/README.md)
