# Claude Code 夜班模块

在非工作时间自动运行 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)，配备自动重试、速率限制处理和结构化报告。

## 运作方式

```
┌─ Cron 在你的夜间时间触发 ─┐
│                             │
│  回合 1  →  回合 2  →  回合 N    │
│  (2.5小时)   (2.5小时)   (直到       │
│                         视窗       │
│                         结束)      │
│                             │
│  PID 锁防止并发运行            │
│  速率限制 → 自动等待 60 分钟    │
│  超时 → 下一回合              │
└─────────────────────────────────┘
```

## 快速开始

```bash
# 测试单一回合
./night_shift.sh --max-rounds 1

# 完整夜班（5 回合，6 小时视窗）
./night_shift.sh

# 自定义配置
./night_shift.sh --max-rounds 3 --window-hours 8 --prompt my_prompt.txt
```

## 配置

| 变量 | 默认值 | 描述 |
|----------|---------|-------------|
| `MAX_ROUNDS` | 5 | 每班次最大回合数 |
| `WINDOW_HOURS` | 6 | 总时间视窗（小时） |
| `ROUND_TIMEOUT` | 9000 (2.5小时) | 每回合最大秒数 |
| `RATE_LIMIT_WAIT` | 3600 (1小时) | 速率限制等待秒数 |
| `SHUTDOWN_BUFFER` | 300 (5分钟) | 视窗关闭前缓冲时间 |
| `CLAUDE_BIN` | `claude` | Claude Code CLI 路径 |

## Cron 设定

```bash
# 当地时间凌晨 1 点运行，周一至周五
0 1 * * 1-5 cd ~/ai-night-shift && bash claude-code/night_shift.sh >> logs/cron.log 2>&1
```

## 自定义提示词

编辑 `prompt_template.txt` 来定义 Claude Code 在夜班期间做什么。可用的模板变量：

- `{ROUND}` — 目前回合编号
- `{MAX_ROUNDS}` — 配置的总回合数
- `{DATE}` — 目前日期
- `{REMAINING_TIME}` — 视窗剩余时间
