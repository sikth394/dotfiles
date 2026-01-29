#!/usr/bin/env bash
set -euo pipefail

# Git Lock File Cleanup Utility
# Safely detects and removes stale Git lock files with multiple safety checks

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Default configuration
AGE_THRESHOLD_MINUTES=5
MODE="interactive"
TARGET_PATH=""
QUIET=false
DRY_RUN=false

# Output functions
info() {
    [[ "$QUIET" == true ]] || echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    [[ "$QUIET" == true ]] || echo -e "${GREEN}✓${NC} $*"
}

warning() {
    [[ "$QUIET" == true ]] || echo -e "${YELLOW}⚠${NC} $*" >&2
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Safely detect and remove stale Git lock files.

OPTIONS:
    --auto                  Non-interactive mode (removes stale locks automatically)
    --interactive           Interactive mode (asks for confirmation) [default]
    --quiet                 Suppress all output
    --dry-run              Show what would be removed without removing
    --main-worktree PATH   Clean locks in main worktree
    --worktree PATH        Clean locks in specific worktree
    --age-threshold MIN    Minimum age for stale detection (default: 5)
    -h, --help             Show this help message

EXAMPLES:
    # Interactive cleanup of current directory
    $(basename "$0") --interactive

    # Automatic cleanup of main worktree (for scripts)
    $(basename "$0") --auto --main-worktree \$PLATFORM_REPO

    # Dry run to preview what would be removed
    $(basename "$0") --dry-run --worktree \$PLATFORM_REPO-worktrees/feature

COMMON LOCK FILES:
    .git/index.lock              - Main staging area lock
    .git/HEAD.lock               - Branch switching lock
    .git/refs/heads/*.lock       - Branch ref locks
    .git/worktrees/*/index.lock  - Per-worktree index locks
EOF
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                MODE="auto"
                shift
                ;;
            --interactive)
                MODE="interactive"
                shift
                ;;
            --quiet)
                QUIET=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --main-worktree)
                TARGET_PATH="$2"
                shift 2
                ;;
            --worktree)
                TARGET_PATH="$2"
                shift 2
                ;;
            --age-threshold)
                AGE_THRESHOLD_MINUTES="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Check if a lock file is stale
is_lock_stale() {
    local lock_file="$1"

    # Check 1: File must exist
    [[ -f "$lock_file" ]] || return 1

    # Check 2: Age threshold (older than X minutes)
    local age_seconds=$((AGE_THRESHOLD_MINUTES * 60))
    local current_time=$(date +%s)
    local file_time=$(stat -f %m "$lock_file" 2>/dev/null || stat -c %Y "$lock_file" 2>/dev/null || echo 0)
    local age=$((current_time - file_time))

    if [[ $age -lt $age_seconds ]]; then
        return 1  # Too recent, not stale
    fi

    # Check 3: No process has the file open
    if command -v lsof >/dev/null 2>&1; then
        if lsof "$lock_file" >/dev/null 2>&1; then
            return 1  # File is open by a process
        fi
    fi

    return 0  # Lock is stale
}

# Find all Git lock files in a directory
find_lock_files() {
    local base_path="$1"
    local git_path="$base_path/.git"

    # Check if .git exists (either as directory or file)
    if [[ ! -e "$git_path" ]]; then
        return
    fi

    # Handle worktree case: .git is a file pointing to the actual git directory
    if [[ -f "$git_path" ]]; then
        # Parse the gitdir line to get the actual git directory
        local worktree_git_dir
        worktree_git_dir=$(grep "^gitdir:" "$git_path" | cut -d' ' -f2)

        if [[ -n "$worktree_git_dir" && -d "$worktree_git_dir" ]]; then
            {
                # Find locks in the worktree-specific git directory (non-recursive to avoid worktrees subdirs)
                find "$worktree_git_dir" -maxdepth 1 -type f -name "*.lock" 2>/dev/null || true

                # Also check the main .git directory (contains shared resources like index.lock)
                local commondir
                if [[ -f "$worktree_git_dir/commondir" ]]; then
                    commondir=$(cat "$worktree_git_dir/commondir" | tr -d '\n')
                    local main_git_dir="$worktree_git_dir/$commondir"
                    if [[ -d "$main_git_dir" ]]; then
                        find "$main_git_dir" -maxdepth 2 -type f -name "*.lock" 2>/dev/null || true
                    fi
                fi
            } | while IFS= read -r lock_file; do
                # Convert to absolute canonical path for deduplication (resolve .. and symlinks)
                if cd "$(dirname "$lock_file")" 2>/dev/null; then
                    echo "$(pwd -P)/$(basename "$lock_file")"
                    cd - >/dev/null
                else
                    echo "$lock_file"
                fi
            done | sort -u
        fi
    # Handle normal repository case: .git is a directory
    elif [[ -d "$git_path" ]]; then
        # Find all .lock files in .git directory
        find "$git_path" -type f -name "*.lock" 2>/dev/null || true
    fi
}

