# Claude Code Guidelines

## Tool Priorities - STRICT HIERARCHY

### Finding Files
- **fd** - `fd "pattern"` or `fd "pattern" path/`

### Searching File Contents
- **rg** - `rg "pattern"` or `rg -l "pattern"` (files only)
- **ast-grep** - syntax-aware search for structural patterns

### Reading & Editing Files
- **Read** - for reading file contents
- **Edit** - for editing files

### Editing - MANDATORY HIERARCHY

1. **Edit tool** - for text changes when you've read the file and know exact context

2. **ast-grep** - syntax-aware search *and* replace (use `--update-all` flag)
   - Use for complex structural changes across multiple files

3. **sed/awk** - LAST RESORT for batch operations across many files
   - **NEVER use `sed -i ''`** on macOS - use `sed -i '.bak'` instead

### Import/Usage Edit Order (CRITICAL)
**Linter (`ruff check --fix`) auto-removes unused imports** - if you add an import without usage, it gets deleted.

**Strategy - pick one:**
1. **All-at-once**: Add import AND usage in same Edit call
2. **Usage-first**: Add the code that uses the import, then add the import

**Never**: Add import alone → run linter → import gone → confusion

### Validation
**you MUST perform all those steps before you present code to the user, commit it treat it as done**
- `ruff check --fix` + `ruff format` (run directly, not from venv)
- `uv run pyright` → type checking (handles dynamic imports)
- run all relevant tests
- validate resulting diff when relevant
- think about your changes from a critical perspective, from a bird-eyes view

### When to Use Bash
- **fd**: file searching
- **rg**: content searching
- **ast-grep**: syntax-aware search and replace
- **sed/awk**: batch text operations (use `sed -i '.bak'` on macOS)
- **git**: version control operations
- **running commands**: tests, builds, scripts

### Subagents - USE LIBERALLY
- **Proactively use subagents** whenever possible - they extend main session context life
- Explore agents for codebase investigation
- Task agents for isolated subtasks
- Any agent type that fits - don't hesitate, just deploy them
- Main session staying lean = longer productive conversations

### Large Files
- Save large outputs to `/tmp` first (`cmd > /tmp/output.txt`), then use `rg`/`head`/`tail` on the saved file
- Benefit: You can run multiple filters without re-running the original command if your first filter wasn't right (unlike piping where data is lost)

### Communication Style
- **Ask questions freely** - via AskUser tool or plain text, doesn't matter
- Questions enable real-time steering with user's domain knowledge
- Avoids looping on things the user already knows
- We lose nothing by asking and getting "idk" - but gain a lot when user has the answer
- **Important info in final message only** - user typically sees only the last message before getting control back
- Before returning control, consolidate all important findings/results since user's last message
- Don't bury critical info in intermediate messages (gray circles) that get lost in thinking/tool output

---

## Git and Version Control

### Commits and Pull Requests
**CRITICAL RULES - READ BEFORE ANY GIT OPERATION**:

1. **ALWAYS ASK BEFORE COMMITTING**: Never create a git commit without explicit user approval
   - Present a summary of changes first
   - Ask the user if they want to commit
   - Only proceed after explicit confirmation

2. **ALWAYS ASK BEFORE CREATING PRs**: Never create a pull request without explicit user approval
   - Show the PR title and description first
   - Ask the user to review and approve
   - Only create the PR after explicit confirmation

### Allowed Git Operations
- `git status`, `git diff`, `git log` - inspection only
- `git add`, `git commit` - ONLY after explicit user approval
- `git branch`, `git checkout` - branch management
- `gh pr create` - ONLY after explicit user approval
- `git push` - ONLY after explicit user approval

---

## Code Style

### Core Philosophy
KISS, DRY, Pythonic (`import this`). TDD/SDD when fitting. Blend into existing repo patterns. Easy-to-understand above all.

### Functions
- ~4 lines, single responsibility
- Break complex operations into simple, atomic functions
- Readability over cleverness

### Naming
- Clear over clever
- Long and clear > short and cryptic (e.g., `get_user_by_email` > `get_usr`)

### Minimalism
- Only what's needed - no "just in case" code
- Remove unused parameters, options, imports
- No speculative edge case handling

### Comments
- Let code speak for itself
- **No self-explanatory single-line comments** - extract to a well-named function instead (e.g., `# get user` → `get_user()`)
- Only for non-obvious logic or edge cases
- Docstrings: concise, when needed

### Error Handling
- Handle only expected, relevant errors
- Don't over-engineer recovery

### Design
- Prefer functional for utilities
- OOP when state/inheritance actually helps
- Static methods → probably should be plain functions

### Testing
- Happy path first
- DRY: test classes, fixtures, shared helpers
- Atomic helpers over monolithic test functions
- Match existing repo test patterns
