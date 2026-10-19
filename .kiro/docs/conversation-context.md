---
inclusion: auto
---
# 对话上下文（工作流水）

> **用途**：按日期正序记录每日工作流水，新对话开启时读取最近 3 天恢复状态。
> **格式**：`### YYYY-MM-DD` → `#### 主题` → 操作摘要 + commit hash
> **写入时机**：每完成一个独立动作后立即追加（代码提交、bug 修复、配置变更等）
> **归档**：超过 500 行 → `.kiro/docs/archives/context-{YYYY-MM}.md`
> **与其他文档**：事件维度摘要。对话明细 → `dialogs/current.md`，收尾报告 → `conversation-end-reports.md`

---

### 2026-10-19

#### .kiro 三层上下文体系移植

- 参考更新后的 Media-Library，移植完整的三层上下文管理体系到 ai-forge
- 复用项目无关文件：`docs/misc/kiro-architecture-guide.md`（854 行）、`settings/lsp.json`
- 新增 steering：`quick-reference.md`，重写 `kiro-usage.md`、增强 `executor.md`（快捷命令 + 结束对话 6 步 + 推送后 7 项检查）
- 新增 `.kiro/docs/`：conversation-context / conversation-end-reports / todo / code-fix-experience / dialogs/current
- 升级 `kiro-start.sh`：归档检查 + 对话轮转 + git 状态检查（保留 GPU 环境检查）
- 原则：裁剪而非照搬，刮削/翻译/NFO 专属内容全部改写为 AI 场景（GPU/模型/量化/推理/API）

#### 补齐通用机制（pre-push hook）

- 新增 `scripts/pre-push.sh`（裁剪 ML 版，保留通用+AI专属检查），安装为 `.git/hooks/pre-push`
- 复制 `README-sync.md` 到 `.kiro/sh/`，`commit-conventions.md` 补"技术保障"章节
- 确认 kiro-agents sync.sh 已注册 ai-forge

#### self-evolving-rules.md 初始化

- 为项目级 `self-evolving-rules.md` 建立完整规则体系
- 新增提取时机（含 AI 项目特有 6 种场景）+ 提取流程 5 步 + 格式定义
- 7 个分类框架：GPU/显存、API 调用、模型管理、量化与微调、Serving、训练、实验管理
- 从 code-review / quick-reference / README / executor 提取 22 条种子规则（R-001 ~ R-022）
- 预留失败模式记录区（F-XXX），后续从实际错误中学习

#### 学习计划建立

- 在 todo.md 中建立五阶段学习计划，共 20 个任务（T-001~T-020）
- P1 阶段一 7 项（API 调用）、P2 阶段二/三 7 项（本地部署+工具）、P3 阶段四/五 6 项（量化微调+训练）
- 明天从 T-001（配置骨架）开始

#### 碎片化学习指南

- 创建 `.kiro/docs/misc/fragmented-learning-guide.md`，覆盖设备场景 / 时间策略 / 阶段资源 / 知识同步闭环

#### dialogs/current.md 同步遗漏修复

- 补全 21:12~21:23 遗漏的 5 轮对话记录
- 新增 R-023 [对话] 实时同步规则 + F-001 失败模式
- kiro-usage.md 新增「⚠️ dialogs/current.md 实时写入」专节，含摘要 vs 明细的粒度区分示例