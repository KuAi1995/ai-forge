---
inclusion: auto
---
# 高频规则速查卡（ai-forge）

从系统级规则和 AI 项目场景精选的高频核心约束。
AI 启动时优先加载此文件，项目级规则积累到 30 条以上后从 `self-evolving-rules.md` 精选同步。

---

## GPU / 显存

- **加载模型前评估显存**：参考 README 4090 能力表，避免 OOM。启动 GPU 任务前先 `nvidia-smi`。
- **模型只加载一次并复用**：不每次请求重新加载。
- **耗时 GPU 任务后台运行**：量化/微调/训练用 `nohup ... &`，启动后立即返回对话。
- **提交前检查残留进程**：`nvidia-smi` + `ps aux | grep python`，不留后台任务污染显存。

## API 调用

- **4xx 不重试**：除 429 限流外是确定性失败。（系统级 R-001）
- **余额耗尽自动 fallback**：连续失败标记禁用，避免无效重试。（系统级 R-002）
- **幂等操作失败也写缓存**：空值，避免重复调 API。（系统级 R-003）
- **token 成本有记录**：避免无意识烧钱。

## 配置 / 路径

- **路径不硬编码**：模型路径、数据路径走配置项。（系统级 R-008）
- **敏感信息不入库**：API key / token / wandb key 从 configs 或环境变量读。
- **新增配置同步更新**：config.example.yaml + README。
- **模块级变量延迟求值**：依赖运行时配置的变量改为函数调用。（系统级 R-017）

## Git 提交

- **禁止 `--no-verify`**：除非用户在当前对话明确说"跳过检查"。（系统级 R-013）
- **功能做完立即 commit**：代码 + 文档 + kiro-log 同一个 commit，不先提交再补文档。
- **原子性**：一个 commit 只做一件事，多个独立功能/实验分开提交。
- **scope 对应阶段**：api / serving / tools / training / pretrain / docs。

## 产物管理

- **大体积产物不入库**：模型/数据/checkpoint/GGUF 写到 `models/` 或 `data/`（gitignore）。
- **notebook 提交前清输出**：避免大 diff 和敏感输出泄露。

## 量化 / 微调

- **量化前后有基准对比**：精度 + 速度，不是跑通就算完。
- **方案与用途匹配**：GGUF→llama.cpp，GPTQ/AWQ→GPU 推理。
- **微调默认 QLoRA + unsloth**：4090 单卡显存友好。

---

> 规则编号 R-xxx 中「系统级」指 `~/.kiro/steering/self-evolving-rules.md`。
> 项目专属规则沉淀到 `.kiro/steering/self-evolving-rules.md` 后在此同步高频项。
