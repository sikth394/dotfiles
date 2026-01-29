#!/bin/bash

# Check Sync Status Script
# Usage: ./scripts/check_sync_status.sh [worktree_directory]
# Checks if sync_all and intellij_deps are still running in background

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

WORKTREE_PATH="${1:-.}"
WORKTREE_PATH="$(cd "$WORKTREE_PATH" 2>/dev/null && pwd)" || {
    echo -e "${RED}✗${NC} Invalid worktree path: $1"
    exit 1
}

# Determine log directory within the worktree
LOG_DIR="$WORKTREE_PATH/scripts/git_worktree/logs"

# Check if log directory exists
if [[ ! -d "$LOG_DIR" ]]; then
    echo -e "${GREEN}✓${NC} No background processes (log directory not found)"
    exit 0
fi

WORKTREE_DIR="$LOG_DIR"

# Function to check a process
check_process() {
    local name="$1"
    local pid_file="$WORKTREE_DIR/${name}.pid"
    local log_file="$WORKTREE_DIR/${name}.log"

    # Check if PID file exists
    if [[ ! -f "$pid_file" ]]; then
        echo -e "${GREEN}✓${NC} ${name} completed"
        if [[ -f "$log_file" ]]; then
            echo "  Last 3 lines of log:"
            tail -n 3 "$log_file" | sed 's/^/  /'
        fi
        return 0
    fi

    # Check if process is still running
    local pid=$(cat "$pid_file")
    if ps -p "$pid" > /dev/null 2>&1; then
        echo -e "${YELLOW}⏳${NC} ${name} still running (PID: $pid)"

        if [[ -f "$log_file" ]]; then
            echo "  Recent progress:"
            tail -n 2 "$log_file" | sed 's/^/  /'
            echo ""
            echo "  To monitor live: tail -f $log_file"
        fi
        return 1
    else
        echo -e "${GREEN}✓${NC} ${name} completed"
        echo "  (PID file is stale, cleaning up)"
        rm -f "$pid_file"

        if [[ -f "$log_file" ]]; then
            echo "  Last 3 lines of log:"
            tail -n 3 "$log_file" | sed 's/^/  /'
        fi
        return 0
    fi
}

echo -e "${BLUE}Background Process Status:${NC}"
echo ""

# Check IntelliJ deps (only if PyCharm user)
if [[ -f "$WORKTREE_DIR/intellij_deps.pid" ]] || [[ -f "$WORKTREE_DIR/intellij_deps.log" ]]; then
    check_process "intellij_deps"
    echo ""
fi

# Check sync_all
check_process "sync_all"
