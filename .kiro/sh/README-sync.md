# Kiro 配置同步说明

## 🎯 架构

**单一入口，全局同步**
- `.kiro/sh/kiro-start.sh` - 项目启动入口
- `kiro-agents/sync.sh` - 统一同步脚本（位于 kiro-agents 仓库）

## 📐 工作流程

```
kiro-start.sh → 更新 kiro-agents 仓库 → 执行 sync.sh → 同步所有项目
```

## 🚀 使用

### 首次使用

```bash
# 1. 克隆 kiro-agents 仓库
git clone <repo-url> ~/Project/Python/kiro-agents

# 2. 运行启动脚本
./.kiro/sh/kiro-start.sh
```

### 日常使用

```bash
# 每次工作前后运行
./.kiro/sh/kiro-start.sh
```

会自动：
- 拉取其他设备的更改
- 推送本地的更改
- 启动 Kiro CLI

## 🔄 同步策略

双向智能同步（基于时间戳）：
- 仅本地存在 → 推送到仓库
- 仅仓库存在 → 拉取到本地
- 都存在 → 比较时间戳，较新者胜出

## ⚙️ 添加新项目

编辑 `kiro-agents/sync.sh`：

```bash
PROJECTS=(
    "Media-Library|$HOME/Project/Python/Media-Library"
    "FUOS|$HOME/Project/Android/FUOS"
    "NewProject|/path/to/project"  # 添加这行
)
```

## ⚠️ 注意

1. 确保系统时间准确
2. 避免多设备同时编辑同一文件
3. 养成工作前后运行 kiro-start.sh 的习惯