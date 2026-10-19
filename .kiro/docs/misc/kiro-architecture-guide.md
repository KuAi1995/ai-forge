# .kiro 目录架构使用规范

> 新项目初始化 .kiro 目录时参照本文档快速展开。
> 总结自 Media-Library（Python 数据采集）和 FUOS/miuix（Android SDK 60+ 模块）两个项目的实战经验。

---

## 一、整体架构

```
.kiro/
├── docs/                  ← AI 工作记录（对话管理、待办、经验）
│   ├── conversation-context.md    ← 工作流水（按日期，恢复上下文用）
│   ├── conversation-end-reports.md ← 对话收尾报告（会话级摘要）
│   ├── todo.md                     ← 独立待办追踪
│   ├── code-fix-experience.md      ← 修复经验库（含排查弯路）
│   ├── dialogs/                    ← 对话轮次记录
│   │   ├── current.md              ← 当日对话（每天轮转）
│   │   └── archives/               ← 历史对话归档
│   ├── archives/                   ← 各类文档月度归档
│   └── misc/                       ← 临时研究笔记、实验记录
├── steering/              ← 行为约束（AI 自动加载，inclusion: auto）
│   ├── self-evolving-rules.md      ← 经验规则库（持续积累）
│   ├── quick-reference.md          ← 高频规则速查卡
│   ├── executor.md                 ← 指令映射 + 快捷命令
│   ├── commit-conventions.md       ← 提交规范
│   ├── code-review.md              ← 审查检查清单
│   ├── dev-guidelines.md           ← 开发规范（项目专属）
│   ├── kiro-usage.md               ← Kiro CLI 使用规范
│   └── {domain}.md                 ← 领域专项规范（按需）
├── agents/                ← 专项任务代理（按职责拆分）
│   └── {role}.md
├── settings/              ← 工具配置
│   ├── lsp.json                    ← 语言服务器配置
│   └── mcp.json                    ← MCP 服务器配置（如需外部集成）
└── sh/                    ← 启动与自动化脚本
    └── kiro-start.sh              ← 项目启动入口
```

### 与项目 docs/ 的关系

| 维度 | 项目 `docs/` | `.kiro/docs/` |
|------|-------------|---------------|
| 受众 | 人类（开发者/用户） | AI 助手 |
| 内容 | README、需求、进度、架构设计 | 对话上下文、待办、修复经验 |
| 生命周期 | 跟随项目版本，长期维护 | 跟随对话会话，频繁轮转归档 |
| 引用方式 | GitHub 页面浏览 | AI 启动时自动加载 |

两个目录并行，各司其职，不合并。

---

## 二、docs/ 文档体系

### 2.1 conversation-context.md — 工作流水

**核心职责**：按日期正序记录每日工作流水，新对话开启时读取最近 3 天恢复状态。

```markdown
---
inclusion: auto
---
# 对话上下文（工作流水）

### 2026-10-18

#### 主题简述
- 具体操作/结果/关联 commit hash
- 另一个操作
```

**写入时机**：每完成一个独立动作后立即追加（代码提交、bug 修复、配置变更、刮削结果等）。

**设计要点**：
- 按日期分三级标题，同一天追加到同一章节
- 内容要足够详细以支持跨对话恢复，但不写完整代码
- 多机场景：通过 git 仓库同步（见"多机同步"章节）

### 2.2 conversation-end-reports.md — 对话收尾报告

**核心职责**：每次对话结束时生成结构化收尾报告，确保每次对话闭环。

```markdown
### YYYY-MM-DD HH:MM

#### 完成事项
- 具体完成的功能/修复/变更

#### 规则变更
- 新增/更新的 self-evolving-rules 条目，或"无"

#### 文档同步状态
- README.md: ✅/❌
- docs/progress.md: ✅/❌
- ...

#### 遗留事项
- 未完成的任务/待跟进的问题，或"无"
```

**写入时机**：对话结束时（用户说"结束对话/收工"触发）。

