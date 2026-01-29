#!/bin/bash

# Git Worktree Setup Script
# Creates a new worktree with shared .env files, .run configs, and builds project structure
# Usage: ./scripts/git_worktree/worktree_setup.sh <branch-name> [base-branch]

set -e

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Validate inputs
if [[ -z "$1" ]]; then
    error "Branch name is required"
    echo "Usage: $0 <branch-name> [base-branch]"
    exit 1
fi

BRANCH_NAME="$1"
BASE_BRANCH="${2:-master}"

# Use PLATFORM_REPO if set, otherwise detect dynamically
MAIN_WORKTREE="${PLATFORM_REPO:-$(git rev-parse --show-toplevel 2>/dev/null)}"

if [[ -z "$MAIN_WORKTREE" ]]; then
    echo "Error: Could not detect platform repository location"
    echo "Make sure you're in a git repository or PLATFORM_REPO is set"
    exit 1
fi

# Worktree directory should be alongside the main repo
PARENT_DIR="$(dirname "$MAIN_WORKTREE")"
REPO_NAME="$(basename "$MAIN_WORKTREE")"
WORKTREE_DIR="$PARENT_DIR/$REPO_NAME-worktrees"
NEW_WORKTREE="$WORKTREE_DIR/$BRANCH_NAME"
LOG_DIR="$NEW_WORKTREE/scripts/git_worktree/logs"

# Verify we're in the main worktree
CURRENT_DIR="$(pwd)"
if [[ "$CURRENT_DIR" != "$MAIN_WORKTREE" ]]; then
    error "This script must be run from the main worktree: $MAIN_WORKTREE"
    echo "Current directory: $CURRENT_DIR"
    exit 1
fi

# Check if worktree already exists
if [[ -d "$NEW_WORKTREE" ]]; then
    error "Worktree already exists: $NEW_WORKTREE"
    echo "Use 'wt-rm $NEW_WORKTREE' to delete it first"
    exit 1
fi

# Verify base branch exists
if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
    error "Base branch '$BASE_BRANCH' does not exist"
    exit 1
fi

echo ""
info "Creating worktree for branch: $BRANCH_NAME (based on $BASE_BRANCH)"
echo ""

# Create worktree directory if it doesn't exist
mkdir -p "$WORKTREE_DIR"

# Create the worktree
info "Creating git worktree (checking out ~8k files, may take 20-30s)..."
if git worktree add "$NEW_WORKTREE" -b "$BRANCH_NAME" "$BASE_BRANCH" 2>/dev/null; then
    success "Worktree created at: $NEW_WORKTREE"
elif git worktree add "$NEW_WORKTREE" "$BRANCH_NAME" 2>/dev/null; then
    success "Worktree created (branch already exists)"
else
    error "Failed to create worktree"
    exit 1
fi

echo ""
info "Creating hard links for .env files..."

# Use glob patterns for fast linking (avoid slow find command)
ENV_COUNT=0
for dir in "$MAIN_WORKTREE"/microservices/*/; do
    if [[ -f "$dir.env" ]]; then
        service_name=$(basename "$dir")
        target_dir="$NEW_WORKTREE/microservices/$service_name"
        mkdir -p "$target_dir"
        rm -f "$target_dir/.env"
        if ln "$dir.env" "$target_dir/.env" 2>/dev/null; then
            ((ENV_COUNT++))
        else
            warning "Could not link: microservices/$service_name/.env"
        fi
    fi
done

success "Hard linked $ENV_COUNT .env files"

echo ""
info "Creating hard links for .run configurations..."

# Use glob patterns for fast linking (avoid slow find command)
mkdir -p "$NEW_WORKTREE/.run"
RUN_COUNT=0
for run_file in "$MAIN_WORKTREE"/.run/*.run.xml; do
    [[ -f "$run_file" ]] || continue
    filename=$(basename "$run_file")
    rm -f "$NEW_WORKTREE/.run/$filename"
    if ln "$run_file" "$NEW_WORKTREE/.run/$filename" 2>/dev/null; then
        ((RUN_COUNT++))
    else
        warning "Could not link: .run/$filename"
    fi
done

success "Hard linked $RUN_COUNT .run configurations"

# Create log directory for this worktree
mkdir -p "$LOG_DIR"

# Only build IntelliJ dependencies if using PyCharm
if [[ "${WT_IDE:-pycharm}" == "pycharm" ]]; then
    echo ""
    info "Starting IntelliJ dependency build in background (8-15s)..."

    # Run build_intelij_deps.py in background
    (
        cd "$NEW_WORKTREE/cli"

        # Run uv sync
        echo "Starting uv sync at $(date)" > "$LOG_DIR/intellij_deps.log"
        if uv sync --quiet >> "$LOG_DIR/intellij_deps.log" 2>&1; then
            echo "✓ uv sync completed successfully" >> "$LOG_DIR/intellij_deps.log"
            echo "" >> "$LOG_DIR/intellij_deps.log"

            # Run build script using venv python
            echo "Running build_intelij_deps.py..." >> "$LOG_DIR/intellij_deps.log"
            if .venv/bin/python build_intelij_deps.py >> "$LOG_DIR/intellij_deps.log" 2>&1; then
                echo "" >> "$LOG_DIR/intellij_deps.log"
                echo "✓ IntelliJ dependencies built successfully at $(date)" >> "$LOG_DIR/intellij_deps.log"
            else
                echo "" >> "$LOG_DIR/intellij_deps.log"
                echo "✗ build_intelij_deps.py failed at $(date)" >> "$LOG_DIR/intellij_deps.log"
            fi
        else
            echo "✗ uv sync failed at $(date)" >> "$LOG_DIR/intellij_deps.log"
        fi
    ) &
    INTELLIJ_PID=$!
    echo $INTELLIJ_PID > "$LOG_DIR/intellij_deps.pid"
    disown

    success "IntelliJ dependency build running in background (PID: $INTELLIJ_PID)"
else
    echo ""
    info "Skipping IntelliJ dependencies (WT_IDE=${WT_IDE:-pycharm})"
fi

echo ""
info "Starting sync_all in background (1-3 minutes)..."

# Run sync_all directly in background to avoid terminal spam from tee
(
    cd "$NEW_WORKTREE"
    "$MAIN_WORKTREE/workspace_cli.sh" sync_all > "$LOG_DIR/sync_all.log" 2>&1
    echo "" >> "$LOG_DIR/sync_all.log"
    echo "sync_all completed at: $(date)" >> "$LOG_DIR/sync_all.log"
) &
SYNC_PID=$!
echo $SYNC_PID > "$LOG_DIR/sync_all.pid"
disown

cd "$MAIN_WORKTREE"
success "sync_all running in background (PID: $SYNC_PID)"

echo ""
success "Worktree setup complete!"
echo ""
echo "Location: $NEW_WORKTREE"
echo ""
echo "Check background processes status:"
echo -e "  ${GREEN}wt-sync-status${NC}"
echo ""
echo "Switch to worktree:"
echo -e "  ${GREEN}wt-switch${NC}"
echo ""
