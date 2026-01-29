#!/bin/bash

# Git Worktree Trash Cleanup Script
# Removes all worktrees from the trash directory using git worktree remove
# Usage: ./scripts/git_worktree/trash_cleanup.sh

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

# Check if trash directory exists
if [[ ! -d "$TRASH_DIR" ]]; then
    info "Trash directory is empty or doesn't exist: $TRASH_DIR"
    exit 0
fi

# Find all directories in trash
TRASH_ITEMS=($(find "$TRASH_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null))

if [[ ${#TRASH_ITEMS[@]} -eq 0 ]]; then
    info "Trash directory is empty"
    exit 0
fi

echo ""
info "Found ${#TRASH_ITEMS[@]} worktree(s) in trash"
echo ""

# List what will be cleaned
for item in "${TRASH_ITEMS[@]}"; do
    echo "  - $(basename "$item")"
done

echo ""
read -p "Remove all ${#TRASH_ITEMS[@]} worktree(s) from trash? (y/N): " -n 1 -r
echo ""
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Cleanup cancelled"
    exit 0
fi

cd "$MAIN_WORKTREE"

# Process each trash item
REMOVED_COUNT=0
FAILED_COUNT=0

for item in "${TRASH_ITEMS[@]}"; do
    ITEM_NAME="$(basename "$item")"

    # Check if it's still tracked by git
    if git worktree list | grep -q "$item"; then
        info "Removing worktree: $ITEM_NAME"

        # Use git worktree remove with force flag to handle any lingering files
        if git worktree remove --force "$item" 2>/dev/null; then
            success "Removed: $ITEM_NAME"
            ((REMOVED_COUNT++))
        else
            warning "Failed to remove via git, trying manual cleanup: $ITEM_NAME"

            # Fallback: manual cleanup
            if rm -rf "$item" 2>/dev/null; then
                # Clean up git metadata
                git worktree prune 2>/dev/null || true
                success "Manually cleaned: $ITEM_NAME"
                ((REMOVED_COUNT++))
            else
                error "Failed to remove: $ITEM_NAME"
                ((FAILED_COUNT++))
            fi
        fi
    else
        # Orphaned directory, just delete it
        info "Removing orphaned directory: $ITEM_NAME"

        if rm -rf "$item" 2>/dev/null; then
            success "Removed: $ITEM_NAME"
            ((REMOVED_COUNT++))
        else
            error "Failed to remove: $ITEM_NAME"
            ((FAILED_COUNT++))
        fi
    fi
done

# Clean up any stale worktree references
git worktree prune 2>/dev/null || true

echo ""
success "Trash cleanup complete!"
echo ""
echo "Removed: $REMOVED_COUNT"
if [[ $FAILED_COUNT -gt 0 ]]; then
    echo "Failed: $FAILED_COUNT"
fi
echo ""
