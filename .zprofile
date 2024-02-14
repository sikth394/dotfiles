export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
if which pyenv-virtualenv-init > /dev/null; then 
  eval "$(pyenv virtualenv-init -)";
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

##
# Your previous /Users/aviv.weissman/.zprofile file was backed up as /Users/aviv.weissman/.zprofile.macports-saved_2022-06-22_at_15:18:15
##

# MacPorts Installer addition on 2022-06-22_at_15:18:15: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.


# MacPorts Installer addition on 2022-06-22_at_15:18:15: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.