### 2.3 todo.md — 独立待办追踪

**核心职责**：统一管理所有待办事项，按优先级和状态分类。

```markdown
## 统计
| 状态 | 数量 |
|------|------|
| 待处理 | N |
| 已完成 | M |

## 待处理
### P1 — 高优先级
| # | 任务 | 来源 | 新增日期 | 备注 |
|---|------|------|----------|------|
| T-001 | 具体任务描述 | 来源 | 日期 | 备注 |

## 已完成
| # | 任务 | 完成日期 | 备注 |
```

**写入时机**：有新待办或状态变更时。对话开启时自动检查并提醒。

### 2.4 code-fix-experience.md — 修复经验库

**核心职责**：每次 bug 修复后记录完整经验，避免重复排查。这是参考项目（miuix）中最有价值的设计之一。

```markdown
### E-001 问题简述
- **场景**：在什么情况下触发
- **症状**：用户/开发者看到什么现象
- **排查弯路**：试过哪些方案没用（标注"不要重复"）
- **根因**：真正的原因
- **修复**：怎么修的
- **关联**：关联的规则编号 / commit hash
```

**设计要点**：
- **排查弯路是核心价值**——记录"试过但没用"的方案，避免下次再走弯路
- 按问题域分章节（数据源、翻译、图片、GUI、网络...），便于检索
- 与 self-evolving-rules 互补：rules 是规则（"应该做什么"），experience 是案例（"遇到了什么，怎么解决的"）

### 2.5 dialogs/ — 对话轮次记录

**核心职责**：记录每日对话明细（用户消息 + AI 响应摘要），每天轮转。

- `current.md`：当天对话记录
- `archives/dialog-{YYYY-MM-DD}.md`：历史对话

**与 context 的区别**：context 是事件维度（"做了什么"），dialogs 是对话维度（"说了什么"），粒度更细。

### 2.6 misc/ — 临时文档

存放临时性的研究笔记、实验记录、问题分析文档等。不需要严格格式，按需创建。

---

## 三、steering/ 行为约束体系

### 3.1 设计原则

所有 steering 文件都带 `inclusion: auto` 前置元数据，Kiro CLI 启动时自动加载到上下文。

**分层设计**：
- `~/.kiro/steering/` — 系统级规则（跨项目通用）
- `.kiro/steering/` — 项目级规则（项目专属）
- 项目级可继承系统级，冲突时项目级优先

### 3.2 self-evolving-rules.md — 经验规则库

**核心机制**：对话中踩坑→提炼规则→持久化→后续自动遵守。

```markdown
- **R-001** [分类] 规则内容
  来源：踩坑场景描述
```

**提取时机**：
- 用户纠正了 AI 的错误操作
- 发现了 API/工具/框架的隐性限制
- 用户明确了某个操作的标准流程
- 同一方案失败两次以上

**分层规则**：
- 通用规则（网络请求重试、文件 I/O、打包分发）→ 系统级 `~/.kiro/steering/`
- 项目专属（数据源限制、业务流程）→ 项目级 `.kiro/steering/`
- 项目规则中的通用部分定期上提到系统级

**参考规模**：
- 小项目初始 0 条，逐步积累到 10-20 条
- 中型项目（如 Media-Library）~40 条
- 大型项目（如 miuix）可达 100+ 条

### 3.3 quick-reference.md — 高频规则速查卡

**核心职责**：从全量规则中精选最高频的核心约束，AI 启动时优先加载。

**设计要点**：
- 按操作类型分组（Git、翻译、图片、配置...）
- 每条规则一行，引用规则编号
- 当 self-evolving-rules 超过 30 条时必须维护此文件
- 每次新增规则后同步更新

### 3.4 executor.md — 指令映射 + 快捷命令

**核心职责**：将用户的简短指令映射为具体执行动作。

**三层结构**：

1. **指令映射表**：`用户说 → 意图 → 执行动作`
2. **快捷命令**：多步操作封装为一句话命令
3. **纠错记录**：`用户说 X → AI 错误理解 → 正确意图`

