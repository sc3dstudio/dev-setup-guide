# Troubleshooting

Symptom → cause → fix. Find your symptom, try the fix, and if it does not work, the section *Getting help properly* at the end tells you what to send to someone for a fast answer.

---

## First, three questions that solve most problems

Ask these before anything else. They isolate the failure to one layer.

1. **Did you close and reopen the terminal?** An installed tool is invisible to a terminal that was already open. This alone accounts for a large share of "the install did not work".
2. **Did you restart ZCode?** MCP servers and skills are loaded at startup. A config change and a skill copy do nothing until ZCode restarts.
3. **Did the last thing work?** If yes, the problem is in the change you just made. Undo it and confirm the good state returns, then redo the change one piece at a time.

---

## Tools and the terminal

### `X is not recognized as the name of a cmdlet`

The command is not on your `PATH`, or it is not installed.

```powershell
# Is it installed at all?
winget list --id Git.Git          # swap in the package id you are checking
```

**In order:**

1. Close the terminal completely, open a new one, try again.
2. Still failing? Restart the computer — this refreshes `PATH` for every process.
3. Still failing? Re-run that one install:
   ```powershell
   winget install --id <Package.Id> -e --accept-source-agreements --accept-package-agreements
   ```
4. Check the install folder exists. For Node it is `C:\Program Files\nodejs`, for Python `C:\Users\<your-name>\AppData\Local\Programs\Python\Python312`.

### `python` opens the Microsoft Store

Windows ships a fake `python` alias.

**Settings → Apps → Advanced app settings → App execution aliases** → switch **off** `python.exe` and `python3.exe`. Open a new terminal.

### `python3` is not recognised

Normal on Windows. Use `python`. There is no `python3` command here.

### A command works in PowerShell but not in Git Bash

Different `PATH`. Use whichever terminal the guide named for that command, and do not mix them in one step.

### `winget` is not recognised

The **App Installer** is missing or too old. Microsoft Store → search **App Installer** → update → new terminal.

### `Access is denied` or the installer asks for permission

Close the terminal, right-click **Windows PowerShell** → **Run as administrator**, run the command again.

### Where did a tool install itself?

```powershell
Get-Command git, node, python, uv, gh |
  Select-Object Name, Version, Source
```

`Source` is the full path to the executable. Recent Windows also keeps `C:\Users\<your-name>\AppData\Local\Microsoft\WinGet\Packages\` for winget installs.

---

## ZCode

### ZCode will not open, or closes immediately

1. Reboot and try again.
2. Reinstall — download a fresh installer from `https://zcode.z.ai`.
3. Antivirus interference: allow the install folder (`C:\Users\<your-name>\AppData\Local\Programs\ZCode`) and try again.

### The installer is blocked by SmartScreen

**More info → Run anyway.** The block is because the installer is new, not because it is malicious. Verify you downloaded it from `zcode.z.ai`.

### No model is available / the agent cannot answer

The model connection is the problem, not the agent.

1. Bottom-left corner: does it show a model, or a **Connect** button?
2. If it shows **Connect**, sign in again.
3. If it shows a model but requests fail, the subscription or key is not active. Check the account.
4. Sign out and sign in again — this fixes more provider problems than anything else.

### Where are my settings?

| | Path |
|---|---|
| User config (MCP, plugins, hooks) | `C:\Users\<your-name>\.zcode\cli\config.json` |
| Global instructions | `C:\Users\<your-name>\.zcode\AGENTS.md` |
| App installation | `C:\Users\<your-name>\AppData\Local\Programs\ZCode` |
| Plugin cache | `C:\Users\<your-name>\.zcode\cli\plugins\cache` |

A map of every file and which one wins: [zcode-config-map.md](zcode-config-map.md).

---

## Configuration files

### ZCode lost all my MCP servers

You almost certainly broke the JSON. Restore the backup and redo the edit carefully.

```powershell
$dir = "$env:USERPROFILE\.zcode\cli"
Get-ChildItem $dir -Filter 'config.json.bak-*' | Sort-Object Name -Descending | Select-Object -First 5
Copy-Item "$dir\config.json.bak-<timestamp>" "$dir\config.json"
```

