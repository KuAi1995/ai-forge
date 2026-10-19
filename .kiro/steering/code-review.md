---
inclusion: auto
---
# 代码审查检查清单（ai-forge）

进行代码审查或提交前检查时，遵循以下检查清单。本清单针对 AI 全链路项目（API 调用 / 本地推理 / 工具 / 量化微调 / 训练）。

## ⚠️ 功能完整性审查（新功能/重大变更必做）

功能做完后**必须停下来**，沿着完整数据流逐环节检查，不遗漏副作用。

### 流程走查
- [ ] 画出本次变更的完整数据流（输入 → 预处理 → 模型 → 后处理 → 输出），逐环节确认行为正确
- [ ] CLI 入口、API server、notebook 中的**同一逻辑**是否同步修改（容易漏改一处）
- [ ] 新增配置分支是否在所有经过的环节都正确处理，而非只改了入口

### 副作用检查
- [ ] **显存**：加载新模型/增大 batch/长 context 是否评估过显存占用？是否会 OOM？
- [ ] **模型缓存**：是否重复加载模型（应复用已加载实例，不每次请求重新加载）？
- [ ] **配置覆盖**：改动默认推理参数（temperature/max_tokens/dtype）是否影响已有调用方？
- [ ] **文件产物**：量化输出 / checkpoint / GGUF 是否写到 `models/` 或 `data/`（被 gitignore），不污染仓库？
- [ ] **后台任务**：长任务是否正确后台化？是否有残留进程占用 GPU？

## 安全合规
- [ ] 无硬编码的 API key、token、wandb key、HF token
- [ ] 敏感信息从 `configs/` 下的 yaml 或环境变量读取
- [ ] 模型路径、数据路径不硬编码个人绝对路径，走配置项
- [ ] 新增配置项同步更新：`configs/config.example.yaml` + README 配置说明

## 代码合规
- [ ] 公开函数有 docstring 和类型注解
- [ ] 无 `print`（使用 logging）
- [ ] 无裸 `except`，捕获具体异常类型
- [ ] 新增 import 已添加，无循环导入
- [ ] 函数签名变更时所有调用方已同步更新
- [ ] 实验代码留在 notebooks/，成熟后才提取到对应阶段模块

## API 调用（阶段一）
- [ ] HTTP 请求设置超时，不无限等待
- [ ] 4xx 客户端错误（除 429）不重试；5xx/429 指数退避最多 3 次
- [ ] 多模型 fallback：主模型失败自动切备选，连续失败标记禁用避免无效重试
- [ ] token 用量/成本有记录或估算（避免无意识烧钱）
- [ ] 流式响应正确处理分块与中断
- [ ] 结构化输出用 Pydantic 校验，解析失败有降级

## 本地推理与 Serving（阶段二）
- [ ] 模型只加载一次并复用，不每次请求重载
- [ ] 显存与模型/精度匹配（参考 README 的 4090 能力表），加载前评估
- [ ] dtype / device_map 显式指定，不依赖默认
- [ ] 推理参数（max_model_len、gpu_memory_utilization 等）在配置中可调
- [ ] API server 绑定地址明确（0.0.0.0 对外需确认安全边界）
- [ ] 公网暴露（frp/Cloudflare）有鉴权，不裸奔

## 量化与微调（阶段四）
- [ ] 量化前后有精度/速度基准对比（不是只跑通就算完）
- [ ] 量化方案与用途匹配（GGUF→llama.cpp，GPTQ/AWQ→GPU 推理）
- [ ] 微调默认 QLoRA + unsloth（4090 单卡显存友好）
- [ ] 数据集构建质量优先（比模型选择更重要），有清洗/去重
- [ ] 训练超参、随机种子记录可复现
- [ ] 评估不只看 loss，有实际效果评估（lm-eval 等）
- [ ] wandb 等可视化只记录指标，不上传敏感数据

## 训练（阶段五）
- [ ] checkpoint 保存策略明确（频率/保留数量），不塞满磁盘
- [ ] 分布式配置（DeepSpeed/FSDP）与硬件匹配
- [ ] 数据加载不是训练瓶颈（dataloader workers / 预处理缓存）
- [ ] 可从 checkpoint 恢复训练，中断不丢进度
- [ ] tokenizer 与模型配套，词表大小一致

## 性能审查
- [ ] GPU 利用率合理（避免数据加载/CPU 预处理拖累 GPU 空转）
- [ ] batch / 连续批处理用上（vLLM PagedAttention 等）
- [ ] 推理结果可缓存的做缓存（相同 prompt 不重复请求）
- [ ] 热路径无不必要的 CPU↔GPU 数据搬运
- [ ] 大文件/大张量操作不在主线程阻塞交互

## 环境与依赖
- [ ] 新增依赖写入 `pyproject.toml` 对应 optional group
- [ ] GPU 相关依赖（torch/vllm/bitsandbytes）标注安装方式与 CUDA 版本约束
- [ ] 用 uv 管理，不手动 pip 污染全局环境

## 提交合规
- [ ] commit message 符合 `<type>(<scope>): <subject>`，scope 对应阶段
- [ ] 不包含 `__pycache__/`、`.ipynb_checkpoints/`、模型/数据/checkpoint
- [ ] notebook 已清理输出
- [ ] 文档已按 commit-conventions.md 的模块→文档映射表同步