**必备快捷命令**（所有项目通用）：

| 命令 | 执行流程 |
|------|----------|
| 结束对话 / 收工 | 更新 context → 生成 end-report → 更新 todo → 规则检查 → commit |
| 恢复上下文 / 继续 | 读 context 最近 3 天 → 读 todo → 读 kiro-log → 汇报摘要 |
| 同步文档 | 全量对比代码现状与文档，逐个检查 |
| 检查同步 | git status + 文档同步 + .kiro/ 变更 + 汇报 ✅/❌ |
| 记经验 / 沉淀 | 提取修复经验 → code-fix-experience.md |
| 提规则 | 提取规则 → self-evolving-rules.md |
| 自我演进 | 全面审视：意图理解 + 执行方法 + 代码审查 + 文档一致性 |

**推送后自动检查**（每次 git push 必须执行）：
1. ✅/❌ 文档同步
2. ✅/❌ .kiro/ 变更已提交
3. ✅/❌ kiro-agents 同步
4. ✅/❌ conversation-context 已更新
5. ✅/❌ todo.md 状态最新
6. ✅/❌ code-fix-experience 是否需要新增
7. ✅/❌ self-evolving-rules 是否需要新增

**模糊匹配**：用户输入不精确时按语义就近匹配（如"同步"→同步文档，"收工"→结束对话）。

### 3.5 commit-conventions.md — 提交规范

**核心要素**：

1. **原子性**：一个 commit 只做一件事
2. **格式**：`<type>(<scope>): <subject>`
3. **文档同步**：每个 commit 必须同时更新相关文档
4. **失败模式记录**：从实际违规中学习（F-001, F-002...）
5. **模块→文档映射表**：代码变更时按表检查文档

**大型项目补充**（如 miuix 的 Gerrit 门禁）：
- Commit-MSG-Check 格式模板（Bugfix/Feature 各有固定格式）
- Git Hooks（pre-commit 代码审查、prepare-commit-msg 自动生成）

### 3.6 code-review.md — 审查检查清单

**核心维度**：
- 正确性（逻辑/空指针/线程安全/资源泄漏）
- 性能（热路径优化/缓存/并发）
- API 设计（文档/兼容性）
- 副作用检查（NFO/数据库/文件移动/图片/词典/云盘）

**大型项目补充**：
- 三级标记：🔴 必须修改 / 🟡 建议修改 / 🟢 可选优化

### 3.7 领域专项 steering（按需）

根据项目类型按需新增：

| 文件 | 适用场景 |
|------|----------|
| `autobugfix.md` | Bug 修复自动化（分析→修复→提交→回填） |
| `module-doc-sync.md` | 多模块项目的文档同步规范 |
| `kiro-cloud-sync.md` | 多机同步架构 |
| `symbol-font-add.md` | 机械性多文件操作流程 |

---

## 四、agents/ 专项代理

### 4.1 设计原则

按职责拆分，每个 agent 聚焦一个领域：

```markdown
---
inclusion: auto
---
# {Role} Agent 职责

## 职责范围
- 具体负责什么

## 工作规则
- 具体怎么做

## 输出格式
- 分析/方案/修复的标准输出格式
```

### 4.2 通用 agents（所有项目）

| Agent | 职责 |
|-------|------|
| `architecture.md` | 架构分析、重构优化、性能改进 |
| `requirement.md` | 需求分析、bug 排查、问题定位 |

### 4.3 按项目类型扩展

| 项目类型 | 推荐 agents |
|----------|-------------|
| 数据采集 | scraper.md / parser.md / generator.md |
| Android SDK | library-dev.md / sample-dev.md / publish.md |
| Web 应用 | frontend.md / backend.md / deploy.md |
| 大型项目 | doc-sync.md（独立文档同步 agent，减轻主 agent 负担） |

### 4.4 doc-sync agent 设计（大型项目推荐）

