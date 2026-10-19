# 项目进度（ai-forge）

> AI 全链路学习项目，五阶段递进。本文件跟踪各阶段模块状态与待办。

## 阶段总览

| 阶段 | 目标 | 状态 |
|------|------|------|
| 阶段一 · 云端 API 调用 | 掌握大模型 API 调用范式 | ⬜ 未开始 |
| 阶段二 · 本地部署与 Serving | 4090 部署本地模型，提供 API | ⬜ 未开始 |
| 阶段三 · AI 工具搭建 | 代码助手/图片生成/RAG/MCP | ⬜ 未开始 |
| 阶段四 · 量化与微调 | 模型压缩与定制化训练 | ⬜ 未开始 |
| 阶段五 · 自主训练 | 从零训练 transformer | ⬜ 未开始 |

状态图例：⬜ 未开始 / 🔄 进行中 / ✅ 完成

## 阶段一 · 云端 API 调用

| 模块 | 目录 | 状态 | 说明 |
|------|------|------|------|
| API 客户端 | `api/clients/` | ⬜ | 各厂商 SDK 封装 |
| prompt 管理 | `api/prompts/` | ⬜ | prompt 模板系统 |
| 多步编排 | `api/chains/` | ⬜ | 多步调用链 |
| function calling 工具 | `api/tools/` | ⬜ | 工具定义 |

## 阶段二 · 本地部署与 Serving

| 模块 | 目录 | 状态 | 说明 |
|------|------|------|------|
| 本地推理 | `serving/local/` | ⬜ | Ollama/transformers/llama.cpp |
| API server | `serving/api_server/` | ⬜ | vLLM OpenAI 兼容 API |
| 反向代理 | `serving/proxy/` | ⬜ | nginx/frp 内网穿透 |
| 容器化 | `serving/docker/` | ⬜ | docker-compose 部署 |

## 阶段三 · AI 工具搭建

| 模块 | 目录 | 状态 | 说明 |
|------|------|------|------|
| 代码助手 | `tools/code_agent/` | ⬜ | 终端集成代码助手 |
| 图片生成 | `tools/image_gen/` | ⬜ | SD/FLUX |
| 文本工具 | `tools/text_tools/` | ⬜ | 翻译/摘要/改写 |
| RAG | `tools/rag/` | ⬜ | 本地知识库检索 |
| MCP 服务 | `tools/mcp/` | ⬜ | MCP 协议工具服务 |

## 阶段四 · 量化与微调

| 模块 | 目录 | 状态 | 说明 |
|------|------|------|------|
| 量化 | `training/quantization/` | ⬜ | GPTQ/AWQ/GGUF |
| 微调 | `training/finetune/` | ⬜ | LoRA/QLoRA |
| 数据集 | `training/datasets/` | ⬜ | 准备与清洗 |
| 评估 | `training/evaluation/` | ⬜ | 精度/速度基准 |

## 阶段五 · 自主训练

| 模块 | 目录 | 状态 | 说明 |
|------|------|------|------|
| 端侧小模型 | `pretrain/small_models/` | ⬜ | <1B 从零训练 |
| 大模型训练 | `pretrain/large_models/` | ⬜ | 分布式 |
| 分词器 | `pretrain/tokenizer/` | ⬜ | 分词器训练 |
| 数据管线 | `pretrain/data_pipeline/` | ⬜ | 大规模数据处理 |
| 训练基础设施 | `pretrain/infra/` | ⬜ | DeepSpeed/FSDP |

## 已知问题

<!-- 格式：[状态] 描述 -->
暂无。

## 下一步优先级

1. 搭建阶段一 API 客户端骨架与配置模板
