# Component: Auth — Sign In

Handles the authentication flow when a user needs to sign in to the agent.

## When to Use

Add this component when:
- `settings.mcs.yml` has `authenticationMode: ManualAzureAD`
- The agent needs to identify the user (to personalise responses, check permissions, or call APIs on their behalf)

Do **not** add this component when:
- `authenticationMode: None` (anonymous agent)
- `authenticationMode: IntegratedAzureAD` (SSO — user identity is already available via `System.User.*` without a sign-in prompt)

## File

| File | Purpose |
|------|---------|
| `SignIn.topic.mcs.yml` | OnSignIn trigger — prompts the user to authenticate via OAuthInput |

## What to Replace

| Placeholder | Replace with |
|-------------|-------------|
| `_REPLACE` suffixes | Unique random strings (e.g. `_a1b2c3`) |

## How It Works

1. Fires when `System.SignInReason = SignInRequired` (not on token refreshes)
2. Sends a polite prompt explaining why sign-in is needed
3. Presents the `OAuthInput` card — the user clicks and authenticates via Azure AD
4. After successful sign-in, the conversation continues from where it left off

## After Sign-In

Once signed in, use `System.User.DisplayName`, `System.User.Id`, and `System.User.Email` in your topics. For richer M365 profile data (job title, country, manager), combine with the [`conversation-init`](../conversation-init/) component.

## Gotchas

- The OAuthInput connection must be configured in the agent's connection settings in Copilot Studio
- Sign-in is per-conversation, not per-session — users may need to sign in again after inactivity
- If using in Teams with `IntegratedAzureAD`, this topic is unnecessary and will never trigger
