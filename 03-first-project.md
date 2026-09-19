# Your first project

Installing tools proves nothing. This file makes you do the whole loop once, on something small, so you have done every part yourself at least one time.

**In real work your agent does most of this for you** — it commits, it pushes, it runs the commands. Do it by hand here, once, so that when the agent reports "I committed and pushed", you know exactly what happened and where to look. That is the whole point of this file.

Do both projects. The first has no code in it at all — it is only about Git and GitHub. The second has code, and shows you what working with an agent actually feels like.

---

## The loop you are learning

Every project, forever, is this:

```
  describe what you want
          │
          ▼
    the agent works  ──►  you check the result
          │                     │
          │                     ▼
          │            good? ──► commit  (a saved, named snapshot)
          │              │
          │              └─ no ──►  describe what is wrong, repeat
          ▼
   repeat until done
```

Three habits make this go well:

1. **One goal at a time.** "Add a contact form" — not "add a contact form and also restyle the header and fix the login bug".
2. **Check before you commit.** The agent is confident even when it is wrong. Read what changed.
3. **Commit often.** A commit is a named point you can return to. Small commits are cheap; one giant commit at the end of the day is not.

---

## Project 1 — A repository with no code

**Goal:** create a repo, put a file in it, publish it on GitHub. This teaches Git and `gh` with nothing else in the way.

### 1. Make the project folder

```powershell
cd $env:USERPROFILE\Dev
mkdir hello-dev
cd hello-dev
```

### 2. Turn it into a Git repository

```powershell
git init
```

**You should see**

```
Initialized empty Git repository in C:/Users/<your-name>/Dev/hello-dev/.git/
```

A hidden `.git` folder now exists. That folder *is* the repository — it holds the entire history. Deleting it deletes your history, so never touch it by hand.

### 3. Create a file

```powershell
@'
# hello-dev

My first repository.

- [x] installed the tools
- [x] opened a terminal
- [x] made a repo
'@ | Set-Content -Encoding utf8 README.md
```

### 4. See what Git noticed

```powershell
git status
```

**You should see**

```
Untracked files:
        README.md
```

**Read this output carefully — you will look at it constantly.** `Untracked` means Git sees the file but is not yet watching it.

### 5. Save a snapshot

```powershell
git add README.md
git status
git commit -m "Add README"
```

**You should see**

`git status` now says `Changes to be committed` — the file is staged. Staging means "include this in the next snapshot".

The commit prints something like:

```
[main (root-commit) 1a2b3c4] Add README
 1 file changed, 6 insertions(+)
```

**What just happened:** you froze those exact file contents into history with the message `Add README`. You can return to this moment forever.

### 6. Change the file, and look at the difference

```powershell
Add-Content README.md "- [x] saved my first snapshot"
git diff
```

`git diff` shows exactly what changed, line by line. `-` lines were removed, `+` lines were added.

**This is the single most useful command you have.** Before you commit anything an agent wrote, run `git diff` and read it.

### 7. Commit the change

```powershell
git add README.md
git commit -m "Note the first snapshot in the README"
```

### 8. Publish it on GitHub

```powershell
gh repo create hello-dev --public --source=. --push
```

This creates the repository on GitHub and pushes your commits to it.

**You should see**

```
✓ Created repository <your-name>/hello-dev on GitHub
✓ Pushed commits to https://github.com/<your-name>/hello-dev
```

Open that URL in your browser. Your README is there.

**If it fails**

| Error | Fix |
|---|---|
| `gh: not logged in` | Run `gh auth login` again |
| `name already exists` | Pick another name: `gh repo create hello-dev-<yourname> --public --source=. --push` |
| `remote origin already exists` | You already ran this. Run `git push -u origin main` instead |

### 9. The undo button

Change a file badly, on purpose, and get it back:

```powershell
Add-Content README.md "This line is a mistake."
git diff                          # see the mistake
git restore README.md             # throw the change away
git diff                          # empty again
```

`git restore` discards unsaved changes to a file and returns it to the last commit. **Use it without fear.** This is why you commit often: it is the thing that makes undo possible.