当项目文档同步工作量大时，将文档更新从主 agent 分离为独立 agent：

- **触发方式**：主 agent 完成任务后 spawn doc-sync agent
- **输入**：JSON 任务描述（type: ipd_done / push_done / session_end 等）
- **写权限**：仅限 `.kiro/docs/**` 和 `self-evolving-rules.md`
- **好处**：主 agent 专注代码，文档同步不占主对话上下文

---

## 五、settings/ 工具配置

### 5.1 lsp.json — 语言服务器

```json
{
  "python": {
    "command": "pyright-langserver --stdio",
    "filetypes": ["py"],
    "project_files": ["pyproject.toml", "setup.py", "requirements.txt"],
    "timeout_seconds": 60,
    "exclude_directories": ["node_modules", ".git", "__pycache__", "dist", "build"]
  }
}
```

按项目语言配置。支持 Java/Kotlin（jdtls）、Go（gopls）、Rust（rust-analyzer）、TypeScript 等。

### 5.2 mcp.json — MCP 服务器（可选）

用于集成外部服务（如问题跟踪平台、云文档平台）：

```json
{
  "mcpServers": {
    "service-name": {
      "type": "streamable-http",
      "url": "http://...",
      "headers": { "Authorization": "Bearer ..." }
    }
  }
}
```

---

## 六、sh/ 自动化脚本

### 6.1 kiro-start.sh — 启动脚本

**标准启动流程**：

```
1. 同步 kiro-agents 仓库（多项目统一同步）
2. 归档检查（各类文档行数/日期阈值）
3. 对话文件日期轮转（dialogs/current.md）
4. Git 状态检查（未提交/未推送警告）
5. 启动 Kiro CLI + 传入恢复 prompt
```

**恢复 prompt 模板**：

```
开始对话恢复：
1. 读取 .kiro/docs/conversation-context.md 最近 3 天
2. 读取 .kiro/docs/todo.md 待处理列表
3. 读取 docs/kiro-log.md 最近 3 个日期条目
4. 汇报上下文摘要，等待指令
```

### 6.2 nightly-sync.sh — 夜间同步（大型项目可选）

无人值守模式，用 `kiro-cli chat --no-interactive` 运行：
- 外部问题平台全量刷新
- 待办/问题追踪文档自动更新
- 日报自动补写
- 对话文件日期轮转
- crontab 定时调用

---

## 七、归档机制

### 7.1 归档规则

| 文件 | 触发条件 | 归档位置 |
|------|----------|----------|
| conversation-context.md | 超过 500 行 | archives/context-{YYYY-MM}.md |
| conversation-end-reports.md | 超过 30 天 | archives/end-reports-{YYYY-MM}.md |
| todo.md | 已完成项超 30 天 | archives/todo-{YYYY-MM}.md |
| dialogs/current.md | 每天轮转 | dialogs/archives/dialog-{YYYY-MM-DD}.md |
| 项目 kiro-log.md | 超过 1000 行 | docs/archive/kiro-log-{YYYYMMDD}.md |

### 7.2 归档操作

- 提取需归档的内容 → 写入归档文件 → 从主文档删除
- 归档文件只读不更新
- kiro-start.sh 启动时自动检查是否需要归档

---

## 八、代码工作流程

### 8.1 需求实现流程

```
需求输入 → 分析拆解 → 方案确认 → 实现 → 验证 → 提交 → 文档同步 → 推送
```

**详细步骤**：

1. **需求分析**
   - 明确输入/输出、边界条件、异常场景
   - 拆解为可执行的子任务，标注涉及模块
   - 复杂功能或不确定的变更 → 先说方案让用户确认，不直接动手

2. **方案设计**
   - 读取相关现有代码，理解当前架构
   - 确认方案不破坏现有功能（配置默认值行为不变）
   - 大范围重构拆分为多个原子性步骤

3. **实现**
   - 按项目代码规范编写（dev-guidelines.md）
   - 多入口项目的共享逻辑抽到共享模块，入口只做 UI + 参数组装
   - 新增配置项同步更新：配置模板 + GUI 配置页 + README

