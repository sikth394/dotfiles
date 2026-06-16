---
name: flesh-out-missions
description: Use when user types FOM or asks to flesh out, expand, elaborate, or detail existing mission stubs. Runs before mission-management execution — converts bare missions created by nm/nmf into concrete tasks, richer context, and useful refs while preserving template structure and the user's original wording.
---

# Flesh Out Missions

Runs **before** `mission-management` execution. Converts bare mission stubs (created via `nm` / `nmf`) into actionable work while preserving the template layout and the user's wording.

## Trigger

- `FOM` (alone) → run the selection flow below
- "flesh out / expand / detail mission X" → flesh that specific mission directly, skip selection

## Selection Flow (FOM)

1. Read `~/workspace/docs/missions/BOARD.md`
2. Collect `- [ ] [[title]]` entries from **TODO** and **In Progress** only (skip Done, On Hold, Long Hold, Waiting For Review)
3. Present a sectioned, **continuously-numbered** list so the user can reply with a single number:

```
TODO:
  1. 👻 InternalAccount inactive
  2. 🧹 Rollforward cleanup
In Progress:
  3. 🚀 BFF split

Which mission(s) would you like me to flesh out?
```

4. User picks numbers (single `2`, comma `1,3`, or range `1-2`). Confirm with `Fleshing out: <titles>` then begin.
5. Multiple missions → do them sequentially, announce each before starting.

## Per Mission

### 1. Read the mission file

Path: `~/workspace/docs/missions/_missions/<full title with emoji>.md`. Note what sections already exist and what the user wrote.

### 2. Classify the mission — calibrate output to scope

This is the single most important step. **Default to less.** Pick one:

| Class | Looks like | Output target |
|-------|------------|---------------|
| **Surgical** | Clear, single-axis change. "Remove button X", "Rename Y to Z", "Add a `select_for_update` to function W" | Add code refs to `# Tasks` only. **Don't touch `# Context`** unless the user's wording is wrong. Skip `# Extra` unless validation isn't obvious. 1–3 tasks. |
| **Capture** | 1–2 sentences on broader work needing context. "We should refactor how reconciliation passes data to the report generator" | Use the per-section guidance below. 3–7 tasks. |
| **Spike / vague** | "Fix the rollup thing", exploratory, scope unclear | **STOP.** Suggest `superpowers:brainstorming` or `superpowers:writing-plans` instead. |

A surgical mission with a 30-line fleshed-out output is bloat. The best surgical output is ~5–10 lines added.

### 3. Identify the repo

| Signals in the stub | Repo |
|---------------------|------|
| BE / Python / BFF / workflow / Temporal / DB / platform terms | `~/workspace/platform` (check worktrees too: `fd -t d platform ~/workspace -d 1`) |
| UI / FE / dashboard / React / component | `~/workspace/dashboard` |
| Clearly both | Ask before fleshing — user usually splits cross-stack work into 2 sibling missions |
| Unclear | Ask the user — don't guess |

Default assumption: single-repo.

### 4. Investigation — match depth to class

- **Surgical** → quick `rg` / `fd` / `Read` in the main session. Just locate the file(s). No subagent.
- **Capture** → dispatch an **Explore subagent** for: relevant file paths + line numbers, existing patterns/tests for similar work, 2–3 candidate approach sketches.
- Either way, you're producing a fleshed-out mission, **not** an implementation plan. Stop the moment you have enough to write code refs.

### 5. Expand the file in place

**Preserve:**
- Section layout from `~/workspace/docs/missions/config/mission format.md` (`# Related Tasks`, `# Context`, `# Tasks`, `# Extra`)
- The user's original context **verbatim** — append to it, never rewrite
- Emoji in title and filename

**`# Context`** — *additive only when the stub lacks something material*. Surgical missions usually need 0 added lines — the user's wording already covers the why. For captures: keep the user's 1–2 sentences as the lead, append where this lives in code (1–3 file refs), and the "why now" if evident. Hard cap ≤ ~8 short lines total. Don't narrate the codebase.

**`# Tasks`** — replace the empty `- [ ]` with concrete items in the exact format used by `mission-management`:

```markdown
- [ ] <verb-first concrete task>
	- `path/to/file.py:42` — why this matters
	- [ ] <sub-task only if parent has multiple actions>
		- acceptance criteria
```

- Verb-first titles ("Add `select_for_update` to …", "Extract helper for …")
- Inline notes = context for the task (refs, acceptance criteria), **not** work items
- **Match the scope.** Surgical: 1–3 tasks. Capture: 3–7. One real task beats three padded ones. There's no floor.
- End with a validation task only when the validation isn't obvious from the change itself

**`# Extra`** — add only when genuinely useful: doc/PR/ticket links you actually have, non-obvious validation commands, gotchas surfaced by investigation. **If you have nothing concrete, leave the section empty — do not write placeholder lines** like `Support ticket link: <paste here>` or `Manual check: load the page and confirm`.

**`# Related Tasks`** — don't invent relationships. If investigation surfaces an obviously related existing mission in `_missions/`, **offer** to link it; don't silently add.

**New sections** — only if clearly warranted (e.g. `# Rollout` for a multi-phase deploy). Default: fit content into existing sections.

### Minimal example — surgical mission

**Before (user's stub):**

```markdown
# Context

Remove the "Beta" badge from the dashboard sidebar — feature is GA now.

# Tasks
- [ ]

# Extra
```

**After fleshing out (good):**

```markdown
# Context

Remove the "Beta" badge from the dashboard sidebar — feature is GA now.

# Tasks
- [ ] Remove the Beta badge from the sidebar
	- `dashboard/src/components/Sidebar.vue:87` — the `<TBadge variant="beta">Beta</TBadge>` block
- [ ] Run `pnpm lint` to confirm no dead imports

# Extra
```

That's the whole thing. No Context expansion. No `# Extra` content. No speculative cleanup tasks.

### 6. Report

- Announce: `Fleshed out <title>.`
- One-sentence summary of what changed (e.g. "Added 2 file refs to context, broke out 5 tasks, added `# Extra` with a manual validation curl")
- **Do not start executing the mission.** That's `mission-management` on explicit request.

## Red Flags — STOP and ask instead

- Stub is ambiguous ("fix the thing") → ask before investigating
- Stub references something that doesn't exist in the code (wrong button name, wrong file) → ask the user to clarify rather than fabricating candidate A/B paths
- Mission clearly spans both platform and dashboard → ask whether to split into siblings
- Stub already looks fleshed out → confirm before editing
- You feel the urge to design a full implementation → stop. Suggest the user run `superpowers:writing-plans` or `superpowers:brainstorming` for it instead

## What NOT to do

- Rewrite the user's original context (append only)
- Invent tasks investigation didn't surface — coarse > fabricated
- Modify `BOARD.md` or other mission files
- Move the mission between board sections (user-controlled)
- Start implementing after fleshing out
- Add empty `# Extra` scaffolding (`Support ticket link: <paste here>`, `Manual check: ...` of obvious things)
- Add a Context paragraph to a surgical mission whose stub already says everything
- Spawn an Explore subagent for a 1-file surgical fix — quick `rg` in main session is enough

## Common Mistakes

- Wiping the original 1–2 sentence context with a prettier rewrite
- Generating 10 sub-tasks from a 1-line stub — noise, not signal
- Producing 28-line output for a "remove button X" mission — should be ~5–10 lines added
- Forgetting the emoji when constructing the file path
- Treating "3–7 tasks" as a floor and inventing tasks to hit it
- Writing speculative validation steps ("manually check the page after the change") that any developer would do anyway
- Drifting into implementation once tasks are written
