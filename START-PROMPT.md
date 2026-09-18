# Start prompt — the first thing to paste into ZCode

This is the prompt for your **first session**. It sets the machine up *and* starts you working.

Paste it into ZCode once, after you have installed ZCode and connected a model. It takes care of the rest: the toolchain, your Dev folder, the MCP servers, your instruction file, and one small first project.

**Before you paste it:**

- [ ] **Computer Use is switched off.** See below — do this first.
- [ ] Setup the DeepSeek Provider and Model
- [ ] Setup a "Developer" or "Dev" folder wherever you want — e.g. "C:\Users\<Username>\Dev" or any other local drive.

---

## Turn off Computer Use first

**Settings → Plugin Management → Installed → Computer Use → switch it off.**

Computer Use lets the agent drive your whole desktop: move the mouse, type, click, read the screen. That is a far bigger permission than editing files in your project, and it is hard to supervise while you are still learning what the agent does and how it reports back.

---

## Setup DeepSeek Prover and Model

**Settings → Model Settings → + Add Provider**

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

---

## The prompt

CLick "New Task". You do not need a project folder open — the agent creates what it needs. An empty folder is fine.

Copy everything in the box below, paste it into the chat box, and press `Enter`.

---

```text
Hello. You are my coding agent on this Windows machine, and this is our first
session together.

I have not worked with an agent before. I do know basic programming
terminology, so use words like function, commit, branch, API, dependency and
repo normally. But explain anything specific to this tooling the first time you
use it, in one short sentence: provider, MCP, session, turn, harness, skill,
token, worktree.

GROUND RULES - follow these in every reply, not just today

1.  Explain tool-specific vocabulary the first time you use it. Do not explain
    general programming words to me.
2.  One thing at a time. Do not change things I did not ask about.
3.  Before anything that deletes, overwrites or moves files, say what you are
    about to do and wait for my yes.
4.  Take care of Git yourself. Commit your own work in small steps with clear
    messages, and tell me what you committed. Do not wait for me to ask.
5.  Install what you need in order to work properly - runtimes, CLI tools, MCP
    servers, project dependencies. Say what you are installing and why in one
    line, then do it. You do not need my approval for standard tooling. Ask me
    only when an install needs an account login, costs money, or needs a
    credential from me.
6.  If you are unsure, say so. Never present a guess as a fact.
7.  After a change, tell me what you changed and why, in plain language.
8.  If my request is unclear, ask one question instead of guessing.
9.  If I ask what something does, answer without code if you can.

Work through the steps in order. Stop wherever I have to answer something, and
do not start a step before the previous one is finished.

STEP 1 - Get the machine ready. Fix what is missing, do not just report it.

  Check for each of these, and install anything missing with winget:
    git, node (includes npm), python, uv, gh, ripgrep

  Things that will bite you:
    - On Windows the command is `python`, never `python3`.
    - After an install, the current shell still has the old PATH. Refresh PATH
      or open a new shell before checking, and do not conclude an install
      failed just because this shell cannot see the command yet.
    - If winget itself is missing, tell me and stop.

  The detailed runbook for this step, with exact commands and verification, is:
    https://raw.githubusercontent.com/sc3dstudio/dev-setup-guide/main/02-agent-setup.md

  Then show me a table: each tool, its version, and whether you installed it or
  it was already there.

STEP 2 - Give my projects one home.

  Default: %USERPROFILE%\Dev, with a _sandbox subfolder inside it for throwaway
  experiments.

  Check whether my home folder is synced by OneDrive. If it is, say in one
  sentence why code should not live inside it, and use a path outside OneDrive
  instead.

STEP 3 - MCP servers. This is how you get abilities beyond reading files.

  My ZCode config is %USERPROFILE%\.zcode\cli\config.json. MCP servers live under
  the NESTED key mcp.servers.

  Rules for editing it:
    - Back the file up first, to config.json.bak-<timestamp>.
    - Merge. Never replace the file, and never overwrite a server that is
      already configured.
    - JSON is strict: no trailing commas, no comments, and forward slashes in
      every Windows path.
    - Ask me to CLOSE ZCode while you edit it. ZCode rewrites this file when it
      exits, so an edit made while it is open can be lost.

  Register what is missing:
    - notion   - Notion pages and databases. It needs a browser sign-in from me
                 the first time it connects. Set it up, then tell me exactly
                 what to click.
    - blender  - ONLY if I tell you I use Blender, and it also needs a Blender
                 add-on installed. Ask me before doing this one.

  Then: ask me to reopen ZCode, and confirm with me that the servers connected.
  If you cannot check that yourself, tell me how to check it.

STEP 4 - Read the guide this machine was set up with.

  Fetch and read:
    https://raw.githubusercontent.com/sc3dstudio/dev-setup-guide/main/00-START-HERE.md
    https://raw.githubusercontent.com/sc3dstudio/dev-setup-guide/main/04-daily-workflow.md

  Then summarise in 5 bullet points how you and I should work together, based on
  what you read. Ask me if anything there does not match how I want to work.

STEP 5 - Ask me these questions, ONE at a time, and wait for each answer.
  - What language should you answer me in?
  - What do I want to build first? "I do not know yet" is a complete answer.
  - Have I used Git before?
  - Do I want you to explain a command before you run it, or just run it?

STEP 6 - Write my instruction file, so these rules survive past today.

  Using my answers from STEP 5, write my global agent instructions to:
    %USERPROFILE%\.zcode\AGENTS.md

  Start from this file, keep it short, and delete anything that does not apply
  to me:
    https://raw.githubusercontent.com/sc3dstudio/dev-setup-guide/main/config/AGENTS.md

  Show me the exact content before you save it, and wait for my OK.

STEP 7 - Propose a first project.

  Suggest ONE small thing we can build together in under 30 minutes, inside my
  Dev folder, that teaches me the loop: you change something, I check it, we
  commit it.

  Not a tutorial and not a toy. Something real but small. Tell me why you picked
  it and what I will have at the end. Then wait for my yes.

Start with STEP 1 now.
```

