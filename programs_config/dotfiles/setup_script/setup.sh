#!/bin/bash

show_help() {
  cat << EOF
Usage: $0 git_worktree_setup

Git Worktree Setup Command:
  git_worktree_setup    Configure git worktree aliases and environment

Description:
  Sets up git worktree workflow integration including:
  - Interactive IDE selection (PyCharm, Cursor, VS Code, Neovim, or None)
  - Shell aliases for worktree management
  - Environment variables configuration
  - Worktree directory structure

  This command will:
  1. Check for required dependencies (fzf)
  2. Prompt for IDE preference
  3. Backup and update ~/.zshrc with worktree aliases
  4. Create the worktree directory structure
  5. Configure PLATFORM_REPO environment variable

Examples:
  $0 git_worktree_setup    # Run interactive setup

After Setup:
  source ~/.zshrc          # Load new configuration
  wt-new <branch>          # Create new worktree
  wt-switch                # Switch between worktrees
  wt-ls                    # List all worktrees

Documentation:
  Full guide: docs/git_worktree/README.md
  Reference:  docs/git_worktree/GIT_WORKTREE_REF.md

EOF
}


git_worktree_setup() {
  local GREEN=$'\e[32m'
  local YELLOW=$'\e[33m'
  local RED=$'\e[31m'
  local BLUE=$'\e[34m'
  local RESET=$'\e[0m'

  echo -e "${BLUE}=== Git Worktree Setup ===${RESET}\n"

  # 1. Check prerequisites
  echo -e "${BLUE}Checking prerequisites...${RESET}"
  if ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}⚠ fzf is not installed (required for smooth experience)${RESET}"
    echo -e "  Install with: ${GREEN}brew install fzf${RESET}\n"
    read -p "Continue without fzf? (y/N): " continue_without_fzf
    if [[ ! "$continue_without_fzf" =~ ^[Yy]$ ]]; then
      echo "Setup cancelled."
      exit 0
    fi
    echo ""
  else
    echo -e "${GREEN}✓ fzf is installed${RESET}\n"
  fi

  # 2. Interactive IDE selection
  echo -e "${BLUE}Select your preferred IDE:${RESET}"
  echo "  1) PyCharm (default)"
  echo "  2) Cursor"
  echo "  3) VS Code"
  echo "  4) Neovim"
  echo "  5) None (no IDE integration)"
  echo ""
  read -p "Enter selection (1-5): " ide_choice

  local wt_ide
  case "$ide_choice" in
    1|"") wt_ide="pycharm" ;;
    2) wt_ide="cursor" ;;
    3) wt_ide="vscode" ;;
    4) wt_ide="neovim" ;;
    5) wt_ide="none" ;;
    *)
      echo -e "${RED}Invalid selection. Using PyCharm (default).${RESET}"
      wt_ide="pycharm"
      ;;
  esac
  echo -e "${GREEN}✓ Selected IDE: ${wt_ide}${RESET}\n"

  # 3. Backup .zshrc
  local zshrc_path="$HOME/.zshrc"
  if [[ ! -f "$zshrc_path" ]]; then
    echo -e "${YELLOW}⚠ ~/.zshrc not found, creating new file${RESET}"
    touch "$zshrc_path"
  else
    local backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$zshrc_path" "$backup_file"
    echo -e "${GREEN}✓ Backed up ~/.zshrc to: ${backup_file}${RESET}\n"
  fi

  # 4. Update .zshrc
  echo -e "${BLUE}Updating ~/.zshrc...${RESET}"

  # Detect current repository location
  local repo_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel 2>/dev/null)"
  if [[ -z "$repo_path" ]]; then
    echo -e "${RED}Error: Could not detect git repository location${RESET}"
    exit 1
  fi

  if grep -q "# Git Worktree Aliases" "$zshrc_path"; then
    # Section exists, update WT_IDE and PLATFORM_REPO values
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS sed
      sed -i '' "s/^export WT_IDE=.*/export WT_IDE=\"$wt_ide\"/" "$zshrc_path"
      sed -i '' "s|^export PLATFORM_REPO=.*|export PLATFORM_REPO=\"$repo_path\"|" "$zshrc_path"
    else
      # GNU sed
      sed -i "s/^export WT_IDE=.*/export WT_IDE=\"$wt_ide\"/" "$zshrc_path"
      sed -i "s|^export PLATFORM_REPO=.*|export PLATFORM_REPO=\"$repo_path\"|" "$zshrc_path"
    fi
    echo -e "${GREEN}✓ Updated WT_IDE to: ${wt_ide}${RESET}"
    echo -e "${GREEN}✓ Updated PLATFORM_REPO to: ${repo_path}${RESET}\n"
  else
    # Detect current repository location
    local repo_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && git rev-parse --show-toplevel 2>/dev/null)"
    if [[ -z "$repo_path" ]]; then
      echo -e "${RED}Error: Could not detect git repository location${RESET}"
      exit 1
    fi

    # Append entire block (using double quotes to allow variable expansion)
    cat >> "$zshrc_path" << EOF

