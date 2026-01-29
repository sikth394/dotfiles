# Git Worktree Setup

## What & Why

Git worktrees let you work on **multiple branches simultaneously** without stashing or committing WIP. Perfect for when
AI agents work on Feature A while you work on Feature B, or when you need to quickly jump to a hotfix without losing
context.

**Traditional branching:** Stash/commit before switching → Context lost → Can't run multiple branches at once

**With worktrees:** Each branch has its own directory → No stashing → Work in parallel → Full context preserved

## 5-Minute Setup

### Automated Setup (Recommended)

### Step 1: Run the automated setup script from your platform repository:

```bash
cd /path/to/your/platform  # e.g., ~/workspace/platform or ~/repos/platform
./workspace_cli.sh git_worktree_setup
```

The script will:

1. Auto-detect your repository location
2. Check for prerequisites (fzf)
3. Ask for your IDE preference (PyCharm, Cursor, VS Code, Neovim, or none)
4. Configure your shell (~/.zshrc) with portable paths
5. Create necessary directories

### Step 2: Apply Changes

```bash
source ~/.zshrc
```

---

### Manual Setup (Alternative)

If you prefer manual configuration or need to customize the setup:

#### Prerequisites

- **fzf** (for interactive `wt-switch`): `brew install fzf`

#### Step 1: Add Aliases to Shell Config

Add this to your `~/.zshrc` (replace `/path/to/your/platform` with your actual repo path):

```bash
# ===========================
# Git Worktree Aliases
# ===========================

# Platform repository location (set to your repo path)
export PLATFORM_REPO="/path/to/your/platform"  # e.g., ~/workspace/platform or ~/repos/platform

# IDE preference for git worktree operations
# Supported: pycharm, cursor, vscode, neovim, none
export WT_IDE="pycharm"

# Git worktree basic aliases
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'

# Custom workflow commands
alias wt-ls='cd "$PLATFORM_REPO" && git worktree list'
alias wt-new='cd "$PLATFORM_REPO" && ./scripts/git_worktree/worktree_setup.sh'
alias wt-rm='cd "$PLATFORM_REPO" && ./scripts/git_worktree/worktree_cleanup.sh'
alias wt-sync-status='$PLATFORM_REPO/scripts/git_worktree/check_sync_status.sh'
alias wt-unlock='$PLATFORM_REPO/scripts/git_worktree/cleanup_git_locks.sh --interactive'
alias wt-trash-rm='$PLATFORM_REPO/scripts/git_worktree/trash_cleanup.sh'

# wt-switch requires a function (not an alias) to change directory
wt-switch() {
  local selected_path=$($PLATFORM_REPO/scripts/git_worktree/select_worktree.sh)

  if [[ -z "$selected_path" ]]; then
    echo "Selection cancelled"
    return 1
  fi

  # Clean up any stale locks before switching (silent, no output unless error)
  $PLATFORM_REPO/scripts/git_worktree/cleanup_git_locks.sh \
      --auto --quiet --worktree "$selected_path" 2>/dev/null || true

  # Ask to open in IDE based on WT_IDE setting
  if [[ "${WT_IDE:-none}" != "none" ]]; then
    echo ""
    local ide_name=""
    local ide_app=""

    case "${WT_IDE}" in
      pycharm)
        ide_name="PyCharm"
        ide_app="PyCharm"
        ;;
      cursor)
        ide_name="Cursor"
        ide_app="Cursor"
        ;;
      vscode)
        ide_name="VS Code"
        ide_app="Visual Studio Code"
        ;;
      neovim)
        ide_name="Neovim"
        ide_app=""  # Neovim opens in terminal, not as app
        ;;
      *)
        ide_name=""
        ;;
    esac

    if [[ -n "$ide_name" ]]; then
      read "open_ide?Open in $ide_name? (y/n): "
      echo ""

      if [[ "$open_ide" =~ ^[Yy]$ ]]; then
        echo "✓ Opening in $ide_name..."
        if [[ "$WT_IDE" == "neovim" ]]; then
          # Open neovim in the current terminal
          nvim "$selected_path"
        else
          open -a "$ide_app" "$selected_path" 2>/dev/null || echo "⚠ $ide_name not found"
        fi
      fi
    fi
  fi

  cd "$selected_path" || return
  echo "✓ Switched to: $(basename $selected_path)"
  echo ""
  echo "Tip: Run 'cld' to update Claude context"
}
```

### Step 2: Apply Changes

```bash
source ~/.zshrc
```

---

### Create Your First Worktree

