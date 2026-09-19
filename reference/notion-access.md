# Notion access

How the Notion MCP works, and how to give someone access to a shared skills library without giving them access to a whole workspace.

This is optional. Everything else in this guide works without Notion.

---

## How Notion access actually works

Two facts decide everything:

1. **Notion's MCP authenticates as a person.** When your agent connects, a browser opens and **you** sign in to **your own** Notion account and press Allow. The approval is cached on your machine in `~\.mcp-auth\mcp-remote-v1\`.
2. **The MCP can only see what that account can see.** It reads through your permissions. It is not a back door and not a shared credential.

**Consequences:**

- You cannot lend someone your Notion access. They sign in with their own account. Sharing an account would give them your entire workspace — do not do it.
- What you *can* control precisely is **what their account is allowed to see**. That is where the access trick lives.
- Nobody has to be a paying member of anyone else's workspace. Access is granted per page or per database.

---

## What the other person needs

- Their own Notion account. The free plan is enough.
- The Notion MCP server in their ZCode config — see [mcp-servers.md](mcp-servers.md), server `notion`.
- Your content shared with their Notion email address, in one of the ways below.

---

## Giving access — four options

| Option | They need a Notion account | Costs a seat | Can they edit | Best for |
|---|---|---|---|---|
| **A. Guest on specific pages** | yes | usually no | optional | a real shared library |
| **B. Publish to the web** | no | no | no | zero-friction read access |
| **C. A separate workspace** | yes | no | optional | keeping it out of your main workspace |
| **D. GitHub repo instead** | no | no | no | skills you maintain properly |

### Option A — invite them as a guest on specific pages

This is the normal answer for a shared skills library. You keep your workspace private and they get exactly one database.

1. Open the page or database (for a library, a database is better — one row per skill).
2. **Share → Invite** (top right).
3. Enter their Notion email address.
4. Set the permission: **Can view** for a library they only read, **Can edit** if they contribute skills.
5. Send the invite. They accept it in their own Notion.

**Why this is the right granularity:** their account now sees that one database and nothing else. When their agent queries Notion, it returns that database. Your other pages are not visible, not listed, and not searchable.

**About seats:** a guest added to specific pages is not the same as a workspace member. Notion's free plan allows a limited number of guests and paid plans are more generous; the current limits change, so check your plan's settings before inviting a group. For one or two people this is normally fine and costs nothing extra.

### Option B — publish to the web

If you only need them to *read*, publishing removes the seat question entirely.

1. Open the page or database.
2. **Share → Publish** (or **Share to web**).
3. Copy the public URL.

That URL now works for anyone, with no login. Their agent can fetch it with a plain web request — no Notion account, no MCP, no invite. Optionally enable **Allow duplicate as template** so they can copy the structure.

**Trade-off:** anybody with the link can read it, and search engines may index it. That is fine for a skills library and wrong for anything private. You can unpublish at any time, which kills the link.

### Option C — a separate workspace just for shared content

Useful when you do not want this content mixed into the workspace you work in daily.

1. Create a free Notion workspace specifically for shared material.
2. Move or create the skills library there.
3. Invite the other person as the only guest of that workspace.

They see a workspace that contains only the shared library. Your main workspace stays untouched, and you can hand over or shut down the whole thing independently.

### Option D — put the skills in a Git repo instead

For skills you actually maintain, this is the better home, and it is worth saying plainly:

| | Notion library | Git repo |
|---|---|---|
| Versioning | page history, clunky | every change, with messages |
| Diff review | no real diff | full diff |
| Install | agent has to sync it | one clone or plugin install |
| Offline | no | yes |
| Format safety | markdown can be reformatted | byte-exact |
| Editing by non-technical people | excellent | poor |

**The pragmatic combination:** keep the skills in a Git repo as the real source, and use Notion for the things Notion is genuinely good at — discussing, proposing, and letting people who do not use Git read and comment. Several people writing skills in Notion and syncing to Git works well; a Notion page as the only copy of a skill does not, because a round-trip through Notion can quietly change formatting.

If you go the repo route, a plugin marketplace is the cleanest way to distribute it: they add your repo once, then install and update from the UI. See [skills-and-plugins.md](skills-and-plugins.md).

---

## Reading skills from a Notion library

If you keep a skills library in Notion, the flow is:

```
Notion database (one row per skill)
        │  agent queries it via the Notion MCP
        ▼
agent reads each page
        │
        ▼
writes C:\Users\<your-name>\.agents\skills\<slug>\SKILL.md
        │
        ▼
ZCode finds the skill on next restart
```

**A format that syncs cleanly.** Make one database with these properties, and put the skill body in the page:

| Property | Type | Purpose |
|---|---|---|
| Name | title | human name, e.g. "Release Notes" |
| Slug | text | folder name, e.g. `release-notes` — lowercase, hyphens |
| Enabled | checkbox | unticked means skip it |
| Updated | last edited time | so you can see what changed |

Page body:

````markdown
```skill
---
name: release-notes
description: Use when the user asks for release notes from a set of commits.
---

# Release notes

1. Get the commits since the last tag.
2. ...
```
````

Wrapping in a fenced `skill` block keeps the frontmatter intact and makes it obvious where the file starts and ends. The agent extracts that block and writes it out verbatim.

**To pull the library:**

```
Sync my skills from the Notion library. For each row where Enabled is
ticked, write the content of its `skill` block to
C:\Users\<your-name>\.agents\skills\<slug>\SKILL.md, overwriting what is
there. Then list what you wrote and what you skipped.
```

There is a ready-made skill for this in this repo: [`skills/sync-skills-from-notion`](../skills/sync-skills-from-notion/SKILL.md). Install it, set your database address in it once, and afterwards you only say *"sync my skills from Notion"*.

**Restart ZCode and start a new task after a sync.** Skills are read only when ZCode starts, so the task you are in will not pick them up.

**Before you overwrite, be aware:** a sync replaces local files. If you edited a skill locally, that edit is gone. Either edit in Notion and treat it as the source, or keep local skills out of the library's slug list.

---

## Revoking access

| You want to | Do this |
|---|---|
| Stop one person reading a page | Notion → **Share** → remove their guest entry |
| Kill a public link | **Share → Publish** → unpublish |
| Revoke your own agent's access | Delete `~\.mcp-auth\mcp-remote-v1\`, or revoke the connection in Notion's own settings under **Settings → Connections** |
| Stop the agent reaching Notion at all | Remove the `notion` entry from `mcp.servers` in `config.json`, then restart ZCode and start a new task |

Removing a guest takes effect for their account immediately. Their agent will return nothing for that database on its next query.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `notion` connected but every query returns nothing | The browser sign-in was never completed, or you are in an old task | Restart ZCode, start a new task, ask the agent to list pages — a browser should open |
| Sign-in keeps being requested | The cached approval was deleted or expired | Sign in again; it will cache for next time |
| Agent cannot find a database it used to see | Access was removed, or the page was moved | Check **Share** on that page |
| Agent finds the page but the content looks wrong | Notion reformatted the markdown | Keep the skill in a fenced code block, or move the source of truth to Git |
| Search returns a duplicate of your page | A duplicate copy exists in the workspace | Prefer the live page; delete stale duplicates |
| Works on one machine, not another | Each machine signs in separately | Expected — the approval is per machine |
| A sync overwrote a local edit | Sync replaces files | Keep one source of truth. Recover the text from the Notion page history |

**One question that solves most Notion problems:**

```
List every Notion page you can see, with its title and its full page URL.
```

If your shared page is not in that list, the problem is sharing, not the MCP.