> Careful: `git restore` throws work away permanently. It only affects files you have not committed. If you are unsure, commit first — a commit is safe, it costs nothing.

### What you now know

| Command | What it does |
|---|---|
| `git status` | what has changed |
| `git add <file>` | include a file in the next snapshot |
| `git commit -m "..."` | take the snapshot |
| `git diff` | show the exact changes |
| `git restore <file>` | undo uncommitted changes to a file |
| `git log --oneline` | list your snapshots |
| `gh repo create` | publish a repo on GitHub |

---

## Project 2 — Let the agent build something

**Goal:** make the agent write a small working program, and practise checking its work.

### 1. Set up

```powershell
cd $env:USERPROFILE\Dev
mkdir word-count
cd word-count
git init
```

### 2. Open this folder in ZCode

In ZCode, open the folder `C:\Users\<your-name>\Dev\word-count`. The agent now sees only this folder.

### 3. Ask for something specific

Paste this:

```
Write a Python script called count.py.

It reads a text file given as a command-line argument and prints:
  - how many lines the file has
  - how many words it has
  - the ten most common words, each with its count

Rules:
- Use only the Python standard library, no extra packages.
- Handle a missing file gracefully: print a clear message instead of crashing.
- Keep it short and readable.
- Explain what you wrote afterwards, in plain language, as if I have never
  seen Python before.

Then create a file sample.txt with about ten lines of any English text,
and show me the exact command to run the script on it.
```

### 4. Watch what it does

A good agent will:

- create `count.py` and `sample.txt`,
- run the script to check it works,
- show you the output,
- explain what it did.

**Your job:** read the explanation. If you do not understand a line, say *"explain lines 12 to 18 in plain language"*. The agent is obliged to make it clear, and "explain this" is a completely normal thing to ask.

### 5. Verify it yourself

Do not take its word for it. Run it yourself:

```powershell
python count.py sample.txt
```

**You should see**

```
Lines: 10
Words: ...
Top 10 words:
  ...
```

**Then try to break it:**

```powershell
python count.py does-not-exist.txt
```

**You should see** a clear message, not a crash with a long stack trace. You asked for graceful handling. Now you know whether you got it.

**This is the core skill of vibecoding:** asking for something specific enough to check, then checking it.

### 6. Commit

```powershell
git status
git diff
git add .
git commit -m "Add word count script"
gh repo create word-count --public --source=. --push
```

### 7. Ask for one improvement

```
Make the top-10 list ignore common English filler words like "the", "and", "of",
and make the script accept multiple file names at once.
```

Then check again:

```powershell
python count.py sample.txt
```

**Notice what happened:** you gave one instruction, the agent changed the code, you verified. That is the loop. Everything else is the same loop with bigger goals.

---

## Practising the loop on purpose

These are safe exercises in `Dev\_sandbox`. Break things.

| Say this to your agent | What it teaches |
|---|---|
| "Explain what this project does, as if to a new colleague." | Orientation before changing anything |
| "What would break if I deleted this file?" | Learning a codebase without touching it |
| "Show me the three riskiest things in this code." | Reading critically, not trusting blindly |
| "Undo your last change." | Recovery when the agent gets it wrong |
| "Rewrite that more simply." | You are allowed to ask for clarity |
| "Add comments explaining what each part does." | Turning code into something you can read |
| "I do not understand this error — what does it mean?" | The most useful question there is |

---

## Three ways to get a bad result

Learn these now and you will avoid most frustration:

**Too vague.** "Make me a website." The agent guesses, and it guesses wrong. Instead: "A single page with a heading, a paragraph and a contact email, styled in black and white, no frameworks."

**Too big.** "Build the whole app." The agent produces a lot of code you cannot check. Instead, cut it into a first version you can verify, then add one thing at a time.

**No check.** You accept what the agent says without running it. Then three steps later, something breaks and you cannot tell which of the three steps caused it.

---

## Next

**[04-daily-workflow.md](04-daily-workflow.md)** — how to work like this every day: sessions, commits, permissions, and keeping your skills current.
