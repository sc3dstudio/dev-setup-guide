# Start prompt — the first thing to paste into ZCode

This is the prompt for your **first session**. It sets the machine up *and* starts you working.

Paste it into ZCode once, after you have installed ZCode, set up a model, and made your Dev folder. It takes care of the rest: the toolchain, Git, GitHub, your instruction file, and one small first project.

**Before you paste it:**

- [ ] ZCode is installed and opened
- [ ] The DeepSeek provider and model are set up — see below
- [ ] A "Developer" or "Dev" folder exists, wherever you want it — e.g. `C:\Users\<your-name>\Dev` or any other local drive
- [ ] **Computer Use is switched off** — see below

---

## Turn off Computer Use first

**Settings → Plugin Management → Installed → Computer Use → switch it off.**

Computer Use lets the agent drive your whole desktop: move the mouse, type, click, read the screen. That is a far bigger permission than editing files in your project, and it is hard to supervise while you are still learning what the agent does and how it reports back.

---

## Set up the DeepSeek provider and model

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

Click **New Task**. You do not need a project folder open — the agent creates what it needs. An empty folder is fine.

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

Work through the steps in order. Stop wherever I have to answer something or do
something in a browser, and do not start a step before the previous one is
finished.

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

STEP 2 - Git identity, then GitHub login. Both need something from me, so expect
  to stop twice.

  First my Git identity. Every commit is stamped with a name and an email.
  ASK ME for both. Do not invent them, and do not guess them from my Windows
  username. Use the email address on my GitHub account.
  Then set:
    git config --global user.name  "<what I tell you>"
    git config --global user.email "<what I tell you>"
    git config --global init.defaultBranch main
    git config --global core.longpaths true
    git config --global core.autocrlf true

  Then the GitHub login. You cannot do this one for me: it needs an interactive
  terminal prompt and a browser that only I can complete. So give me the
  instructions and wait. Ask me to:
    1. Press the Windows key, type PowerShell, open it
    2. Run:  gh auth login
    3. Answer:  GitHub.com  /  HTTPS  /  Yes  /  Login with a web browser
    4. Copy the one-time code it prints, press Enter, paste the code in the
       browser, sign in, click Authorize

  Wait for me to tell you I am done. Then run:
    gh auth setup-git
    gh auth status
  and show me the output. If it says I am not logged in, help me work out why
  rather than asking me to repeat all of it.

  Never type my password, and never try to complete a browser sign-in for me.

STEP 3 - Give my projects one home.

  I may have already created a Dev folder. ASK ME where it is, and use that path.
  If I have not made one, suggest %USERPROFILE%\Dev, create it, and put a
  _sandbox subfolder inside it for throwaway experiments.

  Check whether that folder sits inside OneDrive. If it does, say in one sentence
  why code should not live there - node_modules and .git are thousands of small
  files and OneDrive syncs and can corrupt them - and propose a path outside
  OneDrive. Do not move anything without my yes.

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
  commit it. Committing it is part of the exercise, so do not skip that.

  Not a tutorial and not a toy. Something real but small. Tell me why you picked
  it and what I will have at the end. Then wait for my yes.

STEP 8 - MCP servers. Do this LAST, because it ends our session.

  Why it ends the session: ZCode reads MCP servers only when it starts. Nothing
  you do in THIS session can make them available here. You configure them, I
  restart ZCode, and we continue in a new task. If I ask you to use Notion or
  Blender before that restart, remind me of this instead of trying.

  My ZCode config is %USERPROFILE%\.zcode\cli\config.json. MCP servers live under
  the NESTED key mcp.servers.

  Rules for editing it:
    - Back the file up first, to config.json.bak-<timestamp>.
    - Merge. Never replace the file, and never overwrite a server that is
      already configured.
    - JSON is strict: no trailing commas, no comments, and forward slashes in
      every Windows path.
    - Check that the file still parses after you write it.
    - You are running INSIDE ZCode, so you cannot edit this file while ZCode is
      closed. Write it now, then have me restart - and plan to verify in the new
      session, because ZCode may rewrite its config as it exits. See the last
      bullet below.

  Register what is missing:
    - notion   - Notion pages and databases. Its first connection needs a browser
                 sign-in from me, which can only happen after the restart.
    - blender  - ONLY if I tell you I use Blender. ASK ME first: it also needs a
                 Blender add-on installed, and many people never open Blender.

  Then, before I restart, write me a short handover in your reply - not in a
  file - with:
    1. what you configured, and the exact path you changed
    2. what I do now: close ZCode, reopen it, start a new task
    3. what to ask you in that new task, to check each server came up

  And tell me this, in one line, so the next session fixes it if needed: if
  ZCode rewrote its config on exit and the servers are gone, the new session
  should add them again - the second attempt sticks, because by then the
  restart has already happened.

