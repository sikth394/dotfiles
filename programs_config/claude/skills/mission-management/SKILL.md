---
name: mission-management
description: Use when user references missions, tasks, the Kanban board, or wants to plan, track, start, continue, complete, or review work items. Also triggers on 'next task', 'mark done', 'mission status', 'work on mission', or any task/board management request.
---

# Mission Management

## Ownership Model

- **Board sections are user-controlled.** The user moves missions between sections (TODO → In Progress, etc.) as their way of prioritizing. **Never move missions between sections** unless the user explicitly asks (e.g. "move X to done", "put X under review").
- **Task checkboxes are AI-controlled.** Mark tasks `[x]` in mission files as you complete them. This is your job — do it immediately, not at the end.
- **New missions go to TODO.** Always add to the TODO section. The user decides when to promote.

## Structure

- **Board:** `~/workspace/missions/BOARD.md` — Obsidian Kanban with 6 sections: TODO, In Progress, Waiting For Review, On Hold, Done, On Long Hold
- **Mission files:** `~/workspace/missions/_missions/<mission title>.md`
- **Template:** `~/workspace/missions/config/mission format.md`
- **Titles** include emoji prefixes (e.g. `👻 InternalAccount inactive`) and are wrapped in `[[double brackets]]` (Obsidian wiki-links)

## Creating a New Mission

When the user asks to create a new mission (e.g. "create a mission for X", "add a new mission", "devise a plan/task for X"):

### 1. Create the Mission File

Write to `~/workspace/missions/_missions/<emoji> <title>.md` following the template in `~/workspace/missions/config/mission format.md`.

**Required sections:** `# Context` and `# Tasks`
**Optional sections:** `# Related Tasks` (link related missions), `# Extra` (references, links)

Task format:
```markdown
# Tasks
- [ ] <task 1>
	- notes, refs, or context (non-checkbox indented lines)
	- `path/to/relevant/file.py:42`
	- [ ] <sub-task>
- [ ] <task 2>
	- [ ] <sub-task>
		- acceptance criteria or test notes
```

Inline notes (non-checkbox indented lines) provide context — file refs, acceptance criteria, setup instructions. They are not actionable items.

- Pick a fitting emoji prefix for the title
- **Only write what you know** — capture what the user said and what came up in conversation. Don't explore the repo or invent details. Minimal input → minimal mission. Rich conversation → rich mission.
- Structure tasks with sub-tasks where appropriate

### 2. Add to the Board

Add `- [ ] [[<emoji> <title>]]` to the **TODO** section of `~/workspace/missions/BOARD.md`.

**Preserve the `%% kanban:settings` block** at the bottom — do not modify or remove it.

---

## Working on a Mission

### 1. Find the Mission

1. Read `~/workspace/missions/BOARD.md`
2. **By name** ("work on the rollforward mission") — fuzzy match against **In Progress** missions. User may omit emoji, abbreviate, or use partial keywords.
3. **By number** ("work on mission 1") — 1-indexed position within In Progress
4. **No identifier** ("work on mission" / "next task") — pick the **top item** in In Progress
5. If only found in another section, tell the user which section and ask before proceeding
6. Read mission file from `~/workspace/missions/_missions/<full mission title>.md`

### 2. Prioritize Next Task

Walk the task checklist top-to-bottom:
- **Checked parent (`- [x]`):** skip it AND all its children — unchecked sub-tasks under a checked parent are stale, not actionable
- **Unchecked parent (`- [ ]`):** check its children — first unchecked child is the next work item. If no unchecked children, the parent itself is next
- **All top-level tasks checked:** mission is done — announce it

Tell the user which task/sub-task you're picking up and why.

### 3. Scope

- **"next sub-task only" / "just the next item"** → do only that single item
- **"work on mission X"** (no modifier) → assess complexity: simple → execute; complex → brainstorm/plan first
- **"continue" / "keep going"** → resume from last unchecked item
- **"how much is left on X?" / progress query** → summarize checked vs unchecked, don't execute
- Respect scope. Don't expand beyond what was asked.

### 4. Mark Completions

1. Edit mission file: `- [ ]` → `- [x]` for the completed item — **immediately**, not at the end
2. If all sub-tasks of a parent are done, mark parent done too
3. If all top-level tasks done, announce mission completion

### 5. Board Edits

**Only when the user explicitly asks** (e.g. "move X to done", "put X in review"):
1. Move the `- [ ] [[Mission Name]]` line to the requested section (use `- [x]` for Done)
2. **Preserve all 6 sections** and the `%% kanban:settings` block

## Mission Status

When the user asks for status ("mission status", "show me the board", "what's in progress?"):
1. Read `~/workspace/missions/BOARD.md`
2. Summarize by section — focus on In Progress, mention counts for others
3. Don't execute anything — this is informational only

## Common Mistakes

- **Moving missions between board sections without being asked** — board layout is user-controlled. Only move when explicitly requested.
- **Destroying kanban metadata** — the `%% kanban:settings ... %%` block at the end of BOARD.md is required by Obsidian. Always preserve it exactly.
- **Acting on stale sub-tasks** — unchecked items under a checked parent are NOT actionable. The parent being checked means the work is done.
- **Dropping board sections** — the board has 6 sections. Preserve all of them when editing, even empty ones.
- **Forgetting emoji in filenames** — mission files on disk include the emoji prefix. Use the exact title from the board when constructing the file path.
- **Delaying task marking** — mark `[x]` immediately after completing each item, not in batch at the end.
