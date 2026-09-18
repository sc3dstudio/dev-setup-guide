# Track B — Let your agent do the setup

You install ZCode and connect a model. Then you paste one prompt, and the agent installs and checks everything else.

This file has three parts:

1. **[Before you paste](#1-before-you-paste)** — the two things you must do yourself first.
2. **[The prompt](#2-the-prompt)** — copy this into ZCode. This is the whole interface.
3. **[The runbook](#3-the-runbook-the-agent-follows)** — what the agent will actually do. Read it so nothing surprises you.

---

## 1. Before you paste

The agent cannot do these two things, because both need a human at a keyboard.

- [ ] **ZCode is installed and open.** See [01-human-setup.md](01-human-setup.md) Step 7.
- [ ] **A model is connected**, and asking ZCode *"List the files in the current directory"* gives a real answer. See [01-human-setup.md](01-human-setup.md) Step 8.

Without a connected model there is no agent, and there is nothing to paste a prompt into.

**Also decide this before you start:**

| Question | Why it matters |
|---|---|
| Do you use Blender? | If yes, the agent installs the Blender MCP and the Blender add-on. If no, it skips it. |
| Do you want Notion connected now? | It is optional and can be added later. It needs a browser sign-in from you. |

You will be asked these. Have the answers ready.

---

## 2. The prompt

Open ZCode. Make sure you are in a folder inside your `Dev` directory — or in no folder at all, which is fine too.

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
5. Never put a password, API key or token into a file that goes into a Git repo.
6. After installing a tool, a NEW terminal is needed for it to be on PATH. Either open
   a new shell or refresh PATH from the registry. Do not conclude an install failed
   just because the current shell cannot see the command.
7. If a step fails and you cannot fix it after two attempts, STOP. Report what you tried,
   the exact error text, and what you need from me. Do not guess and continue.
8. Explain in plain language what each tool is for the first time you install it.
   I am new to this. Assume I do not know what "PATH" or "package manager" means.

PHASES — do them in this order

Phase 0 — Recon (change nothing)
  Report: Windows version, whether winget works, and which of these already exist:
  git, node, npm, python, uv, gh, rg.
  Show me the result before you install anything.

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

Phase 6 — ZCode MCP servers
  ZCode's user config is: C:\Users\<my-name>\.zcode\cli\config.json
  It holds mcp.servers as a NESTED object. MCP servers live at mcp.servers, not at
  the top level.
  - BACK UP the file before editing it, to config.json.bak-<timestamp>.
  - MERGE. Never overwrite servers that are already there.
  - JSON is strict: no trailing commas, no comments, forward slashes in every path.
  - Server to add: notion
      command: <full path to npx.cmd, find it with: where.exe npx>
      args:    -y mcp-remote https://mcp.notion.com/mcp --transport http-only
      timeoutMs: 60000
  - Server to add, ONLY IF I tell you I use Blender: blender-fork
      Install via the official bootstrap:
        Set-ExecutionPolicy Bypass -Scope Process -Force
        irm https://raw.githubusercontent.com/newo-ether/blender-mcp/main/bootstrap.ps1 | iex
      This is interactive: it shows a checklist and asks which Blender version and
      which MCP clients to register. Tell me what it is asking and wait for my input.
      It also installs the Blender add-on. Then find the executable:
        Get-ChildItem "$env:LOCALAPPDATA\BlenderMCP" -Recurse -Filter blender-mcp.exe
      and register that path as the blender-fork command, with env:
        BLENDER_MCP_DISABLE_TELEMETRY = "1"
    If the installer refuses to run non-interactively, stop and hand it to me.
  - ZCode must be CLOSED while you edit this file, or it overwrites your change on exit.
    Tell me to close it, then tell me to reopen it.

Phase 7 — Skills
  Copy the repo's skills\* folders into C:\Users\<my-name>\.agents\skills\
  The rule: each skill is a folder directly containing a SKILL.md.
  A layout like skills\name\name\SKILL.md will NOT be discovered.
  List what you installed.

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
    - one suggested next step.

Ask me the Blender and Notion questions now, then begin with Phase 0.
```

---

## 3. The runbook the agent follows

This is what the agent above will do. Read it so you can tell if it goes off track.

### Phase 0 — Recon

Nothing is changed. The agent reports your Windows version, whether `winget` exists, and which tools are already present.

**Check it:** it should ask you the Blender and Notion questions and show you a recon result *before* installing anything. An agent that starts installing immediately skipped this.

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

### Phase 6 — MCP servers

The agent backs up `config.json`, merges in the servers, and restarts ZCode.

**Check it:** `config.json.bak-<timestamp>` exists next to the original. If the agent edited without a backup, your original config is gone.

**This is the riskiest phase.** The specific trap: `mcp.servers` is a *nested* object.

```json
{ "mcp": { "servers": { "notion": { ... } } } }
```

An agent that writes `"mcpServers"` at the top level, or `"servers"` at the top level, produces a file ZCode silently ignores. See [reference/zcode-config-map.md](reference/zcode-config-map.md).

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
| Set `ExecutionPolicy` to `Unrestricted` permanently | The setup only needs `Bypass` for one window, one time |
| Store an API key in a file inside a repo | It will be published the moment you push |

---

## 5. After the agent is done

1. Run the verification yourself, so you see it with your own eyes:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
   ```
2. Close ZCode completely and open it again. This is what loads the new MCP servers and skills.
3. Ask the agent: *"Which MCP tools do you have?"* Blender and Notion should appear.
4. If Notion is installed, ask: *"List the Notion pages you can see."* The first call opens a browser for you to approve.
5. Start your first working session with the prompt in **[START-PROMPT.md](START-PROMPT.md)**. That prompt installs nothing — it orients the agent, tells it you are new, and sets up how you two will work together.
6. Then go to **[03-first-project.md](03-first-project.md)** and build something small.

**If something is broken**, the agent will have left a report. Compare it with [CHECKLIST.md](CHECKLIST.md) to find the step that did not land, then read [reference/troubleshooting.md](reference/troubleshooting.md).

---

## 6. Reusing this prompt

This prompt works on any Windows machine, not just this one. It is the same six steps every time.

When you set up a second machine, come back to this file and paste the same prompt. That is the whole point of writing the setup down instead of doing it from memory.
