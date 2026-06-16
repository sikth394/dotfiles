---
name: execute-mission
description: Use when user wants to work on, continue, or make progress on an existing mission. Triggers on 'EM', 'work on mission', 'next task', 'continue mission', 'keep going', 'how much is left', or picking up execution of in-progress work items.
---

# Execute Mission

## Parsing the EM Invocation

Arguments after `EM` are parsed as an optional **mission selector** and an optional **task selector**. They are independent axes — a bare number selects a mission, `task N` selects a task within whatever mission was resolved.

| Syntax | Mission resolved | Task resolved |
|--------|-----------------|---------------|
| `EM` | Current mission in conversation, else top of In Progress | Next unchecked |
| `EM 2` | #2 in In Progress (1-indexed) | Next unchecked |
| `EM <name>` | Fuzzy match — In Progress first, then all sections | Next unchecked |
| `EM task 3` | Current mission in conversation, else top of In Progress | Task #3 |
| `EM 2 task 3` | #2 in In Progress | Task #3 |
| `EM <name> task 3` | Fuzzy match (any section) | Task #3 |

**Mission resolution rules:**
- A bare number (`EM 2`) always refers to a mission position in In Progress, never a task number.
- `task N` always refers to a task within the resolved mission, never a mission position.
- "Current mission in conversation" = a mission already loaded or discussed in this session. If none, fall back to top of In Progress.
- Fuzzy name match: ignore emoji, case-insensitive, partial keywords OK. Search **In Progress first** — if found there, proceed without asking. If only found in another section, tell the user which section and confirm before proceeding.

**Task resolution rules:**
- Task number is 1-indexed over **top-level unchecked tasks** (skipping checked parents and their children).
- If out of range, tell the user and fall back to next unchecked.

---

## Find the Mission

1. Read `~/workspace/docs/missions/BOARD.md`
2. Apply the parsing rules above to identify the target mission
3. Read mission file from `~/workspace/docs/missions/_missions/<full mission title>.md`
4. Walk the checklist to identify the target task per the task resolution rules above
5. Tell the user which mission and task you're picking up and why.

---

## Scope

- **"next sub-task only" / "just the next item"** → do only that single item
- **`EM`** (no modifier) → assess complexity: simple → execute; complex → brainstorm/plan first
- **"continue" / "keep going"** → resume from last unchecked item
- **"how much is left on X?" / progress query** → summarize checked vs unchecked, don't execute
- Respect scope. Don't expand beyond what was asked.

---

## Handoff to Execution Skills

After identifying the next task(s), check whether a superpowers skill should be invoked. **Most leaf sub-tasks are simple and need no skill** — if the task is a concrete, single-action item (e.g., "add `select_for_update()` to the query"), just do it directly. Only invoke a skill when the task genuinely matches a trigger below.

| Situation | Invoke Skill | When |
|-----------|-------------|------|
| Task is ambiguous, creative, or under-specified | `superpowers:brainstorming` | Before any implementation — clarify intent and approach |
| Task is complex / multi-step with no plan yet | `superpowers:writing-plans` | Before touching code — produce a plan first |
| A written plan exists (in mission or `~/.claude/plans/`) | `superpowers:executing-plans` | Execute the plan with review checkpoints |
| Multiple independent sub-tasks to parallelize | `superpowers:dispatching-parallel-agents` | When 2+ tasks have no shared state or ordering dependency |
| Implementing a feature or bugfix | `superpowers:test-driven-development` | Before writing implementation code |
| Hit a bug or unexpected failure during work | `superpowers:systematic-debugging` | Before proposing fixes — diagnose first |
| Task/group completed, about to mark done | `superpowers:verification-before-completion` | Before claiming success — run verification |
| All tasks in mission done | `superpowers:requesting-code-review` | Get review before finishing |
| Received review feedback on mission work | `superpowers:receiving-code-review` | Before implementing suggestions |
| Mission fully complete, branch ready | `superpowers:finishing-a-development-branch` | Decide: merge, PR, or cleanup |

**Selection logic:**
1. Read the next task description and its inline notes
2. **Simple leaf task** with clear action + file path → skip this table, just do it
3. Task says "design", "think about", "figure out" → `brainstorming`
4. Task has multiple independent sub-tasks → `parallel agents`
5. Task is a concrete implementation item → `TDD` or `executing-plans` (if a plan exists)
6. Just finished a task group → `verification` before marking done
7. When in doubt, `brainstorming` is the safest default — it clarifies before committing

---

## Mark Completions

1. Edit mission file: `- [ ]` → `- [x]` for the completed item — **immediately**, not at the end
2. If all sub-tasks of a parent are done, mark parent done too
3. If all top-level tasks done, announce mission completion and trigger back-write if applicable

---

## Back-write Resolution to Meeting-Notes Source

If the mission's `# Context` includes a `#### source` sub-header referencing a meeting-notes file (path under `~/workspace/docs/meeting-notes/...`), back-write a one-sentence resolution status to that file when the mission resolves.

**Trigger** (whichever comes first — write once, don't duplicate):
- All top-level tasks just got marked `[x]`
- User asks to move the mission to Done

**How to write:**
1. Read the meeting-notes file from the source path
2. Find the section the source line points to (e.g. `## Item 1`)
3. Append a sub-bullet at the end of that section, with the status text wrapped in single `*` for Obsidian italic rendering:
   - Done cleanly: `- *✅ Status: done — <one-sentence summary>*`
   - Done with caveats: `- *⚠️ Status: done with caveats — <caveat A>; <caveat B>*`
   - Abandoned / not done: `- *❌ Status: not done — <reason>*`
4. Before writing, scan the target section for an existing `*…Status:…*` sub-bullet — if one exists, skip.

**Skip back-write if** the mission has no `#### source`, or the source path isn't under `~/workspace/docs/meeting-notes/`.

---

## Common Mistakes

- **Acting on stale sub-tasks** — unchecked items under a checked parent are NOT actionable. The parent being checked means the work is done.
- **Delaying task marking** — mark `[x]` immediately after completing each item, not in batch at the end.
- **Forgetting the meeting-notes back-write on resolution** — when a mission with a `#### source` resolves, back-write is required, not optional.
- **Duplicating back-writes** — always check the target section for an existing `*…Status:…*` sub-bullet before appending.
- **Expanding scope** — if user asked for one task, do one task. Don't pull ahead.
- **Treating `EM 2` as task #2** — a bare number is always a mission selector. Only `task N` selects a task.
- **Ignoring conversational context** — if a mission is already in focus from earlier in the session, `EM task 3` targets that mission, not the top of In Progress.
