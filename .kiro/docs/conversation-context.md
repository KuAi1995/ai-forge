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
