# The setup runbook — what the agent does, in detail

This is the manual behind the prompt. It is **not** the prompt you paste.

**If you are setting up a machine from scratch, use [START-PROMPT.md](START-PROMPT.md).** That prompt does everything here, plus it agrees with you how you will work together. It is the one to paste on a first machine.

Read this file when:

- you want to see exactly what the agent will do before you let it, or
- something in the setup looks wrong and you need to check it against the intended steps, or
- you only want the machine configured and already have your working rules sorted — then paste the setup-only prompt in [section 2](#2-the-setup-only-prompt) below.

This file has three parts:

1. **[Before you paste](#1-before-you-paste)** — the two things you must do yourself first.
2. **[The setup-only prompt](#2-the-setup-only-prompt)** — installs and configures, and stops there.
3. **[The runbook](#3-the-runbook-the-agent-follows)** — what the agent will actually do, phase by phase.

---

## 1. Before you paste

Some of this needs a human at a keyboard.

- [ ] **ZCode is installed and open.** See [01-human-setup.md](01-human-setup.md) **Stage 1**.
- [ ] **A model is connected**, and asking ZCode *"List the files in the current directory"* gives a real answer. See [01-human-setup.md](01-human-setup.md) **Stage 2**.
- [ ] **Computer Use is switched off.** See the top of [README.md](README.md), or **Stage 3**.
- [ ] **A Dev folder exists.** See **Stage 4** — or let the agent create one, and it will ask you where.

Without a connected model there is no agent, and there is nothing to paste a prompt into.

**The agent will ask you two questions in Phase 6. Both are optional, and "no" to both is a complete answer:**

| Question | What it controls |
|---|---|
| Do you want Notion connected? | The agent can then read and write Notion pages and databases. Needs a browser sign-in from you on first use |
| Do you use Blender? | Only useful if you actually use Blender. The Blender MCP also needs a Blender add-on installed |

An empty MCP list is a normal, working setup. Nothing is broken if you say no to both.

---

## 2. The setup-only prompt

Use this instead of the start prompt when the machine needs configuring but your working rules are already in place — a second machine, or a rebuild.

Open ZCode. You do not need a project folder open.

Copy everything in the box below and paste it into the chat box. Then press `Enter` and let it work.

> **Do not paste this into a folder that already contains a project you care about.** The agent creates folders and installs tools. It is written to be safe, but a fresh or empty folder is the right place to start.

---

```text
You are setting up this Windows computer as a development machine for a beginner.
Work step by step. Do not rush. Verify each step before moving to the next.

FIRST: fetch the full runbook and follow it exactly.
  https://raw.githubusercontent.com/sc3dstudio/dev-setup-guide/main/02-agent-setup.md
  If you cannot fetch it, follow the steps in this prompt — they are the summary.

GROUND RULES
1. Windows, PowerShell. Assume no development tools are installed yet.
2. Be idempotent: check whether something is already installed before installing it.
   Never reinstall over a working installation unless it is broken.
3. Before any command that deletes, overwrites, or moves files, say what you are about
   to do and why, and wait for my "yes".
4. Never edit an existing configuration file without making a backup copy first.
5. After installing a tool, a NEW terminal is needed for it to be on PATH. Either open
   a new shell or refresh PATH from the registry. Do not conclude an install failed
   just because the current shell cannot see the command.
6. If a step fails and you cannot fix it after two attempts, STOP. Report what you tried,
   the exact error text, and what you need from me. Do not guess and continue.
7. I know basic programming terminology, so use words like function, commit, branch and
   repo normally. Explain anything specific to this tooling the first time you use it,
   in one short sentence: provider, MCP, session, turn, harness, token. And explain what
   each tool is for the first time you install it.

PHASES — do them in this order

Phase 0 — Recon, then continue
  Report: Windows version, whether winget works, and which of these already exist:
  git, node, npm, python, uv, gh, rg.
  Then go straight on to Phase 1. Do NOT wait for my approval to install standard
  tooling. Stop and tell me only if something unexpected turns up: winget missing,
  a tool present but broken, or a version old enough to change the plan.

Phase 1 — Install the missing tools with winget
  Git.Git | OpenJS.NodeJS.LTS | Python.Python.3.12 | astral-sh.uv |
  GitHub.cli | BurntSushi.ripgrep.MSVC
  Use: winget install --id <ID> -e --accept-source-agreements --accept-package-agreements
  Then refresh PATH and verify every one prints a version.
  NOTE: on Windows the command is `python`, never `python3`.

Phase 2 — Dev folder
  Create C:\Users\<my-name>\Dev and a subfolder Dev\_sandbox.
  Confirm it is NOT inside OneDrive. If my home folder is synced by OneDrive,
  tell me and use a path outside it instead. Explain why in one sentence.

Phase 3 — Git identity
  Set user.name and user.email (ASK ME for both values — do not invent them),
  plus init.defaultBranch main, core.longpaths true, core.autocrlf true.

Phase 4 — GitHub login (HUMAN GATE — stop here)
  Run `gh auth login` and hand over to me for the browser part. Wait for my
  confirmation that the browser flow finished. Then run:
    gh auth setup-git
    gh auth status
  and show me the output.

Phase 5 — Clone this repo into Dev
  git clone https://github.com/sc3dstudio/dev-setup-guide.git
  So that the scripts and config examples are available locally.

Phase 6 — ZCode MCP servers (ask first, both are optional)
  ASK ME which of these I want before installing either. Do not install either
  one without an answer. "No" to both is a complete answer - if that is my
  answer, say so plainly and skip the rest of this phase.

  ZCode's user config is: C:\Users\<my-name>\.zcode\cli\config.json
  It holds mcp.servers as a NESTED object. MCP servers live at mcp.servers, not at
  the top level.
  - BACK UP the file before editing it, to config.json.bak-<timestamp>.
  - MERGE. Never overwrite servers that are already there.
  - JSON is strict: no trailing commas, no comments, forward slashes in every path.
  - Server to add ONLY IF I say yes to Notion: notion
      command: <full path to npx.cmd, find it with: where.exe npx>
      args:    -y mcp-remote@0.14.2 https://mcp.notion.com/mcp --transport http-only
      timeoutMs: 60000
      The version is pinned on purpose. Do not silently take a newer one - a
      bridge script runs on my machine, so pinning is the safer default. Tell me
      if you would rather not pin.
  - Server to add ONLY IF I say yes to Blender: blender-fork
      This one runs a remote installer, so tell me that before you start it:
        Set-ExecutionPolicy Bypass -Scope Process -Force
        irm https://raw.githubusercontent.com/newo-ether/blender-mcp/main/bootstrap.ps1 | iex
      It is interactive: it shows a checklist and asks which Blender version and
      which MCP clients to register. Tell me what it is asking and wait for my input.
      It also installs the Blender add-on. Then find the executable:
        Get-ChildItem "$env:LOCALAPPDATA\BlenderMCP" -Recurse -Filter blender-mcp.exe
      and register that path as the blender-fork command, with env:
        BLENDER_MCP_DISABLE_TELEMETRY = "1"
      If the installer refuses to run non-interactively, stop and hand it to me.
      If you cannot tell me what that script does, do not run it.
  - You are running INSIDE ZCode, so you cannot edit this file while ZCode is
    closed. Write it, then have me restart. ZCode may rewrite its config as it
    exits, so plan to VERIFY in the new session and re-add anything that was lost.

Phase 7 — Skills
  Copy the repo's skills\* folders into C:\Users\<my-name>\.agents\skills\
  The rule: each skill is a folder directly containing a SKILL.md.
  A layout like skills\name\name\SKILL.md will NOT be discovered.
  List what you installed.

  Skills are read only when ZCode starts, exactly like MCP servers. Do not claim
  they are working in this session. They are working when a NEW task can use them.

Phase 8 — Verify
  Run: powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
  Show me the full output, then summarise it in plain language:
  what works, what is optional, what is broken.

Phase 9 — Report
  Give me:
    - a table of every tool with its version,
    - every file you created or changed, with its full path,
    - anything you changed a backup of,
    - the exact things that still need a human (browser logins, purchases),
    - what I should do now: close ZCode, reopen it, start a NEW task,
    - what to ask you in that new task to check the MCP servers came up,
    - one suggested next step.

  Be explicit that the MCP servers and skills cannot work in this session, and
  that the new task is where they will. Do not tell me something is verified when
  it can only be verified after a restart.

Ask me the Notion and Blender questions when you reach Phase 6 - both default to
no, and "no" to both is a complete answer. Begin with Phase 0.
```

---

## 3. The runbook the agent follows

This is what the agent above will do. Read it so you can tell if it goes off track.

### Phase 0 — Recon

Nothing is changed yet. The agent reports your Windows version, whether `winget` exists, and which tools are already present.

**Check it:** it should show you a recon result and go straight on to installing. It should **not** pause for your approval to install standard tooling — that is ground rule 5 in the prompt. It should stop and tell you only if something unexpected turns up: `winget` missing, a tool present but broken, or a version old enough to change the plan.

### Phase 1 — Install tools

Six `winget` installs, then a version check on each.

**Check it:** each tool prints a version. The usual failure is an agent that checks a tool in the same shell it installed it in, does not find it, and installs it again. The prompt tells it not to do that.

### Phase 2 — Dev folder

`C:\Users\<your-name>\Dev` plus `Dev\_sandbox`.

**Check it:** the folder exists, and it is not inside OneDrive.

### Phase 3 — Git identity

Sets your name and email for Git commits. **It must ask you for both.** If the agent invents an email address, stop it and give it the real one — every commit you ever make will carry that address.

### Phase 4 — GitHub login (human gate)

The agent starts `gh auth login` and hands over. You complete the browser flow. Then the agent runs `gh auth setup-git` and `gh auth status`.

**Check it:** the last command prints `✓ Logged in to github.com`.

### Phase 5 — Clone this repo

Gets `config/` and `scripts/` onto your machine so the rest can run.

### Phase 6 — MCP servers (both optional, and it asks first)

The agent asks whether you want Notion, and whether you use Blender. **If you say no to both, this phase ends there** — an empty or absent `mcp.servers` is a normal, working configuration, and no restart is needed.

If you say yes to something, it backs up `config.json`, merges in that server, and gives you a handover telling you to restart.

**Check it:** `config.json.bak-<timestamp>` exists next to the original. If the agent edited without a backup, your original config is gone.

**This is the riskiest phase.** Two traps:

**1. The nesting.** `mcp.servers` is a *nested* object:

```json
{ "mcp": { "servers": { "notion": { ... } } } }
```

An agent that writes `"mcpServers"` at the top level, or `"servers"` at the top level, produces a file ZCode silently ignores. See [reference/zcode-config-map.md](reference/zcode-config-map.md).

**2. It installs code from the internet.** The Notion entry runs `npx -y mcp-remote` — that downloads and runs a package every time it starts — and the Blender entry runs a script fetched from a URL and piped straight into PowerShell. Both are normal for MCP servers and both deserve knowing about.

That is why the Notion entry in this guide pins `mcp-remote@0.14.2` instead of taking whatever is newest. **Check that your agent pinned a version, and ask it what the Blender installer does before it runs it.** If it cannot tell you, that is a reason to stop.

The full trust model, and how to update a pinned version deliberately: *Where the code comes from* in [reference/mcp-servers.md](reference/mcp-servers.md).

### Phase 7 — Skills

Copies `skills\*` into `C:\Users\<your-name>\.agents\skills\`.

**Check it:** run this and confirm each skill folder directly contains `SKILL.md`:

```powershell
Get-ChildItem "$env:USERPROFILE\.agents\skills" -Recurse -Filter SKILL.md |
  Select-Object -ExpandProperty FullName
```

### Phase 8 — Verify

Runs the check script and explains the result.

### Phase 9 — Report

Every tool version, every file touched, every backup made, and what is left for you.

---

## 4. What the agent must not do

If your agent tries any of these, stop it:

| It must not | Why |
|---|---|
| Type your passwords | Only ever sign in through the official browser page |
| Install a browser extension or helper "to make login easier" | Not part of this setup |
| Buy, upgrade or subscribe to anything | Costs money and depends on the account you were given |
| Delete a config file and write a fresh one | Loses other settings. Merge, and back up first |
| Disable Windows Defender, the firewall, or a security setting | Fix the actual problem instead |
| Force-push, or rewrite Git history | Destroys work with no way back |
| Push to GitHub without asking you | Committing is local and reversible. Pushing publishes, where others can see it and it is awkward to take back |
| Set `ExecutionPolicy` to `Unrestricted` permanently | The setup only needs `Bypass` for one window, one time |
| Invent a Git name or email instead of asking you | Every commit you ever make carries that address |
| Claim the MCP servers or skills are working in the setup session | They load only when ZCode starts. Verified means verified in a **new task** |

---

## 5. After the agent is done

**Steps 1 to 5 apply only if you asked for Notion or Blender.** If you said no to both, there is nothing to configure and no restart is needed — skip to step 6.

**MCP servers and skills are read once, when ZCode starts.** The agent configures them; you restart; they work in the next task. That is why the MCP phase comes last in the runbook — everything that needs the agent still running happens before it.

1. Close ZCode completely — not minimise. Quit it from the system tray if it sits there.
2. Open it again, and start a **New Task**.
3. Check that the config survived the restart:

```
Is mcp.servers still in my config? List what is in it.
```

If it is empty, ZCode rewrote the file as it closed. Have the agent add the servers again — the second attempt sticks, because the restart has already happened.

4. Ask the agent: *"Which MCP tools do you have?"* The servers you asked for should appear. An empty list is a normal, working setup if you said no to both.
5. If you asked for Notion, ask: *"List the Notion pages you can see."* The first call opens a browser for you to approve.
6. Run the verification yourself, so you see it with your own eyes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
```

If your projects live somewhere other than `%USERPROFILE%\Dev`, pass the path so it is not reported as missing:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1 -DevRoot "D:\Dev"
```

7. Then go to **[03-first-project.md](03-first-project.md)** and build something small.

**If something is broken**, the agent will have left a report. Compare it with [CHECKLIST.md](CHECKLIST.md) to find the stage that did not land, then read [reference/troubleshooting.md](reference/troubleshooting.md).

---

## 6. Reusing this prompt

This prompt works on any Windows machine, not just this one. It is the same phases every time.

When you set up a second machine, come back to this file and paste the same prompt. That is the whole point of writing the setup down instead of doing it from memory.

**Its place in the bigger picture:** this file is the agent's half. Your half — the actions only you can take, and the questions this prompt will make the agent ask you — is [01-human-setup.md](01-human-setup.md). If you are setting up a machine from scratch, read that one and let it drive. This file is the detail behind the prompt.
