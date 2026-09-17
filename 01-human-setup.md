# Track A — Setup by hand

Every step the agent would do, done by you. Read one step, do it, check the result, then move on.

**How to read this file:** each step has *Do this*, *You should see*, and — only when it commonly happens — *If it fails*.

**Two tips before you start:**

- Do the steps in order. Later steps assume earlier ones worked.
- If a step fails and the fix is not listed, stop and ask. Do not continue and hope.

---

## Step 0 — Open a terminal

**Do this**

1. Press the `Windows` key.
2. Type `PowerShell`.
3. Click **Windows PowerShell**.

**You should see**

A blue window with a prompt ending in `>`:

```
PS C:\Users\<your-name>>
```

This window is your terminal. You will paste commands here. To paste, right-click inside the window, or press `Ctrl+V`.

**If it fails**

If PowerShell will not open, restart the computer and try again.

> **Why not just run the script?** There is a script, `scripts/setup-windows.ps1`, that does steps 2 and 4 for you. Doing it by hand first is better, because you see what each tool is and you will recognise a problem later. Section *Shortcut* at the end of this file shows the script.

---

## Step 1 — Install the basic tools

You need six tools. You install all of them with `winget`, the Windows package manager.

**Do this**

Copy this whole block, paste it into PowerShell, and press `Enter`. It installs the tools one after another and may take 10-15 minutes.

```powershell
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
winget install --id Python.Python.3.12 -e --accept-source-agreements --accept-package-agreements
winget install --id astral-sh.uv -e --accept-source-agreements --accept-package-agreements
winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements
winget install --id BurntSushi.ripgrep.MSVC -e --accept-source-agreements --accept-package-agreements
```

**What each one is for:**

| Tool | What it does |
|---|---|
| `Git.Git` | Records changes to your files. Your undo button. |
| `OpenJS.NodeJS.LTS` | Runs JavaScript tools. Installs `npm`, which downloads most MCP servers. |
| `Python.Python.3.12` | Runs Python tools. |
| `astral-sh.uv` | Installs and runs Python tools cleanly. Provides `uvx`. |
| `GitHub.cli` | The `gh` command. Talks to GitHub. |
| `BurntSushi.ripgrep.MSVC` | A very fast text search tool. Agents use it constantly. |

**You should see**

For each tool, lines ending with something like:

```
Successfully installed
```

Some installers will ask for permission to make changes. Click **Yes**.

A few may print `Found an existing package already installed` and skip. That is fine.

**If it fails**

- **`winget` is not recognised.** You are on an old Windows version. Open the Microsoft Store, search for **App Installer**, update it, close PowerShell, open it again.
- **A tool says `No package found`.** Check you copied the whole line, including the `--accept-...` parts.
- **Permission errors.** Close PowerShell, then right-click **Windows PowerShell** and choose **Run as administrator**. Run the commands again.

---

## Step 2 — Close and reopen the terminal

This step looks pointless. It is not. It is the single most common reason a beginner thinks an install failed.

**Do this**

1. Close the PowerShell window completely.
2. Open PowerShell again, the same way as Step 0.

**Why**

Installing a tool changes your `PATH` — the list of folders Windows searches for commands. Windows only reads that list when a terminal starts. An open terminal will not see a tool you just installed, even though the install worked.

If you skip this, the next step will tell you `node` is not recognised, and you will install it a second time for no reason.

---

## Step 3 — Check that the tools work

**Do this**

Paste this block into PowerShell:

```powershell
git --version
node -v
npm -v
python --version
uv --version
gh --version
```

**You should see**

Six lines, each a version number. The exact numbers do not matter. They will look roughly like this:

```
git version 2.55.0.windows.3
v24.19.0
11.17.0
Python 3.12.10
uv 0.12.15
gh version 2.101.0
```

**If it fails**

- **`... is not recognized as the name of a cmdlet`** — the tool is installed but not on your `PATH`. Close the terminal, open a new one, try again. Still failing? Restart the computer. Still failing? The install did not complete; run that one `winget install` line again.
- **`python` opens the Microsoft Store.** Windows has a fake `python` shortcut. Fix it in **Settings → Apps → Advanced app settings → App execution aliases**, and switch **off** the `python.exe` and `python3.exe` entries. Then try again.
- **`python` works but `python3` does not.** This is normal on Windows. Always use `python`, never `python3`.

---

## Step 4 — Create your Dev folder

