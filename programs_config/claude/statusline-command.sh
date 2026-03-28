#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~
short_cwd="${cwd/#$HOME/~}"

# Git branch (skip optional locks to avoid blocking)
branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

RESET="\033[0m"
BOLD_WHITE="\033[1;97m"
TRUE_BLACK="\033[38;2;0;0;0m"

# Segment backgrounds (24-bit true color)
# Directory: blue
DIR_BG="\033[48;2;30;80;160m"
DIR_FG="\033[38;2;30;80;160m"

# Git branch: green
GIT_BG="\033[48;2;30;130;60m"
GIT_FG="\033[38;2;30;130;60m"

# Model + context: orange
CTX_BG="\033[48;2;230;113;79m"
CTX_FG="\033[38;2;230;113;79m"

# --- Build output ---
out=""

# Directory segment: blue bg, bold white, dir label
out="${out}${DIR_BG}${BOLD_WHITE} ${short_cwd} ${RESET}"

# Git segment: green bg, bold white (only inside a repo)
if [ -n "$branch" ]; then
  out="${out} ${GIT_BG}${BOLD_WHITE} ${branch} ${RESET}"
fi

# Model + context segment: orange bg, true black text (not bold)
if [ -n "$model" ]; then
  ctx_text=""
  if [ -n "$used_pct" ]; then
    ctx_int=$(printf "%.0f" "$used_pct")
    ctx_text=" ${ctx_int}%"
  fi
  out="${out} ${CTX_BG}${TRUE_BLACK} ${model}${ctx_text} ${RESET}"
fi

printf "%b\n" "$out"