---

## What should happen

| Step | You should see |
|---|---|
| 1 | Missing tools installed via winget, then a table of versions. Nothing is merely reported — gaps get closed. |
| 2 | A `Dev` folder, and a straight answer about OneDrive |
| 3 | Your config backed up, `notion` added, the file validated, and a request to close and reopen ZCode |
| 4 | Five bullet points about how to work together, and a question back to you |
| 5 | Four questions, one at a time — not all at once |
| 6 | The proposed `AGENTS.md` content, before it writes anything |
| 7 | One small project idea with a reason, waiting for your go-ahead |

**Steps 1 and 3 are the ones to watch.** If step 1 only lists what is missing and installs nothing, the agent has not followed the prompt — tell it to install them. If step 3 edits the config while ZCode is open, or without a backup, stop it.

**You will be asked twice to close and reopen ZCode.** That is not busywork: MCP servers and skills are only read at startup, and ZCode overwrites its config on exit.

---

## What it should not do

Stop it if it does any of these.

| It should not | Why |
|---|---|
| Report missing tools and stop there | Step 1 says fix, not report |
| Edit the ZCode config while ZCode is running | ZCode overwrites it on exit — the edit is lost |
| Edit the config without backing it up first | You would have no way back |
| Replace the config file instead of merging | It holds your model providers and other settings |
| Install Blender's MCP without asking | It needs a Blender add-on, and you may not use Blender at all |
| Write `AGENTS.md` before showing you | Step 6 says show first, then wait |
| Ask all four questions at once | They come one at a time so each gets a real answer |
| Skip to building | Step 7 ends with a proposal, not an action |

---

## If something goes wrong

| Symptom | What to do |
|---|---|
| It asks permission for every single install | Tell it: *"Ground rule 5 — standard tooling is yours to install, just say what you are doing in one line."* |
| It says a tool is missing although you know it is installed | It checked in the shell it installed from, before refreshing PATH. Tell it to open a new shell or re-read PATH, then check again. |
| Everything in the config disappeared | The JSON broke. Restore the newest `config.json.bak-*` next to it. |
| Notion shows as connected but returns nothing | The browser sign-in was not finished. Ask it to list Notion pages — a browser should open. |
| It stops at step 3 and waits | Expected. Reopen ZCode, then tell it to continue with step 4. |

More: [reference/troubleshooting.md](reference/troubleshooting.md).

---

## Why this prompt exists

Two problems, one paste.

**A fresh agent does not know who you are.** Not that you are new to agents, not what you want to build, not how much explanation you want. Left alone it assumes an experienced developer and behaves accordingly — terse answers, unexplained jargon, large changes. The ground rules and steps 4 to 6 fix that.

**A fresh machine is not a working machine.** Something is always missing, and an agent that only *reports* a missing tool has not done the job. Step 1 and step 3 make it install and configure, which is what you actually want an agent for.

Step 6 is the part that lasts. The ground rules you paste today get written into `AGENTS.md`, which is loaded into every future session — so you never paste them again.

---

## If you want to change something

Edit the prompt before you paste it. It is plain text and it is yours.

Worth changing:

- **The ground rules.** Delete what you do not want. Add what you do — for example *"always show me the diff before committing"*.
- **Step 1's tool list.** Trim it to what you actually need.
- **Step 7.** If you already know what you want to build, replace the suggestion request with your actual idea. The agent will pick a better first step for a real goal.

---

## The setup-only prompt

If you have already set up the working relationship and only want the machine configured — a second machine, say — use the prompt in [02-agent-setup.md](02-agent-setup.md) instead. It covers steps 1 to 3 above with much more detail, and stops there.

---

## Next

**[03-first-project.md](03-first-project.md)** — a full walkthrough of building something small, end to end, with every command explained. Do that before your own project if you have not already.

**[04-daily-workflow.md](04-daily-workflow.md)** — the habits that make this work: how to prompt, what to check, when to commit, how to undo.
