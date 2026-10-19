---
inclusion: auto
---
# ai-forge 指令理解与执行

继承系统级 [`~/.kiro/steering/executor.md`](../../../.kiro/steering/executor.md) 通用规则，本文件补充项目专属的指令映射和快捷命令。

## 项目专属指令映射

| 用户说 | 意图 | 执行动作 |
|--------|------|----------|
| 跑一下 XX 模型 | 本地推理 | 根据模型大小选择合适的加载方式（Ollama/transformers/vLLM） |
| 量化 XX | 量化模型 | 选择合适的量化方案（GPTQ/AWQ/GGUF），后台运行 |
| 微调 XX | 微调模型 | 默认 QLoRA + unsloth，后台运行 |
| 部署 XX | 启动 serving | 默认 vLLM OpenAI 兼容 API |
| 对比 XX 和 YY | 模型对比 | 同一 prompt 发给多模型，对比效果与成本 |
| 看看显存 / 显存够吗 | GPU 状态 | `nvidia-smi`，评估目标模型是否放得下 |
| 看看配置 | 查看配置 | 读取 `configs/config.yaml` 展示关键项 |
| 自我演进 | 全面审视并提取规则 | 执行系统级 executor.md 定义的自我演进流程 |

## 上下文推断补充

- **"这个模型"** → 当前对话中最近提到的模型
- **"那个实验"** → 最近讨论的量化/微调/训练实验
- **"显存问题"** → OOM 或显存占用相关
- **"推理慢"** → serving/推理性能相关（batch/量化/dtype）

## 执行规则

### 耗时任务（后台运行）
- 模型下载、量化、微调、训练、serving 启动等，用 `nohup ... &` 后台运行
- 启动前先 `nvidia-smi` 确认显存可用，避免 OOM
- 启动后立即返回对话，告知用户日志路径

### 快速任务（前台执行）
- 单次 API 调用、配置查看、agent 同步等秒级任务，前台等待结果

### 执行前检查
- GPU 任务：先确认显存可用（`nvidia-smi`）
- API 任务：确认 `configs/config.yaml` 的 key 已填写
- 加载模型前评估显存占用（参考 README 的 4090 能力表）

## 快捷命令

以下快捷命令封装多步操作流程：

### 对话管理

| 用户说 | 执行流程 |
|--------|----------|
| 结束对话 / 收工 / 下班 | 见下方"结束对话完整流程"6 步 |
| 恢复上下文 / 继续上次 | 1. 读 `.kiro/docs/conversation-context.md` 最近 3 天<br>2. 读 `.kiro/docs/todo.md` 待处理<br>3. 读 `docs/kiro-log.md` 最近 3 个日期条目<br>4. 汇报摘要 |

### 文档与同步

| 用户说 | 执行流程 |
|--------|----------|
| 同步文档 | 按 commit-conventions 映射表全量对比 docs/ 与代码现状，逐个检查 README/progress/requirements/kiro-log |
| 检查同步 | 1. `git status`<br>2. `git log` 最近 commit 是否已 push<br>3. 文档全量对比<br>4. `.kiro/` 变更检查<br>5. kiro-agents 同步<br>6. 自我演进<br>7. 汇报每项 ✅/❌ |
| 归档 | 检查各文件是否超归档阈值 → 触发归档流程 |

### 经验沉淀

| 用户说 | 执行流程 |
|--------|----------|
| 记经验 / 沉淀 | 将当前修复/决策提取为经验条目 → 写入 `.kiro/docs/code-fix-experience.md` |
| 提规则 | 从当前对话提取规则 → 写入 `self-evolving-rules.md`（项目级或系统级） |
| 自我演进 | 执行系统级 executor.md 定义的自我演进流程 |

### 结束对话完整流程

当用户说"结束对话"/"收工"/"下班了"时，按以下 6 步执行：

1. **更新上下文**：本次工作内容追加到 `.kiro/docs/conversation-context.md`
2. **生成收尾报告**：按四段式模板追加到 `.kiro/docs/conversation-end-reports.md`
3. **更新待办**：`.kiro/docs/todo.md` 完成的标记完成、新增的追加
4. **规则/经验检查**：本次是否有可沉淀的规则（self-evolving-rules）或修复经验（code-fix-experience）
5. **提交**：`git add` + `git commit`（含所有 .kiro/ 变更）
6. **同步**：kiro-agents sync（如有 .kiro/ 变更）

### 推送后自动检查（每次 git push 后必须执行）

1. ✅/❌ 文档同步（README/progress/requirements/kiro-log）
2. ✅/❌ `.kiro/` 变更是否已提交
3. ✅/❌ kiro-agents 是否需要同步
4. ✅/❌ conversation-context 是否已更新
5. ✅/❌ todo.md 状态是否最新
6. ✅/❌ code-fix-experience 是否需要新增（如本次有 bug 修复）
7. ✅/❌ self-evolving-rules 是否需要新增

## 行为规则

- 用户同时提出多个问题/任务 → 逐个解决逐个提交，不耦合在一起
- 复杂功能或不确定的变更 → 先说方案让用户确认，不直接动手
- GPU 任务 OOM 风险 → 加载前评估显存，不盲目启动

## 纠错记录

<!-- 格式：E-XXX | 用户原话 | AI 错误理解 | 正确意图 | 日期 -->
