#!/bin/bash
# Install Obsidian community plugins and theme for the missions vault.
# Usage: ./install_plugins.sh [vault_path]
#   vault_path defaults to ~/workspace/docs/missions

set -euo pipefail

VAULT="${1:-$HOME/workspace/docs/missions}"
OBSIDIAN_DIR="$VAULT/.obsidian"
PLUGINS_DIR="$OBSIDIAN_DIR/plugins"
THEMES_DIR="$OBSIDIAN_DIR/themes"
REGISTRY_URL="https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/community-plugins.json"
THEME_REGISTRY_URL="https://raw.githubusercontent.com/obsidianmd/obsidian-releases/master/community-css-themes.json"
THEME_NAME="Dracula Official"

# Read plugin IDs from the vault's community-plugins.json
PLUGINS_JSON="$OBSIDIAN_DIR/community-plugins.json"
if [[ ! -f "$PLUGINS_JSON" ]]; then
  echo "Error: $PLUGINS_JSON not found. Copy the vault template first."
  exit 1
fi

echo "Fetching plugin registry..."
REGISTRY=$(curl -sL "$REGISTRY_URL")

# Parse plugin IDs from the local JSON array
PLUGIN_IDS=$(python3 -c "import json; [print(p) for p in json.load(open('$PLUGINS_JSON'))]")

echo ""
echo "Installing plugins to $PLUGINS_DIR"
echo "===================================="

while IFS= read -r plugin_id; do
  # Look up the GitHub repo from the registry
  repo=$(echo "$REGISTRY" | python3 -c "
import json, sys
registry = json.load(sys.stdin)
for p in registry:
    if p['id'] == '$plugin_id':
        print(p['repo'])
        break
" 2>/dev/null)

  if [[ -z "$repo" ]]; then
    echo "  ⚠ $plugin_id — not found in registry, skipping"
    continue
  fi

  plugin_dir="$PLUGINS_DIR/$plugin_id"
  mkdir -p "$plugin_dir"

  base_url="https://github.com/$repo/releases/latest/download"

  # Download main.js and manifest.json (required)
  if curl -sL -f -o "$plugin_dir/main.js" "$base_url/main.js" &&
     curl -sL -f -o "$plugin_dir/manifest.json" "$base_url/manifest.json"; then
    echo "  ✓ $plugin_id"
  else
    echo "  ✗ $plugin_id — download failed"
    rm -rf "$plugin_dir"
    continue
  fi

  # Download styles.css (optional, not all plugins have it)
  curl -sL -f -o "$plugin_dir/styles.css" "$base_url/styles.css" 2>/dev/null || true

done <<< "$PLUGIN_IDS"

# Install theme
echo ""
echo "Installing theme: $THEME_NAME"
echo "===================================="

THEME_REPO=$(curl -sL "$THEME_REGISTRY_URL" | python3 -c "
import json, sys
for t in json.load(sys.stdin):
    if t['name'] == '$THEME_NAME':
        print(t['repo'])
        break
")

if [[ -n "$THEME_REPO" ]]; then
  theme_dir="$THEMES_DIR/$THEME_NAME"
  mkdir -p "$theme_dir"

  # Try GitHub releases first, fall back to raw repo
  release_url="https://github.com/$THEME_REPO/releases/latest/download"
  raw_url="https://raw.githubusercontent.com/$THEME_REPO/HEAD"

  for file in manifest.json theme.css; do
    if ! curl -sL -f -o "$theme_dir/$file" "$release_url/$file" 2>/dev/null; then
      curl -sL -f -o "$theme_dir/$file" "$raw_url/$file" 2>/dev/null || true
    fi
  done

  if [[ -f "$theme_dir/theme.css" ]]; then
    echo "  ✓ $THEME_NAME"
  else
    echo "  ✗ $THEME_NAME — download failed"
  fi

  # Activate theme in appearance.json
  APPEARANCE="$OBSIDIAN_DIR/appearance.json"
  if [[ -f "$APPEARANCE" ]]; then
    python3 -c "
import json
with open('$APPEARANCE') as f:
    data = json.load(f)
data['cssTheme'] = '$THEME_NAME'
with open('$APPEARANCE', 'w') as f:
    json.dump(data, f, indent=2)
"
  else
    echo '{"cssTheme": "'"$THEME_NAME"'"}' > "$APPEARANCE"
  fi
  echo "  ✓ Theme activated in appearance.json"
else
  echo "  ⚠ $THEME_NAME — not found in theme registry"
fi

echo ""
echo "Done. Restart Obsidian to load plugins and theme."
