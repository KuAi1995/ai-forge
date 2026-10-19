# AI Forge

AI 全链路学习与实践项目。从云端 API 调用到本地部署、工具搭建、模型量化微调，直至自主训练，由浅入深覆盖 AI 工程全栈技能。

## 硬件环境

| GPU | 显存 | 角色 | 适用场景 |
|-----|------|------|----------|
| RTX 4090 | 24GB | 主力 | 量化/微调/推理/训练/serving |
| 3080 Ti (笔记本) | 16GB | 辅助 | 轻量推理、移动开发、远程连接 4090 |
| RX 6800 XT | 16GB | 不参与 AI | ROCm 生态差，AI 工作全交 NVIDIA |

- 系统：Ubuntu 26.04
- CUDA：12.x
- Python 环境管理：uv

## 项目结构

```
ai-forge/
├── api/                  ← 阶段一：云端 API 调用
│   ├── clients/          ← 各厂商 SDK 封装
│   ├── prompts/          ← prompt 模板管理
│   ├── chains/           ← 多步调用编排
│   └── tools/            ← function calling 工具定义
├── serving/              ← 阶段二：本地部署与 serving
│   ├── local/            ← 本地推理（transformers、llama.cpp、Ollama）
│   ├── api_server/       ← OpenAI 兼容 API（vLLM / FastAPI）
│   ├── proxy/            ← 反向代理（nginx、frp 内网穿透）
│   └── docker/           ← 容器化部署
├── tools/                ← 阶段三：AI 工具搭建
│   ├── code_agent/       ← 代码助手（终端集成，类 codex-cli）
│   ├── image_gen/        ← 图片生成（Stable Diffusion / FLUX）
│   ├── text_tools/       ← 翻译、摘要、改写等文本工具
│   ├── rag/              ← 检索增强生成
│   └── mcp/              ← MCP 协议工具服务
├── training/             ← 阶段四：模型量化与微调
│   ├── quantization/     ← 量化实验（GPTQ、AWQ、GGUF）
│   ├── finetune/         ← 微调（LoRA、QLoRA）
│   ├── datasets/         ← 数据集准备与清洗
│   ├── evaluation/       ← 精度评估、速度基准
│   └── notebooks/        ← 实验记录
├── pretrain/             ← 阶段五：自主训练
│   ├── small_models/     ← 端侧小模型（<1B，从零训练）
│   ├── large_models/     ← 大模型训练（分布式）
│   ├── tokenizer/        ← 分词器训练
│   ├── data_pipeline/    ← 大规模数据处理
│   └── infra/            ← 训练基础设施（DeepSpeed / FSDP）
├── notebooks/            ← 各阶段交互式实验
├── configs/              ← 统一配置（API key、模型路径等）
├── docs/                 ← 学习笔记与架构文档
├── models/               ← 模型文件存放（gitignore）
├── data/                 ← 数据集存放（gitignore）
└── .kiro/                ← Kiro CLI 配置
```

## 阶段路线

### 阶段一：云端 API 调用

目标：熟练掌握大模型 API 的调用范式和工程技巧。

核心技能：
- prompt engineering（few-shot、chain-of-thought、结构化输出）
- 多模型调度与 fallback（OpenAI、Claude、Gemini、国内模型）
- 流式响应处理
- function calling / tool use
- token 计算与成本控制

实践项目：
- 多模型对比工具：同一 prompt 发给不同模型，对比效果与成本
- prompt 模板管理系统

技术栈：
- `openai` / `anthropic` / `google-genai` SDK
- httpx（自定义 HTTP 调用）
- Pydantic（结构化输出验证）

### 阶段二：本地部署与 Serving

目标：在 4090 上部署本地模型，提供局域网/公网可访问的 API 服务。

推进路线：
1. **Ollama** 快速体验 → 理解本地推理基本流程
2. **transformers + accelerate** 手动加载 → 理解模型加载、显存管理、推理参数
3. **vLLM** 搭建 OpenAI 兼容 API → 生产级 serving（PagedAttention、连续批处理）
4. **局域网访问**：绑定 `0.0.0.0`，笔记本通过 SSH 或直接 HTTP 调用
5. **公网访问**：frp 内网穿透 或 Cloudflare Tunnel

