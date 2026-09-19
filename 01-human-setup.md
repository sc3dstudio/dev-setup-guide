# Your part — the human role script

This setup is **one chronological script with two roles**. This file is only your role. Everything not listed here is done automatically by the agent.

You do not need to read the agent's half, and you do not need to understand the configuration. If you do exactly what is in this file, the setup completes.

---

## How to read this

Every stage has the same three lines:

| Line | Meaning |
|---|---|
| **YOU DO** | the action. This is the only part you perform |
| **THE AGENT** | what it is doing at that moment, so nothing surprises you |
| **IT WILL ASK** | have this answer ready before you move on |

**There are exactly two commands in this whole script:** creating your Dev folder in stage 4, and the GitHub login in stage 8. Both need something only you can provide — a decision about where your projects live, and a browser sign-in.

---

## Your whole job, at a glance

Fifteen stages. Nine of them are just answering a question.

| # | What you do | Kind |
|---|---|---|
| 1 | Install ZCode | setup |
| 2 | Set up the DeepSeek provider and model | setup |
| 3 | Switch off Computer Use | setup |
| 4 | Create your Dev folder — *command 1 of 2* | setup |
| 5 | Paste the start prompt into a new task | the handover |
| 6 | Click **Yes** if Windows asks for permission | while it works |
| 7 | Answer: your Git name and email | answer |
| 8 | Run `gh auth login` and authorize in the browser — *command 2 of 2* | action |
| 9 | Answer: where your Dev folder is | answer |
| 10 | Answer: do the working rules match? | answer |
| 11 | Answer four questions, one at a time | answer |
| 12 | Approve your `AGENTS.md` | approve |
| 13 | Approve the first project | approve |
| 14 | Answer: do you want Notion? Do you use Blender? Then restart ZCode — **skipped if you say no to both** | answer + action |
| 15 | In the new task: verify, and approve the Notion sign-in — **only if you asked for Notion** | action |

**Stages 1 to 4 happen before any agent exists.** Nothing is automated there, because there is nothing yet to automate it.

**Stage 5 is the handover.** From stage 6 onward, you are answering, not working.

**You can skip the last two stages entirely.** Notion and Blender are both optional, the agent will ask you, and "no" to both is a complete answer. Nothing is broken by an empty MCP list.

---

# Part 1 — Before your agent exists

Four stages, all yours. Budget about 20 minutes, most of it downloading.

---

## Stage 1 — Install ZCode

**YOU DO**

1. Open `https://zcode.z.ai` in your browser.
2. Download the **Windows x64** installer.
3. Run it and click **Next** through the wizard.
4. Open **ZCode** from the Start menu.

**THE AGENT** — does not exist yet.

**You should see** an onboarding screen offering **Start using ZCode** or a **Data Migration Wizard**. Choose **Start using ZCode**. The migration wizard is only for people moving from another agent tool.

**If it fails**

- **Windows SmartScreen blocks it** ("Windows protected your PC"): click **More info**, then **Run anyway**. The block is because the installer is new, not because it is dangerous.
- **Your antivirus blocks it**: allow the installer, or allow the ZCode install folder, and try again.

**IT WILL ASK** — nothing.

---

## Stage 2 — Set up the DeepSeek provider and model

Nothing works until a model is connected. ZCode will open a chat box, but it has nothing to think with.

**YOU DO**

**Settings → Model Settings → + Add Provider**, then fill in:

```
Base URL
https://api.deepseek.com/anthropic

API format
Anthropic messages (/v1/messages)

API key
[Paste the provided key]

Model List
deepseek-flash

Input Types:
Text [x], Image [x]
```

Then check the bottom-left corner shows the model instead of a **Connect** button.

**THE AGENT** — does not exist yet.

**You should see** — prove it works by asking ZCode this in the chat box:

```
List the files in the current directory.
```

A real answer — a list of files, or "this folder is empty" — means the model works. Either answer is fine.

**Do not buy anything.** The API key comes from whoever gave you this guide. If you do not have it, ask before you sign up for anything.

**If it fails**

- **No model listed** — the provider is not saved. Reopen **Model Settings** and check the fields.
- **It answers with a provider error** — the key is wrong, or the base URL has a typo. `https://api.deepseek.com/anthropic` — note `/anthropic` at the end.

**IT WILL ASK** — nothing.

---

## Stage 3 — Switch off Computer Use

Do this before you give any agent a task.

**YOU DO**

**Settings → Plugin Management → Installed → Computer Use → switch it off.**

**THE AGENT** — does not exist yet.