# Get human-readable age of a file
get_file_age() {
    local lock_file="$1"
    local current_time=$(date +%s)
    local file_time=$(stat -f %m "$lock_file" 2>/dev/null || stat -c %Y "$lock_file" 2>/dev/null || echo 0)
    local age_seconds=$((current_time - file_time))
    local age_minutes=$((age_seconds / 60))

    if [[ $age_minutes -lt 60 ]]; then
        echo "${age_minutes} minutes old"
    else
        local age_hours=$((age_minutes / 60))
        echo "${age_hours} hours old"
    fi
}

# Remove a lock file
remove_lock() {
    local lock_file="$1"

    if [[ "$DRY_RUN" == true ]]; then
        return 0
    fi

    if rm -f "$lock_file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Main cleanup logic
cleanup_locks() {
    local target_path="${TARGET_PATH:-$(pwd)}"

    # Validate target path
    if [[ ! -d "$target_path" ]]; then
        error "Target path does not exist: $target_path"
        return 1
    fi

    info "Scanning for Git lock files in: $target_path"

    # Find all lock files
    local lock_files=()
    while IFS= read -r lock_file; do
        if is_lock_stale "$lock_file"; then
            lock_files+=("$lock_file")
        fi
    done < <(find_lock_files "$target_path")

    # No stale locks found
    if [[ ${#lock_files[@]} -eq 0 ]]; then
        success "No stale lock files found"
        return 0
    fi

    # Display found locks
    if [[ "$QUIET" != true ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "\n${YELLOW}Would remove:${NC}"
        else
            echo -e "\n${YELLOW}Found ${#lock_files[@]} stale lock file(s):${NC}"
        fi

        for lock_file in "${lock_files[@]}"; do
            local relative_path="${lock_file#$target_path/}"
            local age=$(get_file_age "$lock_file")
            echo "  $relative_path ($age)"
        done
        echo ""
    fi

    # Handle based on mode
    case $MODE in
        interactive)
            if [[ "$DRY_RUN" == true ]]; then
                info "No changes made (dry-run mode)"
                return 0
            fi

            read -p "Remove stale locks? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Cleanup cancelled"
                return 0
            fi
            ;;
        auto)
            if [[ "$DRY_RUN" == true ]]; then
                [[ "$QUIET" != true ]] && info "No changes made (dry-run mode)"
                return 0
            fi
            # Proceed automatically
            ;;
    esac

    # Remove locks
    local removed_count=0
    local failed_count=0

    for lock_file in "${lock_files[@]}"; do
        if remove_lock "$lock_file"; then
            ((removed_count++))
            [[ "$QUIET" != true ]] && success "Removed: ${lock_file#$target_path/}"
        else
            ((failed_count++))
            error "Failed to remove: ${lock_file#$target_path/}"
        fi
    done

    # Summary
    if [[ "$QUIET" != true ]]; then
        echo ""
        if [[ $failed_count -eq 0 ]]; then
            success "Cleanup complete! Removed $removed_count lock file(s)"
        else
            warning "Cleanup finished with errors: $removed_count removed, $failed_count failed"
        fi
    fi

    return 0
}

# Main execution
main() {
    parse_args "$@"
     cleanup_locks
}

main "$@"
