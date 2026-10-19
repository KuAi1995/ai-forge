---
inclusion: auto
---
# ai-forge 自演进规则

项目专属的经验教训和操作规范。通用规则参见系统级 `~/.kiro/steering/self-evolving-rules.md`。

## 提取时机

对话中出现以下情况时，提取规则：
- 用户纠正了 AI 的错误操作
- 发现了 API / 工具 / 框架 / 模型的隐性限制
- 用户明确了某个操作的标准流程
- 踩坑后总结出的最佳实践
- **AI 项目特有**：
  - GPU OOM 或显存分配踩坑
  - 模型加载 / dtype / device_map 兼容性问题
  - 推理参数（temperature / top_p / max_tokens）对效果的非直觉影响
  - 量化方案与部署目标不匹配
  - 多模型 API 的隐性差异（参数名 / 限制 / 计费方式）
  - 数据集构建中发现的质量陷阱

## 提取流程

1. **识别**：对话中出现上述情况时，主动提炼为一条规则
2. **分层**：判断规则是项目专属还是跨项目通用
   - 通用 → 写入系统级 `~/.kiro/steering/self-evolving-rules.md`
   - 专属 → 写入本文件
3. **确认**：向用户简述提炼的规则，确认是否准确
4. **写入**：追加到对应分类下，编号递增
5. **同步**：规则超 30 条后，高频项同步到 `quick-reference.md`

## 格式

```
- **R-XXX** [分类] 规则内容。
  来源：触发场景 / 日期。
```

---

## 已沉淀规则

### GPU / 显存

- **R-001** [显存] 加载模型前必须评估显存占用（参考 README 4090 能力表），启动 GPU 任务前先 `nvidia-smi` 确认可用显存。盲目加载导致 OOM 需要 kill 进程并清理显存。
  来源：code-review + quick-reference 初始化提取。

- **R-002** [显存] 模型实例全局只加载一次并复用（单例 / 模块级变量），不在每次请求或函数调用中重新加载。重复加载浪费显存且耗时。
  来源：code-review 初始化提取。

- **R-003** [显存] 耗时 GPU 任务（量化 / 微调 / 训练 / serving 启动）用 `nohup ... &` 后台运行，启动后立即返回对话并告知日志路径。
  来源：executor.md 初始化提取。

- **R-004** [显存] 提交代码前检查残留 GPU 进程：`nvidia-smi` + `ps aux | grep python`，避免后台任务占用显存影响后续实验。
  来源：quick-reference 初始化提取。

### API 调用

- **R-005** [API] 多模型调用时，各厂商 API 的参数名、限制、计费方式存在隐性差异。统一封装层必须处理这些差异，不暴露给上层。
  来源：README 阶段一目标 + 行业经验初始化提取。

- **R-006** [API] token 用量和成本必须有记录或估算机制（至少日志级别），避免实验阶段无意识烧钱。
  来源：code-review 初始化提取。

- **R-007** [API] 流式响应必须正确处理分块与中断（客户端断连 / 网络超时），不能假设流总是完整到达。
  来源：code-review 初始化提取。

- **R-008** [API] 结构化输出用 Pydantic 校验，解析失败有降级方案（重试 / 回退到非结构化 / 记录原始响应），不直接抛异常丢数据。
  来源：code-review 初始化提取。

### 模型管理

- **R-009** [模型] dtype / device_map 必须显式指定，不依赖库的默认值。不同 transformers 版本的默认行为可能变化。
  来源：code-review 初始化提取。

- **R-010** [模型] 推理参数（max_model_len / gpu_memory_utilization / batch_size 等）必须在配置文件中可调，不硬编码。不同模型的最优参数差异很大。
  来源：code-review 初始化提取。

- **R-011** [模型] 模型文件、量化产物、checkpoint 只存放在 `models/` 或 `data/`（被 .gitignore 覆盖），绝不进入 git 仓库。
  来源：commit-conventions + quick-reference 初始化提取。

### 量化与微调

- **R-012** [量化] 量化前后必须有精度和速度的基准对比（perplexity / lm-eval 指标 + tokens/s），不是"跑通就算完"。
  来源：code-review 初始化提取。

- **R-013** [量化] 量化方案与部署目标必须匹配：GGUF → llama.cpp / CPU 混合推理，GPTQ / AWQ → GPU 推理（vLLM / transformers）。选错格式导致无法部署或性能差。
  来源：code-review + quick-reference 初始化提取。

- **R-014** [微调] 4090 单卡微调默认 QLoRA + unsloth，显存友好。全量微调仅用于 <1B 小模型理解训练流程。
  来源：README 阶段四 + quick-reference 初始化提取。

- **R-015** [微调] 数据集质量比模型选择更重要。微调前必须有数据清洗 / 去重 / 格式校验步骤，不直接喂原始数据。
  来源：README 阶段四初始化提取。

### Serving

- **R-016** [serving] API server 绑定 `0.0.0.0` 对外暴露时必须确认安全边界。公网暴露（frp / Cloudflare Tunnel）必须有鉴权，不裸奔。
  来源：code-review 初始化提取。

- **R-017** [serving] vLLM 等 serving 框架的推理参数（max_model_len / gpu_memory_utilization）影响显存占用和吞吐，必须按实际模型和硬件调优，不用默认值。
  来源：code-review 初始化提取。

### 训练

- **R-018** [训练] checkpoint 保存策略必须明确：保存频率 + 最大保留数量 + 磁盘空间预估。训练中断可恢复，不丢进度。
  来源：code-review 初始化提取。

- **R-019** [训练] tokenizer 与模型必须配套，词表大小一致。混用 tokenizer 导致隐性错误（生成乱码 / 性能下降）且难排查。
  来源：code-review 初始化提取。

- **R-020** [训练] 训练超参和随机种子必须记录（wandb / 配置文件），保证实验可复现。
  来源：code-review 初始化提取。

### 实验管理

- **R-021** [实验] 实验代码留在 `notebooks/`，成熟后才提取到对应阶段模块。实验性提交用 `exp(scope):` 前缀，与正式功能区分。
  来源：dev-guidelines + commit-conventions 初始化提取。

- **R-022** [实验] notebook 提交前必须清理输出（`jupyter nbconvert --clear-output`），避免大 diff 和敏感输出（API key / token / 模型权重片段）泄露。
  来源：commit-conventions + quick-reference 初始化提取。

## 失败模式记录

<!-- 格式：F-XXX [分类] 描述。来源：日期/场景 -->
<!-- 项目推进过程中从实际错误中学习，追加到此 -->