**Why it matters, in one sentence:** Computer Use lets an agent drive your whole desktop — mouse, keyboard, screen — which is far wider than editing files in a project, and hard to supervise while you are still learning how the agent behaves.

Nothing in this setup needs it. Turn it on later if you want it, once watching the agent work feels routine.

**IT WILL ASK** — nothing.

---

## Stage 4 — Create your Dev folder (command 1 of 2)

This is where every project will live. You choose the location, because it depends on your machine — which drive has space, and which folders are cloud-synced.

**YOU DO**

1. **Pick a location.** Anywhere on a local drive. Two rules:
   - **Not inside OneDrive**, or any other folder that syncs to the cloud. A project fills up with thousands of small files, and syncing those slows the machine down and can corrupt a project mid-write. This one decision saves hours later.
   - **Not in `Documents`, `Desktop` or `Downloads`.** Those tend to be synced or cleaned up. Keep code somewhere deliberate.
2. **Create it.** Open PowerShell — press the `Windows` key, type `PowerShell`, click **Windows PowerShell** — then paste this, changing the path if you want a different drive:

```powershell
$DevRoot = "$env:USERPROFILE\Dev"          # or e.g. "D:\Dev"
New-Item -ItemType Directory -Force -Path $DevRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DevRoot '_sandbox') | Out-Null
Write-Host "Dev root is $DevRoot"
```

**THE AGENT** — does not exist yet.

**You should see** — it prints the path back, e.g. `Dev root is C:\Users\<you>\Dev`.

**Remember that path.** You will be asked for it in stage 9. If you would rather not create the folder yourself, skip this stage — the agent will make one at stage 9. But then you will not have chosen the drive.

**IT WILL ASK** — nothing yet. Note your path down.

---

# Part 2 — Start the agent

---

## Stage 5 — Paste the start prompt

This is the moment the agent starts existing. Everything after this is it working and you answering.

**YOU DO**

1. In ZCode, click **New Task**.
2. Open [START-PROMPT.md](START-PROMPT.md) and copy the whole prompt out of the box.
3. Paste it into the chat box and press `Enter`.

You do not need a project folder open. The agent creates what it needs.

**THE AGENT** — reads the prompt and starts **STEP 1**: checking which tools exist and installing the missing ones.

**You should see** — within a minute or two, it says what it found and starts installing. It should **not** ask your permission for each install. If it does, tell it:

```
Ground rule 5 - standard tooling is yours to install, just say what you are
doing in one line.
```

**Reminder:** the prompt lives at `https://github.com/sc3dstudio/dev-setup-guide/blob/main/START-PROMPT.md` if you need it again on another machine.

**IT WILL ASK** — nothing yet.

---

# Part 3 — It works, you answer

From here the agent drives. Nine interactions, and only one of them needs a terminal.

---

## Stage 6 — The toolchain

Nothing to answer. This stage is just so you know what the quiet is.

**YOU DO** — click **Yes** if Windows shows a permission prompt ("Do you want to allow this app to make changes?"). Some installs ask; most do not.

**THE AGENT** — installs `git`, `node`, `python`, `uv`, `gh` and `ripgrep` with `winget`, refreshing `PATH` between steps. This takes 10 to 15 minutes and most of it is downloading.

**You should see** — a table at the end: each tool, its version, and whether it installed it or it was already there.

**If it fails**

- **It only lists what is missing and installs nothing.** It did not follow the prompt. Say: *"Install them, don't just report them."*
- **It says a tool is missing although you know it is installed.** It checked in the shell it installed from, before `PATH` refreshed. Say: *"Open a new shell, or re-read PATH from the registry, then check again."*

**IT WILL ASK** — nothing.

---

## Stage 7 — Your Git identity

**IT WILL ASK**

1. **Your name** for Git commits.
2. **Your email** for Git commits.

**YOU DO** — answer with the email address on your **GitHub** account. Your real name is fine, or your GitHub username.

**THE AGENT** — runs `git config --global user.name ...` and `user.email ...`, plus three settings: `init.defaultBranch main`, `core.longpaths true`, `core.autocrlf true`.

**Read this one properly.** Every commit you ever make is stamped with that name and email, permanently, in the history. It is the reason the agent is told to *ask* rather than guess.

**If it fails** — if the agent picks an email for you instead of asking, stop it and give the right one.

---

## Stage 8 — GitHub login (command 2 of 2)

**This is the only stage where you run a command yourself.** It cannot be automated: it needs an interactive prompt and a browser sign-in that is yours.

**YOU DO**

1. Open PowerShell — `Windows` key, type `PowerShell`, click **Windows PowerShell**.
2. Run:

```powershell
gh auth login
```

