# ===========================
# Powerlevel10k Instant Prompt
# ===========================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===========================
# Oh-My-Zsh Configuration
# ===========================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX="true"

plugins=(z zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ===========================
# Path Configuration
# ===========================
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Use specific python version as default (avoids ~340ms brew --prefix call at startup)
# Update the version below to match your installed python
# PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"

# ===========================
# Python/Pyenv Configuration
# ===========================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=0

alias pyenv-fix='rm -f ~/.pyenv/shims/.pyenv-shim && pyenv rehash'

# Lazy init pyenv when first pyenv command is run
pyenv() {
  unset -f pyenv
  eval "$(command pyenv init -)"
  pyenv "$@"
}

# Auto-activate/deactivate virtualenv on directory change
function cd() {
  builtin cd "$@"

  if [ -z "$VIRTUAL_ENV" ] ; then
    if [ -d ./.venv ] ; then
      source ./.venv/bin/activate
    fi
  else
    parentdir="$(dirname "$VIRTUAL_ENV")"
    if [[ "$PWD"/ != "$parentdir"/* ]] ; then
      deactivate
      if [ -d ./.venv ]; then
        source ./.venv/bin/activate
        printf "\033[0;32mSwitched venv\033[0m\n"
      fi
    fi
  fi
}

# ===========================
# Node/NVM Configuration
# ===========================
# Hardcode default node to PATH for instant availability (~0ms vs ~1130ms eager nvm)
# Update the version below to match your installed node version
export NVM_DIR="$HOME/.nvm"
# export PATH="$NVM_DIR/versions/node/v23.11.0/bin:$PATH"

# Lazy load nvm itself — only needed for `nvm use/install/etc`
_nvm_load() {
  local nvm_prefix="/opt/homebrew/opt/nvm"
  unset -f nvm
  [ -s "${nvm_prefix}/nvm.sh" ] && \. "${nvm_prefix}/nvm.sh"
  [ -s "${nvm_prefix}/etc/bash_completion.d/nvm" ] && \. "${nvm_prefix}/etc/bash_completion.d/nvm"
}
nvm() { _nvm_load; nvm "$@"; }

# ===========================
# Git Configuration
# ===========================
# Interactive branch checkout with fzf (or pass branch name directly)
gc() {
  if [[ $# -gt 0 ]]; then
    git checkout "$@"
    return
  fi
  local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -z "$current_branch" ]]; then
    echo "Not in a git repository"
    return 1
  fi
  local branch=$(git branch \
    | sed 's|^[* ] ||' \
    | grep -F -x -v "$current_branch" \
    | fzf --prompt="Checkout branch: " \
          --header="Current branch: ${current_branch}" \
          --preview="git log --oneline --color=always -15 {}" \
          --preview-window=right:50%)
  if [[ -z "$branch" ]]; then
    echo "No branch selected"
    return 0
  fi
  git checkout "$branch"
}
alias gcb="git checkout -b"
alias gcm="git commit -m"
alias glg="git lg"
alias glgr="git lgr"
alias gba="git branch --all"
alias gst="git status"
alias gsh="git stash"
alias gshp="git stash pop"
alias gs="git switch"
alias gk="gitk"
alias gbp="git rev-parse --abbrev-ref HEAD"
alias gmm="git merge origin/master"
alias gmmp="git fetch --no-recurse-submodules origin master && git branch -f master origin/master 2>/dev/null && git merge origin/master"
alias grm="git rebase origin/master"
alias gmc="git merge --continue"
alias gfo="git fetch origin"
alias gp="git pull"
alias gps="git push"
alias gituser='echo "Name: $(git config user.name)\nEmail: $(git config user.email)\nRemote: $(git remote get-url origin 2>/dev/null || echo "No origin set")"'
alias delmaster="git branch -D master"

# Launch Claude Code
alias cla="claude"

# Fetch, prune, and delete branches whose remote is gone
gfp() {
  git fetch --prune
  git branch -vv | awk '/: gone]/{print $1}' | grep -v '^$' | while read -r branch; do
    git branch -D "$branch"
  done
}

# Create branch from latest master
gcbm() {
  git fetch --no-recurse-submodules origin master && git branch -f master origin/master && git checkout -b "$1" --no-track origin/master
}

# Interactive multi-select branch delete with fzf
gbd() {
  local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -z "$current_branch" ]]; then
    echo "Not in a git repository"
    return 1
  fi

  local branches_to_delete=$(git branch \
    | sed 's/^[* ] //' \
    | grep -F -x -v "$current_branch" \
    | fzf --multi \
          --prompt="Delete branches (TAB to select, ENTER to confirm): " \
          --header="Current branch: ${current_branch} (excluded)" \
          --preview="git log --oneline --color=always -10 {}" \
          --preview-window=right:50%)

  if [[ -z "$branches_to_delete" ]]; then
    echo "No branches selected"
    return 0
  fi

  echo ""
  echo "Branches to delete:"
  echo "$branches_to_delete" | while read -r b; do echo "  - $b"; done
  echo ""
  echo -n "Confirm deletion? [y/N] "
  read -r confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted"
    return 0
  fi

  echo "$branches_to_delete" | while read -r branch; do
    if git branch -d "$branch" 2>/dev/null; then
      echo "Deleted: $branch"
    elif git branch -D "$branch" 2>/dev/null; then
      echo "Force-deleted (unmerged): $branch"
    else
      echo "Failed to delete: $branch"
    fi
  done
}

# Git help reference
ghelp() {
  echo ""
  echo "Git Aliases & Functions Quick Reference"
  echo "========================================"
  echo ""
  printf "%-18s %-50s\n" "Command" "Description"
  printf "%-18s %-50s\n" "-------" "-----------"
  echo ""
  echo "🚀 \033[1mBranching & Checkout\033[0m"
  printf "%-18s %-50s\n" "gc <branch>" "Checkout branch (fzf interactive if no arg)"
  printf "%-18s %-50s\n" "gcb <branch>" "Create and checkout new branch"
  printf "%-18s %-50s\n" "gcbm <branch>" "Create branch from latest master"
  printf "%-18s %-50s\n" "gs <branch>" "Switch to branch"
  printf "%-18s %-50s\n" "gbp" "Show current branch name"
  printf "%-18s %-50s\n" "gba" "Show all branches (local + remote)"
  printf "%-18s %-50s\n" "delmaster" "Delete local master branch"
  echo ""
  echo "📝 \033[1mCommitting\033[0m"
  printf "%-18s %-50s\n" 'gcm "msg"' "Commit with message"
  echo ""
  echo "🔄 \033[1mSyncing & Merging\033[0m"
  printf "%-18s %-50s\n" "gp" "Pull from remote"
  printf "%-18s %-50s\n" "gps" "Push to remote"
  printf "%-18s %-50s\n" "gfo" "Fetch from origin"
  printf "%-18s %-50s\n" "gmm" "Merge origin/master into current branch"
  printf "%-18s %-50s\n" "gmmp" "Fetch and merge origin/master"
  printf "%-18s %-50s\n" "grm" "Rebase on origin/master"
  printf "%-18s %-50s\n" "gmc" "Continue merge after conflicts"
  echo ""
  echo "📜 \033[1mHistory & Info\033[0m"
  printf "%-18s %-50s\n" "glg" "Show git log (custom format)"
  printf "%-18s %-50s\n" "glgr" "Show git log with reflog"
  printf "%-18s %-50s\n" "gk" "Open gitk GUI"
  printf "%-18s %-50s\n" "gituser" "Show current git user name, email, and remote"
  echo ""
  echo "📊 \033[1mStatus\033[0m"
  printf "%-18s %-50s\n" "gst" "Show git status"
  echo ""
  echo "📦 \033[1mStashing\033[0m"
  printf "%-18s %-50s\n" "gsh" "Stash changes"
  printf "%-18s %-50s\n" "gshp" "Pop stash"
  echo ""
  echo "🧹 \033[1mCleanup\033[0m"
  printf "%-18s %-50s\n" "gfp" "Fetch, prune, and delete gone branches"
  printf "%-18s %-50s\n" "gbd" "Interactive multi-select branch delete (fzf)"
  echo ""
}

# ===========================
# Development Tools
# ===========================
# Claude Code fullscreen rendering (flicker-free, mouse support, flat memory)
export CLAUDE_CODE_NO_FLICKER=1

# Python linting/formatting
alias rfo="ruff format ."
alias rcf="ruff check --fix"

# Virtual environment
alias acti=" source .venv/bin/activate"
alias deac="deactivate"

# Claude context update - point this to your update_context.sh script location
alias cld="<path-to>/update_context.sh"

# ===========================
# Mission Management
# ===========================
# Inherit Obsidian settings (plugins, themes, snippets) from missions vault into a new vault
# Usage: obs-inherit <target_vault> [source_vault]
alias obs-inherit="$HOME/workspace/dotfiles/programs_config/obsidian/inherit_settings.sh"

# Open missions directory in Obsidian
alias msn="obs ~/workspace/docs/missions"

# Show in-progress missions from BOARD.md (full content)
smsn() {
  local board="$HOME/workspace/docs/missions/BOARD.md"
  local missions_dir="$HOME/workspace/docs/missions/_missions"
  local in_progress
  in_progress=$(awk '/^## In Progress/{found=1; next} /^## /{found=0} found && /\[\[.*\]\]/{gsub(/.*\[\[|\]\].*/,""); print}' "$board")
  if [ -z "$in_progress" ]; then
    echo "No missions in progress."
    return
  fi
  local mission_num=1
  while IFS= read -r mission_name; do
    local mission_file="$missions_dir/$mission_name.md"
    printf "\033[1;36m# ============================================================\033[0m\n"
    printf "\033[1;36m# Mission $mission_num: $mission_name\033[0m\n"
    printf "\033[1;36m# ============================================================\033[0m\n"
    echo ""
    if [ -f "$mission_file" ]; then
      cat "$mission_file"
    else
      echo "(file not found: $mission_file)"
    fi
    echo ""
    mission_num=$((mission_num + 1))
  done <<< "$in_progress"
}

# List in-progress missions (number + title only)
lsmsn() {
  local board="$HOME/workspace/docs/missions/BOARD.md"
  local in_progress
  in_progress=$(awk '/^## In Progress/{found=1; next} /^## /{found=0} found && /\[\[.*\]\]/{gsub(/.*\[\[|\]\].*/,""); print}' "$board")
  if [ -z "$in_progress" ]; then
    echo "No missions in progress."
    return
  fi
  local mission_num=1
  while IFS= read -r mission_name; do
    printf "\033[1;36mMission %d:\033[0m %s\n" "$mission_num" "$mission_name"
    mission_num=$((mission_num + 1))
  done <<< "$in_progress"
}

# Add mission link to BOARD.md TODO section
_add_to_board() {
  local name="$1"
  local board="$HOME/workspace/docs/missions/BOARD.md"
  sed -i '.bak' "/^## TODO$/a\\
- [ ] [[$name]]
" "$board" && rm -f "$board.bak"
}

# Create new mission file in _missions/ and add to board
# Usage: nm name :: optional body text
nm() {
  local input="$*"
  local name="${input%%::*}"
  name="${name%"${name##*[! ]}"}"  # trim trailing spaces
  name="${name//\//-}"  # replace / with - for safe filenames
  local body=""
  if [[ "$input" == *"::"* ]]; then
    body="${input#*::}"
    body="${body#"${body%%[! ]*}"}"  # trim leading spaces
    if [[ -z "$body" ]]; then
      vared -p "body> " body
    fi
  fi
  local mission_file="$HOME/workspace/docs/missions/_missions/$name.md"
  if [[ -n "$body" ]]; then
    echo "$body" > "$mission_file"
  else
    touch "$mission_file"
  fi
  _add_to_board "$name"
  obs "$mission_file"
}

# Create new mission file with format template in _missions/ and add to board
# Usage: nmf name :: optional context text
nmf() {
  local input="$*"
  local name="${input%%::*}"
  name="${name%"${name##*[! ]}"}"  # trim trailing spaces
  name="${name//\//-}"  # replace / with - for safe filenames
  local body=""
  if [[ "$input" == *"::"* ]]; then
    body="${input#*::}"
    body="${body#"${body%%[! ]*}"}"  # trim leading spaces
    if [[ -z "$body" ]]; then
      vared -p "context> " body
    fi
  fi
  local mission_file="$HOME/workspace/docs/missions/_missions/$name.md"
  local template="$HOME/workspace/docs/missions/config/mission format.md"
  if [[ -n "$body" ]]; then
    awk -v body="$body" '/^# Context$/{print; print ""; print body; next} 1' "$template" > "$mission_file"
  else
    cat "$template" > "$mission_file"
  fi
  _add_to_board "$name"
  obs "$mission_file"
}

# Interactive multi-select mission delete (fzf)
dm() {
  local missions_dir="$HOME/workspace/docs/missions/_missions"
  local root_dir="$HOME/workspace/docs/missions"
  local board="$HOME/workspace/docs/missions/BOARD.md"

  # Parse BOARD.md: extract missions grouped by section, excluding Done
  # Colors match kanban CSS: blue=TODO, cyan=In Progress, grey=On Hold, mauve=Long Hold
  local entries=""
  local section=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^##\ (.+) ]]; then
      section="${match[1]}"
      [[ "$section" == *"Done"* ]] && section=""
    elif [[ -n "$section" && "$line" =~ '\[\[(.+)\]\]' ]]; then
      local name="${match[1]}"
      local color=""
      case "$section" in
        TODO)            color="\x1b[38;2;100;160;230m" ;;  # cool blue
        "In Progress")   color="\x1b[38;2;0;200;255m" ;;    # electric cyan
        "Waiting For Review"*) color="\x1b[38;2;180;130;255m" ;; # soft violet
        "On Hold"*)      color="\x1b[38;2;155;140;180m" ;;  # lavender grey
        "On Long Hold"*) color="\x1b[38;2;180;100;130m" ;;  # muted rose
        *)               color="\x1b[37m" ;;
      esac
      entries+="${color}[$section]\x1b[0m $name"$'\n'
    fi
  done < "$board"

  # Add loose files from root missions folder (no board association)
  local loose_color="\x1b[38;2;180;180;100m"  # dim yellow
  for f in "$root_dir"/*.md(N); do
    local basename="${f##*/}"
    [[ "$basename" == "BOARD.md" ]] && continue
    local name="${basename%.md}"
    entries+="${loose_color}[Root]\x1b[0m $name"$'\n'
  done
  for f in "$root_dir"/*.png(N) "$root_dir"/*.jpg(N) "$root_dir"/*.jpeg(N) "$root_dir"/*.gif(N); do
    local basename="${f##*/}"
    entries+="${loose_color}[Root]\x1b[0m $basename"$'\n'
  done
  # Add files from Files/ directory
  local files_color="\x1b[38;2;160;140;200m"  # soft purple
  for f in "$root_dir"/Files/*(N); do
    [[ ! -f "$f" ]] && continue
    local basename="${f##*/}"
    entries+="${files_color}[Files]\x1b[0m $basename"$'\n'
  done

  if [[ -z "$entries" ]]; then
    echo "No missions or loose files found."
    return 0
  fi

  local selected=$(echo -e "$entries" | sed '/^$/d' \
    | fzf --multi --ansi \
          --prompt="Delete missions (TAB to select, ENTER to confirm): " \
          --preview="name=\$(echo {} | sed 's/^\[[^]]*\] //'); if [ -f '$root_dir'/Files/\"\$name\" ]; then echo '[Files/]'; file '$root_dir'/Files/\"\$name\"; elif [ -f '$root_dir'/\"\$name\" ]; then echo '[Root file]'; file '$root_dir'/\"\$name\"; elif [ -f '$root_dir'/\"\$name\".md ]; then cat '$root_dir'/\"\$name\".md; elif [ -f '$missions_dir'/\"\$name\".md ]; then cat '$missions_dir'/\"\$name\".md; else echo 'No file found'; fi" \
          --preview-window=right:50%)

  if [[ -z "$selected" ]]; then
    echo "No missions selected"
    return 0
  fi

  echo ""
  echo "Missions to delete:"
  echo "$selected" | while read -r m; do echo "  - $m"; done
  echo ""
  echo -n "Confirm deletion? [y/N] "
  read -r confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted"
    return 0
  fi

  echo "$selected" | while read -r line; do
    # Strip ANSI escape codes before parsing
    line=$(printf '%s' "$line" | sed -E 's/\x1B\[[0-9;]*[mK]//g')
    local section_tag="${line%%\] *}"
    section_tag="${section_tag#\[}"
    local name="${line#\[*\] }"
    if [[ "$section_tag" == "Files" ]]; then
      rm -f "$root_dir/Files/$name"
      echo "Deleted (Files): $name"
    elif [[ "$section_tag" == "Root" ]]; then
      if [[ -f "$root_dir/$name" ]]; then
        rm -f "$root_dir/$name"
      else
        rm -f "$root_dir/$name.md"
      fi
      echo "Deleted (root): $name"
    else
      rm -f "$missions_dir/$name.md"
      sed -i '.bak' "/\[\[$name\]\]/d" "$board"
      echo "Deleted: $name"
    fi
  done
  rm -f "$board.bak"
}

