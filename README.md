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
cp -r programs_config/obsidian/missions ~/workspace/docs/missions
```

Install plugins and theme automatically:
```bash
./programs_config/obsidian/install_plugins.sh ~/workspace/docs/missions
```
This downloads all 8 community plugins from GitHub and installs the Dracula Official theme.

Set up **shared hotkeys** — one file all vaults symlink to, so keyboard shortcuts stay in sync. The missions vault ships the canonical `hotkeys.json`; seed the shared copy from it and point the vault at it:
```bash
cp ~/workspace/docs/missions/.obsidian/hotkeys.json ~/.obsidian-shared-hotkeys.json
ln -sf ~/.obsidian-shared-hotkeys.json ~/workspace/docs/missions/.obsidian/hotkeys.json
```
Any other vault set up with `inherit_settings.sh` (below) gets symlinked to this shared file automatically. Edit shortcuts in any vault → all vaults update.

Open Obsidian, add `~/workspace/docs/missions` as a vault, then:
1. Go to Settings > Community Plugins > Enable community plugins > enable all installed plugins
2. Enable the CSS snippet: Settings > Appearance > CSS Snippets > enable `kanban-colors`

#### Vault structure

```
missions/
├── BOARD.md                  # Obsidian Kanban board — the source of truth for mission state
├── _missions/                # One markdown file per mission (titles carry an emoji prefix)
├── Files/                    # Attachments: screenshots, eval JSON, scratch notes
├── config/
│   └── mission format.md     # Template applied to new missions (nmf / Kanban "new note")
└── .obsidian/                # Vault config (versioned in this repo)
    ├── community-plugins.json  # List of plugin IDs to install
    ├── core-plugins.json
    ├── appearance.json         # Active theme (Dracula Official)
    ├── hotkeys.json
    ├── plugins/                # Installed plugins (populated by install_plugins.sh)
    ├── themes/                 # Installed themes (populated by install_plugins.sh)
    └── snippets/
        └── kanban-colors.css   # Per-section color coding for the board
```

The board has **6 Kanban sections** — `TODO`, `In Progress`, `Waiting For Review`, `On Hold`, `Done`, `On Long Hold` — plus an `Archive` list. Each card is an Obsidian wiki-link (`[[🚀 Mission Title]]`) to a file in `_missions/`. The `%% kanban:settings %%` block at the bottom of `BOARD.md` is required by the Kanban plugin — never delete it.

Mission files follow `config/mission format.md`: `# Related Tasks`, `# Context`, `# Tasks` (a `- [ ]` checklist), and `# Extra`.

#### Reuse these settings in another vault

To give a different vault the same plugins, theme, hotkeys, and snippets without copying per-vault UI state:
```bash
./programs_config/obsidian/inherit_settings.sh <target_vault> [source_vault]
```
`source_vault` defaults to `~/workspace/docs/missions`. It rsyncs `.obsidian/` while excluding per-vault state (`workspace.json`, `types.json`) and symlinks the target's `hotkeys.json` to the shared `~/.obsidian-shared-hotkeys.json` (seeding it from the source on first run). Run `install_plugins.sh <target_vault>` afterward to download the plugin binaries.

#### Meeting-notes vault (optional)

A second Obsidian vault for per-meeting notes (one folder per recurring meeting, dated `YYYY-MM-DD.md` notes from templates). Set it up by copying the scaffold and inheriting the missions vault's Obsidian settings:
```bash
cp -r programs_config/obsidian/meeting-notes ~/workspace/docs/meeting-notes
./programs_config/obsidian/inherit_settings.sh ~/workspace/docs/meeting-notes
./programs_config/obsidian/install_plugins.sh ~/workspace/docs/meeting-notes
```
Add `~/workspace/docs/meeting-notes` as a vault in Obsidian. Then use `mtg` to open it and `nmtg [meeting]` to create today's note from a template (`_templates/default.md`, or `_templates/<meeting>.md` per meeting). The mission skills can back-write a resolution status into a meeting note when a mission spawned from it completes.

Run `mhelp` to see all mission, meeting-note, and Claude-plan commands (`msn`, `nm`, `nmf`, `dm`, `cms`, `mtg`, `nmtg`, `pln`, `cps`, etc.).

### 14. Install Claude Code
```bash
brew install claude
```

Set up global configuration, skills, and scripts:
```bash
mkdir -p ~/.claude/skills
cp programs_config/claude/CLAUDE.md ~/.claude/CLAUDE.md
cp -r programs_config/claude/skills/* ~/.claude/skills/
cp programs_config/claude/notifications/claude-icon-cropped.png ~/.claude/
```

This installs four personal skills. They auto-trigger on the keyword aliases below (no extra config needed — the triggers live in each skill's `description`):

| Skill | Alias | Purpose |
|-------|-------|---------|
| `mission-management` | **MM** | Create / move / edit missions and the Kanban board. New missions land at the end of `TODO`; the board layout is user-controlled (Claude never moves cards unasked). |
| `flesh-out-missions` | **FOM** | Expand a bare mission stub into concrete, verb-first tasks with code refs — calibrated to scope (surgical vs capture). Runs *before* execution. |
| `execute-mission` | **EM** | Pick up the next unchecked task from an in-progress mission and do it, marking `[x]` as it goes. Supports `EM 2`, `EM <name>`, `EM task 3`. |
| `writeup` | **/writeup** | Export a substantial artifact (explanation, debug breakdown, analysis) verbatim into the Obsidian exports vault at `~/workspace/claude-docs/exports/` for reading outside the terminal. |

The three mission skills (typical loop: **MM** capture → **FOM** flesh out → **EM** execute) read/write `~/workspace/docs/missions/` (the vault from step 13), so they only work once that vault exists. `writeup` needs its own exports vault:
```bash
mkdir -p ~/workspace/claude-docs/exports
```
Optionally open `~/workspace/claude-docs/exports` as an Obsidian vault to browse exports comfortably.

Set up notifications (requires `terminal-notifier` and `jq`):
```bash
brew install terminal-notifier jq
cp programs_config/claude/notifications/notify.sh ~/.claude/notify.sh
chmod +x ~/.claude/notify.sh
```
This sends a macOS notification with the Claude icon when Claude needs your attention (permission prompts, questions, task completion) — but only when iTerm2 is not in focus.

Set up the status line (shows directory, git branch, model, and context usage):
```bash
cp programs_config/claude/statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

Add these to your Claude settings (`~/.claude/settings.json`):
```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/notify.sh",
            "timeout": 5
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
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
