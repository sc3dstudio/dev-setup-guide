# Daily workflow

How to work with an agent well, once the setup is done.

This is not about the tools any more. It is about the habits that decide whether an agent saves you hours or wastes them.

---

## Starting a session

**Open the project folder, not the whole `Dev` folder.**

An agent sees the folder you open and everything under it. Open `Dev` and it can see every project you own — more context, more confusion, more chance it edits the wrong thing.

Open `Dev\<project>` and it sees one project. That is what you want.

**Look at the folder before you start.**

```powershell
git status
```

If there are uncommitted changes from last time, deal with them first — commit them or throw them away. Do not start new work on top of an unexplained half-finished change.

---

## The shape of a good request

Four parts. You do not need all four every time, but a request missing the first two gets a bad result.

| Part | Example |
|---|---|
| **Goal** — what you want | "Add a search box to the header." |
| **Done looks like** — how you will check it | "Typing a word filters the list live. Empty input shows everything." |
| **Constraints** — what it must not do | "Do not add a framework. Keep it one file." |
| **Context** — what it needs to know | "The list is rendered in `index.html` at line 40." |

Written out:

```
Add a search box to the header.

Done looks like: typing a word filters the visible list live.
An empty box shows everything again.

Constraints: no new frameworks, keep it to the existing two files.

The list is rendered in index.html around line 40.
```

Compare with *"add search"*. The long version takes 30 seconds longer to write and saves an hour of guessing.

---

## While the agent works

**Let it finish a small step, then look.**

Do not interrupt with three more ideas. Do not let it run 40 steps unsupervised on something you care about. The right rhythm is: small goal → it works → you look → next small goal.

**Watch for these three moments:**

1. **It asks for permission.** Something in your settings requires your approval. Read what it wants to do before you say yes.
2. **It says it is done.** This is your cue to check, not to relax.
3. **It announces a big plan.** A plan with 12 steps on a project you have not understood yet is a warning. Ask for step one only.

---

## Checking the work

This is the part beginners skip, and it is the part that matters.

### Always run `git diff` before you commit

```powershell
git diff
```

Read it. You are looking for:

- files you did not expect to change,
- deletions of things you did not ask to delete,
- changes to configuration or secrets,
- code that is much longer than the task needed.

You do not have to understand every line. You do have to notice *"why is my login file in this change?"*

### Ask for an explanation in your own terms

```
Summarise what you changed in 5 bullet points, without code.
```

Then, for anything unclear:

```
Explain what you did on line 22, as if I have never programmed.
```

An agent that cannot explain its own change in plain language has usually made a change it does not understand either.

### Test the thing, not the description

The agent says it works. Run it.

```powershell
python count.py sample.txt
```

A green report from the agent and a working program are two different things. Only one of them counts.

---

## Let it handle the routine

Your agent knows more about this than you do — that is the point of having one. Do not turn it into a permission machine by approving every small thing.

**The agent's job, without asking you each time:**

| It does this | Because |
|---|---|
| Installs the toolchain and ordinary project dependencies | It cannot work properly without them, and `winget` and package managers are built for exactly this |
| Commits each working step with a clear message | Small commits are the undo button. Waiting for your approval makes them rare and large |
| Pushes a finished step to your repo | That is your backup. It should happen on its own |
| Creates folders, files and branches it needs | Routine work, and reversible with Git |

**Say what you are installing and why in one line** — that is the level of reporting you want. Not a permission request.

**Where you do want to be asked:**

- Anything that needs your **account login, a credential, or money**. Those are yours.
- Anything that would **overwrite or delete** without a clear way back.
- Anything that would **change a part of the setup that already works**. "While I was in there" is how a working machine breaks.
- An install that would **replace a tool you already rely on**.

The test is not "is this risky in theory". It is "if this goes wrong, can I get back to where I was?" If yes, let the agent work. If no, you are in the loop.

---

## Committing

**Your agent commits. Your job is to read what it committed.**

Commit after every working step, not at the end of the day. If the next step breaks something, you return to the last working commit and lose five minutes instead of five hours.

You should still know the commands, because you will want them yourself:

```powershell
git status          # what changed
git diff            # read it
git add .           # stage everything
git commit -m "Add live search filter to the header"
```

**Read the `git diff` before you accept a step as done.** That is the one habit that matters most, and it is the thing the agent cannot do for you — it cannot tell you whether it built what you actually wanted.

**Messages should say what and why:**

```
Good:  Add live search filter to the header
Bad:   update
Bad:   stuff
Bad:   fixed it finally
```

Future-you will read these to find the moment something broke. If the agent writes vague messages, tell it once — ground rule 4 in your `AGENTS.md` covers it.

