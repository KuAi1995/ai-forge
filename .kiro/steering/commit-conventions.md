---
inclusion: auto
---
# 提交与推送规范（ai-forge）

每次 git commit 和 push 前，必须执行以下检查清单。

## 提交前检查

### 1. 原子性
- [ ] 本次 commit 只做一件事（一个功能/一个实验/一个 bugfix）
- [ ] 多个独立功能必须分开提交，不合并
- [ ] 实验性代码用 `exp(scope):` 前缀，与正式功能区分

### 2. Commit Message
- [ ] 格式：`<type>(<scope>): <subject>`
- [ ] type: feat / fix / refactor / docs / chore / perf / test / exp
- [ ] scope: 阶段模块名（api / serving / tools / training / pretrain / docs）
- [ ] subject 简洁明确，中文描述

### 3. 文档同步（每次 commit 必须包含）
- [ ] [`README.md`](../../README.md) — 阶段路线、技术栈、项目结构（如有变更）
- [ ] [`docs/progress.md`](../../docs/progress.md) — 阶段进度、模块状态、已知问题
- [ ] [`docs/requirements.md`](../../docs/requirements.md) — 需求状态、配置项、模型/硬件约束
- [ ] [`docs/kiro-log.md`](../../docs/kiro-log.md) — 本次决策和变更记录
- [ ] **全量对比**：不只看本次变更，逐个文档检查整体内容是否与代码现状一致（目录结构、配置项、模型清单等）
- [ ] 检查 [`.kiro/steering/self-evolving-rules.md`](self-evolving-rules.md) 是否需要新增/更新规则

### 4. 文件检查
- [ ] 不包含 `configs/config.yaml`（真实配置）、`__pycache__/`、`.idea/`、`.ipynb_checkpoints/`
- [ ] 不包含模型文件（`models/`）、数据集（`data/`）—— 应被 .gitignore 覆盖
- [ ] 不包含敏感信息（API key、token、wandb key）
- [ ] 不包含大体积产物（量化输出、checkpoint、GGUF 文件）

### 5. 代码验证
- [ ] 修改的 Python 代码能正常 import（无语法错误）
- [ ] notebook 清理输出后再提交（避免大 diff 和敏感输出）
- [ ] 新增依赖已写入 `pyproject.toml` 对应的 optional group

## 推送前检查
- [ ] 当前在 main 分支（或正确的功能分支 `feat/xxx`）
- [ ] 所有文档已同步更新
- [ ] agent 文件变更后执行 kiro-agents `sync.sh`
- [ ] 无后台 GPU 任务残留污染（`nvidia-smi` + `ps aux | grep python` 检查）
- [ ] `.gitignore` 覆盖新增的生成文件（模型/数据/日志/checkpoint）
- [ ] 跳过检查 `git push --no-verify` **必须由用户明确确认后才能使用**，AI 不得自行决定跳过

## 技术保障（pre-push hook）
- `scripts/pre-push.sh` 安装为 `.git/hooks/pre-push`，是文档同步的最后防线
- 安装命令：`cp scripts/pre-push.sh .git/hooks/pre-push && chmod +x .git/hooks/pre-push`
- push 时自动检查：
  - 代码变更是否同步了 kiro-log/progress/requirements
  - 大体积产物（模型/权重/data）是否误入库
  - 敏感文件/真实配置是否误入库
  - `.kiro/` 是否有未提交变更
  - notebook 是否未清输出、Python 是否残留调试代码
- `.kiro/` 有变更时自动执行 kiro-agents sync
- 跳过检查 `git push --no-verify` **必须由用户明确确认后才能使用**

## ⚠️ 强制自查流程
写完代码后**必须先停下来**，逐项过检查清单，确认后再 `git add` + `git commit`。
不允许"先提交再补文档"——文档必须和代码在同一个 commit 中。

**具体执行步骤（不可跳过）：**
1. 代码写完后，**立即停止**，不要执行 git add
2. 逐个打开文档检查是否需要更新：
   - [`README.md`](../../README.md)：阶段路线/技术栈/项目结构有变化吗？
   - [`docs/kiro-log.md`](../../docs/kiro-log.md)：本次做了什么决策/踩了什么坑？记录
   - [`docs/progress.md`](../../docs/progress.md)：阶段进度/模块状态有变化吗？更新
   - [`docs/requirements.md`](../../docs/requirements.md)：需求/配置/模型约束有变化吗？更新
3. 检查 `.kiro/` 是否有未提交的变更（steering/ 和 agents/ 均检查）
4. 确认以上全部完成后，才执行 `git add` + `git commit`

**如果判断某个文档确实不需要更新，必须在对话中明确说明原因，而不是默默跳过。**

## 失败模式记录（从实际错误中学习）
<!-- 格式：F-XXX [分类] 描述。来源：日期/场景 -->
<!-- 继承自系统级通用失败模式，项目特定的在此追加 -->
- **F-001** [提交] 连续多 commit 漏文档：快速迭代时最容易忘，必须每次停下来过清单。
- **F-002** [提交] agent 文件忘记 git add：`.kiro/` 目录变更不在常规 git add 习惯中，需特别注意。
- **F-003** [同步] kiro-agents 忘记同步：agent 文件变更后必须执行 sync.sh。
- **F-004** [原子性] 多个独立功能/实验合成一个 commit。
- **F-005** [原子性] 用户说"推送"时把积攒的多个独立变更一次提交。正确做法：推送前检查暂存区，按独立功能拆分为多个 commit 后再 push。
  来源：2026-10-19 碎片化学习指南 + dialogs 同步修复合成一个 commit。

## 模块→文档映射（代码变更时按此表检查文档）

| 模块目录 | README 章节 | progress 章节 | requirements 章节 |
|----------|------------|--------------|-------------------|
| `api/clients/` | 阶段一技术栈 | 阶段一·API 客户端 | 支持的模型/厂商 |
| `api/prompts/` | 阶段一实践项目 | 阶段一·prompt 管理 | prompt 模板规范 |
| `api/chains/` | 阶段一 | 阶段一·多步编排 | — |
| `serving/local/` | 阶段二推进路线 | 阶段二·本地推理 | 模型加载方式/显存约束 |
| `serving/api_server/` | 阶段二技术栈 | 阶段二·vLLM serving | API 兼容性/端口 |
| `serving/proxy/` | 阶段二(公网访问) | 阶段二·内网穿透 | 网络暴露配置 |
| `tools/code_agent/` | 阶段三工具清单 | 阶段三·代码助手 | — |
| `tools/image_gen/` | 阶段三工具清单 | 阶段三·图片生成 | SD/FLUX 模型路径 |
| `tools/rag/` | 阶段三工具清单 | 阶段三·RAG | 向量库配置 |
| `tools/mcp/` | 阶段三工具清单 | 阶段三·MCP 服务 | — |
| `training/quantization/` | 阶段四量化路线 | 阶段四·量化 | 量化方案/精度基准 |
| `training/finetune/` | 阶段四微调路线 | 阶段四·微调 | 微调配置/数据集 |
| `training/evaluation/` | 阶段四 | 阶段四·评估 | 评估指标 |
| `pretrain/small_models/` | 阶段五端侧小模型 | 阶段五·小模型训练 | 模型架构/规模 |
| `pretrain/infra/` | 阶段五技术栈 | 阶段五·训练基础设施 | 分布式配置 |
| `configs/` | 配置管理 | — | 全部配置项 |
