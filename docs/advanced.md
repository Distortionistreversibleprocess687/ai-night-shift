# Advanced Guide

## Multi-Agent Setup

The real power of AI Night Shift comes from running multiple agents together.

### Recommended Configuration

```
Agent 1 (Claude Code) — Continuous developer
  Schedule: 1 AM - 7 AM
  Tasks: Coding, testing, deploying

Agent 2 (Gemini) — Periodic researcher
  Schedule: Every 2 hours during Agent 1's window
  Tasks: Research, triage, documentation

Agent 3 (Heartbeat) — Coordinator
  Schedule: Every 30 minutes
  Tasks: Route inbox items, monitor health, dispatch work
```

### Setting Up Inter-Agent Communication

1. **Create agent inboxes:**
```bash
mkdir -p protocols/bot_inbox/{claude,gemini,heartbeat}/{done}
```

2. **Configure agent names** in each module's environment:
```bash
# In Claude Code's session
export AGENT_NAME=claude

# In Gemini's patrol
export AGENT_NAME=gemini
```

3. **Agents send messages to each other:**
```bash
# Claude asks Gemini to research something
./protocols/msg.sh gemini "Please research React Server Components best practices"

# Gemini reports findings back
./protocols/notify.sh claude RESEARCH-1 success "Findings in reports/rsc_research.md"
```

### Task Board Integration

Connect to your preferred task management:

**Linear:**
```bash
export TASK_TOOL="linear"
# Install: pip install linear-sdk
```

**GitHub Issues:**
```bash
export TASK_TOOL="github"
# Uses: gh cli
```

**Plain File:**
```bash
export TASK_TOOL="file"
# Uses: tasks.md with checkbox format
```

## Custom Plugins

### Plugin API

Plugins have access to these environment variables:

| Variable | Description |
|----------|-------------|
| `NIGHT_SHIFT_DIR` | Root framework directory |
| `AGENT_NAME` | Current agent identifier |
| `DATE_TAG` | Current date (YYYY-MM-DD) |

And these directories:

| Path | Purpose |
|------|---------|
| `$NIGHT_SHIFT_DIR/logs/` | Write log output |
| `$NIGHT_SHIFT_DIR/reports/` | Write report files |
| `$NIGHT_SHIFT_DIR/protocols/` | Read/write messages |

### Plugin Lifecycle

```
Pre-plugins  → Run before the night shift (health checks, backups)
Task-plugins → Run during each round (custom automation)
Post-plugins → Run after the night shift (reports, cleanup)
```

### Example: Custom Monitoring Plugin

```bash
#!/usr/bin/env bash
# PLUGIN_NAME: Database Monitor
# PLUGIN_PHASE: pre
# PLUGIN_DESCRIPTION: Check database connection and query performance

set -euo pipefail
NIGHT_SHIFT_DIR="${NIGHT_SHIFT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

# Check database connection
if pg_isready -h localhost -p 5432 2>/dev/null; then
    echo "Database: OK"
else
    echo "WARNING: Database unreachable"
    # Write to night_chat for other agents
    echo "[$(date '+%H:%M')] DBMonitor: Database connection failed!" \
        >> "$NIGHT_SHIFT_DIR/protocols/night_chat.md"
fi
```

## Scaling

### Multiple Projects

Run separate night shifts for different projects:

```bash
# Project A — web development
NIGHT_SHIFT_DIR=~/project-a/night-shift \
  bash ~/ai-night-shift/claude-code/night_shift.sh --prompt project_a_prompt.txt

# Project B — data pipeline
NIGHT_SHIFT_DIR=~/project-b/night-shift \
  bash ~/ai-night-shift/claude-code/night_shift.sh --prompt project_b_prompt.txt
```

### Weekend vs Weekday

Use different schedules and prompts:

```
# Weekday: focused development
0 1 * * 1-5 cd ~/ai-night-shift && bash claude-code/wrapper.sh

# Weekend: research and cleanup
0 1 * * 0,6 cd ~/ai-night-shift && PROMPT_FILE=templates/maintenance.txt bash claude-code/wrapper.sh
```

## Prompt Design for Autonomy

The #1 cause of failed night shifts: your agent stops mid-task and waits for confirmation that never comes.

### The Problem

Most AI CLI tools have interactive behaviors by default:
- Claude Code asks "Should I proceed with this change?"
- Codex CLI prompts for approval on file modifications
- Some agents wait for input on ambiguous instructions

In unattended mode, these prompts mean your agent sits idle until timeout.

