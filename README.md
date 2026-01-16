# dotfiles
everything i need to get a new mac up & running

### Setup Instructions

1. **Fork this repository**
   Fork this repository to your work GitHub account.

2. **Copy .zshrc**
   ```bash
   cp .zshrc ~/.zshrc
   ```

3. **Download Sublime Text**
   Download and install from [sublimetext.com](https://www.sublimetext.com/).

4. **Create `subl` command shortcut**
   ```bash
   sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
   ```

5. **Download Obsidian**
   Download and install from [obsidian.md](https://obsidian.md/).

6. **Create `obs` command**
   Add this alias to your shell configuration if not already present:
   ```bash
   alias obs='open -a "Obsidian"'
   ```

7. **Create workspace folder**
   Create a folder for all your repositories:
   ```bash
   mkdir -p ~/workspace
   ```

8. **Download JetBrains Toolbox & PyCharm**
   Download JetBrains Toolbox from [jetbrains.com/toolbox-app](https://www.jetbrains.com/toolbox-app/) and install PyCharm from there.

9. **Setup SSH Key**
   Generate an SSH key for your work GitHub account:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_work
   ```
   Get the public key:
   ```bash
   cat ~/.ssh/id_ed25519_work.pub
   ```
   Copy the output and add it to your [GitHub account settings](https://github.com/settings/keys) under "SSH and GPG keys" -> "New SSH key".

10. **Clone platform**
    ```bash
    cd ~/workspace
    git clone <platform-repo-url>
    ```

11. **Create missions folder**
    ```bash
    mkdir -p ~/workspace/missions
    ```

12. **Install Claude**
    Follow the official installation guide for Claude.

13. **Setup Claude configuration**
    Put `CLAUDE.md` in the `~/.claude` directory:
    ```bash
    mkdir -p ~/.claude
    cp programs_config/claude/CLAUDE.md ~/.claude/CLAUDE.md
    ```

14. **Create Claude docs folder**
    ```bash
    mkdir -p ~/workspace/claude-docs
    ```

15. **Setup update context script**
    Put `update_context.sh` in the `claude-docs` folder:
    ```bash
    cp programs_config/claude/update_context.sh ~/workspace/claude-docs/
    chmod +x ~/workspace/claude-docs/update_context.sh
    ```
