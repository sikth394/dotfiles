# ===========================
# Powerlevel10k Instant Prompt
# ===========================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===========================
# Oh-My-Zsh Configuration
# ===========================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX="true"

# Plugins - using lazy loading for nvm to improve startup time
plugins=(git z docker zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ===========================
# Path Configuration
# ===========================
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/Users/aviv/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PYTHONPATH=./gen-py/:

# Use python3.11 as default
PATH="$(brew --prefix python@3.11)/libexec/bin:$PATH"

# ===========================
# Python/Pyenv Configuration
# ===========================
# Lazy load pyenv for faster startup
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
    # If .venv folder is found then activate the virtualenv
    if [ -d ./.venv ] ; then
      source ./.venv/bin/activate
    fi
  else
    # Check if the current folder belongs to earlier VIRTUAL_ENV folder
    # If yes then do nothing, else deactivate
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
# Lazy load nvm for faster startup - only load when node/npm/nvm is called
export NVM_DIR="$HOME/.nvm"

nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}

npm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}

npx() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
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

# ===========================
# Development Tools
# ===========================
# Python linting/formatting
alias rfo="ruff format ."
alias rcf="ruff check --fix"

# Virtual environment
alias acti=" source .venv/bin/activate"
alias deac="deactivate"

# Claude context update
alias cld="~/workspace/claude-docs/update_context.sh"

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
# LocalStack Utilities
# ===========================
p_queue() {
  awslocal sqs purge-queue --queue-url http://localhost:4566/000000000000/"${1:-collectors}"_queue.fifo
}

# ===========================
# Mission Management
# ===========================
# Open missions directory in Obsidian
alias msn="obs ~/workspace/missions"

# Create new mission file
nm() {
  obs "$HOME/workspace/missions/$*.md"
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
# Git Worktree Aliases
# ===========================

# Platform repository location (auto-detected during setup)
export PLATFORM_REPO="/Users/aweissman/workspace/platform"

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
  if [[ "none" != "none" ]]; then
    echo ""
    local ide_name=""
    local ide_app=""

    case "" in
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

    if [[ -n "" ]]; then
      read "open_ide?Open in ? (y/n): "
      echo ""

      if [[ "" =~ ^[Yy]$ ]]; then
        echo "✓ Opening in ..."
        if [[ "" == "neovim" ]]; then
          # Open neovim in the current terminal
          nvim ""
        else
          open -a "" "" 2>/dev/null || echo "⚠  not found"
        fi
      fi
    fi
  fi

  cd "" || return
  echo "✓ Switched to: "
  echo ""
  echo "Tip: Run 'cld' to update Claude context"
}

# ===========================
# Powerlevel10k Theme
# ===========================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
