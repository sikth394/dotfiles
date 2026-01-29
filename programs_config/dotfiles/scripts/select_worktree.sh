#!/bin/bash

# Interactive Worktree Selector
# Shows both tracked worktrees and orphaned directories
# Usage: ./scripts/select_worktree.sh
# Returns the selected worktree path for use in shell functions

set -e

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

# Navigate to main worktree to ensure git commands work
cd "$MAIN_WORKTREE"

# Function to get orphaned directories
get_orphaned_dirs() {
    # Get all tracked worktree paths
    tracked_paths=$(git worktree list | awk '{print $1}')

    # Check each directory in worktree folder
    if [[ -d "$WORKTREE_DIR" ]]; then
        for dir in "$WORKTREE_DIR"/*; do
            if [[ -d "$dir" ]]; then
                # Check if this directory is tracked by git
                if ! echo "$tracked_paths" | grep -q "^${dir}$"; then
                    # Extract branch name from path
                    branch_name=$(basename "$dir")
                    echo "$dir [ORPHANED: $branch_name]"
                fi
            fi
        done
    fi
}

# Check if fzf is available
if command -v fzf &> /dev/null; then
    # Build combined list: tracked worktrees + orphaned directories
    selected=$({
        # Tracked worktrees
        git worktree list --porcelain |
            awk '
                /^worktree / {path=$2}
                /^branch / {
                    gsub("refs/heads/", "", $2);
                    branch=$2;
                    print path " [" branch "]"
                }
                /^detached$/ {
                    print path " [detached]"
                }
            ' | grep -v "workspace/.worktree-trash/"

        # Orphaned directories
        get_orphaned_dirs
    } | fzf --height=60% --reverse \
            --prompt="Select worktree: " \
            --preview="echo 'Path: {1}' && echo '' && (git -C {1} status --short 2>/dev/null | head -20 || echo 'Orphaned - no git tracking')" \
            --preview-window=right:50% \
            --header="↑↓ navigate | Enter select | Esc cancel | ORPHANED = not tracked by git" \
            --border=rounded \
            --color="header:italic:underline")

    if [[ -n "$selected" ]]; then
        # Extract just the path (before the bracket)
        echo "$selected" | awk '{print $1}'
    fi
else
    # Fallback to bash select (basic but functional)
    echo "fzf not found (install: brew install fzf)" >&2
    echo "Using basic selector:" >&2
    echo "" >&2

    # Build array of worktree paths and branches
    mapfile -t worktree_data < <({
        git worktree list | awk '{path=$1; $1=""; print path " -" $0}' | grep -v "workspace/.worktree-trash/"
        get_orphaned_dirs | sed 's/\[ORPHANED:/- [ORPHANED:/'
    })

    PS3="Select worktree number (or 0 to cancel): "
    select entry in "${worktree_data[@]}"; do
        if [[ -z "$entry" ]]; then
            echo "Cancelled" >&2
            exit 1
        fi
        # Extract just the path (first field)
        echo "$entry" | awk '{print $1}'
        break
    done
fi
