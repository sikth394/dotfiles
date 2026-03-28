# dotfiles
Everything needed to get a new Mac up & running — with AI in mind.

This repo is designed so an AI assistant can read this file, follow the steps, and use the artifacts in the repo to set up a fully configured development environment.

---

## Setup Instructions

### 1. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Follow the post-install instructions to add Homebrew to your PATH.

### 2. Install Oh-My-Zsh
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. Install Powerlevel10k theme
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
After installing, run `p10k configure` to set up the prompt.

### 4. Install zsh plugins
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 5. Install fzf
Required for interactive git branch selection (`gc`, `gbd`) and mission management (`dm`).
```bash
brew install fzf
```

### 6. Copy .zshrc
```bash
cp .zshrc ~/.zshrc
source ~/.zshrc
```
After copying, configure these placeholders in `~/.zshrc`:
- **Node version**: Uncomment and update the `PATH` line under NVM Configuration with your installed node version
- **Python version**: Uncomment and update the `PATH` line under Path Configuration if you want a specific default python
- **`PLATFORM_REPO`**: Set to your main repository path (for git worktree commands)
- **`cld` alias**: Update the path to point to your `update_context.sh` location

### 7. Install Git + configure
```bash
brew install git
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.lgr "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --reflog"
```
Run `ghelp` after sourcing `.zshrc` to see all available git aliases.

### 8. Install pyenv
```bash
brew install pyenv
pyenv install 3.11  # or your preferred version
pyenv global 3.11
```

### 9. Install nvm + Node.js
```bash
brew install nvm
mkdir ~/.nvm
nvm install --lts
```

### 10. Create workspace folder
```bash
mkdir -p ~/workspace
```

### 11. Setup SSH keys for GitHub
Generate an SSH key:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github
```

Configure SSH to use this key:
```bash
mkdir -p ~/.ssh
cat >> ~/.ssh/config << 'EOF'
Host github.com
    IdentityFile ~/.ssh/id_ed25519_github
EOF
```

Add the public key to your GitHub account:
```bash
cat ~/.ssh/id_ed25519_github.pub
```
Go to [GitHub SSH Keys Settings](https://github.com/settings/keys) and add it.

### 12. Install Sublime Text
Download from [sublimetext.com](https://www.sublimetext.com/), then create the `subl` shortcut:
```bash
sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
```

### 13. Install Obsidian + Setup Missions Vault
Download from [obsidian.md](https://obsidian.md/).

Create the `obs` command (opens/creates files in Obsidian):
```bash
cat > /tmp/obs << 'SCRIPT'
#!/bin/bash
if [ $# -gt 0 ]; then
    for file in "$@"; do
        if [ ! -f "$file" ]; then
            touch "$file"
        fi
    done
fi
open -a Obsidian "$@"
SCRIPT
chmod +x /tmp/obs
sudo mv /tmp/obs /usr/local/bin/obs
```

Set up the missions vault from this repo:
```bash
cp -r programs_config/obsidian ~/workspace/missions
```

Install plugins and theme automatically:
```bash
./programs_config/obsidian/install_plugins.sh ~/workspace/missions
```
This downloads all 8 community plugins from GitHub and installs the Dracula Official theme.

Open Obsidian, add `~/workspace/missions` as a vault, then:
1. Go to Settings > Community Plugins > Enable community plugins > enable all installed plugins
2. Enable the CSS snippet: Settings > Appearance > CSS Snippets > enable `kanban-colors`

The missions vault structure:
```
missions/
├── BOARD.md              # Kanban board (6 sections)
├── _missions/            # Individual mission files
├── Files/                # Attachments and screenshots
├── config/
│   └── mission format.md # Template for new missions
└── .obsidian/            # Obsidian config (hotkeys, plugins, CSS)
```

Run `mhelp` to see all mission management commands (`msn`, `smsn`, `lsmsn`, `nm`, `nmf`, `dm`, etc.).

### 14. Install Claude Code
```bash
brew install claude
```

Set up global configuration:
```bash
mkdir -p ~/.claude
cp programs_config/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

Set up the mission-management skill:
```bash
mkdir -p ~/.claude/skills/mission-management
cp programs_config/claude/skills/mission-management/SKILL.md ~/.claude/skills/mission-management/SKILL.md
```

Set up the context update script:
```bash
mkdir -p ~/workspace/claude-docs
cp programs_config/claude/update_context.sh ~/workspace/claude-docs/
chmod +x ~/workspace/claude-docs/update_context.sh
```

Edit `~/workspace/claude-docs/update_context.sh` and update the configuration variables:
```bash
REPO_DIR="$HOME/workspace/<your-repo>"
GIT_AUTHOR="<your-github-username>"
BASE_BRANCH="master"  # or "main"
```

Then update the `cld` alias in `~/.zshrc` to point to this script:
```bash
alias cld="~/workspace/claude-docs/update_context.sh"
```

For project-specific Claude context, create a CLAUDE.md in your repo with a canary marker:
```bash
mkdir -p ~/workspace/<your-repo>/.claude
cat > ~/workspace/<your-repo>/.claude/CLAUDE.md << 'EOF'
# Project Context

Add project-specific instructions here.

<!-- CANARY_MARKER -->
EOF
```

The `cld` alias regenerates everything below the marker with current git status, missions, and commit history.

### 15. Install JetBrains Toolbox (optional)
Download from [jetbrains.com/toolbox-app](https://www.jetbrains.com/toolbox-app/) and install your IDE of choice.

### 16. Git Worktree Setup (optional)
If you use git worktrees, run the setup script to configure your repository:
```bash
./programs_config/dotfiles/setup_script/setup.sh
```
This will configure `PLATFORM_REPO`, IDE preference, and create the worktree directory structure.
Run `wt-help` to see all worktree commands.

For detailed documentation, see `programs_config/dotfiles/docs/`.

### 17. Disable macOS keyboard beep sounds
Fix the beep on Ctrl+Cmd+Arrow keys:
```bash
mkdir -p ~/Library/KeyBindings
cat > ~/Library/KeyBindings/DefaultKeyBinding.dict << 'EOF'
{
    "^@\UF700" = "noop:";
    "^@\UF701" = "noop:";
    "^@\UF702" = "noop:";
    "^@\UF703" = "noop:";
}
EOF
```
Restart applications for changes to take effect.

---

## Quick Reference

After setup, these help commands show all available aliases:

| Command | Topic |
|---------|-------|
| `help` | List all help commands |
| `ghelp` | Git aliases & functions |
| `mhelp` | Mission & Claude plan management |
| `wt-help` | Git worktree commands |
