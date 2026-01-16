# Claude Code Guidelines

## Tool Priorities (PyCharm MCP) - STRICT HIERARCHY

⚠️ **STOP AND READ THIS BEFORE SEARCHING OR FINDING FILES** ⚠️

🔒 **HARD RESTRICTIONS ACTIVE**: Glob, Grep, bash find, and bash grep are **DENIED** at the system level. You will receive a permission error if you attempt to use them.

### Finding Files - USE IN THIS ORDER:
1. **PyCharm MCP** `find_files_by_name_keyword` - ALWAYS FIRST (indexed, fastest)
2. **bash rg** / **bash ast-grep** - if PyCharm fails/times out

### Searching File Contents - USE IN THIS ORDER:
1. **PyCharm MCP** (`search_in_files_by_text`, `search_in_files_by_regex`) - ALWAYS FIRST (indexed, fastest)
2. **bash rg** / **bash ast-grep** - if PyCharm fails/times out

**❌ WRONG - DO NOT DO THIS:**
```python
# Looking for test files? DO NOT USE:
Glob(pattern="**/test_*.py")           # ❌ WRONG - use PyCharm MCP instead
Grep(pattern="pyyaml")                  # ❌ WRONG - use PyCharm MCP instead
Bash("find . -name 'test_*.py'")       # ❌ WRONG - use PyCharm MCP instead
```

**✅ CORRECT - DO THIS:**
```python
# Finding files by name:
mcp__jetbrains__find_files_by_name_keyword(nameKeyword="test_")

# Searching file contents:
mcp__jetbrains__search_in_files_by_text(searchText="pyyaml")
mcp__jetbrains__search_in_files_by_regex(regexPattern="import yaml")
```

**CRITICAL RULE: Glob/Grep/bash find/bash grep are SYSTEM-DENIED and will fail. ALWAYS use PyCharm MCP FIRST! If PyCharm fails, use bash rg or bash ast-grep.**

### Editing - MANDATORY HIERARCHY

1. **PyCharm** `rename_refactoring` - **MANDATORY FIRST** for symbols (variables, functions, classes)
   - Handles all references across files intelligently
   - **CRITICAL**: After refactoring, MUST use PyCharm `search_in_files_by_text` to validate all references updated
   - Check for string references, comments, and edge cases.
   - **NEVER use sed/awk for symbol renaming when the PyCharm MCP is relevant**

2. **PyCharm** `replace_text_in_file` - **MANDATORY BEFORE sed/awk** for text/regex replacements
   - Supports regex with `regex: true` parameter
   - Use when refactoring is not relevant (strings, comments, non-symbol text)
   - Works per-file with `replaceAll: true` for all occurrences

3. **ast-grep** - syntax-aware search *and* replace (use `--update-all` flag)
   - Use for complex structural changes across multiple files, only when no equivalent PyCharm opertion exits.

4. **Edit tool** - straightforward text changes in known files
   - Use when you've already read the file and know exact context

5. **sed/awk** - LAST RESORT for batch operations across many files
   - Only when PyCharm tools and ast-grep cannot accomplish the task

### Validation
**you MUST perform all those steps before you present code to the user, commit it treat it as done**
- `get_file_problems` → quick IDE feedback
- `ruff check --fix` + `ruff format` (run directly, not from venv)
- `uv run pyright` → type checking (catches what ruff/PyCharm miss, handles dynamic imports)
- run all relevant tests
- validate resulting diff when relevant
- think about your changes from a critical perspective, from a bird-eyes view.

### Other PyCharm Tools
- `get_symbol_info` - type info, docs
- `execute_run_configuration` - run tests
- `get_file_text_by_path` - alternative to Read

### When to Use Read/Bash
- **Read**: exact file paths only (auto-approved for /tmp and ~/tmp)
- **Bash rg**: allowed for all searching when PyCharm MCP is unavailable
  - Can also replace find: `rg --files` or `rg -l pattern` for piping to commands
  - Read-only by design (cannot edit files)
- **Bash ast-grep**: allowed for syntax-aware search and replace
- **Bash**: git operations, running commands (NOT find/grep - those are denied)

---

## Git and Version Control

### Commits and Pull Requests
🚨 **CRITICAL RULES - READ BEFORE ANY GIT OPERATION**:

1. **ALWAYS ASK BEFORE COMMITTING**: Never create a git commit without explicit user approval
   - Present a summary of changes first
   - Ask the user if they want to commit
   - Only proceed after explicit confirmation

2. **ALWAYS ASK BEFORE CREATING PRs**: Never create a pull request without explicit user approval
   - Show the PR title and description first
   - Ask the user to review and approve
   - Only create the PR after explicit confirmation

3. **NEVER PUSH TO REMOTE**: `git push` is DENIED at the system level
   - User will push manually when ready
   - This prevents accidental pushes to shared branches
   - If user asks to push, explain it's restricted and they should do it manually

### Allowed Git Operations
- ✅ `git status`, `git diff`, `git log` - inspection only
- ✅ `git add`, `git commit` - ONLY after explicit user approval
- ✅ `git branch`, `git checkout` - branch management
- ✅ `gh pr create` - ONLY after explicit user approval
- ❌ `git push` - SYSTEM DENIED (use `git push:*` pattern)

---

## Code Style

### Minimalism
- Focus only on what's needed for the task
- No "just in case" code or speculative edge cases
- Remove unused parameters, options, imports

### Functions
- Small and focused (~4 lines)
- Single responsibility; break complex ops into simple functions
- Readability over cleverness

### Comments
- Let code speak for itself
- Only for complex/non-obvious logic
- Docstrings: concise

### Error Handling
- Handle only expected, relevant errors
- Don't over-engineer recovery

### Design
- Prefer functional for utilities
- OOP only when state/inheritance helps (static methods → probably should be functions)

### Testing
- Happy path first; don't over-test edge cases
- **DRY**: use OOP test classes, fixtures, and shared helpers aggressively
- Atomic helpers over monolithic test functions
- Avoid redundant assertions across tests

