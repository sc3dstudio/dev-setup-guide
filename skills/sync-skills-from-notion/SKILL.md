---
name: sync-skills-from-notion
description: Use when the user asks to sync, pull, update or refresh their skills from Notion, or says "get the latest skills", "check for new skills", "sync my skill library". Reads a Notion skills database and writes each enabled row into the local skills folder as a SKILL.md file.
---

# Sync skills from a Notion library

Pulls skills that someone maintains in Notion and installs them locally, so ZCode can use them.

## Setup — do this once

This skill needs to know **which** Notion database holds the library. Find it out and record it here, then delete this Setup section.

**To find the address:**

1. Ask the user for the Notion database, or the link to it.
2. Fetch it and find the `<data-source>` tag in the result. It looks like:
   `collection://f336d0bc-b841-465b-8045-024475c079dd`
3. Write that value below.

```
SKILLS_DATA_SOURCE: <paste the collection:// URL here>
SKILLS_TARGET_DIR:  C:\Users\<user>\.agents\skills
```

**Expected database shape** (ask the user to create this if the library does not have it):

| Property | Type | Meaning |
|---|---|---|
| Name | title | human name of the skill |
| Slug | text | folder name. Lowercase, hyphens. e.g. `release-notes` |
| Enabled | checkbox | unticked means skip this row |
| Updated | last edited time | for reference |

Each row's page contains the skill body, wrapped in a fenced block:

````
```skill
---
name: release-notes
description: Use when the user asks for release notes.
---

# Release notes

1. Get the commits since the last tag.
2. ...
```
````

**If the database does not match this shape, stop and tell the user what is missing. Do not guess which property is the slug.**

## Running a sync

### 1. Read the library

Query the configured data source and list every row:

- `Slug` (fall back to the title if a slug is missing — but say so)
- whether `Enabled` is ticked
- the `Updated` value

Show this list to the user before writing anything.

### 2. Fetch the enabled rows

For each enabled row, fetch the page content and extract the fenced `skill` block.

**Checks before writing — report any failure and skip that row:**

- The block exists and is non-empty.
- It starts with `---` frontmatter containing both `name:` and `description:`.
- The `name:` value matches the `Slug` property. If they differ, use the slug for the folder name and report the mismatch.
- The slug is safe as a folder name: lowercase letters, digits, hyphens and underscores only. Reject anything containing `/`, `\`, `..`, or a colon.

### 3. Write it

For each valid row:

- Target path: `SKILLS_TARGET_DIR\<slug>\SKILL.md`
- Create the folder if it is missing.
- Write the block content **verbatim**. Do not reformat it, re-indent it, or "improve" the wording.

**If the file already exists, compare first.** If the content is identical, skip it and say so. If it differs, tell the user the file changed and what changed, and get confirmation before overwriting — a local edit that exists nowhere else would be lost.

### 4. Report

```
Synced from Notion:
  release-notes      updated   (was: 2026-09-10)
  brand-copy         new
  price-table        unchanged

Skipped:
  old-invoice-format   Enabled is unticked
  broken-thing         no `skill` block on the page
  dodgy               slug contains "/" - rejected

Local files that differ and were NOT overwritten:
  my-notes             local edit differs from Notion. Confirm which version wins.

Restart ZCode and start a new task for the new skills to load. Skills are read only when ZCode starts, so the task you are in will not see them.
```

Always end with the restart reminder. Skills are scanned at startup; a sync alone changes nothing.

## Rules

- **Never write outside `SKILLS_TARGET_DIR`.**
- **Never delete a skill folder.** If a row disappeared from the library, report it and let the user decide.
- **Never overwrite silently.** Different content means ask.
- **Never invent a slug.** If the property is missing, say so.
- **One row, one skill.** If a page contains several `skill` blocks, report that and skip it rather than guessing which one is intended.
- If Notion returns nothing at all, check access before assuming the library is empty. See `reference/notion-access.md` in the dev-setup-guide repo.

## Troubleshooting

| Symptom | Likely cause | What to do |
|---|---|---|
| The query returns no rows | The Notion account has no access to that database | Ask the user to check **Share** on the database, or that the page is published |
| Every row has no `skill` block | The library uses a different format | Show the user the expected format above and ask them to fix one row as a test |
| A skill does not appear in ZCode after a sync | ZCode was not restarted, you are in an old task, or `SKILL.md` is nested one level too deep | Restart ZCode, start a new task. Then check the folder contains `SKILL.md` directly |
| The frontmatter looks mangled | Notion reformatted the markdown | Ask the user to put the whole skill inside a fenced code block |
| Tool not available | The `notion` MCP server is not connected | See `reference/mcp-servers.md` in the dev-setup-guide repo |