4090 能力参考：
| 模型 | 精度 | 能否运行 |
|------|------|----------|
| 7B | FP16 | ✅ 流畅 |
| 14B | FP16 | ⚠️ 勉强 |
| 7B | Q4 | ✅ 快速 |
| 14B | Q4 | ✅ 流畅 |
| 70B | Q4 | ⚠️ 刚好塞下，推理较慢 |

技术栈：
- Ollama / vLLM / TGI
- transformers + accelerate
- llama.cpp（GGUF 格式推理）
- FastAPI（自定义 API 封装）
- frp / Cloudflare Tunnel（公网暴露）
- Docker + docker-compose

### 阶段三：AI 工具搭建

目标：基于阶段一二的基础，搭建实用的 AI 工具。

工具清单：
- **代码助手**：终端集成的代码生成/补全工具，类似 codex-cli
- **图片生成**：Stable Diffusion / FLUX，ComfyUI 工作流 + diffusers 代码调用
- **文本工具**：翻译、摘要、改写、格式转换
- **RAG 系统**：本地知识库检索增强生成
- **MCP 服务**：Model Context Protocol 工具服务，供其他 agent 调用

技术栈：
- diffusers / ComfyUI（图片生成）
- chromadb / faiss（向量检索）
- MCP SDK
- Rich / Textual（终端 UI）

### 阶段四：模型量化与微调

目标：掌握模型压缩和定制化训练能力。

量化路线：
1. **bitsandbytes** 4/8bit 加载 → 最简单，直接在 transformers 里用
2. **GPTQ 量化** → 理解 PTQ（训练后量化）原理
3. **AWQ 量化** → 激活感知量化，效果更好
4. **GGUF 导出** → 给 llama.cpp 用，CPU/混合推理

微调路线：
1. **QLoRA + unsloth** → 显存友好，4090 单卡微调 7B
2. **LoRA + PEFT** → 标准微调流程
3. **全量微调（小模型）** → 理解完整训练流程

关键技能：
- 数据集构建（比模型选择更重要）
- 评估体系设计（loss 之外的实际效果评估）
- 超参调优

技术栈：
- bitsandbytes / auto-gptq / autoawq
- llama.cpp（GGUF 转换）
- peft / unsloth / trl
- wandb（训练可视化）
- lm-evaluation-harness（标准评估）

### 阶段五：自主训练模型

目标：从零训练模型，理解 transformer 全流程。

端侧小模型（<1B）：
1. **nanoGPT** 从零训练 → 理解 GPT 架构、训练循环、数据加载
2. **LLaMA 架构复现** → 用自定义数据训练 100M-1B 模型
3. 导出为 GGUF → 部署到手机/嵌入式设备

大模型训练（需多卡/云端）：
1. **DeepSpeed ZeRO** → 分布式训练基础
2. **FSDP**（PyTorch 原生）→ 更简洁的分布式方案
3. 云端 GPU 按需租用（AutoDL / AWS）

技术栈：
- nanoGPT
- DeepSpeed / PyTorch FSDP
- datasets（HuggingFace 数据加载）
- tokenizers（分词器训练）
- wandb（训练监控）

## 开发环境

| 工具 | 用途 |
|------|------|
| VS Code + Remote SSH | 主力 IDE，笔记本远程连 4090 |
| Jupyter Lab | 交互式实验，特别是阶段四五 |
| Kiro CLI | 辅助编码和项目管理 |
| uv | Python 环境管理 |
| Docker | 部署标准化 |
| wandb | 训练过程可视化 |
| git | 版本管理 |

## 配置管理

- API key 等敏感信息存放在 `configs/` 下，不提交到 git
- 模型文件存放在 `models/`，不提交到 git
- 数据集存放在 `data/`，不提交到 git
- 提供 `configs/config.example.yaml` 配置模板

## 学习资源

后续随学习推进补充。
