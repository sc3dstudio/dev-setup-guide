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
| MCP servers, if you want them | your agent can reach Notion or Blender, not just files. Optional, and it asks you first |
| Skills | your agent learns repeatable jobs instead of you re-explaining them |

At the end you have a working setup, and you know how to check that it still works.

---

## Turn off Computer Use first

**Do this before you give the agent any prompt.** It takes ten seconds and it matters.

**Settings → Plugin Management → Installed → Computer Use → switch it off.**

Computer Use lets the agent drive your whole desktop: move the mouse, type, click, read the screen. That is a much bigger permission than editing files in a project folder, and it is hard to supervise while you are still learning what the agent does and how it reports back.

Nothing in this guide needs it. Turn it on later if you want it, once watching the agent work feels routine. It is stage 3 in [01-human-setup.md](01-human-setup.md).

---

## How the setup runs

**One chronological script, two roles.** You do not choose between them — you do your part, and the agent does everything else.

| Your part | The agent's part |
|---|---|
| **[01-human-setup.md](01-human-setup.md)** — fifteen stages, and nine of them are just answering a question | **[START-PROMPT.md](START-PROMPT.md)** — the prompt you paste at stage 5. [02-agent-setup.md](02-agent-setup.md) is the detail behind it |

Read **[01-human-setup.md](01-human-setup.md)** and do what it says. That file contains everything you personally must do, and nothing else.

The shape of it:

- **Stages 1 to 4 — before the agent exists.** You install ZCode, set up the model, switch off Computer Use, and create your Dev folder. Nothing is automated there, because there is nothing yet to automate it.
- **Stage 5 — the handover.** You paste the prompt from [START-PROMPT.md](START-PROMPT.md) into a new task.
- **Stages 6 to 15 — it works, you answer.** The toolchain, Git, GitHub, your instruction file, your first project and the MCP servers are all its job. You answer nine questions, run one command yourself (the GitHub login, which needs your browser), and restart ZCode once.

**There are exactly two commands in the whole setup, and both are yours:** creating your Dev folder in stage 4, and `gh auth login` in stage 8. Everything else is a click or an answer. Both need something only you can provide — a decision about where your projects live, and a browser sign-in.

If you would rather see exactly what the agent will do before you let it, read [02-agent-setup.md](02-agent-setup.md) first. You never need to, but it is there.

---

## After the setup

Once you are through stage 15 and the Notion sign-in is done, do **[03-first-project.md](03-first-project.md)**. It builds something small end to end, with every command explained, so you have done the whole loop once: the agent changes something, you check it, you commit it.

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

## The four things that are always yours

Almost everything here is automated. Four things cannot be, because they need a human:

1. **Installing ZCode** — it is a normal Windows program with a setup wizard. You click through it.
2. **Setting up the model provider** — your API key, your account.
3. **Every browser sign-in** — GitHub, Notion. Each opens a browser and asks you to sign in and press "Allow".
4. **Decisions** — where your projects live, what language the agent answers in, what to build.

An agent is not allowed to do these for you, and you should not let one. If an agent offers to type your password, stop.

Everything else — the toolchain, the Dev folder, the MCP configuration, the skills, and your commits — an agent can and should do for you.

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
01-human-setup.md             YOUR part — the role script. Start here
START-PROMPT.md               the prompt you paste at stage 5
00-START-HERE.md              plain-word explanation of every piece
02-agent-setup.md             the agent's part, in detail
03-first-project.md           build a small thing to prove it works
04-daily-workflow.md          how to actually work, day to day
CHECKLIST.md                  tick-box list
config/                       ready-made config files to copy
reference/                    the detail, when you need it
scripts/                      the setup and check scripts
skills/                       skills you can install
```
