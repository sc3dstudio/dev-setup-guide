# Skills, commands and plugins

How to teach an agent a procedure once, so you never explain it twice.

---

## What a skill is

A folder containing a file called `SKILL.md`. Nothing else is required.

```
C:\Users\<your-name>\.agents\skills\my-skill\
└── SKILL.md
```

`SKILL.md` starts with a small block of frontmatter between `---` lines, then the instructions:

```markdown
---
name: my-skill
description: Use when the user asks for release notes from a set of commits.
---

# Release notes

1. Get the commits since the last tag.
2. Group them: features, fixes, chores.
3. Write one line per commit, past tense, no ticket numbers.
4. Match the tone of the existing CHANGELOG entries.
```

| Field | Purpose |
|---|---|
| `name` | the skill's identity. Should match the folder name |
| `description` | **the trigger.** The agent reads this to decide whether the skill applies |

**The `description` is the whole game.** It is the only part always loaded into context. A skill with a vague description never fires, no matter how good its instructions are.

```
Weak:   description: Helps with documents.
Strong: description: Use when the user asks to convert, merge, split or extract
        text from a PDF, or says "make this a PDF".
```

Write it as a situation, and include the words a person would actually say.

---

## Where skills load from

In priority order — the first one loaded wins for a given name:

1. Roots configured explicitly
2. `~\.zcode\skills`
3. `~\.agents\skills`
4. `<repo>\.zcode\skills` — at every level from here up to the repo root
5. `<repo>\.agents\skills`
6. Enabled plugin folders

**Which to use:**

| Situation | Location |
|---|---|
| Yours, wanted in every project | `~\.agents\skills\` |
| Yours, but you want it to override another one, only in ZCode | `~\.zcode\skills\` |
| Shared with the project, versioned in the repo | `<repo>\.agents\skills\` |
| Shared with other tools too (Claude, Codex, Cursor) | `~\.agents\skills\` — that folder is the common convention |
| Distributed as a bundle with MCP servers | a plugin |

Same-named skills at different paths are **all discovered**, but only one is loaded. If you edit a skill and nothing changes, you are probably editing a shadowed copy. Ask the agent:

```
List every SKILL.md you can find, with its full path, and tell me which one
would be loaded for the name "my-skill".
```

---

## Installing a skill

### From a folder

```powershell
$skills = Join-Path $env:USERPROFILE '.agents\skills'
New-Item -ItemType Directory -Force -Path $skills | Out-Null
Copy-Item -Recurse -Force 'C:\path\to\the-skill' (Join-Path $skills 'the-skill')
```

**The #1 mistake:** copying one level too deep.

```
✅  skills\my-skill\SKILL.md
❌  skills\my-skill\my-skill\SKILL.md      ← not discovered
❌  skills\my-skill\docs\SKILL.md          ← not discovered
```

`SKILL.md` must be **directly** inside the skill folder.

**Verify:**

```powershell
Get-ChildItem "$env:USERPROFILE\.agents\skills" -Recurse -Filter SKILL.md |
  Select-Object -ExpandProperty FullName
```

Then **restart ZCode** — skills are scanned at startup — and check **Settings → Skills**.

### From a plugin

Cleaner for a bundle. Installing the plugin brings in its skills, commands and MCP servers in one action. See below.

---

## Writing a good skill

**Keep it short and specific.** A skill is a procedure, not documentation. If it needs a page of prose, it is probably two skills.

**Use a `references\` folder for the long parts.** The agent only reads those when it actually needs them:

```
my-skill\
├── SKILL.md              ← short: when to use it, the steps
└── references\
    └── edge-cases.md     ← read only when an edge case shows up
```

**Write steps as instructions, not description.**

```
Weak:   The script handles the input files.
Strong: Run `python build.py --input <folder>` on each input folder in turn.
```

**State the limits.** The most valuable lines in a skill are the ones that stop the agent doing the wrong thing:

```markdown
## Do not

