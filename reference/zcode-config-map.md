# ZCode configuration map

Where every ZCode setting lives, what belongs in it, and which one wins when two disagree.

Use this when you need to change something specific, or when a change you made has no effect.

---

## The two scopes

| Scope | Lives in | Applies to |
|---|---|---|
| **User** | your home folder, `C:\Users\<your-name>\` | every project on this machine |
| **Workspace** | inside a project folder | that project only, and it can be shared through Git |

**Rule of thumb:**

- Personal preference, true everywhere → user scope.
- Project rule, should be shared with the repo → workspace scope.
- Sharing a skill with other tools too (Claude, Codex, Cursor) → `.agents\` folder rather than `.zcode\`.

---

## Every file, in one table

`~` means your home folder: `C:\Users\<your-name>`.

| What | User scope | Workspace scope | Conflict rule |
|---|---|---|---|
| **MCP servers** | `~\.zcode\cli\config.json` → `mcp.servers` | `<repo>\.zcode\config.json` → `mcp.servers` | **User wins** over workspace for a server with the same name |
| **Skills** | `~\.zcode\skills\`, `~\.agents\skills\` | `<repo>\.zcode\skills\`, `<repo>\.agents\skills\` | Same-named skills are all found, but **only the first one loaded runs** — user scope wins |
| **Commands** (`/something`) | `~\.zcode\commands\`, `~\.agents\commands\` | `<repo>\.zcode\commands\`, `<repo>\.agents\commands\` | Deduplicated by name. **First match wins**, user overrides workspace, the other is skipped |
| **Hooks** | `~\.zcode\cli\config.json` → `hooks` | `<repo>\.zcode\config.json` → `hooks` | Need `hooks.enabled: true` in a config file. Plugin hooks are always added |
| **Plugins** | installed from a marketplace; on/off state in `~\.zcode\cli\config.json` → `plugins` | — | A plugin can contain skills, commands, hooks, MCP servers and agents |
| **Instructions** | `~\.zcode\AGENTS.md` | `<repo>\AGENTS.md` | User file loads first, workspace file loads second, so the workspace can narrow it |

### The MCP fallback — a real trap

MCP has a compatibility location that uses a **different key name**:

```
~\.zcode\cli\config.json   →  { "mcp": { "servers": { ... } } }      ← nested
~\.agents\mcp.json         →  { "mcpServers": { ... } }              ← top level
```

Within a scope, ZCode reads `.zcode` first. Only if that scope has **no** MCP servers at all does it fall back to `.agents\mcp.json`.

So if you write servers into `~\.agents\mcp.json` while `~\.zcode\cli\config.json` already has even one server, your new file is ignored and nothing appears to happen. When a server does not appear, check both files and the key name.

---

## Skill and command discovery order

Locations are scanned in this order. Earlier wins.

1. Roots you configured explicitly
2. `~\.zcode\skills`
3. `~\.agents\skills`
4. `<repo>\.zcode\skills` — every folder level from where you are up to the repo root
5. `<repo>\.agents\skills`
6. Enabled plugin folders — lowest priority

Within one level, `.zcode` is read before `.agents`. A folder closer to your current directory beats one at the repo root.

**Skills merge by file path**, so two skills with the same name at different paths are both found — but only the higher-priority one is loaded. The lower one is silently shadowed.

**Commands merge by name.** `review\code.md` becomes the command `/review:code` — the folder joins the name with a colon.

**The practical consequence:** if you edit a skill and nothing changes, you are probably editing a shadowed copy. Ask your agent to list every `SKILL.md` it can find and compare paths.

---

## MCP: precedence and auto-connect

For a server with the same name, the winner is:

```
command line  →  environment  →  user  →  workspace  →  built-in defaults
```

In short: **user overrides workspace**.

**All scopes connect automatically** at session start — user, workspace, plugin, environment and command-line servers. There is no approval step for workspace servers. That is convenient and it is also the reason to be careful about which folders you open: opening a project you do not trust means connecting the MCP servers it declares. Only open workspaces you trust.

Inspect and repair connection state in **Settings → MCP**.

---

## Hooks

Seven events exist, and only these:

`SessionStart` · `UserPromptSubmit` · `PreToolUse` · `PermissionRequest` · `PostToolUse` · `PostToolUseFailure` · `Stop`

**Hooks written in a config file do nothing unless `hooks.enabled: true` is set.** They are off by default. Hooks added by a plugin turn the runner on automatically.

If a hook never fires, this is the first thing to check.

---

## Plugins and marketplaces

- Managed in **Settings → Plugin Management**, with an **Installed** and a **Discover** tab.
- A plugin folder has a manifest at `.zcode-plugin\plugin.json`. The older names `.claude-plugin\` and `.codex-plugin\` also work.
- The only required field is `name`, matching `^[a-z0-9][a-z0-9._-]{0,127}$`.
- Optional component fields: `commands`, `skills`, `hooks`, `mcpServers`, `agents`. Each can be a folder name, a list, or written inline.
- On/off state is stored under `plugins` in `~\.zcode\cli\config.json`.
- A built-in plugin can be switched off but not removed.

**Adding a marketplace:** **Discover** tab → **+** button → choose one of:

| Source | Use |
|---|---|
| GitHub repository | `owner/repo` — the usual choice |
| Git URL | any cloneable URL |
| Local folder | for testing your own plugin before publishing |
| File | a `marketplace.json` you already have |

Plugins are the best way to distribute a bundle of skills and MCP servers together, because installing it is one action instead of a folder copy.

---

## Where to put things — quick answers

| You want to | Do this |
|---|---|
| A rule for every project | `~\.zcode\AGENTS.md` |
| A rule for one project, shared with the team | `<repo>\AGENTS.md`, commit it |
| A skill for yourself, in every tool | `~\.agents\skills\<name>\SKILL.md` |
| A skill that overrides another one, only in ZCode | `~\.zcode\skills\<name>\SKILL.md` |
| A skill only for one project | `<repo>\.agents\skills\<name>\SKILL.md` |
| A personal MCP server | `~\.zcode\cli\config.json` → `mcp.servers` |
| An MCP server the whole team gets | `<repo>\.zcode\config.json`, committed |
| A shortcut command for yourself | `~\.agents\commands\<name>.md` |
| A bundle of skills + MCP servers to hand to someone | A plugin in a Git repo, added as a marketplace |

---

## Secrets

`~\.zcode\cli\config.json` holds **provider API keys in plain text**. Two consequences:

1. **Never commit this file.** If you ever put a ZCode config into a repo to share MCP settings, strip the keys first. The repo's `config\mcp.servers.example.json` is an example with no secrets — copy that pattern.
2. **Never commit a project's `.zcode\config.json` without reading it first.** Workspace config can contain environment values too.

If a key does get committed, treat it as public and rotate it. Deleting the commit is not enough — it stays in the history.

---

## Editing config safely

1. **Close ZCode first.** ZCode writes `config.json` when it exits. Editing while it is open means your change can be overwritten.
2. **Back up before you edit.** One command:
   ```powershell
   Copy-Item "$env:USERPROFILE\.zcode\cli\config.json" `
             "$env:USERPROFILE\.zcode\cli\config.json.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
   ```
