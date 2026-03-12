# Agent Adapters

Adapters let you plug any CLI-based AI agent into the night shift runner. The framework talks to a standard interface; the adapter translates it to your agent's specific flags.

## Available Adapters

| Adapter | Agent | Key Flags |
|---------|-------|-----------|
| `claude-code` | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `--print -p` |
| `codex-cli` | [OpenAI Codex CLI](https://github.com/openai/codex) | `--quiet --full-auto` |
| `aider` | [Aider](https://github.com/paul-gauthier/aider) | `--yes-always --message` |
| `custom` | Your own agent | Template — copy and implement |

## Usage

Set the adapter in `config.env`:

```bash
AGENT_ADAPTER=claude-code
```

Or pass it as a flag:

```bash
bash claude-code/night_shift.sh --adapter codex-cli
```

## Creating Your Own Adapter

1. Copy the template:
```bash
cp adapters/custom.sh adapters/my-agent.sh
```

2. Implement 5 functions:

| Function | Purpose |
|----------|---------|
| `adapter_run` | Execute the agent with a prompt, write output to file |
| `adapter_build_flags` | Return CLI flags for non-interactive mode |
| `adapter_check_rate_limit` | Check if output contains rate limit errors |
| `adapter_check_completion` | Check if agent signaled "I'm done" |
| `adapter_verify` | Check if the agent CLI is installed |
| `adapter_name` | Return a human-readable name |

3. Set your adapter:
```bash
AGENT_ADAPTER=my-agent
```

## Key Requirement

Your adapter's `adapter_run` must ensure the agent runs **non-interactively**. The agent must:
- Accept a prompt as input
- Write output to stdout (redirected by the runner)
- Exit when done (never wait for user input)
- Be wrapped in `timeout` for safety

If your agent has interactive prompts by default, use its flags to disable them (e.g., `--yes-always`, `--non-interactive`, `--auto-approve`).
