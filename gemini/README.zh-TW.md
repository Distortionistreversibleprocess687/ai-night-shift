# Gemini 巡邏模組

[Gemini CLI](https://github.com/google-gemini/gemini-cli) 的週期性巡邏執行器。專為頻繁、輕量級簽到設計，而非長時間連續會話。

## 運作方式

```
Cron（每 1-2 小時）
  → 收集收件匣項目
  → 讀取最近的團隊聊天
  → 建立上下文感知的提示詞
  → 執行 Gemini CLI
  → 發布結果到夜聊
  → 將處理的項目移到 done/
```

## 快速開始

```bash
# 執行單次巡邏
./patrol.sh

# 使用自訂提示詞
./patrol.sh --prompt my_patrol_prompt.txt
```

## 配置

| 變數 | 預設值 | 描述 |
|----------|---------|-------------|
| `GEMINI_BIN` | `gemini` | Gemini CLI 路徑 |
| `NIGHT_SHIFT_DIR` | 自動檢測 | 框架根目錄 |

## Cron 設定

```bash
# 夜班期間每 2 小時巡邏（凌晨 1 點 - 早上 7 點）
0 1,3,5,7 * * * cd ~/ai-night-shift && bash gemini/patrol.sh >> logs/patrol.log 2>&1
```

## 最佳用例

Gemini 的優勢（接地、搜尋、大上下文）使其非常適合：
- **研究任務** — 網路搜尋、資料收集
- **任務分類** — 閱讀收件匣、將工作路由到其他代理
- **文檔** — 撰寫摘要、格式化報告
- **翻譯** — 本地化內容