3. Answer its questions:

| Question | Answer |
|---|---|
| What account do you want to log into? | `GitHub.com` |
| What is your preferred protocol for Git operations? | `HTTPS` |
| Authenticate Git with your GitHub credentials? | `Yes` |
| How would you like to authenticate? | `Login with a web browser` |

4. It shows a **one-time code** like `A1B2-C3D4`. Copy it, press `Enter`, paste the code in the browser, sign in, click **Authorize**.

**THE AGENT** — waiting for you. When you tell it you are done, it runs `gh auth setup-git` and `gh auth status` and shows you the result.

**You should see** — back in PowerShell:

```
✓ Logged in as <your-github-name>
```

**Then tell the agent you are finished**, or it will wait forever.

**If it fails**

- **The browser does not open.** Copy the URL PowerShell printed and paste it into your browser by hand. The code still works.
- **The code expired.** They last a few minutes. Run `gh auth login` again for a fresh one.
- **You have no GitHub account.** Make one at `github.com` first — it is free.

**Never let the agent type your password.** It is told not to, and you should not let it.

---

## Stage 9 — Your Dev folder

**IT WILL ASK** — where your Dev folder is.

**YOU DO** — give it the path from stage 4, for example `C:\Users\<you>\Dev`. If you skipped stage 4, say so and tell it where you want the folder, or accept its suggestion of `%USERPROFILE%\Dev`.

**THE AGENT** — checks the path exists, adds a `_sandbox` subfolder for throwaway experiments, and checks whether the folder sits inside OneDrive. If it does, it will explain the problem and propose a path outside it.

**You should see** — confirmation of the path, and a straight answer about OneDrive. It must not move anything without asking you.

---

## Stage 10 — How you two will work together

**IT WILL ASK** — it reads the guide, then summarises how it thinks you should work together in 5 bullet points, and asks whether that matches what you want.

**YOU DO** — say yes, or correct it. You are allowed to disagree here. For example:

```
Mostly right. But always show me the diff before you commit, and do not
reformat files you are not otherwise changing.
```

**THE AGENT** — reads two guide files and reports back.

**Why this stage is worth your attention:** anything you say here gets carried into `AGENTS.md` in the next stage, so it applies to every future session. This is your one chance to set the tone cheaply.

---

## Stage 11 — Four questions

**IT WILL ASK**, one at a time, waiting after each:

| Question | Worth answering as |
|---|---|
| What language should you answer me in? | your language. This is enforced from now on |
| What do I want to build first? | anything real, or *"I do not know yet"* — that is a complete answer |
| Have I used Git before? | the truth. It changes how much it explains |
| Do I want you to explain a command before you run it, or just run it? | your choice. *"Explain before running"* is the calmer start |

**YOU DO** — answer each one. Do not let it bundle them together; one at a time is deliberate, so each gets a real answer.

**THE AGENT** — waits for each answer before asking the next.

---

## Stage 12 — Your instruction file

**IT WILL SHOW YOU** the exact contents of `AGENTS.md` — the file that carries your rules into every future session — and wait for your OK.

**YOU DO**

1. Read it. It should be short.
2. Approve it, or ask for changes.

**Check for** your language, and that the phrase *"basic programming terminology"* is in there rather than "assume I know nothing". That calibration is what keeps its explanations useful instead of patronising.

**THE AGENT** — writes the file to `%USERPROFILE%\.zcode\AGENTS.md` only after you say yes.

**You should see** — the content in the chat **before** anything is written. If it writes first and shows afterwards, stop it.

---

## Stage 13 — Your first project

**IT WILL PROPOSE** one small thing you can build together in about 30 minutes, inside your Dev folder, and explain what you will have at the end.

**YOU DO** — say yes, or name something you would rather build. If you already know what you want, say so now:

```
I would rather start with <your idea>. Keep it small enough to finish today.
```

**THE AGENT** — waits for your approval before building anything.

**You should see** a specific idea and a reason for it — not "let's make a website". And committing is part of the exercise, so you should see it commit.

---

## Stage 14 — Optional extras, and maybe a restart

Both extras here are optional. The agent asks, and **"no" to both is a complete answer** — you then skip the restart and stage 15 entirely.

If you do want one, the agent will tell you why it goes last: **MCP servers are only read when ZCode starts.** Nothing installed now can work in the session you are in. So it configures them, you restart, and you continue in a new task.

**IT WILL ASK**

**IT WILL ASK**

1. **Do you want Notion connected?** Optional. It gives the agent access to Notion pages and databases, which is how a shared skills library gets in. Say yes or no — **no is a complete answer.**
2. **Do you use Blender?** Optional too, and only worth yes if you actually use Blender. That server also needs a Blender add-on installed.
3. It then asks you to note down a short handover: what it configured, and what to ask in the new task.