4. **验证**
   - 修改的代码能正常 import/编译（无语法错误）
   - 功能测试：正常路径 + 边界情况 + 错误输入
   - 副作用检查：按 code-review.md 检查清单逐项过
   - 配置组合测试：开/关、与其他配置项组合、默认值行为

5. **提交**（见 8.4）

### 8.2 Bug 修复流程

```
问题报告 → 复现 → 定位 → 修复 → 验证 → 记录经验 → 提交 → 规则检查
```

**详细步骤**：

1. **复现**
   - 明确触发条件（环境、输入、配置）
   - 能稳定复现才继续，不能复现则记录到待办

2. **定位**
   - 从日志/堆栈定位到具体模块和函数
   - 分析根因而非表象
   - 记录排查过程中**试过但没用**的方案（后续写入经验库）

3. **修复**
   - 修根因不修表象
   - 修复时避免引入新问题
   - 检查同类问题是否在其他位置也存在

4. **验证**
   - 确认原问题已修复
   - 确认没有引入回归（副作用检查）
   - 边界情况验证

5. **记录经验**（见 8.3）

6. **提交**（见 8.4）

7. **规则检查**
   - 本次修复是否暴露了可通用的规则？→ self-evolving-rules.md
   - 是否需要新增 code-review 检查项？→ code-review.md

### 8.3 经验记录闭环

从修复到记录到规则的完整闭环：

```
Bug 修复
  ├─→ code-fix-experience.md（E-xxx 条目）
  │     场景/症状/排查弯路/根因/修复/关联
  │
  ├─→ self-evolving-rules.md（R-xxx 条目，如果可通用）
  │     [分类] 规则内容 + 来源
  │
  ├─→ quick-reference.md（如果是高频规则）
  │     精选速查条目
  │
  └─→ code-review.md（如果暴露了检查遗漏）
        新增检查项 / 失败模式
```

**经验 vs 规则的区别**：
- **经验**（code-fix-experience）：具体案例，"遇到了什么，怎么解决的"，含排查弯路
- **规则**（self-evolving-rules）：抽象规范，"以后应该怎么做"，可跨场景复用

**演化路径**：
```
首次踩坑 → 记录经验（E-xxx）
同类问题出现第二次 → 提炼为规则（R-xxx）
规则积累超过 30 条 → 精选到速查卡
规则暴露检查遗漏 → 补充 code-review 检查项
多次违规同一规则 → 记录为 commit-conventions 失败模式（F-xxx）
```

### 8.4 提交规范

**提交前强制检查流程**（写完代码后必须停下来逐项过）：

```
代码写完 → 停！不要 git add
  │
  ├─ 1. 原子性检查：本次只做了一件事？
  │
  ├─ 2. 文档同步（按代码→文档映射表逐项检查）：
  │     ├─ README.md 需要更新？
  │     ├─ progress.md 需要更新？
  │     ├─ requirements.md 需要更新？
  │     ├─ kiro-log.md 记录决策？
  │     └─ 如果不需要更新，明确说明原因
  │
  ├─ 3. .kiro/ 变更检查：steering/agents/docs 有未提交的变更？
  │
  ├─ 4. 代码验证：import 无报错？新增依赖已添加？
  │
  ├─ 5. 安全检查：不含 API key / 密码 / 个人路径？
  │
  └─ 全部确认 → git add → git commit
```

**Commit message 格式**：

```
<type>(<scope>): <subject>

- 变更明细 1
- 变更明细 2
```

- type: `feat` / `fix` / `refactor` / `docs` / `chore` / `perf` / `test`
- scope: 模块名
- subject: 简洁描述，中文或英文

### 8.5 推送规范

**推送前检查**：
- 当前在正确的分支？
- 所有文档已同步？
- 代码 import 验证通过？
- 无调试日志残留？（搜索 `[DEBUG]` 标签）
- 无后台任务残留？

