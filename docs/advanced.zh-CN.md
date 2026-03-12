# 高级指南

## 多代理设置

AI Night Shift 的真正威力來自於同時運行多個代理。

### 建議配置

```
代理 1 (Claude Code) — 持續開發者
  调度：凌晨 1 點 - 早上 7 點
  任務：編碼、測試、部署

代理 2 (Gemini) — 週期性研究者
  调度：代理 1 運行期間每 2 小時
  任務：研究、分類、文檔

代理 3 (Heartbeat) — 協調者
  调度：每 30 分鐘
  任務：路由收件匣項目、监控健康、调度工作
```

### 设置代理間通訊

1. **创建代理收件匣：**
```bash
mkdir -p protocols/bot_inbox/{claude,gemini,heartbeat}/{done}
```

2. **在每個模組的環境中设置代理名稱：**
```bash
# 在 Claude Code 的会话中
export AGENT_NAME=claude

# 在 Gemini 的巡邏中
export AGENT_NAME=gemini
```

3. **代理之間发送訊息：**
```bash
# Claude 請 Gemini 研究某事物
./protocols/msg.sh gemini "Please research React Server Components best practices"

# Gemini 报告研究結果
./protocols/notify.sh claude RESEARCH-1 success "Findings in reports/rsc_research.md"
```

### 任務面板整合

連接到你偏好的任務管理工具：

**Linear：**
```bash
export TASK_TOOL="linear"
# 安裝：pip install linear-sdk
```

**GitHub Issues：**
```bash
export TASK_TOOL="github"
# 使用：gh cli
```

**純檔案：**
```bash
export TASK_TOOL="file"
# 使用：tasks.md 勾選格式
```

## 自訂外掛

### 外掛 API

外掛可存取這些環境變數：

| 變數 | 描述 |
|----------|-------------|
| `NIGHT_SHIFT_DIR` | 框架根目錄 |
| `AGENT_NAME` | 目前代理識別碼 |
| `DATE_TAG` | 目前日期（YYYY-MM-DD） |

以及這些目錄：

| 路徑 | 用途 |
|------|---------|
| `$NIGHT_SHIFT_DIR/logs/` | 寫入日誌輸出 |
| `$NIGHT_SHIFT_DIR/reports/` | 寫入報告檔案 |
| `$NIGHT_SHIFT_DIR/protocols/` | 讀寫訊息 |

### 外掛生命週期

```
預處理外掛  → 夜班之前運行（健康檢查、備份）
任務外掛    → 每個回合期間運行（自訂自動化）
後處理外掛  → 夜班之後運行（報告、清理）
```

### 範例：自訂监控外掛

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

## 擴展

### 多個專案

為不同專案運行單獨的夜班：

```bash
# 專案 A — 網頁開發
NIGHT_SHIFT_DIR=~/project-a/night-shift \
  bash ~/ai-night-shift/claude-code/night_shift.sh --prompt project_a_prompt.txt

# 專案 B — 資料管線
NIGHT_SHIFT_DIR=~/project-b/night-shift \
  bash ~/ai-night-shift/claude-code/night_shift.sh --prompt project_b_prompt.txt
```

### 平日 vs 週末

使用不同的调度和提示詞：

```
# 平日：專注開發
0 1 * * 1-5 cd ~/ai-night-shift && bash claude-code/wrapper.sh

# 週末：研究和清理
0 1 * * 0,6 cd ~/ai-night-shift && PROMPT_FILE=templates/maintenance.txt bash claude-code/wrapper.sh
```

## 循環模式（參考）

AI Night Shift 基於已创建的自主循環模式。了解這些幫助你選擇正確的配置：

| 模式 | 我們的實現 | 最適合 |
|---------|-------------------|----------|
| 順序管線 | `night_shift.sh` 回合 | 多步驟開發工作 |
| 週期巡邏 | `patrol.sh` | 輕量級簽到 |
| 心跳 | OpenClaw 模組 | 協調/路由代理 |
| 去鬆散化 | `de_sloppify.sh` 外掛 | 編碼後的質量清理 |
| 完成訊號 | 內建於 `night_shift.sh` | 智慧提前終止 |
| 共享任務筆記 | `shared_task_notes.md` | 跨回合上下文橋樑 |

### 完成訊號

你的代理可以透過輸出魔術片語來表示「我完成了」。在出現訊號後連續 N 個回合，夜班會提前停止：

```bash
# 在 config.env 中
COMPLETION_SIGNAL="NIGHT_SHIFT_COMPLETE"
COMPLETION_THRESHOLD=2  # 連續 2 次訊號後停止
```

在你的提示詞模板中告訴代理：
```
如果所有任務都已完成且沒有其他事情要做，
在你的輸出中包含文字 NIGHT_SHIFT_COMPLETE。
```

### 共享任務筆記（跨回合記憶）

每個 `claude -p` 呼叫都從fresh上下文開始。使用 `shared_task_notes.md` 來橋接上下文：

```markdown
## 進度
- [x] 重構 auth 模組（回合 1）
- [x] 新增 15 個單元測試（回合 2）
- [ ] 仍需要：OAuth 流程的整合測試

## 下回合筆記
- tests/helpers.ts 中的 mock 设置可以重複使用
- Rate limiting 端點有競爭條件 — 需要互斥鎖
```

在你的提示詞模板中加入 `{SHARED_NOTES}` 來自動注入。

### 去鬆散化模式

不要告訴你的 AI「不要寫鬆散的代碼」（這會降低質量），啟用 `de_sloppify.sh` 外掛進行單獨的清理傳遞：

```bash
ln -s ../examples/de_sloppify.sh plugins/enabled/
```

這在每個開發回合後運行，移除：
- 驗證語言/框架行為的測試（不是業務邏輯）
- 類型系統已經強制執行的冗餘類型檢查
- 調試輸出語句和註釋掉的代碼

### 應避免的反模式

1. **無退出條件的無限循環** — 始終设置 `MAX_ROUNDS`、`WINDOW_HOURS`，或使用完成訊號
2. **無上下文橋接** — 沒有 `shared_task_notes.md`，每個回合會重複工作
3. **重試相同的失敗** — 擷取錯誤上下文並向前饋送，不要只是重試
4. **負面指示** — 「不要做 X」會降低質量；改用清理傳遞
5. **所有邏輯放在一個提示詞中** — 將關注點分離到不同的回合/代理

## Telegram 整合

### 设置

1. 透過 [@BotFather](https://t.me/BotFather) 创建 Telegram Bot
2. 取得你的 chat ID
3. 新增到 `config.env`：
```bash
TELEGRAM_BOT_TOKEN=your_token
TELEGRAM_CHAT_ID=your_chat_id
```

4. 啟用早報告外掛：
```bash
ln -s ../examples/morning_report.sh plugins/enabled/
```

### 发送內容

早報告外掛在每個夜班後发送摘要：
- 完成的任務
- 發現的問題
- Git 提交
- 系統健康狀態
