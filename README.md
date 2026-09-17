# Dev Setup Guide

A complete setup guide for a Windows computer that you will use to build software with an AI agent ("vibecoding").

You do not need to be a programmer to use this. You need to be able to copy and paste commands, read what the screen tells you, and stop when something looks wrong.

**Time needed:** 45-60 minutes. Most of it is waiting for downloads.

---

## What this guide does

It turns a normal Windows computer into a working development machine:

| It installs | So that |
|---|---|
| Git, Node.js, Python, uv, GitHub CLI | the basic tools every project needs |
| ZCode | you have an agent that can read, write and run code for you |
| A `Dev` folder | all your projects live in one clean place, outside OneDrive |
| MCP servers | your agent can reach Blender and Notion, not just files |
| Skills | your agent learns repeatable jobs instead of you re-explaining them |

At the end you will have a working setup, and you will know how to check that it still works.

---

## Two ways to do this — pick one

The guide is written twice, on purpose. The steps are the same. The difference is who does them.

### Track A — you do it by hand

Follow **[01-human-setup.md](01-human-setup.md)**.

You run every command yourself. This is slower, but you will understand what is on your machine and why.

**Choose this if** you have never installed a development tool before, or you want to learn what the pieces are.

### Track B — your agent does it

Follow **[02-agent-setup.md](02-agent-setup.md)**.

You install ZCode and connect a model. Then you paste one prompt into ZCode and its agent does the rest, checking each step as it goes.

**Choose this if** you want to get to building quickly, or you already did Track A once and are setting up a second machine.

> Both tracks end in the same place, and both use the same script (`scripts/setup-windows.ps1`). Track B is just Track A with the agent holding the keyboard.

After either track, do **[03-first-project.md](03-first-project.md)** to build something small and prove the whole chain works.

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
00-START-HERE.md              plain-word explanation of every piece
01-human-setup.md             Track A — do it by hand
02-agent-setup.md             Track B — your agent does it
03-first-project.md           build a small thing to prove it works
04-daily-workflow.md          how to actually work, day to day
CHECKLIST.md                  tick-box list
config/                       ready-made config files to copy
reference/                    the detail, when you need it
scripts/                      the setup and check scripts
skills/                       skills you can install
```
