# dotfiles
everything i need to get a new mac up & running

### Setup Instructions

1. **Copy .zshrc**
   ```bash
   cp .zshrc ~/.zshrc
   ```

2. **Download Sublime Text**
   Download and install from [sublimetext.com](https://www.sublimetext.com/).

3. **Create `subl` command shortcut**
   ```bash
   sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
   ```

4. **Download Obsidian**
   Download and install from [obsidian.md](https://obsidian.md/).

5. **Create `obs` command**
   Add this alias to your shell configuration if not already present:
   ```bash
   alias obs='open -a "Obsidian"'
   ```

6. **Create workspace folder**
   Create a folder for all your repositories:
   ```bash
   mkdir -p ~/workspace
   ```

7. **Download JetBrains Toolbox & PyCharm**
   Download JetBrains Toolbox from [jetbrains.com/toolbox-app](https://www.jetbrains.com/toolbox-app/) and install PyCharm from there.

8. **Clone platform**
   ```bash
   cd ~/workspace
   git clone <platform-repo-url>
   ```

9. **Create missions folder**
   ```bash
   mkdir -p ~/workspace/missions
   ```

10. **Install Claude**
   Follow the official installation guide for Claude.

11. **Setup Claude configuration**
    Put `CLAUDE.md` in the `~/.claude` directory:
    ```bash
    mkdir -p ~/.claude
    cp programs_config/claude/CLAUDE.md ~/.claude/CLAUDE.md
    ```

12. **Create Claude docs folder**
    ```bash
    mkdir -p ~/workspace/claude-docs
    ```

13. **Setup update context script**
    Put `update_context.sh` in the `claude-docs` folder:
    ```bash
    cp programs_config/claude/update_context.sh ~/workspace/claude-docs/
    chmod +x ~/workspace/claude-docs/update_context.sh
    ```
