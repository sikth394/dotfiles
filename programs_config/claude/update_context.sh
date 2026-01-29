#!/bin/bash

# Update .claude/CLAUDE.md with auto-generated context
# This script:
# 1. Reads the existing CLAUDE.md up to the CANARY_MARKER
# 2. Trims everything after the canary marker
# 3. Appends fresh auto-generated context

set -e

# Configuration
# TODO: Update these to match your setup
REPO_DIR="$HOME/workspace/<repo-name>"
MISSIONS_DIR="$HOME/workspace/missions"
GIT_AUTHOR="<your-github-username>"  # Your GitHub username for filtering commits
BASE_BRANCH="master"  # Base branch for diffs (master or main)
TARGET_FILE="$REPO_DIR/.claude/CLAUDE.md"
TEMP_FILE=$(mktemp)
TIMESTAMP=$(date +%s)

echo "Updating $TARGET_FILE with fresh context..."

# Read file up to and including the canary marker
awk '/<!-- CANARY_MARKER -->/{print; exit} {print}' "$TARGET_FILE" > "$TEMP_FILE"

# Add separator
echo "" >> "$TEMP_FILE"
echo "---" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Section 1: Active Missions
echo "[SECTION_START: Active Missions - $TIMESTAMP]" >> "$TEMP_FILE"
echo "## Active Missions Content" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

if [ -d "$MISSIONS_DIR" ]; then
    # Recursively find only markdown files (excluding archived and for_later folders)
    mission_num=1
    find "$MISSIONS_DIR" -type f -name "*.md" -not -path "*/archived/*" -not -path "*/for_later/*" -print0 2>/dev/null | sort -z | while IFS= read -r -d '' file; do
        # Get relative path from MISSIONS_DIR
        relative_path="${file#$MISSIONS_DIR/}"
        mission_name="${relative_path%.md}"
        echo "# ============================================================" >> "$TEMP_FILE"
        echo "# Mission $mission_num: $mission_name" >> "$TEMP_FILE"
        echo "# ============================================================" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        cat "$file" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        echo "" >> "$TEMP_FILE"
        mission_num=$((mission_num + 1))
    done
else
    echo "_No active missions found_" >> "$TEMP_FILE"
    echo "" >> "$TEMP_FILE"
fi

echo "[SECTION_END: Active Missions]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Section 2: Last 5 Commits (Full)
echo "[SECTION_START: Last 5 Commits Full - $TIMESTAMP]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "## Last 5 Commits (Full)" >> "$TEMP_FILE"
git -C "$REPO_DIR" log -5 --pretty=medium >> "$TEMP_FILE"
echo "[SECTION_END: Last 5 Commits]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Section 3: Personal Git History
echo "[SECTION_START: Personal Git History - $TIMESTAMP]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "## Git History (Author: $GIT_AUTHOR, Last 20)" >> "$TEMP_FILE"
git -C "$REPO_DIR" log --author="$GIT_AUTHOR" -20 --oneline >> "$TEMP_FILE"
echo "[SECTION_END: Personal Git History]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Section 4: Git Diff Files (Committed)
echo "[SECTION_START: Git Diff Files - $TIMESTAMP]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "## Git Diff ($BASE_BRANCH...HEAD - Files Only)" >> "$TEMP_FILE"
git -C "$REPO_DIR" diff --name-only $BASE_BRANCH...HEAD -- ':!.claude/CLAUDE.md' >> "$TEMP_FILE"
echo "[SECTION_END: Git Diff]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Section 5: Staged Changes (Uncommitted)
echo "[SECTION_START: Staged Changes - $TIMESTAMP]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "## Staged Changes (git diff --cached)" >> "$TEMP_FILE"
git -C "$REPO_DIR" diff --cached --name-only -- ':!.claude/CLAUDE.md' >> "$TEMP_FILE"
echo "[SECTION_END: Staged Changes]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Section 6: Unstaged Changes (Uncommitted)
echo "[SECTION_START: Unstaged Changes - $TIMESTAMP]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"
echo "## Unstaged Changes (git diff)" >> "$TEMP_FILE"
git -C "$REPO_DIR" diff --name-only -- ':!.claude/CLAUDE.md' >> "$TEMP_FILE"
echo "[SECTION_END: Unstaged Changes]" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Replace original file
mv "$TEMP_FILE" "$TARGET_FILE"

echo "✓ Context updated successfully!"
echo "  File: $TARGET_FILE"
