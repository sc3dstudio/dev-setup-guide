# Checklist

Every stage, in order, with the thing that proves it worked. Use this when you set a machine up and want the whole thing on one page.

Stages mirror [01-human-setup.md](01-human-setup.md), which explains each one.

---

# Part 1 — Your actions

Nine of these fifteen stages are just answering a question.

## 1. Install ZCode

- [ ] Downloaded from `https://zcode.z.ai` (Windows x64) and installed
- [ ] Opened, and chose **Start using ZCode** — not the migration wizard
- [ ] SmartScreen said "Windows protected your PC" → **More info → Run anyway**

## 2. Set up the model provider

- [ ] **Settings → Model Settings → + Add Provider**
- [ ] Base URL `https://api.deepseek.com/anthropic`
- [ ] API format `Anthropic messages (/v1/messages)`
- [ ] API key pasted (from whoever gave you this guide — **do not buy anything**)
- [ ] Model list `deepseek-flash`, Input Types Text + Image
- [ ] Bottom-left corner shows the model, not a **Connect** button
- [ ] Asking *"List the files in the current directory"* gives a real answer

## 3. Switch off Computer Use

- [ ] **Settings → Plugin Management → Installed → Computer Use → off**

**Why:** it gives the agent your mouse, keyboard and screen — far wider than editing files in a project, and hard to supervise while you are learning. Nothing here needs it.

## 4. Create your Dev folder

- [ ] Picked a location: **not** inside OneDrive, **not** in Documents/Desktop/Downloads
- [ ] Created it

```powershell
$DevRoot = "$env:USERPROFILE\Dev"          # or e.g. "D:\Dev"
New-Item -ItemType Directory -Force -Path $DevRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DevRoot '_sandbox') | Out-Null
```

- [ ] **Wrote the path down** — the agent asks for it at stage 9

## 5. Paste the start prompt

- [ ] Clicked **New Task** in ZCode
- [ ] Pasted the whole prompt out of [START-PROMPT.md](START-PROMPT.md)
- [ ] It began with STEP 1

## 6. The toolchain — nothing to answer

- [ ] Clicked **Yes** on any Windows permission prompt
- [ ] It installed missing tools with `winget` and then showed a version table
- [ ] It did **not** ask permission for each install

**If it only lists what is missing**, say: *"Install them, don't just report them."*

## 7. Your Git identity — it asks you

- [ ] It **asked** for your name and email — it did not invent them
- [ ] You gave the email on your **GitHub** account

**This is permanent.** Every commit you ever make carries it.

## 8. GitHub login — the one command you run

- [ ] Opened PowerShell and ran `gh auth login`
- [ ] Answered: `GitHub.com` / `HTTPS` / `Yes` / `Login with a web browser`
- [ ] Copied the one-time code, pressed Enter, authorized in the browser
- [ ] It printed `✓ Logged in as <you>`
- [ ] **Told the agent you were done** — otherwise it waits forever
- [ ] You let the agent run `gh auth setup-git` and `gh auth status`

## 9. Your Dev folder — it asks you

- [ ] Gave it the path from stage 4
- [ ] It added `_sandbox` and told you whether OneDrive is a problem

## 10. Working rules — it asks you

- [ ] It summarised how you two should work, in 5 bullet points
- [ ] You agreed, or corrected it

**Anything you say here lands in `AGENTS.md`, so it applies to every future session.**

## 11. Four questions — it asks, one at a time

- [ ] Language you want answers in
- [ ] What you want to build first (*"I do not know yet"* is a complete answer)
- [ ] Whether you have used Git before
- [ ] Whether it should explain a command before running it, or just run it

## 12. Your instruction file — it shows you

- [ ] You saw the content of `AGENTS.md` **before** it was written
- [ ] It says *"basic programming terminology"* rather than "assume I know nothing"
- [ ] You approved it

## 13. Your first project — it proposes

- [ ] It suggested one small thing with a reason, not "let's make a website"
- [ ] You approved it, or named something you would rather build
- [ ] It committed the work as part of the exercise

## 14. MCP servers — it asks, then you restart

- [ ] It asked whether you use Blender, and you answered honestly
- [ ] It backed up `config.json` before editing it
- [ ] It gave you a short handover: what it configured, and what to ask next
- [ ] You **closed ZCode completely** — quit from the tray if it sits there
- [ ] You opened it again and clicked **New Task**

## 15. The new session — where MCP actually works

- [ ] Asked whether `mcp.servers` survived the restart; re-added if it was empty
- [ ] Asked it to list MCP tools and saw `notion` in the list
- [ ] Asked it to list Notion pages, and approved the browser sign-in
- [ ] It returned real page names

**Remember:** MCP servers and skills are read only when ZCode starts. A task that was already running never sees them. When something you installed does not appear, the answer is restart + new task.

---

# Part 2 — Verify

## Final verification

- [ ] Run the check script

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
```

- [ ] Zero `FAIL` lines
- [ ] Every `WARN` is understood and accepted (they are optional things)

## Prove it works end to end

- [ ] A repo exists on GitHub that you made yourself

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

# Part 3 — Habits, from day one

- [ ] I open **one project folder**, not the whole `Dev` folder
- [ ] I run `git diff` before I accept a step as done
- [ ] I let the agent commit each working step, and I read what it committed
- [ ] I let the agent install standard tooling without approving each one
- [ ] I read permission prompts before approving
- [ ] I know that `git reset --hard` and `git push --force` destroy work, and I do not run them on an agent's suggestion alone
- [ ] I keep API keys and passwords out of anything that goes into a repo
- [ ] When the agent is confused, I start a fresh session instead of arguing

---

# Who does what

**Yours, always:**

1. Installing ZCode — a GUI wizard
2. Setting up the model provider — your API key
3. Every browser sign-in — GitHub, Notion
4. Decisions — where projects live, which language, what to build

**The agent's job:** the toolchain, the Dev folder, the Git config, `mcp.servers`, `AGENTS.md`, skills, and your commits. Let it do them — approving each one wastes the reason you have an agent.

**Where it must stop and ask:** anything that deletes or overwrites without a way back, anything needing your account or a credential, anything that costs money, and anything that would change a part of the setup that already works.

**Never let it:** type your password, complete a browser sign-in for you, buy anything, or claim the MCP servers work before you have restarted into a new task.

---

# Re-installing on a new machine

Same fifteen stages. Two shortcuts:

**Let the agent do the machine setup again.** On the new machine, install ZCode, set up the provider, switch off Computer Use, make a Dev folder, then paste the same prompt from [START-PROMPT.md](START-PROMPT.md). It works unchanged.

**Or run the script**, if you want the toolchain and config done without an agent:

```powershell
gh repo clone sc3dstudio/dev-setup-guide
cd dev-setup-guide
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1 -DryRun   # look first
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1 -WithBlender
powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
```

The script is safe to run twice. It skips what is already there, and it backs up your ZCode config before touching it.

Either way, the four things in *Who does what* above are still yours.
