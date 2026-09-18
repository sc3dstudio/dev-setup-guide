# Dev Setup Guide

A complete setup guide for a Windows computer that you will use to build software with an AI agent ("vibecoding").

You do not need to be a developer to use this. You need to be able to copy and paste commands, read what the screen tells you, and stop when something looks wrong. If you already know basic programming words, you are more than ready.

**Time needed:** 45-60 minutes. Most of it is waiting for downloads.

---

## What this guide does

| It sets up | So that |
|---|---|
| Git, Node.js, Python, uv, GitHub CLI | the basic tools every project needs |
| ZCode | you have an agent that can read, write and run code for you |
| A `Dev` folder | all your projects live in one clean place, outside OneDrive |
| MCP servers | your agent can reach Blender and Notion, not just files |
| Skills | your agent learns repeatable jobs instead of you re-explaining them |

At the end you have a working setup, and you know how to check that it still works.

---

## Turn off Computer Use first

**Do this before you give the agent any prompt.** It takes ten seconds and it matters.

**Settings → Plugin Management → Installed → Computer Use → switch it off.**

Computer Use lets the agent drive your whole desktop: move the mouse, type, click, read the screen. That is a much bigger permission than editing files in a project folder, and it is hard to supervise while you are still learning what the agent does and how it reports back.

Nothing in this guide needs it. Turn it on later if you want it, once watching the agent work feels routine.

You can confirm it is off in your config file — `plugins.enabledPlugins` should show:

```json
"computer-use@zcode-plugins-official": false
```

Also on the list in [CHECKLIST.md](CHECKLIST.md), as step 10.

---

## Two ways to do this — pick one

The steps are the same either way. The difference is who does them.

### Track A — you do it by hand

Follow **[01-human-setup.md](01-human-setup.md)**.

You run every command yourself. Slower, but you will understand what is on your machine and why.

**Choose this if** you have never installed a development tool, or you want to know what each piece is before you trust an agent with it.

### Track B — your agent does it

Follow **[START-PROMPT.md](START-PROMPT.md)**.

You install ZCode and connect a model. Then you paste one prompt, and the agent installs the toolchain, creates your `Dev` folder, configures the MCP servers, writes your instruction file, and proposes a small first project.

**Choose this if** you want to get to building quickly, or you are setting up a second machine.

The detailed runbook behind that prompt — what the agent does at each step, and where it must stop and wait for you — is [02-agent-setup.md](02-agent-setup.md). You do not need to read it first, but it is what to check against when something looks off.

> Both tracks end in the same place and use the same script, `scripts/setup-windows.ps1`. Track B is Track A with the agent holding the keyboard.

---

## After the setup — both tracks

Do **[03-first-project.md](03-first-project.md)**. It builds something small end to end, with every command explained, so you have done the whole loop once: the agent changes something, you check it, you commit it.

Then read **[04-daily-workflow.md](04-daily-workflow.md)** — how to prompt well, what to check before you trust a change, when to commit, and how to undo.

---

## Read these when something breaks

| File | What is in it |
|---|---|
| [reference/zcode-config-map.md](reference/zcode-config-map.md) | Every ZCode settings file and what lives in it |
| [reference/mcp-servers.md](reference/mcp-servers.md) | Each MCP server: what it does, its config, how to test it |
| [reference/skills-and-plugins.md](reference/skills-and-plugins.md) | How skills are found, installed and shared |
| [reference/notion-access.md](reference/notion-access.md) | How to get Notion working, including the sharing trick |
| [reference/troubleshooting.md](reference/troubleshooting.md) | Symptom → cause → fix |
| [CHECKLIST.md](CHECKLIST.md) | A tick-box list of everything, for a re-install |

---

## The two things you must do yourself

Almost everything here is automated. Two steps cannot be, because they need a human:

1. **Installing ZCode** — it is a normal Windows program with a setup wizard. You click through it.
2. **Logging in** — to your model provider, to GitHub, and to Notion. Each one opens a browser and asks you to sign in and press "Allow".

An agent is not allowed to do these for you, and you should not let one. If an agent offers to type your password, stop.

Everything else — the toolchain, the MCP servers, the config, the skills — an agent can and should do for you.

---

## Before you start

- Windows 10 or 11, 64-bit.
- An administrator account (some installs ask for permission).
- About 5 GB of free disk space.
- A stable internet connection.

**Ask before you buy anything.** A model subscription is needed to run the agent, but the right plan depends on the account you are being set up with. Do not buy a subscription on your own — ask the person who gave you this guide which account to use.

---

## Repo layout

```
README.md                     you are here
START-PROMPT.md               Track B — the one prompt you paste
00-START-HERE.md              plain-word explanation of every piece
01-human-setup.md             Track A — do it by hand
02-agent-setup.md             the runbook behind the prompt
03-first-project.md           build a small thing to prove it works
04-daily-workflow.md          how to actually work, day to day
CHECKLIST.md                  tick-box list
config/                       ready-made config files to copy
reference/                    the detail, when you need it
scripts/                      the setup and check scripts
skills/                       skills you can install
```
