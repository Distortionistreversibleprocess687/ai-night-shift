# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.2] — 2026-03-13

### Added
- **Plugin:** `gnap_checkpoint.sh` — Git-native state checkpointing for crash recovery and cross-machine resume ([#1](https://github.com/JudyaiLab/ai-night-shift/issues/1))
  - Commits agent state (night_chat, bot_inbox) to an orphan branch after each round
  - Uses git worktree to avoid disrupting main work
  - Includes `--resume` flag to restore state on a different machine
  - `MAX_CHECKPOINTS` pruning to keep branch clean
  - Cleanup trap for safe failure handling
  - Inspired by [GNAP](https://github.com/farol-team/gnap)

### Fixed
- **Bug:** `patrol.sh` no longer marks inbox items as done when Gemini CLI fails
- **Cleanup:** Removed unused `discover_plugins()` from `plugin_loader.sh`

## [1.0.1] — 2026-03-12

### Fixed
- **Security:** Fixed JSON injection vulnerability in `protocols/notify.sh` and `protocols/msg.sh` — user input is now safely escaped via `python3 json.dumps`
- **Security:** `--dangerously-skip-permissions` is now configurable via `SKIP_PERMISSIONS` env var (default: `false`)
- **Bug:** PID lock race condition (TOCTOU) — replaced file-based check with atomic `mkdir`
- **Bug:** `wrapper.sh` now captures the correct exit code using `PIPESTATUS[0]` instead of `tee`'s exit code
- **Bug:** Fixed Gemini CLI npm package name in README (was `@anthropic-ai/gemini-cli`, corrected to `@google/gemini-cli`)
- **Bug:** Template variable substitution now uses global replace (`//`) to handle multiple occurrences
- **Docs:** Added missing `cp config.env.example config.env` step in Quick Start
- **Docs:** Added `SECURITY.md`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md`
- Added GitHub Actions CI (ShellCheck linting)
- Fixed `install.sh` to use `mktemp` for cron backup and detect pipe mode
- Fixed `patrol.sh` to use `--approval-mode yolo` instead of `--yolo`

## [1.0.0] — 2026-03-11

### Added
- Initial release: multi-agent autonomous framework
- Claude Code continuous development module
- Gemini CLI periodic patrol module
- OpenClaw heartbeat coordinator pattern
- Cross-agent communication protocols (bot_inbox, night_chat)
- Plugin system with pre/post/task phases
- Dashboard for visual monitoring
- 4 prompt templates (development, research, content, maintenance)
- Multi-language documentation (EN, zh-TW, zh-CN, ko)
- One-click installer with cron setup
