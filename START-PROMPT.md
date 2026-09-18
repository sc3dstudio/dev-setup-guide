# Start prompt — the first thing to paste into ZCode

This is the prompt for your **first working session**, after the setup is done.

It is not the setup prompt. The setup prompt installs things — that is [02-agent-setup.md](02-agent-setup.md). This one installs nothing. It gets the agent and you oriented, agrees on how you want to work, and picks a first small thing to build.

**Use this when:**

- [ ] ZCode is installed and a model is connected
- [ ] The setup is finished (either track), or you believe it is
- [ ] You have not worked with this agent before

If the setup is not done yet, go to [02-agent-setup.md](02-agent-setup.md) first.

---

## The prompt

Open ZCode. Open your `Dev` folder, or a project inside it — or open nothing at all, which is fine for a first session.

Copy everything in the box below, paste it into the chat box, and press `Enter`.

---

```text
Hello. I am new to this. You are my coding agent on this Windows machine, and
this is our first session together.

I may not know the right words for things. Please explain in plain language.

GROUND RULES — follow these in every reply, not just today

1.  Assume I know nothing about programming. Explain any jargon the first time
    you use it, in one short sentence.
2.  One step at a time. Do not make changes I did not ask for, even small ones.
3.  Before anything that deletes, overwrites or moves files, say what you are
    about to do and wait for my "yes".
4.  Never commit or push to Git unless I ask.
5.  Never put a password, API key or token into a file that could be committed.
6.  Do not install or upgrade anything today. Today is about getting oriented.
7.  If you are unsure, say so. Never present a guess as a fact.
8.  After a change, tell me what you changed and why, in plain language.
9.  If my request is unclear, ask one question instead of guessing.
10. If I ask what something does, answer without code if you can.

STEP 1 - Orientation. Change nothing.

  - Tell me which folder you can currently see.
  - List what you are able to do: which tools you have, and whether you have any
    MCP tools. If you have MCP tools, group them by server name.
  - Tell me specifically whether Blender and Notion appear.
  - Report which of these exist on this machine: git, node, npm, python, uv, gh.
    Do not install any that are missing.

  Show me all of that, then STOP and wait for me.

STEP 2 - Read the guide this machine was set up with.
  Fetch and read:
    https://raw.githubusercontent.com/sc3dstudio/dev-setup-guide/main/00-START-HERE.md
    https://raw.githubusercontent.com/sc3dstudio/dev-setup-guide/main/04-daily-workflow.md

  Then summarise in 5 bullet points how you and I should work together, based on
  what you read. Ask me if anything there does not match how I want to work.

STEP 3 - If something is missing.
  If STEP 1 showed that git, node, npm, python, uv or gh is missing, do NOT
  install it now. Tell me which ones are missing, and give me this link to the
  setup prompt instead:
    https://github.com/sc3dstudio/dev-setup-guide/blob/main/02-agent-setup.md
  Then wait for me.

STEP 4 - Ask me these questions, ONE at a time, and wait for each answer.
  - What language should you answer me in?
  - What do I want to build first? "I do not know yet" is a completely fine answer.
  - Have I used Git before?
  - Do I want you to explain a command before you run it, or just run it?

STEP 5 - Write my instructions file.
  Using my answers from STEP 4, write my global agent instructions to:
    %USERPROFILE%\.zcode\AGENTS.md

  Use this file as the starting point:
    https://raw.githubusercontent.com/sc3dstudio/dev-setup-guide/main/config/AGENTS.md

  Keep it short. Remove anything that does not apply to me. Show me the exact
  content before you save it and wait for my OK.

STEP 6 - Propose a first project.
  Suggest ONE small thing we can build together in under 30 minutes, inside my
  Dev folder, that teaches me the basic loop: you change something, I check it,
  we commit it.

  Not a tutorial and not a toy. Something real but small. Tell me why you picked
  it, and what I will have at the end. Then wait for my yes.

Begin with STEP 1 now. Do not skip ahead, and do not start any step until I have
answered the one before it.
```

---

## What should happen

| Step | You should see |
|---|---|
| 1 | A list of what the agent can do, its MCP tools grouped by server, and which tools exist. **Nothing installed.** |
| 2 | Five bullet points about how to work together, and a question back to you |
| 3 | Either "nothing is missing", or a short list plus the setup link |
| 4 | Four questions, one at a time — not all at once |
| 5 | The proposed `AGENTS.md` content, before it writes anything |
| 6 | One small project idea with a reason, waiting for your go-ahead |

**Then you say yes, and you are working.**

---

## What it should not do

Stop it if it does any of these. They mean the prompt was not read carefully.

| It should not | Why |
|---|---|
| Install or upgrade anything | The setup prompt does that, and it is a deliberate, separate step |
| Write files before you approve them | Step 5 says show first |
| Ask all four questions at once | They come one at a time, so each gets a real answer |
| Create a Git repo or commit anything | You did not ask |
| Skip to building | Step 6 ends with a proposal, not an action |
| Answer in a language you did not ask for | Question one in Step 4 decides that |

---

## Why this prompt exists

A fresh agent does not know that you are new, what you want to build, or how much explanation you want. Without being told, it will assume you are an experienced developer and behave accordingly — terse answers, unexplained commands, large changes.

This prompt fixes that in one paste. The ground rules in it are the same ones in [config/AGENTS.md](config/AGENTS.md), so once Step 5 is done they are permanent and you never have to paste them again.

---

## If you want to change something

Edit the prompt before you paste it. It is plain text and it is yours.

The two lines worth changing:

- **The ground rules.** Delete what you do not want. Add what you do — for example *"always show me the diff before committing"*.
- **Step 6.** If you already know what you want to build, replace the suggestion request with your actual idea. That is faster and the agent will pick a better first step.

---

## Next

**[03-first-project.md](03-first-project.md)** — a full walkthrough of building something small, end to end, with explanations of every command. Do that before you start your own project, if you have not already.

**[04-daily-workflow.md](04-daily-workflow.md)** — the habits that make this go well: how to prompt, what to check, when to commit, how to undo.
