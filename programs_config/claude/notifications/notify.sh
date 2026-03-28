#!/bin/bash
# Claude Code notification hook
# Only notifies when iTerm2 is NOT the frontmost app

FRONTMOST=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
if [[ "$FRONTMOST" == "iTerm2" ]]; then
    exit 0
fi

INPUT=$(cat)

# Only notify for events that need user input
TYPE=$(echo "$INPUT" | jq -r '.notification_type // ""' 2>/dev/null)
case "$TYPE" in
    permission_prompt|question|stop) ;;
    *) exit 0 ;;
esac

MESSAGE=$(echo "$INPUT" | jq -r '.message // "needs your attention"' 2>/dev/null)

if [[ "$TYPE" == "stop" ]]; then
    SUBTITLE="Done - ready for review"
else
    SUBTITLE="Waiting for you"
fi

terminal-notifier \
    -title "Claude Code" \
    -subtitle "$SUBTITLE" \
    -message "${MESSAGE:0:200}" \
    -contentImage "$HOME/.claude/claude-icon-cropped.png" \
    -sound default \
    -group "claude-code" \
    -activate "com.googlecode.iterm2" \
    2>/dev/null

exit 0
