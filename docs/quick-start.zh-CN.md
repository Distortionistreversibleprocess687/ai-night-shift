# 快速入门指南

在 5 分钟内启动 AI 夜班。

## 先决条件

- Linux 或 macOS
- Bash 4+ 和 Python 3.6+
- 至少安装一个 AI CLI 工具：
  - **Claude Code：** `npm install -g @anthropic-ai/claude-code`
  - **Gemini CLI：** `npm install -g @google/gemini-cli`

## 步骤 1：安装

```bash
git clone https://github.com/judyailab/ai-night-shift.git
cd ai-night-shift
bash install.sh
```

安装程序将：

- 创建目录结构
- 设置文件权限
- 可选配置定时任务

## 步骤 2：配置

```bash
cp config.env.example config.env
nano config.env
```

需要调整的关键设置：

- `WINDOW_HOURS` — 夜班运行时长
- `MAX_ROUNDS` — 最大轮次数
- `CLAUDE_BIN` / `GEMINI_BIN` — CLI 工具的路径

## 步骤 3：自定义提示词

编辑提示词模板来告诉 AI 要做什么：

```bash
nano claude-code/prompt_template.txt
```

或使用预置模板之一：

```bash
cp templates/development.txt claude-code/prompt_template.txt
```

## 步骤 4：测试

运行单轮以验证一切正常：

```bash
bash claude-code/night_shift.sh --max-rounds 1
```

检查输出：

```bash
cat reports/$(date +%Y-%m-%d)_round1.md
```

## 步骤 5：计划任务

安装程序可以自动设置定时任务。手动设置：

```bash
crontab -e
```

添加您偏好的计划：

```
# 凌晨 1 点的夜班（调整时区）
0 1 * * * cd ~/ai-night-shift && bash claude-code/wrapper.sh >> logs/cron.log 2>&1

# 夜间每 2 小时的 Gemini 巡逻
0 1,3,5,7 * * * cd ~/ai-night-shift && bash gemini/patrol.sh >> logs/patrol.log 2>&1
```

## 步骤 6：启用插件（可选）

```bash
# 启用系统健康检查（在夜班前运行）
ln -s ../examples/system_health.sh plugins/enabled/system_health.sh

# 启用早间报告（在夜班后运行）
ln -s ../examples/morning_report.sh plugins/enabled/morning_report.sh
```

## 步骤 7：监控

打开仪表板：

```bash
open dashboard/index.html
# 或
xdg-open dashboard/index.html
```

拖放报告文件以可视化您的夜班活动。

## 下一步

- **[架构](architecture.zh-CN.md)** — 了解系统工作原理
- **[高级指南](advanced.zh-CN.md)** — 多代理设置、自定义插件
- **[故障排除](troubleshooting.zh-CN.md)** — 常见问题和解决方案
