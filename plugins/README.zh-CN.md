# 插件系统

使用自定义插件扩展你的夜班。插件在夜班生命周期的特定阶段运行。

## 阶段

| 阶段 | 何时运行 | 用例 |
|-------|------|----------|
| `pre` | 夜班开始前 | 系统健康检查、备份、数据收集 |
| `task` | 每个回合期间 | 自定义任务、监控、报告 |
| `post` | 夜班结束后 | 报告生成、清理、通知 |

## 创建插件

创建具有这些头部注释的 bash 脚本：

```bash
#!/usr/bin/env bash
# PLUGIN_NAME: My Plugin
# PLUGIN_PHASE: pre
# PLUGIN_DESCRIPTION: 简短描述其功能

set -euo pipefail

NIGHT_SHIFT_DIR="${NIGHT_SHIFT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

# 你的代码
echo "Plugin running!"
```

## 启用插件

```bash
# 启用示例插件
ln -s ../examples/system_health.sh plugins/enabled/system_health.sh

# 或复制并自定义
cp plugins/examples/system_health.sh plugins/enabled/
```

## 可用的示例插件

| 插件 | 阶段 | 描述 |
|--------|-------|-------------|
| `system_health.sh` | pre | 磁盘、内存、Docker 健康检查 |
| `backup.sh` | pre | 备份配置和聊天记录 |
| `git_commit_summary.sh` | post | 所有提交的摘要 |
| `morning_report.sh` | post | 编译早间简报 + TG 推送 |

## 运行插件

```bash
# 运行所有已启用的插件
./plugins/plugin_loader.sh

# 只运行班次前插件
./plugins/plugin_loader.sh --phase pre

# 列出所有插件
./plugins/plugin_loader.sh --list
```

## 插件准则

1. **超时：** 每个插件最长执行时间为 5 分钟
2. **退出码：** 返回 0 表示成功，非零表示失败（不会阻止班次）
3. **日志：** 写入 stdout — 加载器会捕获它
4. **无密钥：** 不要硬编码 API 密钥；使用环境变量
5. **幂等：** 插件可能会运行多次；优雅处理
