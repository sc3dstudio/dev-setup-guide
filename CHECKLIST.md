# Checklist

Every step, in order, with the command that proves it worked. Use this when you set up a machine and you want to see the whole thing on one page.

Keep it open beside [01-human-setup.md](01-human-setup.md), which explains each step.

---

## 1. Tools

- [ ] Open PowerShell
- [ ] Install the six tools

```powershell
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
winget install --id Python.Python.3.12 -e --accept-source-agreements --accept-package-agreements
winget install --id astral-sh.uv -e --accept-source-agreements --accept-package-agreements
winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements
winget install --id BurntSushi.ripgrep.MSVC -e --accept-source-agreements --accept-package-agreements
```

- [ ] **Close PowerShell and open it again** (required, not optional)
- [ ] Every command below prints a version

```powershell
git --version; node -v; npm -v; python --version; uv --version; gh --version
```

**Note:** the command is `python`, never `python3`, on Windows.

---

## 2. Dev folder

- [ ] Created, and not inside OneDrive

```powershell
$DevRoot = Join-Path $env:USERPROFILE 'Dev'
New-Item -ItemType Directory -Force -Path $DevRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DevRoot '_sandbox') | Out-Null
Test-Path $DevRoot
```

- [ ] `Test-Path` printed `True`
- [ ] The path is `C:\Users\<your-name>\Dev` and **not** inside `OneDrive`

**Why this matters:** OneDrive syncing `node_modules` and `.git` slows the machine and can corrupt a project.

---

## 3. Git identity

- [ ] Name, email and the three settings are set (replace the two values first)

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.longpaths true
git config --global core.autocrlf true
```

- [ ] Confirm:

```powershell
git config --global --list
```

**Use the email on your GitHub account.** Every commit carries it forever.

---

## 4. GitHub

- [ ] Run `gh auth login` and complete the browser step
- [ ] Run `gh auth setup-git`
- [ ] Confirm

```powershell
gh auth status
```

- [ ] It prints `Logged in to github.com`

**The browser step is yours.** Nobody, and no agent, should type your password.

---

## 5. ZCode

- [ ] Downloaded from `https://zcode.z.ai` and installed
- [ ] Opened, onboarding completed
- [ ] A model connected (bottom-left corner shows a model, not a **Connect** button)
- [ ] It answered this correctly:

```
List the files in the current directory.
```

---

## 6. MCP servers

Write the file with ZCode **closed**:

```powershell
notepad $env:USERPROFILE\.zcode\cli\config.json
```

- [ ] `notion` added under `mcp.servers`
- [ ] `blender-fork` added, **only if you use Blender**
- [ ] Paths use forward slashes `/`, not backslashes `\`
- [ ] Commas are correct, with none after the last entry
- [ ] Validate before reopening ZCode:

```powershell
Get-Content "$env:USERPROFILE\.zcode\cli\config.json" -Raw | ConvertFrom-Json | Out-Null
Write-Host "JSON is valid"
```

- [ ] It printed `JSON is valid`
- [ ] Reopened ZCode → **Settings → MCP** → each server is connected
- [ ] The agent sees the tools:

```
List every MCP tool you have, grouped by server name.
```

**If you use Blender:** Blender must be running, and the BlenderMCP add-on must be enabled under **Edit → Preferences → Add-ons**, before the Blender tools work.

**Before editing that file, back it up:**

```powershell
Copy-Item "$env:USERPROFILE\.zcode\cli\config.json" `
          "$env:USERPROFILE\.zcode\cli\config.json.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
```

---

## 7. Skills

- [ ] Skills folder exists

```powershell
Get-ChildItem "$env:USERPROFILE\.agents\skills" -Recurse -Filter SKILL.md |
  Select-Object -ExpandProperty FullName
```

- [ ] Each skill's `SKILL.md` is **directly** inside its folder (not one level deeper)
- [ ] Restarted ZCode → **Settings → Skills** lists them

**The most common mistake:**

```
OK   skills\my-skill\SKILL.md
BAD  skills\my-skill\my-skill\SKILL.md
```

---

## 8. Notion (optional)

- [ ] The `notion` MCP server is connected
- [ ] A browser sign-in was completed once and approved
- [ ] The agent can see pages:

```
List the Notion pages you can see, with their titles.
```

- [ ] If a shared library is involved, the right database is shared with your Notion account

See [reference/notion-access.md](reference/notion-access.md).

---

## 9. Final verification

- [ ] Run the check script

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
```

- [ ] Zero `FAIL` lines
- [ ] Every `WARN` is understood and accepted (they are optional things)

---

## 10. First working session

- [ ] Pasted the prompt from [START-PROMPT.md](START-PROMPT.md) into a fresh ZCode session
- [ ] The agent reported what it can do, and which MCP tools it has — **without installing anything**
- [ ] It asked the four questions one at a time
- [ ] It showed you your `AGENTS.md` content before saving it
- [ ] You approved one small first project

---

## 11. Prove it works end to end

- [ ] A repo exists on GitHub that you created yourself

```powershell
cd $env:USERPROFILE\Dev
mkdir hello-dev; cd hello-dev
git init
"# hello-dev" | Set-Content -Encoding utf8 README.md
git add README.md
git commit -m "Add README"
gh repo create hello-dev --public --source=. --push
```

- [ ] The repo is visible in your browser
- [ ] `git restore` brought back a deliberately broken file

Full walkthrough with explanations: [03-first-project.md](03-first-project.md).

---

## 12. Habits, from day one

- [ ] I open **one project folder**, not the whole `Dev` folder
- [ ] I run `git diff` before every commit
- [ ] I commit after every working step, not at the end of the day
- [ ] I read permission prompts before approving
- [ ] I know that `git reset --hard` and `git push --force` destroy work, and I do not run them on an agent's suggestion alone
- [ ] I keep API keys and passwords out of anything that goes into a repo
- [ ] When the agent is confused, I start a fresh session instead of arguing

---

## The three human-only steps

No agent can do these, and none should try:

1. Installing ZCode — it is a GUI wizard.
2. Signing in — GitHub, your model provider, Notion. Each opens a browser.
3. Approving anything in a browser.

---

## Re-installing on a new machine

```powershell
# 1. Get this repo
gh repo clone sc3dstudio/dev-setup-guide
cd dev-setup-guide

# 2. See what the script would do
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1 -DryRun

# 3. Do it
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1 -WithBlender

# 4. Check
powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
```

The script is safe to run twice. It skips what is already there, and it backs up your ZCode config before touching it.

**Or paste the agent prompt** from [02-agent-setup.md](02-agent-setup.md) and let the agent do the same steps while you watch.
