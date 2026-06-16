# Meeting Notes

Per-meeting notes for recurring syncs, kept as an Obsidian vault.

## Conventions

- One folder per recurring meeting (e.g. `Team Sync/`, `1-1 with Manager/`)
- Notes named by ISO date: `YYYY-MM-DD.md` (sorts naturally)
- Templates live in `_templates/`; `default.md` is used when a meeting has no dedicated template
- Items that become work → spawn a mission in `~/workspace/docs/missions/_missions/` and link to it from the meeting note (the `mission-management` / `execute-mission` skills can back-write a resolution status here)

## Creating a note

Use the `nmtg` shell function (see the dotfiles `.zshrc`):

```bash
nmtg                  # today's note in "General/" from _templates/default.md
nmtg "Team Sync"      # today's note in "Team Sync/"; uses _templates/Team Sync.md if present, else default.md
```

`nmtg` substitutes `{{date}}` in the template with today's ISO date, creates the meeting folder if missing, and opens the note in Obsidian.
