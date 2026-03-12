# 🌙 AI Night Shift

> 多 Agent 自主框架 — 讓你的 AI 助理在你睡覺時工作。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![English](https://img.shields.io/badge/lang-English-blue)](README.md)
[![简体中文](https://img.shields.io/badge/lang-简体中文-red)](README.zh-CN.md)
[![한국어](https://img.shields.io/badge/lang-한국어-green)](README.ko.md)

**AI Night Shift** 是一個開源框架，用來在非工作時間協調運行多個 AI Agent（Claude Code、Gemini 等）的自主作業。源自 30+ 次真實生產環境夜班經驗，不是理論，是實戰驗證。

## 與眾不同之處

多數「自主 Agent」工具只跑單一個 Agent。AI Night Shift 協調**多個異構 AI Agent** 協同工作：

| Agent | 引擎 | 角色 | 模式 |
|-------|------|------|------|
| 開發者 | Claude Code | 寫程式、除錯、部署 | 持續運行（數小時） |
| 研究員 | Gemini CLI | 研究、資料收集、分類 | 定時巡邏（數分鐘） |
| 協調者 | 任意 LLM | 任務路由、監控 | 心跳模式（30分鐘） |

它們透過共享協定溝通 — 基於檔案的訊息佇列、共享對話記錄和任務管理整合。

## 架構

```
┌─────────────────────────────────────────────┐
│              AI Night Shift                  │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Claude   │  │ Gemini   │  │ 心跳     │  │
│  │ Code     │  │ CLI      │  │ Agent    │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       └──────┬───────┴──────┬───────┘        │
│       ┌──────▼──────┐ ┌────▼─────┐          │
│       │ night_chat  │ │ bot_inbox│          │
│       │    .md      │ │  (JSON)  │          │
│       └─────────────┘ └──────────┘          │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ 外掛程式 │  │ 儀表板   │  │ 模板     │  │
│  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────┘
```

## 快速開始

### 1. 安裝

```bash
git clone https://github.com/judyailab/ai-night-shift.git
cd ai-night-shift
bash install.sh
```

### 2. 設定

```bash
cp config.env.example config.env
nano config.env
```

### 3. 測試

```bash
# 只跑一輪驗證設定
bash claude-code/night_shift.sh --max-rounds 1
```

### 4. 排程

```bash
crontab -e
# 新增：0 1 * * * cd ~/ai-night-shift && bash claude-code/wrapper.sh
```

## 模組

| 模組 | 說明 | 文件 |
|------|------|------|
| [Claude Code](claude-code/) | 持續開發者作業 | [README](claude-code/README.md) |
| [Gemini](gemini/) | 定時巡邏與研究 | [README](gemini/README.md) |
| [OpenClaw](openclaw/) | 心跳協調者模式 | [README](openclaw/README.md) |
| [協定](protocols/) | 跨 Agent 通訊 | [README](protocols/README.md) |
| [外掛](plugins/) | 可擴充的前/後/任務 Hook | [README](plugins/README.md) |
| [儀表板](dashboard/) | 視覺化監控介面 | 開啟 `dashboard/index.html` |
| [模板](templates/) | 依用途分類的 Prompt | 含 4 個模板 |

## Prompt 模板

| 模板 | 用途 |
|------|------|
| `development.txt` | 程式開發、測試、除錯 |
| `research.txt` | 資料收集、分析 |
| `content.txt` | 寫作、翻譯、SEO |
| `maintenance.txt` | 系統管理、監控 |

## 外掛系統

```bash
# 啟用外掛
ln -s plugins/examples/system_health.sh plugins/enabled/

# 列出所有外掛
bash plugins/plugin_loader.sh --list
```

內建外掛：系統健康檢查、備份、Git 提交摘要、晨報生成、De-Sloppify 程式碼清理

## 儀表板

用瀏覽器開啟 `dashboard/index.html`，拖放報告檔案即可視覺化：
- Agent 活動與狀態
- 逐輪時間線
- 夜間對話訊息
- 系統健康指標

## 進階功能

- **完成信號** — Agent 可以主動說「我做完了」來提前結束夜班
- **共享任務筆記** — 跨輪次的上下文記憶橋接
- **De-Sloppify 模式** — 獨立清理 pass，消除程式碼品質問題
- **反模式指南** — 避免常見的自主循環陷阱

## 需求

- **Bash 4+** 和 **Python 3.6+**
- 至少一個 AI CLI 工具：
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- Linux/macOS 系統（含 cron 或任何排程工具）

## 安全性

- **PID 鎖定**防止同時執行
- **時間窗口**確保夜班準時結束
- **速率限制處理**自動等待重試
- **無程式碼內密鑰** — 全透過環境變數
- **附加式通訊** — Agent 無法刪除彼此的訊息
- **外掛逾時** — 每個外掛最多執行 5 分鐘

## 貢獻

請參閱 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 授權

[MIT](LICENSE) — Judy AI Lab

---

*源自 30+ 次自主夜班的實戰經驗。讓 AI 在你睡覺時更努力工作。* 🌙
