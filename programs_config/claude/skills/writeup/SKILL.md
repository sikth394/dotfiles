---
name: writeup
description: Use when the user explicitly asks for a writeup — phrases like "do a writeup about X", "write an explanation about Y", "/writeup", "export latest writeup", or "save this to obsidian". Triggers on explicit writeup keywords only — NOT for general questions, code walkthroughs, or short clarifications, which stay inline. Note: `/export` is Claude Code's native command and does NOT invoke this skill — use `/writeup`. NOT for plans (~/.claude/plans) or missions (~/workspace/docs/missions).
---

# Writeup to Obsidian

Save a substantial artifact — explanations, debug breakdowns, architecture analyses, multi-section walls of text — into the user's Obsidian "exports" vault for comfortable reading outside the terminal.

**Vault path:** `/Users/aweissman/workspace/claude-docs/exports/`

This is **not** the plans vault (`~/.claude/plans/`, where you write implementation plans) and **not** the missions vault (`~/workspace/docs/missions/`, where the user and you track work items). It is purely for artifacts the user wants to digest in Obsidian.

## Two modes

- **Capture** — the artifact already exists in the conversation; copy it verbatim into the vault. Triggered by "/writeup", "export latest writeup", "save this to obsidian".
- **Generate** — the user is requesting a *new* writeup; write the full content directly into the vault file, not into the conversation. Triggered by "do a writeup about X", "write an explanation about Y", and similar explicit requests.

The trigger is the **explicit keyword** ("writeup", "explanation", "save to obsidian"), not the topic. A general question ("how does X work?", "show me an example") stays inline — only write up when the user explicitly asks for a writeup.

**Do not confuse with `/export`** — `/export` is Claude Code's native command for exporting a conversation transcript, and it does not invoke this skill. The slash trigger for this skill is `/writeup`.

## Steps

1. **Determine mode and source the artifact.**
   - **Capture mode:** use the most recent substantial write-up in the conversation. If the user named or quoted something specific, use that. If ambiguous (multiple long write-ups recently), ask which one in one sentence.
   - **Generate mode:** *you* write the full content directly into the export file. The file is the primary destination — do not post the full writeup in the conversation. Only a brief teaser appears in the conversation (see step 4).

2. **Pick a filename:** `YYYY-MM-DD-<topic-slug>.md`
   - Date = today (use the `currentDate` from session context).
   - Slug = kebab-case, 2–5 words, derived from the artifact's actual topic (e.g. `bff-pagination-len-iterable-fix`, `temporal-workflow-determinism`, `gapfill-dedupe-rationale`).
   - If the file already exists, append `-2`, `-3`, etc.

3. **Write the file** to `/Users/aweissman/workspace/claude-docs/exports/<filename>` with this header, then the artifact body:

   ```
   ---
   date: YYYY-MM-DD
   topic: <one-line topic, plain text>
   ---

   # <Title — same topic as a human-readable heading>

   <artifact content, verbatim>
   ```

4. **Confirm.**
   - **Capture mode:** one line — the absolute path of the written file. Nothing else.
   - **Generate mode:** a 1–3 sentence teaser describing what's in the file, then the absolute path on its own line. Nothing else. The user reads the full content in Obsidian, not in the terminal.

## Rules

- **Verbatim.** Preserve the artifact's headings, code blocks, tables, lists, and inline formatting exactly. Do not paraphrase, summarize, trim, or restructure into a "cleaner" form. The wall of text is the point.
- **Markdown is already markdown.** Your terminal output already renders as Github-flavored markdown — copy it through unchanged. Don't escape or re-encode.
- **Strip ANSI / terminal cruft** if any leaked into the source (rare, but possible from pasted terminal output).
- **Scrub secrets** before writing: API keys, tokens, DB hostnames, internal URLs, IPs. Per CLAUDE.md security rules. If in doubt, ask.
- **Don't add commentary** at the top or bottom of the file ("Here is the export…"). The frontmatter + heading + body are the entire file.
- **Use the Write tool**, not Bash heredocs.

## Common mistakes

| Mistake | Fix |
|---|---|
| Writing a summary instead of the verbatim artifact | Copy the original text exactly. |
| Saving to `~/.claude/plans/` or `~/workspace/docs/missions/` | Always use `/Users/aweissman/workspace/claude-docs/exports/`. |
| Generic filenames like `export.md` or `note.md` | Use a topic-specific slug so the file is findable in Obsidian's list. |
| Adding a chatty preamble or trailing "let me know if…" | The file contains only frontmatter + heading + artifact. |
| Overwriting an existing same-day same-topic export | Append `-2`, `-3`. |
| Triggering on a general question, code walkthrough, or short clarification | The trigger is an explicit writeup keyword ("do a writeup", "write an explanation", "/writeup"). General Q&A stays inline. |
| Treating `/export` as a trigger for this skill | `/export` is Claude Code's native command — let it pass through. The slash trigger for this skill is `/writeup`. |
| In generate mode, posting the full writeup in the conversation as well as the file | The file is the primary destination. Only a 1–3 sentence teaser + path appear in the conversation. |
