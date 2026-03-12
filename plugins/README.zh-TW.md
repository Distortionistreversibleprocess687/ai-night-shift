# 外掛系統

使用自訂外掛擴展你的夜班。外掛在夜班生命週期的特定階段運行。

## 階段

| 階段 | 何時運行 | 用例 |
|-------|------|----------|
| `pre` | 夜班開始前 | 系統健康檢查、備份、資料收集 |
| `task` | 每個回合期間 | 自訂任務、監控、報告 |
| `post` | 夜班結束後 | 報告生成、清理、通知 |

## 建立外掛

建立具有這些標頭註解的 bash 腳本：

```bash
#!/usr/bin/env bash
# PLUGIN_NAME: My Plugin
# PLUGIN_PHASE: pre
# PLUGIN_DESCRIPTION: 簡短描述其功能

set -euo pipefail

NIGHT_SHIFT_DIR="${NIGHT_SHIFT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

# 你的程式碼
echo "Plugin running!"
```

## 啟用外掛

```bash
# 啟用範例外掛
ln -s ../examples/system_health.sh plugins/enabled/system_health.sh

# 或複製並自訂
cp plugins/examples/system_health.sh plugins/enabled/
```

## 可用的範例外掛

| 外掛 | 階段 | 描述 |
|--------|-------|-------------|
| `system_health.sh` | pre | 磁碟、記憶體、Docker 健康檢查 |
| `backup.sh` | pre | 備份配置和聊天記錄 |
| `git_commit_summary.sh` | post | 所有提交的摘要 |
| `morning_report.sh` | post | 編譯早間簡報 + TG 推送 |

## 運行外掛

```bash
# 運行所有已啟用的外掛
./plugins/plugin_loader.sh

# 只運行班次前外掛
./plugins/plugin_loader.sh --phase pre

# 列出所有外掛
./plugins/plugin_loader.sh --list
```

## 外掛準則

1. **超時：** 每個外掛最長執行時間為 5 分鐘
2. **退出碼：** 返回 0 表示成功，非零表示失敗（不會阻止班次）
3. **日誌：** 寫入 stdout — 載入器會捕獲它
4. **無密鑰：** 不要硬編碼 API 金鑰；使用環境變數
5. **冪等：** 外掛可能會運行多次；優雅處理