```bash
wt-new my-feature

# Wait 1-3 minutes for sync_all to complete
wt-sync-status $PLATFORM_REPO-worktrees/my-feature

# Switch to it (arrow keys to select, optional PyCharm)
wt-switch
```

Done! You now have a fully isolated workspace.

## IDE Configuration

The git worktree tools support multiple IDEs through the `WT_IDE` environment variable:

### Supported IDEs

- **pycharm** - PyCharm IDE (default)
- **cursor** - Cursor IDE
- **vscode** - Visual Studio Code
- **neovim** - Neovim (opens in terminal)
- **none** - No IDE integration

### Configuration

Set your preferred IDE in `~/.zshrc`:

```bash
export WT_IDE="pycharm"   # Default
# export WT_IDE="cursor"  # Or use Cursor
# export WT_IDE="vscode"  # Or use VS Code
# export WT_IDE="neovim"  # Or use Neovim
# export WT_IDE="none"    # Or disable IDE integration
```

### Behavior

**When switching worktrees (`wt-switch`):**

- If `WT_IDE` is set (not "none"), you'll be prompted to open the worktree in your chosen IDE
- Example: `Open in PyCharm? (y/n):`
- For Neovim, it opens directly in the current terminal

**When creating worktrees (`wt-new`):**

- If `WT_IDE="pycharm"`, IntelliJ dependencies are built automatically
- For other IDEs (`cursor`, `vscode`, `neovim`, `none`), this step is skipped for faster setup

**To change your IDE:**

```bash
# Edit ~/.zshrc and change WT_IDE value
export WT_IDE="cursor"

# Apply changes
source ~/.zshrc

# Now wt-switch will offer to open in Cursor
wt-switch
```

## Expected Filesystem Layout

The worktree directory structure is created alongside your main repository:

```
/path/to/repos/                  # Your repos directory (e.g., ~/workspace/ or ~/repos/)
├── platform/                    # Main worktree (master)
│   ├── .env files (original)
│   └── .run/ (original configs)
│
├── platform-worktrees/          # Feature worktrees (automatically created)
│   ├── feature-auth/
│   │   ├── .venv/ (isolated)    # Own dependencies
│   │   ├── .env (hard linked)   # Shared configs
│   │   └── .run/ (hard linked)  # Shared run configs
│   └── bugfix-payment/
│
└── .worktree-trash/             # Auto-cleanup (automatically created)
```

**Key Points:**

- `.env` files are **hard linked** (edit once, changes everywhere)
- `.run` PyCharm configs are **hard linked** (add once, available everywhere)
- `.venv` directories are **isolated** (each worktree has its own)
- Git commits are **shared** (same repository)
- **Portable**: Works regardless of where you clone the repo (~/workspace/, ~/repos/, etc.)

## Essential Commands

| Command           | Description                               |
|-------------------|-------------------------------------------|
| `wt-ls`           | List all worktrees                        |
| `wt-new <branch>` | Create new worktree with full setup       |
| `wt-switch`       | Interactive switch (fzf + PyCharm option) |
| `wt-rm`           | Interactive delete (fzf + confirmation)   |
| `wt-sync-status`  | Check sync_all progress                   |
| `wt-unlock`       | Clean up stale Git lock files             |
| `wt-trash-rm`     | Clean up trash folder (remove all)        |

### What `wt-new` Does

```bash
wt-new my-feature              # Based on master
wt-new hotfix-prod develop     # Based on develop
```

Automatically:

- Creates branch and worktree
- Hard links all `.env` files (~20 files)
- Hard links all `.run` PyCharm configs (~31 files)
- Builds IntelliJ project structure
- Runs `sync_all` in background (1-3 min)

### What `wt-switch` Does

Interactive worktree switcher:

- Shows all worktrees in fzf selector
- Option to open in PyCharm
- Changes terminal directory

```
$ wt-switch
[fzf selector - use arrows + Enter]

Open in PyCharm? (y/n): y
✓ Opening in PyCharm...
✓ Switched to: feature-auth
```

### What `wt-rm` Does

Interactive worktree deletion:

- Shows all worktrees in fzf selector
- Checks for uncommitted changes
- Asks for confirmation if changes found
- Stops sync_all if still running
- Deletes the branch automatically
- Moves to trash (not immediate deletion)
- Removes from git worktree list
- Deletes in background

```
$ wt-rm
[fzf selector - use arrows + Enter]

⚠ This worktree has uncommitted changes!
M some-file.py

Continue deletion? (y/N): y

⚠ sync_all is running (PID: 12345)
ℹ Stopping sync_all process...
✓ Stopped sync_all
✓ Removed from git worktree list
✓ Branch 'my-feature' deleted
✓ Worktree removed!
```

### What `wt-trash-rm` Does

