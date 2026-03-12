# 快速開始指南

5 分鐘內啟動你的 AI Night Shift。

## 前提條件

- Linux 或 macOS
- Bash 4+ 和 Python 3.6+
- 至少安裝一個 AI CLI 工具：
  - **Claude Code：** `npm install -g @anthropic-ai/claude-code`
  - **Gemini CLI：** `npm install -g @google/gemini-cli`

## 步驟 1：安裝

```bash
git clone https://github.com/judyailab/ai-night-shift.git
cd ai-night-shift
bash install.sh
```

安裝程式會：
- 建立目錄結構
- 設定檔案權限
- 可選擇設定 cron 工作

## 步驟 2：設定

```bash
cp config.env.example config.env
nano config.env
```

需要調整的關鍵設定：
- `WINDOW_HOURS` — 夜班執行時長
- `MAX_ROUNDS` — 最大執行回合數
- `CLAUDE_BIN` / `GEMINI_BIN` — CLI 工具路徑

## 步驟 3：自訂提示詞

編輯提示詞模板來告訴 AI 要做什麼：

```bash
nano claude-code/prompt_template.txt
```

或使用預建模板：
```bash
cp templates/development.txt claude-code/prompt_template.txt
```

## 步驟 4：測試

執行單一回合來驗證一切正常：

```bash
bash claude-code/night_shift.sh --max-rounds 1
```

查看輸出：
```bash
cat reports/$(date +%Y-%m-%d)_round1.md
```

## 步驟 5：排程

安裝程式可以自動設定 cron 工作。手動設定：

```bash
crontab -e
```

加入你偏好的排程：
```
# 凌晨 1 點夜班（調整時區）
0 1 * * * cd ~/ai-night-shift && bash claude-code/wrapper.sh >> logs/cron.log 2>&1

# 凌晨時段每 2 小時 Gemini 巡邏
0 1,3,5,7 * * * cd ~/ai-night-shift && bash gemini/patrol.sh >> logs/patrol.log 2>&1
```

## 步驟 6：啟用外掛（可選）

```bash
# 啟用系統健康檢查（夜班前執行）
ln -s ../examples/system_health.sh plugins/enabled/system_health.sh

# 啟用早報告（夜班後執行）
ln -s ../examples/morning_report.sh plugins/enabled/morning_report.sh
```

## 步驟 7：監控

開啟儀表板：
```bash
open dashboard/index.html
# 或
xdg-open dashboard/index.html
```

拖放報告檔案來視覺化你的夜班活動。

## 下一步

- **[架構](architecture.zh-TW.md)** — 了解系統如何運作
- **[進階指南](advanced.zh-TW.md)** — 多代理設定、自訂外掛
- **[疑難排解](troubleshooting.zh-TW.md)** — 常見問題和解決方案