- Do not add dependencies. This project stays dependency-free.
- Do not reorder the existing entries. Append only.
- If a commit message is unclear, ask instead of guessing.
```

**Point at the real source.** If the format is defined somewhere, say where:

```markdown
Match the format of the existing entries in `CHANGELOG.md`.
```

That is more reliable than describing the format in prose.

---

## Skills vs commands vs AGENTS.md

Three different tools. Use the right one.

| | Skill | Command | AGENTS.md |
|---|---|---|---|
| Triggered by | the agent, when the description matches | you, typing `/name` | always loaded |
| Written in | `SKILL.md` | a `.md` file | `AGENTS.md` |
| Use for | a procedure the agent should apply on its own | something you want to run on demand | standing rules |
| Example | "how we write release notes" | `/release-notes` | "always answer in German" |

**Rules of thumb:**

- A procedure the agent should recognise and apply → **skill**.
- Something you want to invoke deliberately → **command** (you can make a command that loads a skill).
- A rule about *how to behave*, not *what to do* → **AGENTS.md**.

Commands nest into namespaces: `review\code.md` becomes `/review:code`.

---

## Plugins and marketplaces

A plugin bundles skills, commands, MCP servers and hooks so one install sets up everything.

**A plugin folder looks like this:**

```
my-plugin\
├── .zcode-plugin\
│   └── plugin.json      ← the manifest
├── skills\
│   └── my-skill\SKILL.md
├── commands\
│   └── my-command.md
└── .mcp.json            ← optional MCP servers
```

`plugin.json` needs only a `name`, matching `^[a-z0-9][a-z0-9._-]{0,127}$`:

```json
{
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "What this plugin gives you"
}
```

The compatibility folder names `.claude-plugin\` and `.codex-plugin\` also work, so a plugin written for another tool can often be installed as-is.

**Installing:**

**Settings → Plugin Management → Discover → the `+` button**, then pick a source:

| Source | Use |
|---|---|
| GitHub repository | `owner/repo` — the normal way to share |
| Git URL | any cloneable URL |
| Local folder | testing your own plugin before publishing |
| File | a `marketplace.json` you already have |

On/off state is stored in `~\.zcode\cli\config.json` under `plugins`. A built-in plugin can be switched off but not removed.

**Marketplace vs plain skills folder:**

| | Marketplace plugin | Plain skills folder |
|---|---|---|
| Install | one action from the UI | copy folders |
| Update | reinstall from the UI | copy again |
| Can ship MCP servers too | yes | no |
| Works in other tools | not always | yes, `.agents\skills` is a shared convention |
| Best for | a bundle you maintain for others | your own skills |

If you are handing skills to someone else, a plugin in a Git repo is the better shape: one thing to install, one thing to update, and you control the version.

---

## Sharing skills with someone else

Three options, worst to best for a maintained library:

1. **Copy the folders.** Works, but every update means copying again, and you will not know who has which version.
2. **A Git repo.** Keep the skills in a repo. They clone it, pull to update. Versioned and reviewable.
3. **A plugin marketplace.** They add your repo as a marketplace once, then install and update from the UI. Best when there is more than one skill.

If the person is writing skills in Notion rather than in Git, see [notion-access.md](notion-access.md).

---

## When a skill does not fire

Work down this list:

1. **Is `SKILL.md` directly inside the skill folder?** Not one level deeper. This is the most common cause.
2. **Did you restart ZCode?** Skills load at startup.
3. **Is the description a real trigger?** If it does not contain the words you actually say, the agent will not match it. Rewrite it as *"Use when the user asks to ..."* and include the phrasing you use.
4. **Is it shadowed?** A same-named skill in a higher-priority location wins. Ask the agent which copy it would load.
5. **Is the frontmatter valid?** Exactly `---` on the first line, `name:` and `description:`, `---` to close. No indentation, no missing dashes.
6. **Is it disabled in settings?** Check **Settings → Skills**.

Then ask the agent to be explicit rather than guessing:

```
Which skills can you currently see? List them, then tell me why
"my-skill" would or would not be triggered by the request "write my release notes".
```