# ===========================
# Git Worktree Aliases
# ===========================

# Platform repository location (auto-detected during setup)
export PLATFORM_REPO="$repo_path"

# IDE preference for git worktree operations
# Supported: pycharm, cursor, vscode, neovim, none
export WT_IDE="pycharm"

# Git worktree basic aliases
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'

# Custom workflow commands
alias wt-ls='cd "\$PLATFORM_REPO" && git worktree list'
alias wt-new='cd "\$PLATFORM_REPO" && ./scripts/git_worktree/worktree_setup.sh'
alias wt-rm='cd "\$PLATFORM_REPO" && ./scripts/git_worktree/worktree_cleanup.sh'
alias wt-sync-status='\$PLATFORM_REPO/scripts/git_worktree/check_sync_status.sh'
alias wt-unlock='\$PLATFORM_REPO/scripts/git_worktree/cleanup_git_locks.sh --interactive'
alias wt-trash-rm='\$PLATFORM_REPO/scripts/git_worktree/trash_cleanup.sh'

# wt-switch requires a function (not an alias) to change directory
wt-switch() {
  local selected_path=\$(\$PLATFORM_REPO/scripts/git_worktree/select_worktree.sh)

  if [[ -z "\$selected_path" ]]; then
    echo "Selection cancelled"
    return 1
  fi

  # Clean up any stale locks before switching (silent, no output unless error)
  \$PLATFORM_REPO/scripts/git_worktree/cleanup_git_locks.sh \\
      --auto --quiet --worktree "\$selected_path" 2>/dev/null || true

  # Ask to open in IDE based on WT_IDE setting
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
        ide_app=""  # Neovim opens in terminal, not as app
        ;;
      *)
        ide_name=""
        ;;
    esac

    if [[ -n "$ide_name" ]]; then
      read "open_ide?Open in $ide_name? (y/n): "
      echo ""

      if [[ "$open_ide" =~ ^[Yy]$ ]]; then
        echo "✓ Opening in $ide_name..."
        if [[ "$WT_IDE" == "neovim" ]]; then
          # Open neovim in the current terminal
          nvim "$selected_path"
        else
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
EOF

    # Update the WT_IDE value to match user's selection
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/^export WT_IDE=.*/export WT_IDE=\"$wt_ide\"/" "$zshrc_path"
    else
      sed -i "s/^export WT_IDE=.*/export WT_IDE=\"$wt_ide\"/" "$zshrc_path"
    fi
    echo -e "${GREEN}✓ Added git worktree aliases to ~/.zshrc${RESET}\n"
  fi

  # 5. Create worktree directory
  echo -e "${BLUE}Creating worktree directory...${RESET}"
  local parent_dir="$(dirname "$repo_path")"
  local repo_name="$(basename "$repo_path")"
  local worktree_dir="$parent_dir/$repo_name-worktrees"
  mkdir -p "$worktree_dir"
  echo -e "${GREEN}✓ Created: ${worktree_dir}${RESET}\n"

  # 6. Success message
  echo -e "${GREEN}=== Setup Complete! ===${RESET}\n"
  echo -e "Next steps:"
  echo -e "  1. ${BLUE}source ~/.zshrc${RESET}  (or open a new terminal)"
  echo -e "  2. ${BLUE}wt-new <branch>${RESET}  (create your first worktree)"
  echo -e "  3. ${BLUE}wt-switch${RESET}        (switch between worktrees)\n"
  echo -e "Full documentation: ${BLUE}docs/git_worktree/README.md${RESET}"
  echo -e "Cheat Sheat: ${BLUE}docs/git_worktree/GIT_WORKTREE_REF.md${RESET}"
}

# Main script logic
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

case "$1" in
  git_worktree_setup)
    git_worktree_setup
    ;;
  --help)
    show_help
    ;;
  *)
    echo "Invalid command. Use --help for usage information."
    exit 1
    ;;
esac
