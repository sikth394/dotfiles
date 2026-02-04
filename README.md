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
   Create a script that can create and open files in Obsidian:
   ```bash
   cat > /tmp/obs << 'EOF'
   #!/bin/bash
   if [ $# -gt 0 ]; then
       for file in "$@"; do
           if [ ! -f "$file" ]; then
               touch "$file"
           fi
       done
   fi
   open -a Obsidian "$@"
   EOF
   chmod +x /tmp/obs
   sudo mv /tmp/obs /usr/local/bin/obs
   ```

7. **Create workspace folder**
   Create a folder for all your repositories:
   ```bash
   mkdir -p ~/workspace
   ```

8. **Install and Configure Git**
   Check if git is already installed:
   ```bash
   git --version
   ```

   If not installed, install via Homebrew:
   ```bash
   brew install git
   ```

   Set up a nice git log alias for better commit visualization:
   ```bash
   git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
   ```

   Now you can use `git lg` instead of `git log` for a much more readable commit history.
   you can also use `glg` which is an alias for `git lg` in your `.zshrc` file.

9. **Download JetBrains Toolbox & PyCharm**
   Download JetBrains Toolbox from [jetbrains.com/toolbox-app](https://www.jetbrains.com/toolbox-app/) and install PyCharm from there.

10. **Setup SSH Keys for GitHub**
   Generate an SSH key (using ed25519 as recommended by GitHub):
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github
   ```

   Configure SSH to use this key for GitHub:
   ```bash
   mkdir -p ~/.ssh
   cat >> ~/.ssh/config << 'EOF'
   Host github.com
       IdentityFile ~/.ssh/id_ed25519_github
   EOF
   ```

   Get your public key:
   ```bash
   cat ~/.ssh/id_ed25519_github.pub
   ```

   Copy the output and add it to your GitHub account:
   - Go to [GitHub SSH Keys Settings](https://github.com/settings/keys)
   - Click "New SSH key"
   - Paste your public key and give it a descriptive title

   For more information, see [GitHub's SSH documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

11. **Clone your main work repository**
    Clone your main work repository (replace `<repo-name>` with your actual repo name):
    ```bash
    cd ~/workspace
    git clone git@github.com:your-org/<repo-name>.git
    ```

12. **Create missions folder**
    Create a folder for active mission/task documentation that will be auto-included in Claude context:
    ```bash
    mkdir -p ~/workspace/missions
    ```

13. **Install Claude**
    Install Claude Code CLI:
    ```bash
    brew install claude
    ```
    For more information, visit the [Claude Code documentation](https://github.com/anthropics/claude-code).

14. **Setup Claude global configuration**
    Put the global `CLAUDE.md` in the `~/.claude` directory:
    ```bash
    mkdir -p ~/.claude
    cp programs_config/claude/CLAUDE.md ~/.claude/CLAUDE.md
    ```

15. **Setup project-specific Claude configuration**
    Create a project-specific CLAUDE.md file in your work repo with a canary marker (replace `<repo-name>` with your actual repo name):
    ```bash
    mkdir -p ~/workspace/<repo-name>/.claude
    cat > ~/workspace/<repo-name>/.claude/CLAUDE.md << 'EOF'
# Project Context

Add your project-specific instructions, conventions, and context here.

<!-- CANARY_MARKER -->
EOF
    ```

    The `<!-- CANARY_MARKER -->` is important - the update script will preserve everything above this marker and regenerate everything below it with current git status, missions, and commit history.

16. **Create Claude docs folder**
    ```bash
    mkdir -p ~/workspace/claude-docs
    ```

17. **Setup update context script**
    Put `update_context.sh` in the `claude-docs` folder and make it executable:
    ```bash
    cp programs_config/claude/update_context.sh ~/workspace/claude-docs/
    chmod +x ~/workspace/claude-docs/update_context.sh
    ```

    Edit the script and update the configuration variables:
    ```bash
    # Change these lines in ~/workspace/claude-docs/update_context.sh
    REPO_DIR="$HOME/workspace/<repo-name>"
    GIT_AUTHOR="<your-github-username>"
    BASE_BRANCH="master"  # or "main" depending on your repo
    ```

    This script auto-generates context in `~/workspace/<repo-name>/.claude/CLAUDE.md` including:
    - Active missions from `~/workspace/missions` (excluding archived/)
    - Last 5 commits (full details)
    - Your git history (last 20 commits)
    - Git diff files (base branch vs HEAD)
    - Staged and unstaged changes

    Run it using the `cld` alias before working with Claude to provide fresh context.

18. **Disable macOS keyboard beep sounds**
    Fix the annoying beep sound when pressing Ctrl+Cmd+Arrow keys by creating a custom key binding file:
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

    This maps Ctrl+Cmd+Arrow keys to no-op, preventing the system beep:
    - `\UF700` = Up Arrow
    - `\UF701` = Down Arrow
    - `\UF702` = Left Arrow
    - `\UF703` = Right Arrow

    Restart applications (or restart your Mac) for changes to take effect.