This is where every project will live. One folder, in a known place. Later, "where is my project" always has the same answer.

**Where, and why there**

```
C:\Users\<your-name>\Dev
```

Not in `Documents`, and **not inside OneDrive**.

OneDrive syncs everything it contains. A project folder fills up with thousands of small files (`node_modules`, `.venv`, `.git`). OneDrive tries to sync all of them, which slows your machine down and can corrupt a project mid-write. Keep code out of OneDrive. This one decision saves hours later.

**Do this**

```powershell
$DevRoot = Join-Path $env:USERPROFILE 'Dev'
New-Item -ItemType Directory -Force -Path $DevRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DevRoot '_sandbox') | Out-Null
Write-Host "Dev root is $DevRoot"
```

**You should see**

```
Dev root is C:\Users\<your-name>\Dev
```

**What you just made**

| Folder | Use |
|---|---|
| `Dev` | the root. Every project is a folder inside it. |
| `Dev\_sandbox` | somewhere to make a mess. Test projects, throwaway experiments, "what does this command do". |

**If it fails**

If `$env:USERPROFILE` is empty, you are not in PowerShell. Use `cmd` style: `echo %USERPROFILE%`.

---

## Step 5 — Tell Git who you are

Git stamps every commit with a name and an email. Set them once.

**Do this**

Replace the two values with your own, then paste:

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.longpaths true
git config --global core.autocrlf true
```

**What each line does**

| Setting | Why |
|---|---|
| `user.name` / `user.email` | Who made each commit. Use the email on your GitHub account. |
| `init.defaultBranch main` | New repos start on `main`, the modern default. |
| `core.longpaths true` | Lets Git handle long file paths. Windows normally refuses paths over 260 characters, and deep project folders hit that easily. |
| `core.autocrlf true` | Handles the difference between Windows and Unix line endings. |

**You should see**

Nothing at all. Silence means success. These commands have no output.

**If it fails**

`git: command not found` means Step 1 did not finish. Go back.

---

## Step 6 — Log in to GitHub

**Do this**

```powershell
gh auth login
```

It asks questions. Answer like this:

| Question | Answer |
|---|---|
| What account do you want to log into? | `GitHub.com` |
| What is your preferred protocol for Git operations? | `HTTPS` |
| Authenticate Git with your GitHub credentials? | `Yes` |
| How would you like to authenticate? | `Login with a web browser` |

It then shows a **one-time code** like `A1B2-C3D4` and asks you to press `Enter`.

Press `Enter`. Your browser opens. Paste the code, sign in to GitHub, click **Authorize**.

**You should see**

Back in the terminal:

```
✓ Logged in as <your-github-name>
```

**Then run this**, so Git itself can use the login:

```powershell
gh auth setup-git
gh auth status
```

**You should see**

```
✓ Logged in to github.com account <your-github-name>
```

**If it fails**

- **The browser does not open.** Copy the URL the terminal printed and paste it into your browser by hand. The code still works.
- **The code expired.** Codes last a few minutes. Run `gh auth login` again for a fresh one.
- **You have no GitHub account.** Make one at `github.com` first — free.

---

## Step 7 — Install ZCode

ZCode is the application you will actually work in. It is a normal Windows program.

**Do this**

1. Open `https://zcode.z.ai` in your browser.
2. Download the **Windows x64** installer.
3. Run the installer. Click **Next** through the wizard, then **Install**.
4. Open **ZCode** from the Start menu.

For reference, the current Windows x64 installer link looks like this:

```
https://cdn-zcode.z.ai/zcode/electron/releases/<version>/windows-x64/ZCode-<version>-win-x64.exe
```

Use the download page rather than a saved link, so you always get the current version.

**You should see**

An onboarding screen. It offers **Start using ZCode** or a **Data Migration Wizard**. Choose **Start using ZCode** — the migration wizard is only for people moving from another tool.

**If it fails**

- **Windows SmartScreen blocks it** ("Windows protected your PC"). Click **More info**, then **Run anyway**. The block is because the installer is new, not because it is dangerous.
- **Your antivirus blocks it.** Allow the installer, or allow the ZCode install folder, then try again.
- **It installs to `C:\Users\<your-name>\AppData\Local\Programs\ZCode`.** That is normal and correct.

---

## Step 8 — Connect a model

ZCode needs a model before it can do anything. Right now it can open a chat box but has nothing to think with.

**Do this**