# Clear all missions
cms() {
  rm -f ~/workspace/docs/missions/_missions/*.md
}

# ===========================
# Meeting Notes
# ===========================
# Open the meeting-notes vault in Obsidian
alias mtg="obs ~/workspace/docs/meeting-notes"

# Create today's meeting note from a template and open it in Obsidian
# Usage:
#   nmtg                    # today's note in "General/" from _templates/default.md
#   nmtg "<meeting>"        # today's note in "<meeting>/"; template _templates/<meeting>.md, fallback default.md
nmtg() {
  local vault="$HOME/workspace/docs/meeting-notes"
  local meeting="${1:-General}"
  local folder="$vault/$meeting"
  local default_template="$vault/_templates/default.md"
  local meeting_template="$vault/_templates/$meeting.md"
  local template
  if [[ -f "$meeting_template" ]]; then
    template="$meeting_template"
  else
    template="$default_template"
  fi
  local date_str=$(date +%F)
  local note="$folder/$date_str.md"

  [[ ! -d "$folder" ]] && mkdir -p "$folder"

  if [[ ! -f "$note" ]]; then
    if [[ -f "$template" ]]; then
      sed "s/{{date}}/$date_str/g" "$template" > "$note"
    else
      touch "$note"
    fi
    echo "Created $note"
  fi

  obs "$note"
}

# Mission & plan management help
mhelp() {
  echo ""
  echo "Mission & Claude Plan Management"
  echo "================================="
  echo ""
  echo "📋 \033[1mMissions\033[0m"
  printf "%-18s %-50s\n" "Command" "Description"
  printf "%-18s %-50s\n" "-------" "-----------"
  printf "%-18s %-50s\n" "msn" "Open missions directory in Obsidian"
  printf "%-18s %-50s\n" "smsn" "Show in-progress missions (full content)"
  printf "%-18s %-50s\n" "lsmsn" "List in-progress missions (number + title)"
  printf "%-18s %-50s\n" "nm <name>" "Create new mission (nm name :: body)"
  printf "%-18s %-50s\n" "nmf <name>" "Create mission with template (nmf name :: ctx)"
  printf "%-18s %-50s\n" "dm" "Interactive multi-select mission delete (fzf)"
  printf "%-18s %-50s\n" "cms" "Clear all mission files"
  echo ""
  echo "📝 \033[1mMeeting Notes\033[0m"
  printf "%-18s %-50s\n" "mtg" "Open meeting-notes vault in Obsidian"
  printf "%-18s %-50s\n" "nmtg [meeting]" "Create today's meeting note from template"
  echo ""
  echo "📐 \033[1mClaude Plans\033[0m"
  printf "%-18s %-50s\n" "pln" "Open plans directory in Obsidian"
  printf "%-18s %-50s\n" "cps" "Clear all Claude plans"
  echo ""
  echo "🔧 \033[1mContext\033[0m"
  printf "%-18s %-50s\n" "cld" "Update Claude context"
  echo ""
}

# ===========================
# Claude Plans Management
# ===========================
# Open plans directory in Obsidian
alias pln="obs ~/.claude/plans"

# Clear all Claude plans
cps() {
  rm -f ~/.claude/plans/*
}

# ===========================
# Master Help
# ===========================
help() {
  echo ""
  echo "📖 Available Help Commands"
  echo "==========================="
  echo ""
  printf "%-12s %-40s\n" "Command" "Topic"
  printf "%-12s %-40s\n" "-------" "-----"
  printf "%-12s %-40s\n" "ghelp" "🔀 Git aliases & functions"
  printf "%-12s %-40s\n" "mhelp" "📋 Missions & Claude plans"
  printf "%-12s %-40s\n" "wt-help" "🌳 Git worktrees"
  echo ""
}

# ===========================
# Powerlevel10k Theme
# ===========================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===========================
# Git Worktree Aliases
# ===========================

# Main repository location - configure for your setup
export PLATFORM_REPO="$HOME/workspace/<your-repo>"

# IDE preference for git worktree operations
# Supported: pycharm, cursor, vscode, neovim, none
export WT_IDE="pycharm"

# PyCharm window mode (optional, prompts if not set)
# Supported: new, current
# export WT_PYCHARM_WINDOW="current"

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
alias wt-unlock-fast='$PLATFORM_REPO/scripts/git_worktree/cleanup_git_locks.sh --interactive --fast'
alias wt-trash-rm='$PLATFORM_REPO/scripts/git_worktree/trash_cleanup.sh'
alias wt-sync-envs='$PLATFORM_REPO/scripts/git_worktree/sync_envs.sh'

# wt-switch requires a function (not an alias) to change directory
wt-switch() {
  local selected_path=$($PLATFORM_REPO/scripts/git_worktree/select_worktree.sh)

  if [[ -z "$selected_path" ]]; then
    echo "Selection cancelled"
    return 1
  fi

  $PLATFORM_REPO/scripts/git_worktree/cleanup_git_locks.sh \
      --auto --quiet --worktree "$selected_path" 2>/dev/null || true

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
        ide_app=""
        ;;
      *)
        ide_name=""
        ;;
    esac

    if [[ -n "$ide_name" ]]; then
      read "open_ide?Open in $ide_name? (y/n): "
      echo ""

      if [[ "$open_ide" =~ ^[Yy]$ ]]; then
        if [[ "$WT_IDE" == "neovim" ]]; then
          nvim "$selected_path"
        elif [[ "$WT_IDE" == "pycharm" ]]; then
          local window_mode="${WT_PYCHARM_WINDOW:-}"

          if [[ -z "$window_mode" ]]; then
            read "window_mode?Open in (n)ew window or (c)urrent window? [n/c]: "
            echo ""
          fi

          if [[ "$window_mode" =~ ^[Cc]$ || "$window_mode" == "current" ]]; then
            if command -v pycharm &> /dev/null; then
              echo "✓ Opening in current PyCharm window..."
              pycharm "$selected_path" 2>/dev/null
            else
              echo "⚠ PyCharm command-line launcher not found"
              echo "  Install it via: PyCharm > Tools > Create Command-line Launcher"
              echo "  Falling back to new window..."
              open -a "$ide_app" "$selected_path" 2>/dev/null || echo "⚠ PyCharm not found"
            fi
          else
            echo "✓ Opening in new PyCharm window..."
            open -a "$ide_app" "$selected_path" 2>/dev/null || echo "⚠ PyCharm not found"
          fi
        else
          echo "✓ Opening in $ide_name..."
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

# wt-help displays a table of all git worktree aliases
wt-help() {
  echo ""
  echo "Git Worktree Quick Reference"
  echo "============================="
  echo ""
  printf "%-18s %-50s\n" "Command" "Description"
  printf "%-18s %-50s\n" "-------" "-----------"
  printf "%-18s %-50s\n" "wt-ls" "List all worktrees"
  printf "%-18s %-50s\n" "wt-new <branch>" "Create new worktree with full setup"
  printf "%-18s %-50s\n" "wt-switch" "Interactive switch (fzf + IDE option)"
  printf "%-18s %-50s\n" "wt-rm" "Interactive delete (fzf + confirmation)"
  printf "%-18s %-50s\n" "wt-sync-status" "Check sync_all progress"
  printf "%-18s %-50s\n" "wt-sync-envs" "Sync environment files across all worktrees"
  printf "%-18s %-50s\n" "wt-unlock" "Clean up stale Git lock files (with time check)"
  printf "%-18s %-50s\n" "wt-unlock-fast" "Clean up Git lock files (skip time check)"
  printf "%-18s %-50s\n" "wt-trash-rm" "Clean up trash folder (remove all)"
  echo ""
  echo "For detailed documentation, see: docs/git_worktree/GIT_WORKTREE_REF.md"
  echo ""
}
