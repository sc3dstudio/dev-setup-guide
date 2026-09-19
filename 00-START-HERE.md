# Start Here — what all these pieces are

Read this once before you install anything. It takes five minutes and it makes the rest of the guide much easier, because you will know what each piece is for.

You do not need to memorise this. Come back when a word is unclear.

---

## The one-sentence version

You are building a workshop. ZCode is the workbench, your agent is the worker, and the tools (Git, Node, Python, MCP servers, skills) are what the worker is allowed to use.

---

## The pieces, in plain words

### Terminal

A window where you type instructions as text instead of clicking buttons.

On Windows you will use **PowerShell**. Open it by pressing the Windows key and typing `PowerShell`.

Some commands in this guide are for **Git Bash**, a second terminal that Git installs. When a command is for a specific one, the guide says so.

**Why you care:** the agent runs commands in a terminal for you. When you understand that a terminal is just "type a command, read the answer", nothing about this setup is mysterious.

### Git

A tool that records every change you make to your files, so you can always go back.

It saves **snapshots**. Each snapshot is called a **commit**. A folder that Git watches is called a **repository** (or **repo**).

**Why you care:** this is your undo button for a whole project. Agents make mistakes. With Git you can always return to the last good state.

### GitHub

A website that stores Git repositories online. `github.com`.

**Why you care:** it is your backup, it is how you get code to other people, and it is how you get code *from* other people. You will use it with the `gh` command.

### Node.js and npm

A runtime and a package manager. A **package** is a piece of code someone else wrote that you can reuse.

`npm install` downloads packages. Most modern tools are installed this way.

**Why you care:** many MCP servers and helper tools are Node packages.

### Python and uv

Another runtime, used a lot for scripts and AI tools.

**uv** is a modern tool that installs and runs Python tools without the usual dependency mess. Several MCP servers are Python packages, and you start them with `uvx`.

**Why you care:** the Blender MCP server is a Python package started by `uvx`.

### ZCode

The **agentic development environment**. This is the main program you will work in.

It is an app with a chat box. You describe what you want. The agent reads your files, writes code, runs commands, and shows you the result.

ZCode is the **harness**: the thing that holds your project, talks to the model, and gives the agent its powers. Everything else in this guide plugs into ZCode.

### Model / provider

The AI that does the thinking. ZCode is the app; the model is the brain it calls.

You connect ZCode to a **provider** — an account or an API key — and pick a model. You need one before the agent can do anything.

### Agent

The thing that actually does the work. You give it a goal in normal language. It plans, edits files, runs commands, checks results, and repeats.

**Mental model:** you are the person who decides *what* and *why*. The agent handles *how*. Your job is to be clear about what you want and to check the result.

### MCP server

**Model Context Protocol.** A standard way to give an agent extra abilities beyond reading and writing files.

An MCP server is a small program that exposes **tools**. Each tool is a thing the agent can call.

Examples you will install:

- **Blender MCP** — the agent can look at and change a Blender scene: create objects, edit materials, run scripts.
- **Notion MCP** — the agent can read and write pages and databases in Notion.

**Why you care:** without MCP the agent only sees files. With MCP it can drive real applications.

### Skills

A skill is a folder with a `SKILL.md` file inside. It is written instructions that teach the agent how to do one specific job, the way you want it done.

Example: a skill called `release-notes` might say "look at the commits since the last tag, group them by type, write them in this tone".

**Why you care:** skills are how you stop repeating yourself. You explain a procedure once, write it down as a skill, and the agent follows it forever after.

**Where skills live on your machine:**

```
C:\Users\<your-name>\.agents\skills\<skill-name>\SKILL.md
```

You install a skill by copying its folder there. That is the whole mechanism.

### Plugins and marketplaces

A **plugin** is a bundle that can contain skills, commands, MCP servers and hooks in one package. A **marketplace** is a list of plugins you can install from.

ZCode ships with a marketplace already set up. You add plugins from **Settings → Plugin Management**.

### AGENTS.md

A plain text file with standing instructions for the agent. Not a skill — just rules that are always loaded.

There are two:

- `C:\Users\<your-name>\.zcode\AGENTS.md` — your rules, in every project.
- `<your-project>\AGENTS.md` — rules for that project only.

**Why you care:** this is where you write "always answer in German", "never delete files without asking me", "explain commands before running them".

---

## How the pieces connect

```
          You
           │  describe what you want
           ▼
      ┌─────────┐                     ┌─────────┐
      │  ZCode  │  ─ prompt/context ► │  Model  │ ← does the thinking
      │ (Agent/ |                     | (Brain) |
      | Harness)│ ◄ asks for tools ─  │         │   (needs an account)
      └────┬─▲──┘                     └─────────┘
           │ │
  executes │ │ returns results
     tools │ │ (to be sent back to Model)
           ▼ │
┌────────────────────────────────┐
│ Environment:                   │
│  • files in your Dev folder    │
│  • terminal commands           │
│  • MCP servers (Blender,       │
│    Notion)                     │
│  • skills (your procedures)    │
└────────────────────────────────┘
```

---

## What "good" looks like

You are set up correctly when all of these are true:

1. `git --version`, `node -v`, `python --version`, `uv --version` and `gh --version` all print a version instead of an error.
2. ZCode opens, is connected to a model, and answers a simple question.
3. You have one folder — `C:\Users\<your-name>\Dev` by default, or wherever you chose — where all projects live.
4. `gh auth status` says you are logged in to GitHub.
5. Your agent can list the MCP tools it has. **Blender and Notion only appear here if you asked for them** — an empty list is a normal, working setup.

`scripts/verify-setup.ps1` checks all of this for you and prints a report. If you put your projects somewhere other than the default, pass the path: `.\scripts\verify-setup.ps1 -DevRoot "D:\Dev"`.

---

## The three rules to remember

1. **Read before you run.** If a command looks strange, ask your agent what it does before you run it.
2. **Commit often.** Small commits are a cheap undo button. A day of uncommitted work is not undoable.
3. **Secrets never go in a repo.** Passwords and API keys stay in configuration files on your machine. Never paste them into a file you commit.

Next: read **[01-human-setup.md](01-human-setup.md)** or **[02-agent-setup.md](02-agent-setup.md)**.
