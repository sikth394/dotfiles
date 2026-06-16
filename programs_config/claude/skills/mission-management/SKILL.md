---
name: mission-management
description: Use when user wants to create, add, edit, move, or check status of missions or the Kanban board. Triggers on 'MM', 'new mission', 'add mission', 'move to done', 'mission status', 'show me the board', or any board/mission creation and organization request.
---

# Mission Management

## Ownership Model

- **Board sections are user-controlled.** The user moves missions between sections (TODO → In Progress, etc.) as their way of prioritizing. **Never move missions between sections** unless the user explicitly asks (e.g. "move X to done", "put X under review").
- **Task checkboxes are AI-controlled.** Mark tasks `[x]` as you complete them — immediately, not at the end.
- **New missions go to TODO.** The user decides when to promote.

## Structure

- **Board:** `~/workspace/docs/missions/BOARD.md` — Obsidian Kanban with 6 sections: TODO, In Progress, Waiting For Review, On Hold, Done, On Long Hold
- **Mission files:** `~/workspace/docs/missions/_missions/<mission title>.md`
- **Template:** `~/workspace/docs/missions/config/mission format.md`
- **Titles** include emoji prefixes (e.g. `👻 InternalAccount inactive`) and are wrapped in `[[double brackets]]` (Obsidian wiki-links)

## Creating a New Mission

When the user asks to create a new mission (e.g. "create a mission for X", "add a new mission", "MM: ..."):

### 1. Create the Mission File

Write to `~/workspace/docs/missions/_missions/<emoji> <title>.md` following the template in `~/workspace/docs/missions/config/mission format.md`.

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
- **If the mission originates from a meeting-notes file** (e.g. user says "create a mission from the 2026-05-07 meeting Item 1", or pastes content from `~/workspace/docs/meeting-notes/...`), fill in the `#### source` sub-header inside `# Context` with the meeting reference and path. Otherwise leave `#### source` empty.

### 2. Add to the Board

**Append** `- [ ] [[<emoji> <title>]]` to the **end** of the **TODO** section of `~/workspace/docs/missions/BOARD.md`. Do not insert at the top or in the middle — TODO order reflects the user's prioritization, and new missions are unprioritized until the user moves them.

**Preserve the `%% kanban:settings` block** at the bottom — do not modify or remove it.

---

## Moving Missions on the Board

**Only when the user explicitly asks** (e.g. "move X to done", "put X in review"):
1. Move the `- [ ] [[Mission Name]]` line to the requested section (use `- [x]` for Done)
2. **Preserve all 6 sections** and the `%% kanban:settings` block
3. When moving to Done, check if the mission file has a `#### source` pointing to `~/workspace/docs/meeting-notes/...` — if so, back-write a one-sentence resolution status (see Back-write section in `execute-mission` skill)

---

## Mission Status

When the user asks for status ("mission status", "show me the board", "what's in progress?"):
1. Read `~/workspace/docs/missions/BOARD.md`
2. Summarize by section — focus on In Progress, mention counts for others
3. Don't execute anything — this is informational only

---

## Common Mistakes

- **Moving missions between board sections without being asked** — board layout is user-controlled. Only move when explicitly requested.
- **Destroying kanban metadata** — the `%% kanban:settings ... %%` block at the end of BOARD.md is required by Obsidian. Always preserve it exactly.
- **Dropping board sections** — the board has 6 sections. Preserve all of them when editing, even empty ones.
- **Forgetting emoji in filenames** — mission files on disk include the emoji prefix. Use the exact title from the board when constructing the file path.
- **Inserting new missions at the top of TODO** — new missions go to the **end** of TODO. The user prioritizes by reordering; don't pre-empt that by shoving new work to the front.