### The Solution

Every prompt template must include an explicit **Autonomy Rules** block:

```
## Autonomy Rules (CRITICAL)

You are running unattended. No human is available to respond.

- NEVER ask for confirmation — decide and execute
- NEVER wait for user input — if uncertain, choose the safest option and proceed
- NEVER use interactive commands — no read, no select, no editors that wait for input
- If stuck, skip and move on — log the blocker, move to the next task after 3 failed attempts
```

All templates in `templates/` include this block. If you write custom prompts, **always include it**.

### Additional Prompt Tips

1. **Be specific about scope** — "Fix the auth tests" not "improve the code"
2. **Define done** — "Run tests, all must pass" gives a clear exit condition
3. **Constrain decisions** — "Use PostgreSQL, not SQLite" prevents deliberation
4. **Set priorities** — numbered lists tell the agent what to do first if time runs out

### Claude Code Hook Safety Lock

Claude Code supports [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) that run on lifecycle events. You can use them as an additional safety layer:

```json
// .claude/settings.json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[$(date '+%H:%M')] Agent session ended\" >> ~/ai-night-shift/protocols/night_chat.md"
          }
        ]
      }
    ]
  }
}
```

This logs agent session boundaries to the shared chat, making it visible to other agents when sessions start/stop.

## Loop Patterns (Reference)

AI Night Shift builds on established autonomous loop patterns. Understanding these helps you choose the right configuration:

| Pattern | Our Implementation | Best For |
|---------|-------------------|----------|
| Sequential Pipeline | `night_shift.sh` rounds | Multi-step dev workflows |
| Periodic Patrol | `patrol.sh` | Lightweight check-ins |
| Heartbeat | OpenClaw module | Coordinator/router agents |
| De-Sloppify | `de_sloppify.sh` plugin | Quality cleanup after coding |
| Completion Signal | Built-in to `night_shift.sh` | Smart early termination |
| Shared Task Notes | `shared_task_notes.md` | Cross-round context bridge |

### Completion Signal

Your agent can signal "I'm done" by outputting a magic phrase. After N consecutive rounds with the signal, the shift stops early:

```bash
# In config.env
COMPLETION_SIGNAL="NIGHT_SHIFT_COMPLETE"
COMPLETION_THRESHOLD=2  # Stop after 2 consecutive signals
```

In your prompt template, tell the agent:
```
If all tasks are complete and there's nothing left to do,
include the text NIGHT_SHIFT_COMPLETE in your output.
```

### Shared Task Notes (Cross-Round Memory)

Each `claude -p` call starts with a fresh context. Use `shared_task_notes.md` to bridge context:

```markdown
## Progress
- [x] Refactored auth module (Round 1)
- [x] Added 15 unit tests (Round 2)
- [ ] Still need: integration tests for OAuth flow

## Notes for Next Round
- The mock setup in tests/helpers.ts can be reused
- Rate limiting endpoint has a race condition — needs mutex
```

Add `{SHARED_NOTES}` to your prompt template to inject this automatically.

### De-Sloppify Pattern

Instead of telling your AI "don't write sloppy code" (which degrades quality), enable the `de_sloppify.sh` plugin for a separate cleanup pass:

```bash
ln -s ../examples/de_sloppify.sh plugins/enabled/
```

This runs after each development round and removes:
- Tests that verify language/framework behavior (not business logic)
- Redundant type checks the type system already enforces
- Debug print statements and commented-out code

### Anti-Patterns to Avoid

1. **Infinite loops without exit conditions** — always set `MAX_ROUNDS`, `WINDOW_HOURS`, or use completion signals
2. **No context bridge** — without `shared_task_notes.md`, each round repeats work
3. **Retrying the same failure** — capture error context and feed it forward, don't just retry
4. **Negative instructions** — "don't do X" degrades quality; use a cleanup pass instead
5. **All logic in one prompt** — separate concerns into different rounds/agents

## Telegram Integration

### Setup

1. Create a Telegram bot via [@BotFather](https://t.me/BotFather)
2. Get your chat ID
3. Add to `config.env`:
```bash
TELEGRAM_BOT_TOKEN=your_token
TELEGRAM_CHAT_ID=your_chat_id
```

4. Enable the morning report plugin:
```bash
ln -s ../examples/morning_report.sh plugins/enabled/
```

### What Gets Sent

The morning report plugin sends a summary after each shift:
- Tasks completed
- Issues found
- Git commits made
- System health status