Cleans up the trash folder:

- Lists all worktrees in `~/.worktree-trash/`
- Shows count and names of trashed items
- Asks for confirmation before cleanup
- Uses `git worktree remove --force` for tracked worktrees
- Falls back to manual deletion for orphaned directories
- Prunes stale git references automatically

```
$ wt-trash-rm

ℹ Found 3 worktree(s) in trash

  - 2026-01-28_143022-old-feature
  - 2026-01-27_091533-bugfix-123
  - 2026-01-26_154401-test-branch

Remove all 3 worktree(s) from trash? (y/N): y

ℹ Removing worktree: 2026-01-28_143022-old-feature
✓ Removed: 2026-01-28_143022-old-feature
ℹ Removing worktree: 2026-01-27_091533-bugfix-123
✓ Removed: 2026-01-27_091533-bugfix-123
ℹ Removing orphaned directory: 2026-01-26_154401-test-branch
✓ Removed: 2026-01-26_154401-test-branch

✓ Trash cleanup complete!

Removed: 3
```

## What Gets Shared vs Isolated

**✅ Shared (Hard Linked):**

- `.env` files → Edit once, changes everywhere
- `.run` configs → Add once, available everywhere
- Git commits → Same repository history

**❌ Isolated (Per Worktree):**

- Working directory → Own file changes
- Staging area → `git add` only affects current worktree
- `.venv` → Own Python dependencies
- Build artifacts → Independent compilation

## Typical Workflow

```bash
# Start new feature
wt-new feature-user-auth
wt-switch  # Select feature-user-auth

# ... work on feature ...

# Urgent hotfix!
wt-new hotfix-payment-bug
wt-switch  # Select hotfix-payment-bug

# ... fix bug, test, commit ...

# Back to feature
wt-switch  # Select feature-user-auth
# (no stashing, everything as you left it!)

# Done with hotfix
wt-rm  # Select hotfix-payment-bug, confirm deletion
```

## Best Practices

1. **Descriptive branch names** - You'll see them in the selector often
2. **Delete when done** - Don't accumulate worktrees
3. **Main worktree stays clean** - Keep your main repo on master
4. **Wait for sync** - Don't start work until `sync_all` completes
5. **Hard links are magic** - Update `.env` once, all worktrees updated
6. **Portable setup** - Run `./workspace_cli.sh git_worktree_setup` if you move the repo

## Quick Reference

```bash
wt-ls                  # List worktrees
wt-new <branch>        # Create worktree
wt-switch              # Interactive switch
wt-sync-status         # Check sync progress
wt-rm                  # Interactive delete
wt-unlock              # Clean up stale Git lock files
wt-trash-rm            # Clean up trash folder

# Manual git worktree commands
git worktree list              # List all
git worktree remove <path>     # Remove specific
git worktree prune             # Clean up stale references
```

## Troubleshooting

**Setup script fails?**

```bash
# Re-run setup to update configuration
./workspace_cli.sh git_worktree_setup

# Or manually verify ~/.zshrc was updated
grep "Git Worktree Aliases" ~/.zshrc

# Check if aliases are loaded
source ~/.zshrc
type wt-switch
```

**Git lock file errors? ("Unable to create .git/index.lock")**

```bash
# Automatically clean up stale locks
wt-unlock

# Or manually remove (if you're sure no Git operations are running)
rm -f $PLATFORM_REPO/.git/index.lock
```

**Note:** The `wt-rm` and `wt-switch` commands now automatically clean up stale locks, so manual cleanup is rarely
needed.

**"worktree already exists"**

```bash
wt-rm  # Select and delete old worktree
wt-new my-branch
```

**Hard links not working?**

```bash
# Verify inode numbers match (they should be identical)
ls -li $PLATFORM_REPO/microservices/bff/.env
ls -li $PLATFORM_REPO-worktrees/my-feature/microservices/bff/.env
```

**Sync taking too long?**

```bash
# Watch live progress
tail -f $PLATFORM_REPO-worktrees/my-feature/sync_all.log
```

**Orphaned worktree directories?**

```bash
# If directories exist in platform-worktrees/ but aren't tracked by git:
wt-rm  # Select the orphaned directory

# The script automatically:
# - Detects orphaned worktrees
# - Skips git operations
# - Moves to trash and deletes in background
# You'll see: "⚠ Orphaned worktree detected (not tracked by git)"
```

**Note:** The cleanup script automatically handles race conditions where lingering processes recreate directories after
deletion. Any recreated directories are automatically moved to trash and deleted.

---

**More info:** [Git Worktree Official Docs](https://git-scm.com/docs/git-worktree)