1. In ZCode, click **Connect** in the bottom-left corner.
2. You are offered three routes:
   - **Connect Z.ai** — sign in to a Z.ai account. This is the normal choice with a Coding Plan subscription.
   - **Connect BigModel** — the China-region equivalent.
   - **Use API Key** — paste an API key you were given.
3. Follow the route you were told to use. Sign in and press **Allow** when asked.

**You should see**

The bottom-left corner shows the model name instead of a **Connect** button.

**Then prove it works**

In the chat box, type exactly this and press `Enter`:

```
List the files in the current directory.
```

**You should see**

The agent runs a command and replies with a list of files, or says the folder is empty. Either answer means the connection works.

**If it fails**

- **No model is listed** — your subscription or key is not active. Check the account, then sign in again.
- **It answers with an error about the provider** — the key or session is wrong. Disconnect and connect again.
- **Ask before buying a subscription.** The right plan depends on the account you are being set up with.

---

## Step 9 — Add the MCP servers

MCP servers give your agent abilities beyond reading files. You will add two: Blender and Notion.

In this step you edit a configuration file. It is a **JSON** file, which is strict about punctuation:

- Every `"name"` and every value is in double quotes.
- Items in a list are separated by commas.
- **No comma after the last item in a list or object.**
- **No comments.** JSON has no way to write a comment.

One wrong comma stops the whole file from being read. If ZCode suddenly loses all MCP servers, check your commas first.

### 9a — Open the configuration file

**Do this**

```powershell
notepad $env:USERPROFILE\.zcode\cli\config.json
```

If Notepad says the file does not exist, ZCode has not written its config yet. Open ZCode, change any setting (for example, switch a toggle in Settings), close ZCode, and try again.

**You should see**

Either an empty Notepad window, or content like this:

```json
{
  "plugins": {
    "enabledPlugins": {}
  },
  "mcp": {
    "servers": {}
  }
}
```

The exact contents will differ. That is fine. You are going to **add to** this file, never replace it.

**Before you edit**, close ZCode. ZCode writes this file when it exits, so editing it while ZCode is open can lose your change.

### 9b — Add an MCP server

Inside the `"servers"` object, add an entry. Separate it from any existing entry with a comma.

Here is a minimal server, to see the shape:

```json
{
  "mcp": {
    "servers": {
      "notion": {
        "type": "stdio",
        "command": "C:/Program Files/nodejs/npx.cmd",
        "args": [
          "-y",
          "mcp-remote",
          "https://mcp.notion.com/mcp",
          "--transport",
          "http-only"
        ],
        "timeoutMs": 60000
      }
    }
  }
}
```

**Things to notice:**

- `"command"` is the program to start. Use **forward slashes** (`/`) in paths, not backslashes. Backslashes need escaping in JSON and are a common source of broken configs.
- `"args"` is the list of arguments passed to that program. Each one is its own quoted string.
- `"timeoutMs"` is how long ZCode waits. Network servers need a longer timeout.

To check that the `npx.cmd` path is right on your machine:

```powershell
where.exe npx
```

If it prints a different path, use that one in the config.

### 9c — Blender

The Blender MCP lets your agent inspect and change a Blender scene.

**Only do this part if you use Blender.** If you do not, skip to 9d.

The recommended installer handles the Python environment, the Blender add-on and the MCP registration for you:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/newo-ether/blender-mcp/main/bootstrap.ps1 | iex
```

> **What that does:** the first line allows scripts to run *in this window only* — it does not change your system settings. The second downloads the installer and runs it. The installer is interactive: it shows a checklist, asks which Blender version to install the add-on into, and asks which MCP clients to register.
>
> Read installer scripts before running them. This one is public on GitHub, so you can read `bootstrap.ps1` at the URL above first. If you would rather not pipe a script straight into a shell — a reasonable instinct — download it, read it, then run it.

Afterwards, find the installed server executable:

```powershell
Get-ChildItem "$env:LOCALAPPDATA\BlenderMCP" -Recurse -Filter 'blender-mcp.exe' |
  Select-Object -ExpandProperty FullName
