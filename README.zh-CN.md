# 🌙 AI Night Shift

> 多 Agent 自主框架 — 让你的 AI 助理在你睡觉时工作。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![English](https://img.shields.io/badge/lang-English-blue)](README.md)
[![繁體中文](https://img.shields.io/badge/lang-繁體中文-orange)](README.zh-TW.md)
[![한국어](https://img.shields.io/badge/lang-한국어-green)](README.ko.md)

**AI Night Shift** 是一个开源框架，用于在非工作时间协调运行多个 AI Agent（Claude Code、Gemini 等）的自主作业。源自 30+ 次真实生产环境夜班经验，不是理论，是实战验证。

## 与众不同之处

多数「自主 Agent」工具只运行单一 Agent。AI Night Shift 协调**多个异构 AI Agent** 协同工作：

| Agent | 引擎 | 角色 | 模式 |
|-------|------|------|------|
| 开发者 | Claude Code | 写代码、调试、部署 | 持续运行（数小时） |
| 研究员 | Gemini CLI | 研究、数据采集、分类 | 定时巡逻（数分钟） |
| 协调者 | 任意 LLM | 任务路由、监控 | 心跳模式（30分钟） |

它们通过共享协议通信 — 基于文件的消息队列、共享对话记录和任务管理集成。

## 架构

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
│  │ 插件     │  │ 仪表盘   │  │ 模板     │  │
│  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────┘
```

## 快速开始

### 1. 安装

```bash
git clone https://github.com/judyailab/ai-night-shift.git
cd ai-night-shift
bash install.sh
```

### 2. 配置

```bash
cp config.env.example config.env
nano config.env
```

### 3. 测试

```bash
# 只运行一轮验证配置
bash claude-code/night_shift.sh --max-rounds 1
```

### 4. 调度

```bash
crontab -e
# 添加：0 1 * * * cd ~/ai-night-shift && bash claude-code/wrapper.sh
```

## 模块

| 模块 | 说明 | 文档 |
|------|------|------|
| [Claude Code](claude-code/) | 持续开发者会话 | [README](claude-code/README.md) |
| [Gemini](gemini/) | 定时巡逻与研究 | [README](gemini/README.md) |
| [OpenClaw](openclaw/) | 心跳协调者模式 | [README](openclaw/README.md) |
| [协议](protocols/) | 跨 Agent 通信 | [README](protocols/README.md) |
| [插件](plugins/) | 可扩展的前/后/任务 Hook | [README](plugins/README.md) |
| [仪表盘](dashboard/) | 可视化监控界面 | 打开 `dashboard/index.html` |
| [模板](templates/) | 按用途分类的 Prompt | 含 4 个模板 |

## Prompt 模板

| 模板 | 用途 |
|------|------|
| `development.txt` | 编程开发、测试、调试 |
| `research.txt` | 数据采集、分析 |
| `content.txt` | 写作、翻译、SEO |
| `maintenance.txt` | 系统管理、监控 |

## 插件系统

```bash
# 启用插件
ln -s plugins/examples/system_health.sh plugins/enabled/

# 列出所有插件
bash plugins/plugin_loader.sh --list
```

内置插件：系统健康检查、备份、Git 提交摘要、晨报生成

## 仪表盘

用浏览器打开 `dashboard/index.html`，拖放报告文件即可可视化：
- Agent 活动与状态
- 逐轮时间线
- 夜间对话消息
- 系统健康指标

## 进阶功能

- **完成信号** — Agent 可以主动说「我做完了」提前结束夜班
- **共享任务笔记** — 跨轮次的上下文记忆桥接
- **De-Sloppify 模式** — 独立清理 pass，消除代码质量问题
- **反模式指南** — 避免常见的自主循环陷阱

## 需求

- **Bash 4+** 和 **Python 3.6+**
- 至少一个 AI CLI 工具：
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- Linux/macOS 系统（含 cron 或任何调度工具）

## 安全性

- **PID 锁定**防止并发运行
- **时间窗口**确保夜班准时结束
- **速率限制处理**自动等待重试
- **无代码内密钥** — 全通过环境变量
- **追加式通信** — Agent 无法删除彼此的消息
- **插件超时** — 每个插件最多执行 5 分钟

## 贡献

请参阅 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

[MIT](LICENSE) — Judy AI Lab

---

*源自 30+ 次自主夜班的实战经验。让 AI 在你睡觉时更努力工作。* 🌙
