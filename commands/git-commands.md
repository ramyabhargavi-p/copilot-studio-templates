# Git Commands — Full Reference for Copilot Studio Dev

All git commands used in Copilot Studio agent development, from repo setup to CI/CD promotion.

---

## 1. Install Git

```bash
# Windows — via winget
winget install Git.Git

# Verify
git --version
# Expected: git version 2.X.X
```

---

## 2. First-Time Setup (once per machine)

```bash
# Set your identity (shows in commit history)
git config --global user.name "Your Name"
git config --global user.email "you@org.com"

# Set default branch name to main
git config --global init.defaultBranch main

# Confirm settings
git config --global --list
```

---

## 3. Start a New Agent Project

```bash
# Clone this templates repo
git clone <REPO_URL> copilot-studio-templates
cd copilot-studio-templates

# Create a new branch for your agent
git checkout -b feature/hr-assistant

# Copy base template to start your agent
cp -r base/ agents/hr-assistant/

# Check what files you've added
git status
```

---

## 4. Everyday Development Workflow

```bash
# See what's changed since last commit
git status

# See exact line-by-line changes
git diff

# Stage specific files (preferred — avoids accidentally committing secrets)
git add agents/hr-assistant/agent.mcs.yml
git add agents/hr-assistant/topics/HRPolicy.topic.mcs.yml

# Stage all changes in the agent folder
git add agents/hr-assistant/

# Commit with a clear message
git commit -m "add HR policy topic with escalation and telemetry"

# Push your branch to remote
git push origin feature/hr-assistant
```

---

## 5. Branch Strategy — Dev → UAT → Prod

```
main           ← production-ready code, protected branch
  └── uat      ← UAT-tested code
        └── dev  ← active development
              └── feature/hr-assistant  ← your work branch
```

```bash
# Create your feature branch off dev
git checkout dev
git checkout -b feature/hr-assistant

# When feature is done — merge to dev
git checkout dev
git merge feature/hr-assistant

# Promote dev → uat (after QA sign-off)
git checkout uat
git merge dev
git push origin uat

# Promote uat → main (after UAT sign-off)
git checkout main
git merge uat
git push origin main
git tag v1.0.0        # tag the production release
git push origin v1.0.0
```

---

## 6. Pulling Updates from Remote

```bash
# Pull latest changes on current branch
git pull

# Pull a specific branch
git pull origin dev

# Fetch all remote changes without merging
git fetch --all

# See all branches (local + remote)
git branch -a
```

---

## 7. Reviewing Changes Before Committing

```bash
# See all changed files
git status

# See changes in a specific file
git diff agents/hr-assistant/agent.mcs.yml

# See what's staged (about to be committed)
git diff --staged

# See commit history
git log --oneline -10

# See who changed what in a file
git blame agents/hr-assistant/topics/HRPolicy.topic.mcs.yml
```

---

## 8. Undoing Changes

```bash
# Discard changes to a single file (NOT yet staged)
git checkout -- agents/hr-assistant/agent.mcs.yml

# Unstage a file (staged but not committed)
git restore --staged agents/hr-assistant/agent.mcs.yml

# Undo the last commit but keep the changes as uncommitted
git reset --soft HEAD~1

# See what the file looked like in a previous commit
git show HEAD~2:agents/hr-assistant/agent.mcs.yml
```

---

## 9. Working with Tags (production releases)

```bash
# Create a version tag
git tag v1.0.0
git tag v1.1.0 -m "added knowledge source for IT policy docs"

# Push tags to remote (triggers publish-on-release CI/CD pipeline)
git push origin v1.0.0
git push --tags       # push all tags at once

# List all tags
git tag -l

# Delete a tag (local + remote)
git tag -d v1.0.0
git push origin --delete v1.0.0
```

---

## 10. .gitignore — What to Exclude

Create a `.gitignore` in the root of your agent repo:

```
# Never commit these
.env
*.secret
*credentials*
*client-secret*

# pac CLI auth files
.pac/

# VS Code local settings (optional — keep if team shares settings)
.vscode/settings.json

# OS files
.DS_Store
Thumbs.db
```

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Clone repo | `git clone <URL>` |
| New branch | `git checkout -b feature/name` |
| See changes | `git status` |
| Stage files | `git add agents/my-agent/` |
| Commit | `git commit -m "message"` |
| Push branch | `git push origin feature/name` |
| Merge to dev | `git checkout dev && git merge feature/name` |
| Promote to UAT | `git checkout uat && git merge dev` |
| Promote to Prod | `git checkout main && git merge uat` |
| Tag release | `git tag v1.0.0 && git push origin v1.0.0` |
| Pull latest | `git pull` |
| Undo unstaged | `git checkout -- <file>` |
