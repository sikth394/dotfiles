#!/bin/bash
# Inherit Obsidian settings (plugins, themes, snippets, configs) from a source
# vault to a target vault. Skips per-vault UI state.
#
# Usage: inherit_settings.sh <target_vault> [source_vault]
#   source_vault defaults to ~/workspace/docs/missions

set -euo pipefail

TARGET="${1:?Usage: $0 <target_vault> [source_vault]}"
SOURCE="${2:-$HOME/workspace/docs/missions}"

if [[ ! -d "$SOURCE/.obsidian" ]]; then
  echo "Error: $SOURCE has no .obsidian directory"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Error: $TARGET does not exist"
  exit 1
fi

mkdir -p "$TARGET/.obsidian"

# Shared hotkeys: one file on disk, symlinked into every vault so keyboard
# shortcuts stay in sync. Seed it from the source vault's hotkeys on first run.
SHARED_HOTKEYS="$HOME/.obsidian-shared-hotkeys.json"
if [[ ! -f "$SHARED_HOTKEYS" && -f "$SOURCE/.obsidian/hotkeys.json" ]]; then
  cp -L "$SOURCE/.obsidian/hotkeys.json" "$SHARED_HOTKEYS"
fi

# Excludes per-vault state only:
#   workspace.json / workspace-mobile.json — open tabs and pane layout (reference specific notes)
#   types.json — cache of file-property types found in this vault's notes
#   hotkeys.json — symlinked to the shared file below instead of copied
rsync -a \
  --exclude='workspace.json' \
  --exclude='workspace-mobile.json' \
  --exclude='types.json' \
  --exclude='hotkeys.json' \
  --exclude='.DS_Store' \
  "$SOURCE/.obsidian/" "$TARGET/.obsidian/"

# Point this vault's hotkeys at the shared file
if [[ -f "$SHARED_HOTKEYS" ]]; then
  ln -sf "$SHARED_HOTKEYS" "$TARGET/.obsidian/hotkeys.json"
fi

echo "Inherited Obsidian settings:"
echo "  source: $SOURCE"
echo "  target: $TARGET"
echo "  hotkeys: symlinked to $SHARED_HOTKEYS"
echo ""
echo "Restart Obsidian, then enable plugins in Settings > Community Plugins."
