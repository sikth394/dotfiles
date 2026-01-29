#!/bin/bash

# Git Worktree Cleanup Script
# Quickly moves worktree to trash, then robustly cleans up in background
# - Stops all processes writing to the worktree
# - Moves to trash (fast, returns control immediately)
# - Background: git worktree remove --force (handles .venv, node_modules, etc.)
# Usage: ./scripts/git_worktree/worktree_cleanup.sh [worktree-path]
#        If no path provided, shows interactive selector

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

# Use PLATFORM_REPO if set, otherwise detect dynamically
MAIN_WORKTREE="${PLATFORM_REPO:-$(git rev-parse --show-toplevel 2>/dev/null)}"

if [[ -z "$MAIN_WORKTREE" ]]; then
    echo "Error: Could not detect platform repository location"
    echo "Make sure you're in a git repository or PLATFORM_REPO is set"
    exit 1
fi

# Trash directory should be alongside the main repo's parent
PARENT_DIR="$(dirname "$MAIN_WORKTREE")"
TRASH_DIR="$PARENT_DIR/.worktree-trash"

# Interactive selection if no path provided
if [[ -z "$1" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    WORKTREE_PATH=$("$SCRIPT_DIR/select_worktree.sh")

    if [[ -z "$WORKTREE_PATH" ]]; then
        info "Selection cancelled"
        exit 0
    fi
else
    WORKTREE_PATH="$1"
    # Resolve to absolute path
    WORKTREE_PATH="$(cd "$WORKTREE_PATH" 2>/dev/null && pwd)" || {
        error "Path does not exist: $1"
        exit 1
    }
fi

# Prevent deletion of main worktree
if [[ "$WORKTREE_PATH" == "$MAIN_WORKTREE" ]]; then
    error "Cannot delete the main worktree!"
    echo "Main worktree: $MAIN_WORKTREE"
    exit 1
fi

# Check if it's a tracked worktree or orphaned directory
IS_TRACKED=false
if git -C "$MAIN_WORKTREE" worktree list | grep -q "$WORKTREE_PATH"; then
    IS_TRACKED=true
else
    # Check if it's in the worktree directory (orphaned)
    REPO_NAME="$(basename "$MAIN_WORKTREE")"
    WORKTREE_DIR="$PARENT_DIR/$REPO_NAME-worktrees"
    if [[ "$WORKTREE_PATH" == "$WORKTREE_DIR"/* ]]; then
        warning "Orphaned worktree detected (not tracked by git)"
        info "This directory will be deleted without git operations"
    else
        error "Not a git worktree: $WORKTREE_PATH"
        echo ""
        echo "Current worktrees:"
        git -C "$MAIN_WORKTREE" worktree list | grep -v "workspace/.worktree-trash/"
        exit 1
    fi
fi

# Extract branch name from path
BRANCH_NAME="$(basename "$WORKTREE_PATH")"

# Check for uncommitted changes (skip if orphaned)
if [[ "$IS_TRACKED" == true ]]; then
    cd "$WORKTREE_PATH"
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        warning "This worktree has uncommitted changes!"
        git status --short
        echo ""
        read -p "Continue deletion? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Deletion cancelled"
            exit 0
        fi
    fi
fi

echo ""

# Kill all processes related to this worktree
info "Checking for processes in this worktree..."

LOG_DIR="$WORKTREE_PATH/scripts/git_worktree/logs"

# Kill sync_all process tree if it exists
if [[ -f "$LOG_DIR/sync_all.pid" ]]; then
    SYNC_PID=$(cat "$LOG_DIR/sync_all.pid")
    if ps -p "$SYNC_PID" >/dev/null 2>&1; then
        warning "sync_all is running (PID: $SYNC_PID)"

        # Kill the entire process tree
        pkill -P "$SYNC_PID" 2>/dev/null || true
        kill "$SYNC_PID" 2>/dev/null || true
        sleep 0.5
        pkill -9 -P "$SYNC_PID" 2>/dev/null || true
        kill -9 "$SYNC_PID" 2>/dev/null || true

        success "Terminated sync_all process"
    fi
    rm -f "$LOG_DIR/sync_all.pid"
fi

# Kill intellij_deps process tree if it exists
if [[ -f "$LOG_DIR/intellij_deps.pid" ]]; then
    INTELLIJ_PID=$(cat "$LOG_DIR/intellij_deps.pid")
    if ps -p "$INTELLIJ_PID" >/dev/null 2>&1; then
        warning "intellij_deps is running (PID: $INTELLIJ_PID)"

        # Kill the entire process tree
        pkill -P "$INTELLIJ_PID" 2>/dev/null || true
        kill "$INTELLIJ_PID" 2>/dev/null || true
        sleep 0.5
        pkill -9 -P "$INTELLIJ_PID" 2>/dev/null || true
        kill -9 "$INTELLIJ_PID" 2>/dev/null || true

        success "Terminated intellij_deps process"
    fi
    rm -f "$LOG_DIR/intellij_deps.pid"
fi

# Wait for processes to fully terminate
sleep 1

# Clean up any Git lock files left by killed processes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Cleaning up Git lock files..."

# Clean main worktree locks (most common issue)
"$SCRIPT_DIR/cleanup_git_locks.sh" --auto --quiet --main-worktree "$MAIN_WORKTREE" 2>/dev/null || true

# Clean worktree locks if it still exists
if [[ -d "$WORKTREE_PATH" ]]; then
    "$SCRIPT_DIR/cleanup_git_locks.sh" --auto --quiet --worktree "$WORKTREE_PATH" 2>/dev/null || true
fi

info "Removing worktree: $BRANCH_NAME"
echo ""

# For orphaned directories, delete directly in background
if [[ "$IS_TRACKED" != true ]]; then
    info "Moving to trash..."

    # Create trash directory
    mkdir -p "$TRASH_DIR"
    TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
    TRASH_FOLDER="$TRASH_DIR/${TIMESTAMP}-${BRANCH_NAME}"

    # Move to trash
    mv "$WORKTREE_PATH" "$TRASH_FOLDER"
    success "Moved to trash"

    # Delete in background
    (
        rm -rf "$TRASH_FOLDER" 2>/dev/null || true
    ) > /dev/null 2>&1 &
    disown

    echo ""
    success "Worktree removed!"
    echo ""
    echo "Note: Background cleanup in progress"
    echo " "
    exit 0
fi

# For tracked worktrees: move to trash, then clean up in background
mkdir -p "$TRASH_DIR"

# Generate timestamped folder name
TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
TRASH_FOLDER="$TRASH_DIR/${TIMESTAMP}-${BRANCH_NAME}"

# Move to trash (FAST - returns immediately)
info "Moving to trash..."
if git -C "$MAIN_WORKTREE" worktree move "$WORKTREE_PATH" "$TRASH_FOLDER" 2>&1; then
    success "Moved to trash"
else
    error "Failed to move worktree to trash"
    exit 1
fi

# Background cleanup: robust removal with git worktree remove --force
info "Starting background cleanup..."
(
    # Wait longer for lingering file handles during stress testing
    sleep 3

    # Clean up any orphans at original location (from lingering processes)
    rm -rf "$WORKTREE_PATH" 2>/dev/null || true

    # Remove worktree from git (handles both tracked and untracked files)
    cd "$MAIN_WORKTREE"
    git worktree remove --force "$TRASH_FOLDER" 2>/dev/null
    removal_status=$?

    # Always prune after removal attempt (git best practice)
    git worktree prune 2>/dev/null

    # Fallback cleanup if remove failed
    if [[ $removal_status -ne 0 ]]; then
        rm -rf "$TRASH_FOLDER" 2>/dev/null || true
        git worktree prune 2>/dev/null
    fi

    # Delete branch
    git branch -D "$BRANCH_NAME" 2>/dev/null || true

    # CRITICAL: Clean locks AFTER all operations complete
    # Prevents lock accumulation during rapid create/delete cycles
    sleep 1
    "$SCRIPT_DIR/cleanup_git_locks.sh" --auto --quiet --main-worktree "$MAIN_WORKTREE" 2>/dev/null || true

) > /dev/null 2>&1 &
disown

echo ""
success "Worktree removed!"
echo ""
echo "Note: Background cleanup in progress (survives terminal closure)"
echo "Branch '$BRANCH_NAME' will be deleted automatically"
echo " "
