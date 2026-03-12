# Gemini 巡逻模块

[Gemini CLI](https://github.com/google-gemini/gemini-cli) 的周期性巡逻执行器。专为频繁、轻量级签到设计，而非长时间连续会话。

## 运作方式

```
Cron（每 1-2 小时）
  → 收集收件箱项目
  → 读取最近的团队聊天
  → 建立上下文感知的提示词
  → 执行 Gemini CLI
  → 发布结果到夜聊
  → 将处理的项目移到 done/
```

## 快速开始

```bash
# 执行单次巡逻
./patrol.sh

# 使用自定义提示词
./patrol.sh --prompt my_patrol_prompt.txt
```

## 配置

| 变量 | 默认值 | 描述 |
|----------|---------|-------------|
| `GEMINI_BIN` | `gemini` | Gemini CLI 路径 |
| `NIGHT_SHIFT_DIR` | 自动检测 | 框架根目录 |

## Cron 设定

```bash
# 夜班期间每 2 小时巡逻（凌晨 1 点 - 早上 7 点）
0 1,3,5,7 * * * cd ~/ai-night-shift && bash gemini/patrol.sh >> logs/patrol.log 2>&1
```

## 最佳用例

Gemini 的优势（接地、搜索、大上下文）使其非常适合：
- **研究任务** — 网络搜索、数据收集
- **任务分类** — 阅读收件箱、将工作路由到其他代理
- **文档** — 撰写摘要、格式化报告
- **翻译** — 本地化内容
