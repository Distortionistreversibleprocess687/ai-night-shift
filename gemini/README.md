# Gemini Patrol Module

Periodic patrol runner for [Gemini CLI](https://github.com/google-gemini/gemini-cli). Designed for frequent, lightweight check-ins rather than long continuous sessions.

## How It Works

```
Cron (every 1-2 hours)
  → Collect inbox items
  → Read recent team chat
  → Build context-aware prompt
  → Execute Gemini CLI
  → Post results to night chat
  → Move processed items to done/
```

## Quick Start

```bash
# Run a single patrol
./patrol.sh

# With custom prompt
./patrol.sh --prompt my_patrol_prompt.txt
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `GEMINI_BIN` | `gemini` | Path to Gemini CLI |
| `NIGHT_SHIFT_DIR` | auto-detected | Root directory of the framework |

## Cron Setup

```bash
# Patrol every 2 hours during night window (1 AM - 7 AM)
0 1,3,5,7 * * * cd ~/ai-night-shift && bash gemini/patrol.sh >> logs/patrol.log 2>&1
```

## Best Use Cases

Gemini's strengths (grounding, search, large context) make it ideal for:
- **Research tasks** — web search, data gathering
- **Task triage** — reading inbox, routing work to other agents
- **Documentation** — writing summaries, formatting reports
- **Translation** — localizing content

## Integration with Claude Code

The two modules are complementary:

| Feature | Claude Code | Gemini |
|---------|-------------|--------|
| Mode | Continuous (hours) | Periodic (minutes) |
| Strength | Coding, debugging | Research, triage |
| Token cost | Higher (Opus/Sonnet) | Lower (Pro/Flash) |
| Output | Code commits | Reports, messages |

They share context through `night_chat.md` and `bot_inbox/`.

## Known Issue: YOLO Mode in Automated Sessions

Gemini CLI has multiple approval modes that are often confused:

| Mode | Flag | What it auto-approves | Status bar |
|------|------|-----------------------|------------|
| `default` | (none) | Nothing | `YOLO ctrl+y` |
| `auto_edit` | Ctrl+Y toggle | File edits only | `shift+tab to accept edits` |
| `yolo` | `--approval-mode yolo` | **All tools including shell** | `YOLO ctrl+y` (but `*` prompt) |

**Common mistake:** Using `--yolo` flag or pressing Ctrl+Y only enables `auto_edit` mode, which still prompts for every shell command (ls, cat, python3, etc.). For full automation, you need `--approval-mode yolo`.

**Correct setup for tmux-based automation:**

```bash
# Start with --approval-mode yolo (NOT --yolo)
tmux new-session -d -s gemini-session \
  gemini --approval-mode yolo

# Optionally add to settings.json as fallback:
# ~/.gemini/settings.json → { "approvalMode": "yolo" }
```

**Do NOT** send Ctrl+Y after starting — it toggles to `auto_edit` mode, which is weaker than `yolo`.

Tested with Gemini CLI v0.33.0.