Start with STEP 1 now.
```

---

## What should happen

| Step | You should see |
|---|---|
| 1 | Missing tools installed via winget, then a table of versions. Nothing is merely reported — gaps get closed. |
| 2 | It **asks you** for your Git name and email, then hands you a browser flow for GitHub, then shows `gh auth status` |
| 3 | It asks where your `Dev` folder is, and gives a straight answer about OneDrive |
| 4 | Five bullet points about how to work together, and a question back to you |
| 5 | Four questions, one at a time — not all at once |
| 6 | The proposed `AGENTS.md` content, before it writes anything |
| 7 | One small project idea with a reason, waiting for your go-ahead |
| 8 | The config backed up and `notion` merged in, then a short handover telling you to restart |

**The steps where you are needed: 2, 3, 5, 6, 7 and 8.** Everywhere else it should work on its own. If it stops for approval on a routine install, it has not understood ground rule 5.

**Two things to watch.** In step 1, if it only *lists* what is missing and installs nothing, it has not followed the prompt. In step 8, if it edits the config without backing it up first, or tells you the servers already work, stop it — it cannot know that yet.

---

## After the restart — the new session

Step 8 ends with you restarting ZCode. That is not busywork, and it is why MCP goes last.

**MCP servers are read once, when ZCode starts.** So:

1. Close ZCode.
2. Open it again.
3. Start a **New Task** — not the old one.
4. First, ask it to confirm the servers are still configured:

```
Is mcp.servers in my ZCode config still what you wrote? List the servers in it.
```

If the list is empty, ZCode rewrote its config as it closed. Tell it to add the servers again. **The second attempt sticks**, because the restart has already happened.

5. Then ask what the agent's handover told you to ask, usually:

```
List every MCP tool you have, grouped by server name.
```

Now `notion` should appear, with its tools. If it does, ask it to list your Notion pages — **the first call opens a browser for you to approve**. That approval is cached, so it only happens once.

**A session started before the install will never see the new tools**, no matter how long it runs or how you rephrase the question. If something you installed is not showing up, the answer is almost always: restart, new task.

The same is true of skills.

---

## What it should not do

Stop it if it does any of these.

| It should not | Why |
|---|---|
| Report missing tools and stop there | Step 1 says fix, not report |
| Invent a Git name or email | Every commit you ever make carries it. It must ask |
| Complete a browser sign-in for you | Sign-ins are yours. It should hand over, not help |
| Edit the config without backing it up first | You would have no way back |
| Replace the config file instead of merging | It holds your model providers and other settings |
| Install Blender's MCP without asking | It needs a Blender add-on, and you may not use Blender at all |
| Promise Notion or Blender tools in this session | They cannot work until ZCode restarts |
| Write `AGENTS.md` before showing you | Step 6 says show first, then wait |
| Ask all four questions at once | They come one at a time so each gets a real answer |
| Claim the MCP servers are working, in this session | It cannot know that until after the restart. Verify first |

---

## If something goes wrong

| Symptom | What to do |
|---|---|
| It asks permission for every small thing | Tell it: *"Ground rule 5 — standard tooling is yours to install, just say what you are doing in one line."* |
| It picks a Git email for you | Stop it and give the right one. It is baked into every commit |
| The GitHub browser flow does not open | The terminal prints a URL. Paste it into your browser by hand; the code still works |
| It says a tool is missing although you know it is installed | It checked in the shell it installed from, before refreshing PATH. Tell it to open a new shell or re-read PATH, then check again. |
| Everything in the config disappeared | The JSON broke. Restore the newest `config.json.bak-*` next to it. |
| After the restart, the servers you added are gone | ZCode rewrote its config on exit. Add them again — the second attempt sticks, because the restart already happened |
| Notion does not appear after the restart | You are probably in the old task, or ZCode was not fully closed. Close it, reopen, start a new task. |
| Notion appears but returns nothing | The browser sign-in was not finished. Ask it to list Notion pages — a browser should open. |

More: [reference/troubleshooting.md](reference/troubleshooting.md).

---

## Why this prompt exists

Two problems, one paste.

**A fresh agent does not know who you are.** Not that you are new to agents, not what you want to build, not how much explanation you want. Left alone it assumes an experienced developer and behaves accordingly — terse answers, unexplained jargon, large changes. The ground rules, and steps 4 to 6, fix that.

**A fresh machine is not a working machine.** Something is always missing, and an agent that only *reports* a missing tool has not done the job. Steps 1 to 3 make it install and configure, and step 8 adds the MCP servers — which is what you actually want an agent for.

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

If your working rules are already in place and you only want the machine configured — a second machine, say — use the prompt in [02-agent-setup.md](02-agent-setup.md) instead. It covers the machine setup with much more detail and stops before the MCP step.

---

## Next

**[03-first-project.md](03-first-project.md)** — a full walkthrough of building something small, end to end, with every command explained.

**[04-daily-workflow.md](04-daily-workflow.md)** — the habits that make this work: how to prompt, what to check, when to commit, how to undo.