**If you say no to both, this stage is over.** There is nothing to configure, no restart is needed, and you are done — the agent should tell you that plainly rather than talking you into either one.

**YOU DO**

1. Answer the two questions.
2. Read its short handover. It tells you exactly what to do next.
3. **Close ZCode completely.** Not minimise — close. If it sits in the system tray, quit it from there.
4. **Open ZCode again.**
5. **Click New Task.** Not the old one.

**THE AGENT** — backs up your config, merges in whatever you said yes to, validates the JSON, and writes you the handover. It does not claim the servers work — it cannot know that yet.

**If the config edit goes wrong**, there is a backup next to it: a file named `config.json.bak-<timestamp>`.

---

## Stage 15 — The new session

**Only if you said yes to Notion or Blender in stage 14.** If you said no to both, skip this stage — you are already finished.

You are in a fresh task now, and this is where the MCP servers actually become usable.

**YOU DO**

1. **First, ask it to confirm the servers survived the restart:**

```
Is mcp.servers still in my ZCode config? List what is in it.
```

If the list is empty, ZCode rewrote its config as it closed. Tell it to add the servers again — the second attempt sticks, because the restart has already happened.

2. **Then check the tools are there:**

```
List every MCP tool you have, grouped by server name.
```

The servers you asked for should appear. An empty list is correct if you asked for none.

3. **Only if you asked for Notion, sign in.** Ask it:

```
List the Notion pages you can see.
```

**A browser window opens.** Sign in and click **Allow**. This happens once — the approval is cached on your machine afterwards.

**You should see** real Notion page names in the answer.

**If it fails**

- **A server is missing from the tool list.** You are probably in the old task, or ZCode was not fully closed. Close it, reopen, start a new task.
- **Notion is listed but returns nothing.** The browser sign-in was not completed. Ask again and finish the sign-in.

---

# Reference

## What you never have to do

The agent does all of this. If you find yourself doing it by hand, something has gone wrong.

| It does | Why you do not need to |
|---|---|
| Install the toolchain | `winget` is built for it, and it refreshes `PATH` itself |
| Set the Git config beyond your name and email | Those three settings are conventions, not decisions |
| Edit `mcp.servers` in the ZCode config | It backs up, merges and validates. You would only risk breaking the JSON |
| Write `AGENTS.md` | It drafts from your answers and shows you first |
| Clone the guide repo | It fetches the files it needs over the network |
| Commit your work | Ground rule 4: it commits each working step and tells you what it did. It asks before pushing, because pushing publishes |
| Install skills | Copying a folder into `.agents\skills` is a step, not a decision |

## The four things that are always yours

1. **Installing ZCode** — a GUI wizard.
2. **Setting up the model provider** — your API key.
3. **Every browser sign-in** — GitHub, Notion. Yours, and nobody else's.
4. **Decisions** — where your projects live, what language, what to build.

## If something goes wrong

| Symptom | What to do |
|---|---|
| It asks permission for every small thing | `Ground rule 5 - standard tooling is yours to install, just say what you are doing in one line.` |
| It forces an explanation of every general programming word | `Ground rule 1 - I know basic programming terms. Explain only tool-specific ones.` |
| It picks a Git email for you | Stop it. That address is in every commit you ever make |
| It claims Notion works in the first session | It cannot know that. MCP only loads on restart |
| Something you installed is not showing up | Restart ZCode and start a **new task**. Old sessions never see new tools |
| The config looks broken | Restore the newest `config.json.bak-*` beside it |
| You do not understand what it is doing | `Explain what you just did, as if I am new to this tool.` |

Full symptom list: [reference/troubleshooting.md](reference/troubleshooting.md).

## Where to look things up later

| Question | File |
|---|---|
| What is all this stuff? | [00-START-HERE.md](00-START-HERE.md) |
| What did the agent actually do, in detail? | [02-agent-setup.md](02-agent-setup.md) |
| Build something small, end to end | [03-first-project.md](03-first-project.md) |
| How to work day to day | [04-daily-workflow.md](04-daily-workflow.md) |
| Every ZCode settings file | [reference/zcode-config-map.md](reference/zcode-config-map.md) |
| MCP servers, one by one | [reference/mcp-servers.md](reference/mcp-servers.md) |
| Skills and plugins | [reference/skills-and-plugins.md](reference/skills-and-plugins.md) |
| Notion access and sharing | [reference/notion-access.md](reference/notion-access.md) |
