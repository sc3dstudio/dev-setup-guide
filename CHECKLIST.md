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
- [ ] **Computer Use switched off** — see step 10
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

## 10. Turn off Computer Use

Do this **before** you give the agent any prompt.

- [ ] In ZCode: **Settings → Plugin Management → Installed → Computer Use → off**
- [ ] Confirmed in the config:

```powershell
(Get-Content "$env:USERPROFILE\.zcode\cli\config.json" -Raw | ConvertFrom-Json).plugins.enabledPlugins
```

- [ ] It shows `computer-use@zcode-plugins-official` as `False`

**Why:** Computer Use lets the agent drive your whole desktop — mouse, keyboard, screen. That is far wider than editing files in a project folder, and hard to supervise while you are still learning how the agent behaves. Nothing in this guide needs it. You can turn it back on later.

---

## 11. First working session

- [ ] Pasted the prompt from [START-PROMPT.md](START-PROMPT.md) into a fresh ZCode session
- [ ] Step 1: it **installed** anything missing (not just reported it), then showed a version table
- [ ] Step 2: `Dev` folder exists, and you got a straight answer about OneDrive
- [ ] Step 3: it backed up `config.json`, merged `notion` in, and asked you to close and reopen ZCode
- [ ] It asked the four questions **one at a time**
- [ ] It showed you your `AGENTS.md` content before saving it
- [ ] You approved one small first project

**If the agent only lists missing tools and installs nothing**, it did not follow the prompt. Tell it: *"Ground rule 5 — standard tooling is yours to install, just say what you are doing in one line."*

---

## 12. Prove it works end to end

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

## 13. Habits, from day one

- [ ] I open **one project folder**, not the whole `Dev` folder
- [ ] I run `git diff` before every commit
- [ ] I let the agent commit each working step, and I read what it committed
- [ ] I let the agent install standard tooling without asking me each time
- [ ] I read permission prompts before approving
- [ ] I know that `git reset --hard` and `git push --force` destroy work, and I do not run them on an agent's suggestion alone
- [ ] I keep API keys and passwords out of anything that goes into a repo
- [ ] When the agent is confused, I start a fresh session instead of arguing

---

## What the agent does for you, and what it must not

**Yours to keep:** installing ZCode, and every browser sign-in. No agent can do those, and none should try.

**The agent's job:** the toolchain, the Dev folder, the MCP configuration, the skills, and your commits. Let it do them — approving each one wastes the reason you have an agent.

**Where it must stop and ask:** anything that deletes or overwrites without a way back, anything needing your account or a credential, anything that costs money, and anything that would change a part of the setup that already works.

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

**Or paste the prompt** from [START-PROMPT.md](START-PROMPT.md) and let the agent do all of it while you watch. On a second machine, that is usually the faster route.
