---
inclusion: auto
---
# Kiro CLI 使用规范（ai-forge）

## 启动方式
推荐使用启动脚本（自动同步 agent + 环境检查 + 归档检查 + 对话轮转 + 恢复上下文）：
```bash
.kiro/sh/kiro-start.sh
```
或直接启动（默认模型 claude-opus-4.6）：
```bash
kiro-cli chat --trust-all-tools --model claude-opus-4.6
```

## 进入对话后的首要动作
1. 读取 [`.kiro/docs/conversation-context.md`](../docs/conversation-context.md) 最近 3 天工作流水
2. 读取 [`.kiro/docs/todo.md`](../docs/todo.md) 待处理列表，主动提醒用户
3. 读取 [`docs/kiro-log.md`](../../docs/kiro-log.md) 最近 3 个日期条目，补充决策上下文
4. 阅读 [`docs/progress.md`](../../docs/progress.md) 了解当前阶段进度
5. 使用 `/model` 确认当前模型（本项目默认 claude-opus-4.6），确认工具已信任（`/tools`）
6. 汇报上下文摘要，等待指令

## .kiro 目录结构

```
.kiro/
├── docs/                           ← AI 工作记录（对话管理、待办、经验）
│   ├── conversation-context.md     ← 按日期记录工作流水（恢复上下文用）
│   ├── conversation-end-reports.md ← 每次对话收尾报告
│   ├── todo.md                     ← 独立待办追踪
│   ├── code-fix-experience.md      ← 修复经验库（含排查弯路）
│   ├── dialogs/                    ← 对话轮次记录
│   │   ├── current.md              ← 当日对话（每天轮转）
│   │   └── archives/               ← 归档的历史对话
│   ├── archives/                   ← 归档的历史文档
│   └── misc/                       ← 研究笔记（含 kiro-architecture-guide.md）
├── steering/                       ← 行为约束（AI 自动加载 inclusion: auto）
│   ├── self-evolving-rules.md      ← 经验规则库
│   ├── quick-reference.md          ← 高频规则速查卡
│   ├── executor.md                 ← 指令映射 + 快捷命令
│   ├── commit-conventions.md       ← 提交规范
│   ├── code-review.md              ← 审查检查清单
│   ├── dev-guidelines.md           ← 开发规范
│   └── kiro-usage.md               ← 本文件
├── settings/
│   └── lsp.json                    ← Python LSP（pyright）配置
└── sh/
    └── kiro-start.sh               ← 项目启动入口
```

### 与项目 docs/ 的关系

| 维度 | 项目 `docs/` | `.kiro/docs/` |
|------|-------------|---------------|
| 受众 | 人类（开发者） | AI 助手 |
| 内容 | README、需求、进度、架构 | 对话上下文、待办、修复经验 |
| 生命周期 | 跟随项目版本，长期维护 | 跟随对话会话，频繁轮转归档 |

两个目录并行，各司其职，不合并。

## 三层上下文粒度

| 文件 | 维度 | 粒度 | 用途 |
|------|------|------|------|
| `.kiro/docs/conversation-context.md` | 事件 | 摘要 | 恢复上下文（"做了什么"） |
| `.kiro/docs/dialogs/current.md` | 对话 | 详细 | 完整复盘（"说了什么"） |
| `.kiro/docs/conversation-end-reports.md` | 会话 | 结构化 | 闭环确认（"这次会话的成果"） |

### 各文档职责

- **conversation-context.md** — 工作流水摘要。`### YYYY-MM-DD` → `#### 主题` → 操作摘要 + commit hash。每完成一个独立动作后追加。恢复上下文时读最近 3 天。
- **dialogs/current.md** — 对话明细。`### HH:MM — 主题` → `**用户**：原话` → `**AI**：操作+结果`。每轮交互后追加，每天轮转。
- **conversation-end-reports.md** — 收尾报告。四段式（完成事项/规则变更/文档同步状态/遗留事项）。用户说"收工"时生成。
- **todo.md** — 待办追踪。统计表 + P1/P2/P3 分组 + 已完成归档。对话开启时检查并提醒。
- **code-fix-experience.md** — 修复经验库。`### E-xxx` → 场景/症状/排查弯路/根因/修复/关联。每次 bug 修复后写入。核心价值是"排查弯路"。
- **docs/kiro-log.md** — 决策日志。只记决策和理由，不含过程流水和待办。
- **self-evolving-rules.md** — 经验规则库。`R-xxx [分类] 规则内容` + 来源。踩坑后提炼。
- **quick-reference.md** — 高频规则速查。规则超 30 条时必须维护。

## 对话规范
- 代码修改前先确认影响范围
- 耗时任务（模型下载、量化、微调、训练）用 `nohup ... &` 后台运行，启动后立即返回对话
- GPU 任务启动前先 `nvidia-smi` 确认显存可用，避免 OOM
- 每完成一个功能点，验证通过后立即 commit 并 push
- 每个功能 commit 中同时包含：代码 + 文档（README/progress/requirements）+ kiro-log + agent 变更（如有）
- commit 遵循 `<type>(<scope>): <subject>` 格式，scope 对应阶段：api/serving/tools/training/pretrain/docs

## 结束对话流程

详见 [`executor.md`](executor.md) 的"结束对话完整流程"章节，6 步执行：
1. 更新 conversation-context.md
2. 生成收尾报告到 conversation-end-reports.md
3. 更新 todo.md
4. 规则/经验检查（self-evolving-rules + code-fix-experience）
5. git commit
6. kiro-agents sync

## 归档规则

| 文件 | 触发条件 | 归档位置 |
|------|----------|----------|
| `conversation-context.md` | 超过 500 行 | `.kiro/docs/archives/context-{YYYY-MM}.md` |
| `conversation-end-reports.md` | 超过 30 天 | `.kiro/docs/archives/end-reports-{YYYY-MM}.md` |
| `todo.md` | 已完成项超 30 天 | `.kiro/docs/archives/todo-{YYYY-MM}.md` |
| `dialogs/current.md` | 每天轮转 | `.kiro/docs/dialogs/archives/dialog-{YYYY-MM-DD}.md` |
| `docs/kiro-log.md` | 超过 1000 行 | `docs/archive/kiro-log-{YYYYMMDD}.md` |

## 自演进检查点
每次完成功能模块或修复 bug 后，立即执行：
1. 本次踩坑是否可提取为项目级规则？→ `self-evolving-rules.md`
2. 该规则是否跨项目通用？→ 上提到 `~/.kiro/steering/`
3. bug 修复是否值得记录经验？→ `code-fix-experience.md`
4. 是否有新检查项加入 `code-review.md`？
5. 不等用户提醒，主动执行