3. **Merge, never replace.** The file holds your model providers, plugins and other settings. Overwriting it loses all of them.
4. **JSON is strict.** No comments, no trailing commas, forward slashes in Windows paths.
5. **Validate before reopening ZCode:**
   ```powershell
   Get-Content "$env:USERPROFILE\.zcode\cli\config.json" -Raw | ConvertFrom-Json | Out-Null
   Write-Host "JSON is valid"
   ```
   If this prints an error instead of `JSON is valid`, fix the file before opening ZCode.

---

## When a change has no effect

Work down this list:

1. **Did you restart ZCode?** Skills and MCP servers are loaded at startup.
2. **Is the file valid JSON?** Run the validation command above.
3. **Are you editing the file that wins?** For MCP, user scope beats workspace. For skills, `~\.zcode\skills` beats `~\.agents\skills` beats plugins.
4. **Is the key name right?** `mcp.servers` in `.zcode`, but `mcpServers` in `.agents\mcp.json`.
5. **Is the plugin enabled?** Check `plugins` in `config.json`, or Settings → Plugin Management.
6. **Is the hook enabled?** Config-file hooks need `hooks.enabled: true`.
7. **Is the skill folder one level too deep?** The `SKILL.md` must be *directly* inside the skill folder.

Still stuck → [troubleshooting.md](troubleshooting.md).