**推送后自动检查**（7 项，每次 push 必须执行）：

```
git push 完成
  │
  ├─ 1. ✅/❌ 文档同步（README/progress/requirements/kiro-log）
  ├─ 2. ✅/❌ .kiro/ 变更已提交
  ├─ 3. ✅/❌ kiro-agents 是否需要同步
  ├─ 4. ✅/❌ conversation-context 已更新
  ├─ 5. ✅/❌ todo.md 状态最新
  ├─ 6. ✅/❌ code-fix-experience 是否需要新增（如果本次有 bug 修复）
  └─ 7. ✅/❌ self-evolving-rules 是否需要新增
```

**技术保障**：
- `pre-push hook`：push 时自动检查文档同步、.kiro/ 未提交变更
- 禁止 `--no-verify` 跳过 hook，除非用户明确说"跳过检查"

### 8.6 失败模式学习

commit-conventions.md 中维护一张失败模式表，从实际违规中学习：

```markdown
- **F-001** [提交] 连续多 commit 漏文档：快速迭代时最容易忘
- **F-002** [提交] agent 文件忘记 git add
- **F-003** [同步] kiro-agents 忘记同步
- **F-004** [提交] "小改动不需要更新文档"的错觉
- **F-005** [推送] 自行使用 --no-verify 跳过 hook
```

**核心理念**：每次违规都会被记录为失败模式，下次 AI 加载 steering 时自动看到，形成"越犯错越规范"的正循环。

---

## 九、自我演进机制

### 9.1 两个维度

| 维度 | 沉淀到 | 核心问题 |
|------|--------|----------|
| 意图理解（What）| executor.md | 用户说了什么 → AI 理解对了吗？ |
| 执行方法（How）| self-evolving-rules.md | 怎么做 → 踩了什么坑？ |

### 9.2 被动演进（每次踩坑后）

1. 用户纠正 AI 理解 → 追加到 executor.md 纠错记录
2. 发现隐性限制/踩坑 → 提炼为规则追加到 self-evolving-rules.md
3. 判断通用 or 项目专属 → 写入对应层级（系统级 or 项目级）
4. 如果是 bug 修复 → 同时记录到 code-fix-experience.md

### 9.3 主动演进（定期执行）

当用户说"自我演进"时，执行完整审视流程：

```
1. 意图理解演进（executor.md）
   - 回顾本轮对话所有用户指令，检查理解偏差
   - 高频指令模式固化到映射表

2. 执行方法演进（self-evolving-rules.md）
   - 回顾本轮踩坑/修复/决策，提取可复用规则
   - 检查已有规则是否需要更新
   - 项目规则的通用部分上提到系统级

3. 代码审查演进（code-review.md / commit-conventions.md）
   - 本轮是否有新检查项需加入 review checklist
   - 是否有新失败模式需记录（F-xxx）
   - 模块→文档映射表是否需要更新

4. 文档一致性
   - 全量对比 docs/ 与代码现状
   - 检查 .kiro/ 是否有未提交变更

5. 跨项目审视
   - 系统级 ~/.kiro/steering/ 是否需要同步
   - project-specs-index.md 是否需要更新

输出：新增/更新的规则列表 + 文档变更列表 + 待确认项
```

### 9.4 演进频率建议

| 时机 | 触发 |
|------|------|
| 每次修 bug 后 | 自动检查是否有可提取规则 |
| 每次对话结束时 | 结束对话流程中第 4 步"规则检查" |
| 用户主动说"自我演进" | 执行完整 5 步审视 |
| 规则达到新里程碑（30/50/100 条）| 更新 quick-reference |

---

## 十、系统级与项目级 steering 管理

### 10.1 分层架构

