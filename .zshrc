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

plugins=(git z docker zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ===========================
# Path Configuration
# ===========================
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ===========================
# Python/Pyenv Configuration
# ===========================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$PYENV_ROOT/shims:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=0

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
# Lazy load nvm for faster startup
export NVM_DIR="$HOME/.nvm"

nvm() {
  unset -f nvm node npm npx
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
  [ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"
  nvm "$@"
}

node() {
  unset -f nvm node npm npx
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
  node "$@"
}

npm() {
  unset -f nvm node npm npx
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
  npm "$@"
}

npx() {
  unset -f nvm node npm npx
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
  npx "$@"
}

# ===========================
# Git Configuration
# ===========================
# Git aliases
alias gitt="hub"
alias gcb="git checkout -b"
alias gc="git checkout"
alias gcm="git commit -m"
alias glg="git lg"
alias glgr="git lgr"
alias gba="git branch --all"
alias gst="git stash"
alias gstp="git stash pop"
alias gs="git switch"
alias gk="gitk"
alias gbp="git rev-parse --abbrev-ref HEAD"
alias gmm="git merge origin/master"
alias gmmp="git fetch --no-recurse-submodules origin master && git merge origin/master"
alias grm="git rebase origin/master"
alias gmc="git merge --continue"
alias gfo="git fetch origin"
alias gp="git pull"
alias gps="git push"
alias gituser='echo "Name: $(git config user.name)\nEmail: $(git config user.email)\nRemote: $(git remote get-url origin 2>/dev/null || echo "No origin set")"'
alias delmaster="git branch -D master"

# Git functions
gfp() {
  git fetch --prune
  git branch -vv | awk '/: gone]/{print $1}' | grep -v '^$' | while read -r branch; do
    git branch -D "$branch"
  done
}

gcbm() {
  git fetch origin master:master && git checkout -b "$1" master
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
  printf "%-18s %-50s\n" "gc <branch>" "Checkout branch"
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
  echo "📦 \033[1mStashing\033[0m"
  printf "%-18s %-50s\n" "gst" "Stash changes"
  printf "%-18s %-50s\n" "gstp" "Pop stash"
  echo ""
  echo "🧹 \033[1mCleanup\033[0m"
  printf "%-18s %-50s\n" "gfp" "Fetch, prune, and delete gone branches"
  echo ""
  echo "🔧 \033[1mOther\033[0m"
  printf "%-18s %-50s\n" "gitt" "GitHub hub command"
  echo ""
}

# ===========================
# Development Tools
# ===========================
# Python linting/formatting
alias rfo="ruff format ."
alias rcf="ruff check --fix"

# Virtual environment
alias acti=" source .venv/bin/activate"
alias deac="deactivate"

# ===========================
# AWS Configuration
# ===========================
alias gimme="gimme-aws-creds -p"

# AWS SSO login helper
asl() {
  aws sts get-caller-identity &> /dev/null
  EXIT_CODE="$?"
  if [ $EXIT_CODE != 0 ]; then
    aws sso login
  fi
}

# ===========================
# Mission Management
# ===========================
# Open missions directory in Obsidian
alias msn="obs ~/workspace/missions"

# Cat active missions from CLAUDE.md
alias cmsn='sed -n "/\[SECTION_START: Active Missions/,/\[SECTION_END: Active Missions\]/p" /Users/aweissman/workspace/platform/.claude/CLAUDE.md | sed "1d;\$d" | awk "BEGIN{in_title=0} /^# =+\$/{if(in_title==0){in_title=1}else{in_title=0}; printf \"\033[1;36m%s\033[0m\n\", \$0; next} in_title==1{printf \"\033[1;36m%s\033[0m\n\", \$0; next} {print}"'

# Create new mission file
nm() {
  obs "$HOME/workspace/missions/$*.md"
}

# Create new mission file with format template
nmf() {
  local mission_file="$HOME/workspace/missions/$*.md"
  cat "$HOME/workspace/missions/config/mission format.md" > "$mission_file"
  obs "$mission_file"
}

# Clear all missions
cms() {
  rm -f ~/workspace/missions/*.md
}

# Archive all missions
ams() {
  mkdir -p ~/workspace/missions/archived
  mv ~/workspace/missions/*.md ~/workspace/missions/archived/ 2>/dev/null || true
}

# Clear all archived missions
acms() {
  rm -f ~/workspace/missions/archived/*.md
}

# Mission & plan management help reference
mhelp() {
  echo ""
  echo "Mission & Claude Plan Management"
  echo "================================="
  echo ""
  echo "📋 \033[1mMissions\033[0m"
  printf "%-18s %-50s\n" "Command" "Description"
  printf "%-18s %-50s\n" "-------" "-----------"
  printf "%-18s %-50s\n" "msn" "Open missions directory in Obsidian"
  printf "%-18s %-50s\n" "cmsn" "Show active missions from CLAUDE.md"
  printf "%-18s %-50s\n" "nm <name>" "Create new mission file"
  printf "%-18s %-50s\n" "nmf <name>" "Create new mission with format template"
  printf "%-18s %-50s\n" "cms" "Clear all missions"
  printf "%-18s %-50s\n" "ams" "Archive all missions"
  printf "%-18s %-50s\n" "acms" "Clear all archived missions"
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

# Claude context update - point this to your update_context.sh script location
alias cld="<path-to>/update_context.sh"

# Clear all Claude plans
cps() {
  rm -f ~/.claude/plans/*
}

# ===========================
# Powerlevel10k Theme
# ===========================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===========================
# Git Worktree Aliases
# ===========================

# Platform repository location - configure for your setup
export PLATFORM_REPO="$HOME/workspace/platform"

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
}