```

Then add it to `config.json`, replacing the path with the one printed above:

```json
"blender-fork": {
  "type": "stdio",
  "command": "C:/Users/<your-name>/AppData/Local/BlenderMCP/venv-<version>/Scripts/blender-mcp.exe",
  "args": [],
  "env": {
    "BLENDER_MCP_DISABLE_TELEMETRY": "1"
  }
}
```

The `env` block switches off telemetry. Set it to `"0"` if you want it on.

**Remember the comma.** If `blender-fork` is not the only entry in `"servers"`, the entry before it needs a comma after its closing `}`.

### 9d — Restart ZCode and check

**Do this**

1. Save the config file and close Notepad.
2. Open ZCode.
3. Go to **Settings → MCP**.
4. Each server should be listed and connected, with a green state.

**You should see**

`notion` and (if you added it) `blender-fork` in the list, connected.

**If it fails**

| Symptom | Cause | Fix |
|---|---|---|
| All servers gone from the list | Broken JSON | Check for a missing comma, a trailing comma, or a backslash in a path |
| Server listed but shows an error | Command path wrong | Run `where.exe npx` and compare with the config |
| Notion connects but shows no data | Not signed in yet | See [reference/notion-access.md](reference/notion-access.md) — the first connection opens a browser |
| Server takes very long | Network timeout | Raise `timeoutMs` to `120000` |

A full reference for every server, including what each tool can do, is in [reference/mcp-servers.md](reference/mcp-servers.md).

---

## Step 10 — Install skills

A skill is a folder with a `SKILL.md` inside it. Installing one means copying it to the right place.

The folder for your personal skills:

```
C:\Users\<your-name>\.agents\skills\
```

**Do this — install a skill from this repo**

```powershell
$skills = Join-Path $env:USERPROFILE '.agents\skills'
New-Item -ItemType Directory -Force -Path $skills | Out-Null
Copy-Item -Recurse -Force `
  (Join-Path $PWD 'skills\sync-skills-from-notion') `
  (Join-Path $skills 'sync-skills-from-notion')
Get-ChildItem $skills
```

**You should see**

```
sync-skills-from-notion
```

**Then check that ZCode found it**

Restart ZCode. Go to **Settings → Skills**. Your skill should be in the list.

**If it fails**

- **The skill is not in the list.** In ZCode, skills are discovered from several folders. Check the folder name matches the skill name, and that `SKILL.md` is directly inside it — not one level deeper. A structure like `skills\my-skill\my-skill\SKILL.md` will not be found.
- **You copied it but nothing changed.** Restart ZCode. Skills are scanned at startup.

Read [reference/skills-and-plugins.md](reference/skills-and-plugins.md) for where skills load from, how to write your own, and how to share them.

---

## Step 11 — Notion (optional)

Skip this on your first pass. Do it once the rest works.

Notion gives your agent access to pages and databases — including a shared library of skills that can be updated without you reinstalling anything.

It needs one manual action from you: the first time an agent connects to Notion, a browser opens and asks you to sign in and press **Allow**. This happens once; the approval is cached on your machine afterwards.

Full instructions, including how to be given access to only a few pages rather than a whole workspace, are in **[reference/notion-access.md](reference/notion-access.md)**.

**You should see**

After approving in the browser, asking your agent *"list the Notion pages you can see"* returns real page names.

---

## Step 12 — Final check

**Do this**

Run the verification script from this repo:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-setup.ps1
```

**You should see**

A table of checks, each marked `OK`, `WARN` or `FAIL`, with a summary line at the end.

`FAIL` on a core tool means that step did not land — go back to it. `WARN` is usually optional (Blender not installed, Notion not connected yet) and is safe to ignore.

**If you see any FAIL**

Fix those before you start building. A half-installed toolchain produces confusing errors later that look like agent mistakes but are not.

---

## Shortcut — do steps 1 and 4 with the script

If you would rather not paste six `winget` lines, this repo has a script that does them, and that also writes your Git settings and merges your ZCode MCP config.

**Read it first.** It is a plain text file: `scripts/setup-windows.ps1`.

**Do this**

```powershell
# See what it would do, without changing anything
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1 -DryRun

# Then do it for real
powershell -ExecutionPolicy Bypass -File .\scripts\setup-windows.ps1
```

The script is safe to run twice. It skips anything already installed, and it **backs up** your ZCode config before touching it.

It cannot do these, so you still do them yourself:

- Install ZCode (it downloads the installer and starts it; you click through)
- Log in to GitHub, your model provider, or Notion
- Approve anything in a browser

**You should see**

A summary at the end listing what it installed, what it skipped, and what is left for you to do by hand.

---

## Done

Next: **[03-first-project.md](03-first-project.md)** — build something small, end to end, so you have proof the whole chain works and you have done the full loop once.

Keep [CHECKLIST.md](CHECKLIST.md) for the next machine you set up.
