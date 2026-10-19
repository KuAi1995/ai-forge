# 需求与约束（ai-forge）

> 跟踪需求状态、配置项、模型与硬件约束。

## 硬件约束

| GPU | 显存 | 角色 | 用途 |
|-----|------|------|------|
| RTX 4090 | 24GB | 主力 | 量化/微调/推理/训练/serving |
| 3080 Ti（笔记本） | 16GB | 辅助 | 轻量推理、移动开发、远程连接 4090 |
| RX 6800 XT | 16GB | 不参与 AI | ROCm 生态差 |

- 系统：Ubuntu 26.04，CUDA 12.x
- Python 环境管理：uv

### 4090 模型运行能力

| 模型规模 | 精度 | 能否运行 |
|----------|------|----------|
| 7B | FP16 | ✅ 流畅 |
| 14B | FP16 | ⚠️ 勉强 |
| 7B | Q4 | ✅ 快速 |
| 14B | Q4 | ✅ 流畅 |
| 70B | Q4 | ⚠️ 刚好塞下，推理较慢 |

## 配置项

> 所有配置集中在 `configs/`，提供 `config.example.yaml` 模板。
> 敏感信息（API key / token / wandb key）不入库，路径不硬编码。

| 配置项 | 说明 | 状态 |
|--------|------|------|
| （待阶段一补全） | API key、模型路径等 | ⬜ |

## 需求状态

> 格式：⬜ 待定 / 🔄 进行中 / ✅ 已实现

### 阶段一 · 云端 API 调用
- ⬜ 多模型统一调用接口（OpenAI/Claude/Gemini/国内模型）
- ⬜ prompt 模板管理
- ⬜ 多模型对比工具（同 prompt 对比效果与成本）
- ⬜ 流式响应处理
- ⬜ function calling / tool use
- ⬜ token 计算与成本控制

### 阶段二 · 本地部署与 Serving
- ⬜ Ollama 快速体验
- ⬜ transformers + accelerate 手动加载
- ⬜ vLLM OpenAI 兼容 API
- ⬜ 局域网访问（0.0.0.0）
- ⬜ 公网访问（frp / Cloudflare Tunnel，带鉴权）

### 阶段三 · AI 工具搭建
- ⬜ 代码助手、图片生成、文本工具、RAG、MCP 服务

### 阶段四 · 量化与微调
- ⬜ 量化（bitsandbytes/GPTQ/AWQ/GGUF）+ 精度速度基准
- ⬜ 微调（QLoRA+unsloth / LoRA+PEFT）
- ⬜ 评估体系（lm-eval 等）

### 阶段五 · 自主训练
- ⬜ nanoGPT 从零训练
- ⬜ LLaMA 架构复现（100M-1B）
- ⬜ 分布式训练（DeepSpeed/FSDP）

## 模型清单

> 本地下载的模型记录在此（文件存 `models/`，不入库）。

| 模型 | 规模 | 精度/格式 | 用途 | 状态 |
|------|------|-----------|------|------|
| （待补充） | | | | |
