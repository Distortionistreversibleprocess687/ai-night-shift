#!/usr/bin/env bash
# ============================================================================
# AI Night Shift — Direct Message Between Agents
# Sends a message to another agent's inbox
#
# Usage:
#   ./msg.sh <target_agent> "Your message here"
#   ./msg.sh --task TASK-42 <target_agent> "Please review the PR"
# ============================================================================

set -euo pipefail

NIGHT_SHIFT_DIR="${NIGHT_SHIFT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
INBOX_BASE="${NIGHT_SHIFT_DIR}/protocols/bot_inbox"
NIGHT_CHAT="${NIGHT_SHIFT_DIR}/protocols/night_chat.md"

TASK_ID=""

# Parse optional flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --task) TASK_ID="$2"; shift 2 ;;
        --help|-h)
            echo "Usage: $0 [--task TASK_ID] <target_agent> \"message\""
            exit 0
            ;;
        *) break ;;
    esac
done

if [ $# -lt 2 ]; then
    echo "Usage: $0 [--task TASK_ID] <target_agent> \"message\""
    exit 1
fi

TARGET="$1"
MESSAGE="$2"
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
SENDER="${AGENT_NAME:-unknown}"

# Auto-detect sender
if [ "$SENDER" = "unknown" ]; then
    if command -v claude &>/dev/null && [ -n "${CLAUDE_SESSION:-}" ]; then
        SENDER="claude"
    elif command -v gemini &>/dev/null; then
        SENDER="gemini"
    else
        SENDER=$(hostname -s 2>/dev/null || echo "agent")
    fi
fi

# Create target inbox
TARGET_INBOX="${INBOX_BASE}/${TARGET}"
mkdir -p "$TARGET_INBOX"

# Build message JSON (using python3 for safe escaping)
FILENAME="msg_$(date +%s)_${RANDOM}.json"
python3 -c "
import json, sys
data = {
    'from': sys.argv[1],
    'to': sys.argv[2],
    'type': 'message',
    'message': sys.argv[3],
    'ts': sys.argv[4]
}
if sys.argv[5]:
    data['task_id'] = sys.argv[5]
print(json.dumps(data, indent=2))
" "$SENDER" "$TARGET" "$MESSAGE" "$TIMESTAMP" "$TASK_ID" > "${TARGET_INBOX}/${FILENAME}"

# Log to night_chat
if [ -d "$(dirname "$NIGHT_CHAT")" ]; then
    echo "[$(date '+%H:%M')] ${SENDER} → ${TARGET}: ${MESSAGE}" >> "$NIGHT_CHAT" 2>/dev/null || true
fi

echo "Message sent to ${TARGET}"
