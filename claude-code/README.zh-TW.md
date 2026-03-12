# Claude Code 夜班模組

在非工作時間自動運行 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)，配備自動重試、速率限制處理和結構化報告。

## 運作方式

```
┌─ Cron 在你的夜間時間觸發 ─┐
│                             │
│  回合 1  →  回合 2  →  回合 N    │
│  (2.5小時)   (2.5小時)   (直到       │
│                         視窗       │
│                         結束)      │
│                             │
│  PID 鎖防止並發運行            │
│  速率限制 → 自動等待 60 分鐘    │
│  超時 → 下一回合              │
└─────────────────────────────────┘
```

## 快速開始

```bash
# 測試單一回合
./night_shift.sh --max-rounds 1

# 完整夜班（5 回合，6 小時視窗）
./night_shift.sh

# 自訂配置
./night_shift.sh --max-rounds 3 --window-hours 8 --prompt my_prompt.txt
```

## 配置

| 變數 | 預設值 | 描述 |
|----------|---------|-------------|
| `MAX_ROUNDS` | 5 | 每班次最大回合數 |
| `WINDOW_HOURS` | 6 | 總時間視窗（小時） |
| `ROUND_TIMEOUT` | 9000 (2.5小時) | 每回合最大秒數 |
| `RATE_LIMIT_WAIT` | 3600 (1小時) | 速率限制等待秒數 |
| `SHUTDOWN_BUFFER` | 300 (5分鐘) | 視窗關閉前緩衝時間 |
| `CLAUDE_BIN` | `claude` | Claude Code CLI 路徑 |

## Cron 設定

```bash
# 當地時間凌晨 1 點運行，週一至週五
0 1 * * 1-5 cd ~/ai-night-shift && bash claude-code/night_shift.sh >> logs/cron.log 2>&1
```

## 自訂提示詞

編輯 `prompt_template.txt` 來定義 Claude Code 在夜班期間做什麼。可用的模板變數：

- `{ROUND}` — 目前回合編號
- `{MAX_ROUNDS}` — 配置的總回合數
- `{DATE}` — 目前日期
- `{REMAINING_TIME}` — 視窗剩餘時間