No backup? Then the file was hand-edited without one. Rebuild it from `config\mcp.servers.example.json` in this repo.

### Is my JSON valid?

```powershell
Get-Content "$env:USERPROFILE\.zcode\cli\config.json" -Raw | ConvertFrom-Json | Out-Null
Write-Host "JSON is valid"
```

Anything other than `JSON is valid` means a syntax error. The message names the line and character.

**The four mistakes that cause almost all of them:**

| Mistake | Wrong | Right |
|---|---|---|
| Backslash in a path | `"C:\Program Files\nodejs\npx.cmd"` | `"C:/Program Files/nodejs/npx.cmd"` |
| Trailing comma | `"args": ["a", "b",]` | `"args": ["a", "b"]` |
| A comma after the last entry | `{ "a": 1, "b": 2, }` | `{ "a": 1, "b": 2 }` |
| A comment | `// the notion server` | JSON has no comments. Remove it |

### My edit had no effect

1. **Was ZCode open while you edited?** It writes `config.json` on exit and overwrites your change. Close ZCode, edit, save, reopen.
2. **Are you editing the file that wins?** User scope beats workspace scope. See [zcode-config-map.md](zcode-config-map.md).
3. **Is the key name right?** `mcp.servers` in `.zcode\cli\config.json`, but `mcpServers` in `.agents\mcp.json`. Using the wrong one means the file is read and the setting is not found.
4. **Is it valid JSON?** Run the check above.

---

## MCP servers

### A server is missing from Settings → MCP

The file is not being read — usually invalid JSON, or the wrong key name. Validate first, then compare against the shape in [mcp-servers.md](mcp-servers.md).

### A server shows an error state

Its `command` does not start. Most often a wrong path.

```powershell
where.exe npx
Get-ChildItem "$env:LOCALAPPDATA\BlenderMCP" -Recurse -Filter 'blender-mcp.exe'
```

Copy the exact path into the config, with forward slashes.

### A server connects but returns nothing

For Notion: the browser sign-in has not been completed. Restart ZCode and ask the agent to list pages — a browser should open. The approval is cached in `~\.mcp-auth\mcp-remote-v1\`.

### A server times out

Raise the timeout:

```json
"timeoutMs": 120000
```

Also check whether a corporate proxy or VPN is intercepting the connection.

### Blender tools fail even though the server is connected

Three things must all be true:

1. **Blender is running.** The MCP server bridges to a live session; it does not launch Blender.
2. **The BlenderMCP add-on is enabled.** In Blender: **Edit → Preferences → Add-ons**, tick **Blender MCP**, save preferences.
3. **The add-on shows connected.** Press `N` in the 3D Viewport, open the **BlenderMCP** tab, check the status.

### The agent calls the wrong Blender tool

Two Blender servers are registered at once. Keep one, delete the other, restart ZCode.

### How many tools does the agent actually have?

```
List every MCP tool you have, grouped by server name.
```

Nothing under a server name means that server is not connected — regardless of what Settings claims.

---

## Skills

### A skill never triggers

In order of likelihood:

1. **`SKILL.md` is one level too deep.** It must be directly inside the skill folder.
2. **ZCode was not restarted.** Skills load at startup.
3. **The `description` is not a trigger.** It is the only part the agent uses to decide. Rewrite it as *"Use when the user asks to ..."* and include the words you actually say.
4. **It is shadowed by a same-named skill** in a higher-priority folder.
5. **The frontmatter is malformed.** `---` on line one, `name:` and `description:`, `---` to close, no indentation.

**Find every skill and its path:**

```powershell
Get-ChildItem "$env:USERPROFILE\.agents\skills","$env:USERPROFILE\.zcode\skills" `
  -Recurse -Filter SKILL.md -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty FullName
```

Then ask the agent which copy it would load for that name. See [skills-and-plugins.md](skills-and-plugins.md).

### I edited a skill and nothing changed

You edited a shadowed copy, or you did not restart ZCode. Both are answered by the command above plus a restart.