```
~/.kiro/steering/              ← 系统级（跨项目通用）
├── self-evolving-rules.md         ← 通用经验规则
├── executor.md                    ← 通用指令映射
├── dev-guidelines.md              ← 通用开发规范
├── data-collection-workflow.md    ← 数据采集工程模板
├── ui-component-workflow.md       ← UI 组件开发模板
├── project-specs-index.md         ← 项目规范索引
└── kiro-usage.md                  ← 通用 CLI 使用规范

项目/.kiro/steering/           ← 项目级（项目专属）
├── self-evolving-rules.md         ← 项目专属规则
├── executor.md                    ← 继承系统级 + 项目专属映射
├── dev-guidelines.md              ← 项目技术栈 + 专属规范
├── commit-conventions.md          ← 项目提交规范
├── code-review.md                 ← 项目审查清单
└── ...
```

### 10.2 继承与覆盖规则

- 系统级和项目级同名文件共存，项目级**补充而非替代**系统级
- 项目级 executor.md 开头声明"继承系统级"，只写项目专属映射
- 规则冲突时：项目级优先，但需在项目级文件中明确标注覆盖了哪条系统级规则

### 10.3 规则上提/下沉

| 方向 | 触发条件 | 操作 |
|------|----------|------|
| 上提（项目→系统）| 同一规则在 2+ 个项目出现 | 提取通用部分到系统级，项目级保留专属细节 |
| 下沉（系统→项目）| 系统级规则在某项目需要特化 | 项目级补充具体参数/例外 |

### 10.4 kiro-agents 同步仓库

管理所有项目的 .kiro/ 备份，实现跨设备一致：

```
kiro-agents/
├── system/                  # ~/.kiro/ 系统级文件镜像
│   └── steering/
├── projects/                # 各项目 .kiro/ 镜像
│   ├── Media-Library/
│   │   ├── steering/
│   │   ├── agents/
│   │   ├── sh/
│   │   └── docs/
│   └── ProjectB/
├── sync.sh                  # 统一双向同步脚本
└── README.md
```

**同步时机**：
- 项目 kiro-start.sh 启动时自动 pull + sync
- 每次 git push 后检查 .kiro/ 是否有变更 → 有则同步
- 对话结束时同步

**sync.sh 同步策略**：双向智能同步（基于时间戳），仅本地存在→推送，仅仓库存在→拉取，都存在→较新者胜出。

---

## 十一、写入与同步流程

### 11.1 单机模式（大多数项目）

每完成一个独立任务后：
1. **写本地**：修改 `.kiro/docs/` 对应文件
2. **git commit**：与代码变更一起提交（或独立 .kiro/ commit）

### 11.2 多机模式（可选）

每完成一个独立任务后三步：
1. **写本地**：修改 `.kiro/docs/` 对应文件
2. **同步仓库**：rsync 到 kiro-agents → git push
3. **云端同步（可选）**：写入飞书/Notion 等人可阅读的平台

三步缺一不可。git push 保证多机一致，云端保证人可阅读。

### 11.3 代码→文档映射机制

每个项目的 commit-conventions.md 中维护一张映射表：

```markdown
| 模块文件 | README 章节 | progress 章节 | requirements 章节 |
|----------|------------|--------------|-------------------|
| scraper/*.py | 数据源表 | 刮削器表 | 数据源详情 |
| utils/translator.py | 功能特性 | 翻译模块 | 翻译说明 |
| gui/*.py | 更新日志 | GUI 模块 | — |
| pipeline/*.py | 架构图 | 处理编排层 | — |
```

**作用**：代码变更时按表逐行检查需要更新哪些文档，避免遗漏。

---

## 十二、多机同步详细设计（可选）

### 12.1 架构

```
同步仓库（git，单一真相源）
├── system/steering/     # ~/.kiro/steering/ 系统级规则
└── {project}/           # 项目 .kiro/ 完整镜像
```

### 12.2 同步流程

1. **对话开启**：`git pull --rebase` → 仓库覆盖本地（仓库为准）
2. **任务完成后**：写本地 → rsync 到仓库 → git push
3. **多机冲突**：避免同时编辑，仓库最新版本为准

### 12.3 不入库的文件

- 机器本地状态文件（`.sync_state.json` 等）
- 临时队列文件