### When a step goes wrong

Return to the last good commit:

```powershell
git log --oneline       # find the commit you want
git restore .           # throw away uncommitted changes
```

Or, to undo a commit that is already made while keeping your files:

```powershell
git reset --soft HEAD~1
```

That un-commits the last commit but leaves every file exactly as it is. Safe, and useful when you committed too early.

> **Never** run `git reset --hard` or `git push --force` unless someone experienced tells you to, in that specific case. Both destroy work that cannot be recovered. If an agent suggests either one, stop and ask why.

---

## When to start a new session

Agents work best with a clear, short context. Long sessions drift — the agent starts confusing earlier instructions with the current goal.

Start a fresh session when:

- You finished a feature and are starting a different one.
- The agent seems to have forgotten a rule you gave it earlier.
- It starts repeating a wrong approach, or apologising in circles.
- You switched to a different project.

Before you close a session, commit. The next session should start from a clean, saved state.

**Carry context forward in writing, not in memory.** If a decision matters, put it in the project's `AGENTS.md`:

```markdown
## Project rules

- The API base URL lives in `config.js`. Never hard-code it elsewhere.
- Do not reformat lines you are not otherwise changing. It makes the diff unreadable.
- The client's brand colour is #C8102E. Do not invent new colours.
```

That file is loaded for every future session in that project. It is the cheapest way to stop repeating yourself.

---

## Permissions and safety

An agent with permission can run any command it wants in your project folder.

**Keep the folder narrow.** Open one project, not all of `Dev`.

**Read the permission prompt.** When the agent asks to run a command, read it. You do not need to understand every flag — you need to notice when something is being deleted, uploaded, or sent somewhere.

**Be most careful with these:**

| Action | Why |
|---|---|
| Deleting files or folders | Often unrecoverable unless committed |
| `git push --force` | Rewrites published history. Destroys other people's work too |
| Anything with "delete", "remove", "drop", "purge" | Read twice |
| Sending data to an external service | It leaves your machine, and may be cached or indexed |
| A package you cannot explain | Standard tooling is the agent's job, but you should still know what is being added |

**Secrets.** An API key or password must never enter a file you commit. If you need one, it goes in an environment variable or a file listed in `.gitignore`. If you ever commit a secret, treat it as leaked: rotate the key immediately. Deleting the commit is not enough, because it stays in the history.

---

## Keeping skills current

A skill is your written procedure for a job you repeat. Every time you find yourself writing the same instructions to the agent twice, that is a skill waiting to be written.

To make one:

```powershell
mkdir $env:USERPROFILE\.agents\skills\my-skill
notepad $env:USERPROFILE\.agents\skills\my-skill\SKILL.md
```

```
---
name: my-skill
description: Use when <the situation that should trigger this skill>.
---

# My skill

Instructions, in the order they should happen.
```

The `description` is what the agent matches against. Write it as a trigger: *"Use when the user asks for release notes from a set of commits."* A vague description means the skill never fires.

If you are being given skills from a shared library, see [reference/notion-access.md](reference/notion-access.md) for how to pull the current versions.

---

## Working with a shared setup

If someone else set up your machine, three things come from them and can be updated:

| Thing | Where it lives | How it updates |
|---|---|---|
| Skills | `C:\Users\<your-name>\.agents\skills\` | Copy the new folder over the old one |
| MCP servers | `C:\Users\<your-name>\.zcode\cli\config.json` | They send you a config block; you merge it |
| Project rules | The project's `AGENTS.md` | Comes with the project when you `git pull` |

**Before you overwrite a skill of your own**, check whether you edited it. If you did, copy your version somewhere else first.

---

## A short list to reread when stuck

1. Commit before you try something risky. Always.
2. If the agent is confused, start a fresh session rather than arguing with it.
3. If you do not understand a change, ask for it in plain language. Do not accept a change you cannot explain.
4. If a task is too big, cut it in half and do the first half.
5. `git diff` before every commit. No exceptions.
6. When something breaks, ask *"what did the last change touch?"* before asking anything else.

---

## Where to look things up

| Question | File |
|---|---|
| What does each ZCode setting file do? | [reference/zcode-config-map.md](reference/zcode-config-map.md) |
| How do I add or test an MCP server? | [reference/mcp-servers.md](reference/mcp-servers.md) |
| Where do skills come from and how do I share them? | [reference/skills-and-plugins.md](reference/skills-and-plugins.md) |
| How do I get Notion access? | [reference/notion-access.md](reference/notion-access.md) |
| Something is broken | [reference/troubleshooting.md](reference/troubleshooting.md) |
