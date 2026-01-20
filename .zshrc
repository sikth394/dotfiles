# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH="/Users/aviv/.oh-my-zsh"
export ZSH_CUSTOM="${ZSH:-$HOME/.oh-my-zsh}/custom"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"
# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"
# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13
# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"
# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"
# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"
# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"
# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"
# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
export NVM_COMPLETION=true
export NVM_AUTO_USE=true
plugins=(git brew z pyenv docker nvm zsh-autosuggestions zsh-syntax-highlighting)
ZSH_DISABLE_COMPFIX="true"

# source $ZSH/oh-my-zsh.sh
# User configuration
# export MANPATH="/usr/local/man:$MANPATH"
# You may need to manually set your language environment
# export LANG=en_US.UTF-8
# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
# Compilation flags
# export ARCHFLAGS="-arch x86_64"
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# export PYENV_VIRTUALENV_DISABLE_PROMPT=1
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init --path)"
source ~/powerlevel10k/powerlevel10k.zsh-theme
export PYENV_VIRTUALENV_DISABLE_PROMPT=0
eval "$(pyenv init -)"
PATH=$(pyenv root)/shims:$PATH
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
alias gimme="gimme-aws-creds -p"
alias acti=" source .venv/bin/activate"
alias deac="deactivate"
alias gbp="git rev-parse --abbrev-ref HEAD"
alias rfo="ruff format ."
alias rcf="ruff check --fix"
alias gmm="git merge origin/master"
alias grm="git rebase origin/master"
alias gmc="git merge  --continue"
alias gfo="git fetch origin"
alias gp="git pull"
alias gps="git push"
alias cld="~/workspace/claude-docs/update_context.sh"
alias msn="obs ~/workspace/missions"
alias pln="obs ~/.claude/plans"
alias gituser='echo "Name: $(git config user.name)\nEmail: $(git config user.email)\nRemote: $(git remote get-url origin 2>/dev/null || echo "No origin set")"'
alias delmaster="git branch -D master"

# alias brew="arch -x86_64 brew"
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/Users/aviv/.local/bin:$PATH"
export PYTHONPATH=./gen-py/:

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


gfp() {
  git fetch --prune
  git branch -vv | awk '/: gone]/{print $1}' | grep -v '^$' | while read -r branch; do
    git branch -D "$branch"
  done
}

asl() {
    aws sts get-caller-identity &> /dev/null
    EXIT_CODE="$?"  # $? is the exit code of the last statement
    if [ $EXIT_CODE != 0 ]; then
        aws sso login
    fi
}





p_queue() {
  awslocal sqs purge-queue --queue-url http://localhost:4566/000000000000/"${1:-collectors}"_queue.fifo
}

function cd() {
  builtin cd "$@"

  if [ -z "$VIRTUAL_ENV" ] ; then
    ## If env folder is found then activate the vitualenv
      if [ -d ./.venv ] ; then
        source ./.venv/bin/activate
      fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
      parentdir="$(dirname "$VIRTUAL_ENV")"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        deactivate
        if [ -d ./.venv ]; then
            source ./.venv/bin/activate
            GREEN='\033[0;32m'  # Green color
            NC='\033[0m'         # No color (reset)

            # Construct the string with colors
            UV_VENV=$(uv version) # uv env
            printf "Switch venv to ${GREEN}$UV_VENV${NC}\n"
        fi
      fi
  fi
}


nm() {
    obs ~/workspace/missions/"$*".md
} # new mission

cms() {
    rm -f ~/workspace/missions/*.md
} # delete all missions

ams() {
    mkdir -p ~/workspace/missions/archived
    mv ~/workspace/missions/*.md ~/workspace/missions/archived/ 2>/dev/null || true
} # archive all missions

cps() {
    rm -f ~/.claude/plans/*
} # delete all claude plans

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. ~/.z-src/z.sh
