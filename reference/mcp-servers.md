# MCP servers

MCP (Model Context Protocol) is how an agent gets abilities beyond reading and writing files. An MCP server is a small program that exposes **tools**; the agent calls those tools.

Without MCP an agent can edit your files. With MCP it can inspect a Blender scene, read a Notion database, or query a hosting account.

> Plain-language introduction to what MCP is: [../00-START-HERE.md](../00-START-HERE.md).

---

## The shape of a server entry

Every entry lives in `~\.zcode\cli\config.json` under `mcp.servers`:

```json
{
  "mcp": {
    "servers": {
      "server-name": {
        "type": "stdio",
        "command": "C:/path/to/program.exe",
        "args": ["-y", "some-package", "--flag"],
        "env": { "SOME_SETTING": "1" },
        "timeoutMs": 60000
      }
    }
  }
}
```

| Field | Meaning |
|---|---|
| the key (`server-name`) | what the server is called. Your agent sees tools as `mcp__<server-name>__<tool>` |
| `type` | `stdio` for a local program, `http` for a remote URL |
| `command` | the program to start. **Use forward slashes `/`, never backslashes** |
| `args` | arguments passed to that program. One quoted string per argument |
| `env` | environment variables for that program. This is where you put tokens and switches |
| `timeoutMs` | how long ZCode waits before giving up. Network servers need more |

Instead of `command`/`args`, a remote server can be just:

```json
"some-remote": { "type": "http", "url": "https://example.com/mcp" }
```

**Three rules that prevent almost every failure:**

1. **Forward slashes.** `"C:/Program Files/nodejs/npx.cmd"` — not `"C:\Program Files\..."`. A backslash in JSON starts an escape sequence and breaks the file.
2. **Commas.** Between entries, and none after the last one.
3. **Close ZCode before editing.** It writes this file on exit and will overwrite your change.

---

## The servers in this setup

### `notion` — Notion pages and databases

Lets the agent read and write Notion content, and is how a shared skills library is pulled in. See [notion-access.md](notion-access.md) for the access model.

```json
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
```

| Part | Why |
|---|---|
| `npx.cmd` not `npx` | On Windows, MCP clients must start the `.cmd` wrapper. `npx` alone often fails to spawn |
| `-y` | auto-confirm the package download, so it does not hang on a prompt |
| `mcp-remote` | a small bridge that speaks stdio to ZCode and HTTP to Notion |
| `--transport http-only` | skips a transport negotiation that can stall on locked-down networks |
| `timeoutMs: 60000` | Notion is remote. The default is too short for a slow connection |

**Check the path on your machine:**

```powershell
where.exe npx
```

If it prints something other than `C:\Program Files\nodejs\npx.cmd`, use what it prints.

**First use opens a browser.** `mcp-remote` does an OAuth sign-in the first time it connects, then caches the approval in `~\.mcp-auth\mcp-remote-v1\`. After that it connects silently. If Notion shows as connected but returns nothing, you have not completed that sign-in yet.

---

### `blender-fork` — control Blender

Lets the agent inspect and modify a running Blender scene: objects, materials, node trees, simulation bakes.

This is the community fork (`newo-ether/blender-mcp`), which has a larger toolset than the original. The installer sets up the Python environment, installs the Blender add-on, and can register the MCP client for you.

**Install:**

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/newo-ether/blender-mcp/main/bootstrap.ps1 | iex
```

- `Set-ExecutionPolicy Bypass -Scope Process` allows scripts **in this window only**. It does not change your system policy.
- The installer is interactive: it shows a checklist, detects your Blender versions, and asks which MCP clients to register. Read its prompts.
- Installing the add-on requires **Blender 4.2 or newer**.
- It installs to `%LOCALAPPDATA%\BlenderMCP\venv-<version>`.

**Find the executable it installed:**

```powershell
Get-ChildItem "$env:LOCALAPPDATA\BlenderMCP" -Recurse -Filter 'blender-mcp.exe' |
  Select-Object -ExpandProperty FullName
```

**Config, with that path:**

```json
"blender-fork": {
  "type": "stdio",
  "command": "C:/Users/<your-name>/AppData/Local/BlenderMCP/venv-1.16.1/Scripts/blender-mcp.exe",
  "args": [],
  "env": {
    "BLENDER_MCP_DISABLE_TELEMETRY": "1"
  }
}
```

**Inside Blender, you must also enable the add-on:**

1. **Edit → Preferences → Add-ons**
2. Find **Blender MCP** and tick it
3. Save preferences

Then press `N` in the 3D Viewport and open the **BlenderMCP** tab. It shows the connection status. The port is allocated automatically — you do not configure it.

**Blender must be running** before the agent can use these tools. The MCP server is a bridge to a live Blender session, not something that starts Blender for you.

**Telemetry:** `BLENDER_MCP_DISABLE_TELEMETRY` set to `"1"` turns off all MCP server telemetry. `DISABLE_TELEMETRY` and `MCP_DISABLE_TELEMETRY` are accepted as full-disable switches too. The Blender add-on has its own consent setting in its preferences; declining it stops prompts, code and screenshots from being sent but keeps minimal anonymous operational events.

**Other useful variables:**