---

## 十三、新项目快速展开步骤

### 第 1 步：创建目录骨架

```bash
mkdir -p .kiro/{docs/{dialogs/archives,archives,misc},steering,agents,settings,sh}
```

### 第 2 步：创建核心文件

按优先级：

1. **P0（必须）**：
   - `steering/kiro-usage.md` — 启动流程和首要动作
   - `steering/executor.md` — 指令映射（从通用模板开始，逐步积累）
   - `steering/dev-guidelines.md` — 项目专属开发规范
   - `steering/commit-conventions.md` — 提交规范
   - `docs/conversation-context.md` — 空模板，首次对话开始记录
   - `docs/todo.md` — 空模板

2. **P1（推荐）**：
   - `steering/self-evolving-rules.md` — 空模板，首次踩坑开始记录
   - `steering/code-review.md` — 审查检查清单
   - `docs/conversation-end-reports.md` — 收尾报告模板
   - `docs/code-fix-experience.md` — 空模板，首次修 bug 开始记录
   - `sh/kiro-start.sh` — 启动脚本
   - `settings/lsp.json` — 语言服务器配置

3. **P2（按需）**：
   - `steering/quick-reference.md` — 规则超过 30 条时创建
   - `docs/dialogs/current.md` — 对话轮次记录
   - `agents/*.md` — 按项目类型选择
   - `settings/mcp.json` — 集成外部服务时

### 第 3 步：初始化内容

- 从本文档复制各文件的模板格式
- executor.md 从通用快捷命令表开始
- dev-guidelines.md 填入项目技术栈和专属规范
- 系统级 `~/.kiro/steering/` 的通用规则自动生效

### 第 4 步：持续演进

- 每次踩坑提炼规则到 self-evolving-rules
- 每次修 bug 记录到 code-fix-experience
- 每次对话结束生成 end-report
- 规则超过 30 条时创建 quick-reference
- 定期执行"自我演进"全面审视

---

## 十四、经验总结

### 14.1 最有价值的设计

1. **code-fix-experience 的"排查弯路"字段**：记录"试过但没用"的方案是避免重复踩坑的核心价值
2. **self-evolving-rules 的持续积累**：对话中的每次纠错都会转化为持久化规则
3. **quick-reference 速查卡**：规则多了以后必须有精选版，否则全量加载太重
4. **executor.md 的纠错记录**：用户纠正 AI 理解偏差时立即记录，下次不再犯
5. **三层上下文粒度**：context（事件）+ end-reports（会话）+ dialogs（对话轮次）

### 14.2 常见陷阱

1. **文档与代码脱节**：必须在每个 commit 中同步更新文档，不允许"先提交再补"
2. **规则只写不读**：积累了 100+ 条规则但 AI 每次都加载全量 → 必须有 quick-reference
3. **归档不及时**：context/kiro-log 膨胀到数千行，AI 上下文窗口被占满 → 启动时自动检查
4. **多入口逻辑重复**：CLI + GUI + 其他入口各自实现同一逻辑 → 抽到共享模块
5. **gui_state 互相覆盖**：多处保存状态文件时整体写入 → 必须 merge 模式
6. **`--no-verify` 滥用**：跳过 pre-push hook 导致文档未同步 → 必须用户明确确认
7. **模块级变量早求值**：依赖运行时配置的变量在 import 时就求值了 → 改延迟求值

### 14.3 项目规模与 .kiro 复杂度对应

| 项目规模 | 建议配置 | 参考 |
|----------|----------|------|
| 个人小项目 | P0 文件即可 | 5-6 个文件 |
| 中型项目 | P0 + P1 | ~12 个文件（如 Media-Library） |
| 大型团队项目 | P0 + P1 + P2 + 多机同步 + doc-sync agent | 20+ 个文件（如 miuix） |
| 多项目管理 | 系统级 `~/.kiro/steering/` 统一规则 + 各项目专属 | project-specs-index.md 索引 |
