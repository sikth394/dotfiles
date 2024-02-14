# parse_git_branch() {
#   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
# }
# PS1="\[$(tput setaf 045)\][\u] "; #tourkoize name
# PS1+="\[$(tput setaf 033)\]\W \[$(tput sgr0)\]";  #blue workdir
# PS1+="\[\$(parse_git_branch)\] "
# PS1+="\[$(tput setaf 123)\]-> ";  # light tourkoize arrow
# PS1+="\[$(tput sgr0)\]";          # reset to default color (for commands)
# export PS1;
#!/bin/bash
#export PYENV_VIRTUALENV_DISABLE_PROMPT=1
set_prompt()
{
   local last_cmd=$?
   local txtreset='$(tput sgr0)'
   local txtbold='$(tput bold)'
   local txtblack='$(tput setaf 0)'
   local txtred='$(tput setaf 1)'
   local txtgreen='$(tput setaf 48)'
   local txtyellow='$(tput setaf 055)'
   local txtturquoise='$(tput setaf 045)'
   local txtblue='$(tput setaf 033)'
   local txtpurple='$(tput setaf 134)'
   local txtcyan='$(tput setaf 6)'
   local txtwhite='$(tput setaf 7)'
   # [user] workdir
   PS1="\[$txtturquoise\][\u]\[$txtyellow\]@\[$txtpurple\][\h] \[$txtblue\]\W"
   # Line 4: red git branch
   PS1+="\[$txtred\]$(__git_ps1 ' (%s)')\[$(tput sgr0)\]"
   PS1+=" \[$txtgreen\]-> "
   PS1+="\[$(tput sgr0)\]"
}
PROMPT_COMMAND='set_prompt'
alias gitst="git status"
alias gitstatus="git status"
alias curl="curl --compressed"
alias slsd="serverless deploy"
alias slsr="serverless remove"
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
PYENV_VIRTUALENV_DISABLE_PROMPT=1
eval "$(pyenv init -)"
PATH=$(pyenv root)/shims:$PATH
alias gitt=hub
. "$HOME/.cargo/env"