| Variable | Purpose |
|---|---|
| `BLENDER_HOST` / `BLENDER_PORT` | defaults `localhost` / `9876`, only needed if you changed them |
| `BLENDER_MCP_WORKSPACE` | the folder the server may read node-tree JSON from. Narrow it to your project |
| `BLENDER_MCP_RUNTIME_DIR`, `BLENDER_MCP_CACHE_DIR` | where it keeps runtime and cache files |

---

### Pick one Blender server, not both

There is also an upstream package:

```json
"blender": { "command": "uvx", "args": ["mcp-for-blender"] }
```

**Do not register both.** They expose similar tool names, and the agent gets confused about which one to call — or calls the one that is not connected to your Blender session. Register one, and if it does not work, remove it before adding the other.

The upstream package is now published as `mcp-for-blender`; the older `blender-mcp` name still works but prints a notice telling you to switch.

---

## Optional servers — ask before adding

These exist on a configured machine but they reach **someone's account**, so do not add them without a decision.

### `cloudflare-docs` — Cloudflare documentation search

Read-only documentation search. No account access, so it is safe to add.

```json
"cloudflare-docs": {
  "type": "stdio",
  "command": "C:/Program Files/nodejs/npx.cmd",
  "args": [
    "-y", "mcp-remote",
    "https://docs.mcp.cloudflare.com/mcp",
    "--transport", "http-only"
  ],
  "timeoutMs": 120000
}
```

### `cloudflare-api` — manage a Cloudflare account

This one signs in to a **Cloudflare account** and can change DNS, cache and Workers. Only add it if you own the account it connects to.

```json
"cloudflare-api": {
  "type": "stdio",
  "command": "C:/Program Files/nodejs/npx.cmd",
  "args": [
    "-y", "mcp-remote@0.14.2",
    "https://mcp.cloudflare.com/mcp",
    "--transport", "http-only",
    "--authorize-param", "scope="
  ],
  "timeoutMs": 120000
}
```

The version is pinned (`mcp-remote@0.14.2`) and the scope parameter is deliberately emptied, because the default scope request breaks on some accounts. Both are fiddly details — copy them exactly if you add this.

### `hostinger` — hosting account management

```json
"hostinger": {
  "type": "stdio",
  "command": "C:/Program Files/nodejs/npx.cmd",
  "args": ["-y", "@hostinger/mcp", "--stdio"],
  "timeoutMs": 60000
}
```

It authenticates with a Hostinger API token that you create in hPanel. The token goes in the `env` block; check the package's README for the exact variable name. **This grants control of a hosting account** — do not add it unless you own that account and want an agent to touch it.

---

## Testing a server

> **First, the rule that catches everyone:** MCP servers are read **once, when ZCode starts**. After adding or changing a server you must restart ZCode and start a **new task**. A session that was already running will never see the new tools, no matter how you rephrase the request. If a server "does not work", check this before anything else.

### 1. Is it connected?

**Settings → MCP** in ZCode. Each server shows a state. Anything other than connected needs fixing.

### 2. Does the agent see its tools?

Ask the agent directly:

```
List every MCP tool you have, grouped by server.
```

You should see tools grouped by server name. Nothing from a server means it is not connected.

### 3. Does it actually work?

Ask for something small and checkable:

| Server | Ask this |
|---|---|
| notion | `List the Notion pages you can see, with their titles.` |
| blender-fork | `What objects are in the current Blender scene?` |

For Blender, have Blender open with a file loaded first. For Notion, expect a browser window on the very first call.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Server missing from the list | Broken JSON in `config.json`, so ZCode ignored the file | Validate the JSON (command in [zcode-config-map.md](zcode-config-map.md)) |
| Server listed, state is error | Wrong `command` path | `where.exe npx`, or find the `.exe` and copy its exact path |
| Everything worked, then all servers vanished | An edit broke the JSON | Restore the newest `config.json.bak-*` and redo the edit carefully |
| Server connects but returns nothing | Not signed in, or you are in an old task | Complete the browser sign-in, then restart ZCode and start a new task |
| Server times out | Network or a slow remote | Raise `timeoutMs` to `120000` |
| Agent calls the wrong Blender tool | Two Blender servers registered | Keep one, remove the other, restart ZCode and start a new task |
| MCP server in a project folder is ignored | `~\.agents\mcp.json` used while `.zcode` config exists | See the fallback trap in [zcode-config-map.md](zcode-config-map.md) |
| Blender tools fail though the server is connected | Blender not running, or add-on not enabled | Start Blender, enable the BlenderMCP add-on in Preferences |
| Config changes do nothing | ZCode was open while editing | Close ZCode, edit, save, reopen |

---

## Security

An MCP server is **code you run**, with the permissions of your user account. It can read your files.

- Add servers you or someone you trust chose. A random server from a marketplace is still a program.
- A server that reaches an account (Cloudflare, Hostinger, GitHub) can act as you inside that account. Grant the narrowest access you can.
- Anything a server sends to a remote service leaves your machine, and may be cached or indexed there. That is the reason telemetry switches exist.
- Review what a token can do before you put it in an `env` block. Prefer a read-only token over an admin one. If a server only needs to read, give it a token that can only read.