---

## Git and GitHub

### `fatal: not a git repository`

You are not inside a repo, or the folder has no `.git`.

```powershell
git status              # confirms it
git init                # only if you want a NEW repo here
```

**Do not run `git init` inside a project that already has Git** — you would create a nested repo. Check `git status` first.

### `gh: not logged in`

```powershell
gh auth login
gh auth setup-git
gh auth status
```

### `Permission denied (publickey)` or it asks for a password

Git is not using the `gh` credentials.

```powershell
gh auth setup-git
git config --global credential.helper   # should print: manager
```

### `Updates were rejected because the remote contains work that you do not have`

Someone else pushed, or you pushed from another machine. Pull first:

```powershell
git pull --rebase
```

If it reports conflicts, stop and get help. Do not force-push.

### `Filename too long`

```powershell
git config --global core.longpaths true
```

Windows also has a system-wide long-path setting that this approximates. The Git setting fixes the Git side.

### I committed something I should not have

**A secret** (key, password, token): assume it is leaked. **Rotate the key first** — that is the only real fix. Then remove it from the file and commit the removal. History rewriting does not help, because the value was already published.

**A large or wrong file:** if you have not pushed yet:

```powershell
git reset --soft HEAD~1     # un-commit, keep your files as they are
```

Then fix the files, `git add` the right ones, and commit again.

### I am afraid I broke something

```powershell
git status          # what is changed but not committed
git log --oneline   # your saved points
git diff            # the exact changes
```

Almost nothing is lost while it is committed. If the working tree is a mess and the last commit was good:

```powershell
git restore .       # discards uncommitted changes — this DOES lose work
```

Prefer committing the mess to a temporary branch over discarding it:

```powershell
git checkout -b mess-<date>
git add .
git commit -m "WIP before cleanup"
git checkout main
```

Now nothing is lost and you can go back to something good.

> **Never run `git reset --hard` or `git push --force`** because an agent suggested it, unless someone experienced confirms it for that specific case. Both destroy work permanently.

---

## The agent itself

### The agent seems confused, or forgets earlier instructions

Start a fresh session. Long sessions drift. Before you close, commit your work, and move any rule that matters into the project's `AGENTS.md` so the next session starts with it.

### The agent keeps making the same mistake

It is probably guessing because the request is ambiguous. Be concrete about what "done" looks like:

```
That is not what I wanted. Done looks like: <specific observable result>.
Do not change anything else. Show me the diff before you continue.
```

### The agent says it is done but it is not

Ask for evidence, not assurance:

```
Run it and show me the actual output. Do not describe what it should do.
```

An agent that cannot produce the output has not verified anything.

### The agent wants to install a package or tool

Reasonable to allow for common packages. Read what it is first. Fewer dependencies means fewer things that can break, and every dependency is code by someone else running on your machine.

### The agent asks for a permission and I do not understand it

Copy the command and ask:

```
Explain this command in plain language: <paste>. What could it change,
and what is the worst case if I say yes?
```

You are allowed to say no. If the agent cannot explain it, do not approve it.

### The agent removed hours of work

Recover from Git:

```powershell
git log --oneline
git restore .                    # if the damage is uncommitted
git checkout <commit> -- <file>  # restore one file from a commit
```

Then change your habits, in this order: commit more often, open one project instead of all of `Dev`, and read the permission prompts.

---

## Getting help properly

A vague report gets a vague answer. Send these five things:

1. **What you did** — the exact command or the exact request you typed.
2. **What you expected** — one sentence.
3. **What happened instead** — the full error text. Copy it, do not retype or paraphrase it.
4. **Whether it worked before** — and if so, what changed since.
5. **The output of the checks:**

```powershell
git --version; node -v; npm -v; python --version; uv --version; gh --version
git status
```

For configuration problems, also send the output of the JSON validation command above — it names the line and character of a syntax error.

**Then run the verification script** and include its output. It is designed exactly for this:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
```

**Do not send API keys or tokens.** When you paste a config, replace any key with `<REDACTED>`. Nobody needs it to diagnose your problem.
