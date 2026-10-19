# AI 碎片化学习指南

> 设备受限（手机/平板/公司电脑）或时间碎片化时的学习策略。
> 核心原则：碎片时间做**输入**（读/看/听），连续时间做**输出**（写代码/跑实验）。

---

## 一、按设备分场景

### 手机 / 平板（随时随地）

#### 阅读

| 资源 | 地址 | 说明 |
|------|------|------|
| HuggingFace 博客 | huggingface.co/blog | transformer 架构、量化原理、微调方法，图文质量高 |
| Lilian Weng 博客 | lilianweng.github.io | 系统性技术综述，适合建立全局认知 |
| Papers With Code | paperswithcode.com | 看趋势和方法对比，读摘要和结果表即可 |
| 微信公众号 | 机器之心 / 量子位 / 夕小瑶的卖萌屋 | 中文快讯和技术解读 |
| Anthropic 研究博客 | anthropic.com/research | Claude 背后的技术思考，interpretability 系列 |
| OpenAI 博客 | openai.com/blog | 产品和研究发布，了解前沿方向 |

#### 视频

| 资源 | 说明 | 对应阶段 |
|------|------|----------|
| 3Blue1Brown — Neural Networks | 直觉建立，数学可视化 | 通用基础 |
| Andrej Karpathy — nn-zero-to-hero | 从零构建 GPT，代码级讲解 | 阶段五 |
| 李沐 — 读论文系列 | 经典论文精读，中文讲解 | 通用 |
| StatQuest | 统计和 ML 基础，风格轻松 | 通用基础 |
| Yannic Kilcher | 最新论文速读 | 跟踪前沿 |

#### 播客 / 音频（通勤/走路）

| 资源 | 说明 |
|------|------|
| Latent Space Podcast | AI 工程实践，嘉宾质量高 |
| Gradient Dissent (W&B) | 训练实践和工具 |
| Lex Fridman Podcast（AI 相关集） | 深度访谈，适合长途 |

### 公司电脑（能上网，不方便访问个人仓库）

#### 在线练习环境

| 平台 | GPU | 说明 |
|------|-----|------|
| Google Colab | T4 免费 / A100 付费 | 用 Google 账号登录即跑，不碰个人仓库 |
| Kaggle Notebooks | T4×2 免费（30h/周） | 社区示例丰富，fork 后改着玩 |
| HuggingFace Spaces | 视项目 | 在线体验各种模型效果，理解参数影响 |
| Lightning AI Studios | 免费额度 | 完整开发环境，含 GPU |

#### 可以做的事

- **阶段一**：Colab 跑 API 调用实验（OpenAI / Gemini 有免费额度）
- **阶段二**：Kaggle 跑 transformers 模型加载、推理参数对比
- **阶段四**：Kaggle 跑 bitsandbytes 量化、小模型 QLoRA 微调
- **阶段五**：Colab 跑 nanoGPT 训练小实验

#### 不适合做的事

- 涉及个人 API key 的长期实验（用完即删，不保存 key）
- 大模型下载（受网络和存储限制）
- 需要 4090 完整显存的实验（等回家用主力机）

---

## 二、按可用时间分策略

| 可用时间 | 推荐活动 | 示例 |
|----------|----------|------|
| **5 分钟** | 刷一篇摘要 / 看一个 API 参数文档 | HF 博客标题扫读、OpenAI API 某个参数的文档 |
| **15 分钟** | 读一篇技术文章 / 看半个教学视频 | Lilian Weng 一个章节、Karpathy 视频一段 |
| **30 分钟** | Colab 跑一个小实验 / 读论文方法+结果 | API 调用对比、attention 可视化 |
| **1 小时** | 完整跟一个教程 / Kaggle 做对比实验 | 量化方案对比、prompt 工程实验 |
| **2+ 小时** | 回家用 4090 做完整实验 | vLLM serving、QLoRA 微调、nanoGPT 训练 |

---

## 三、按学习阶段对应资源

### 阶段一 · 云端 API 调用

| 主题 | 碎片资源 | 实操平台 |
|------|----------|----------|
| prompt engineering | OpenAI 官方 prompt guide、Anthropic prompt library | Colab |
| 多模型差异 | 各厂商 API 文档对比阅读 | Colab |
| function calling | OpenAI cookbook（GitHub） | Colab |
| 结构化输出 | Pydantic + instructor 库文档 | Colab |

### 阶段二 · 本地部署

| 主题 | 碎片资源 | 实操平台 |
|------|----------|----------|
| transformers 架构 | HF 文档 + 3B1B 视频 | Kaggle |
| 显存管理 | accelerate 文档、device_map 解释文章 | Kaggle |
| vLLM | vLLM 官方文档 + 博客 | 回家实操 |
| 量化推理 | llama.cpp wiki | 回家实操 |

### 阶段四 · 量化与微调

| 主题 | 碎片资源 | 实操平台 |
|------|----------|----------|
| 量化原理 | HF 博客 quantization 系列、Tim Dettmers 博客 | Kaggle（小模型） |
| LoRA/QLoRA | 原论文 + HF PEFT 文档 | Kaggle（小模型） |
| 数据集构建 | Alpaca/ShareGPT 格式文档、数据清洗最佳实践 | 本地整理 |
| 评估 | lm-evaluation-harness 文档 | 回家实操 |

### 阶段五 · 自主训练

| 主题 | 碎片资源 | 实操平台 |
|------|----------|----------|
| GPT 架构 | Karpathy nn-zero-to-hero 全系列 | Colab（nanoGPT） |
| tokenizer | HF tokenizers 文档、BPE 原理文章 | Colab |
| 训练技巧 | 李沐读 GPT/LLaMA/Chinchilla 论文 | — |
| 分布式 | DeepSpeed 文档、FSDP tutorial | 回家/云端 |

---

## 四、知识同步回项目

碎片学习的产出最终要回流到 ai-forge，形成闭环：

1. **随手记**：手机备忘录 / 笔记 app，格式：`一句话总结 + 关键参数/数值 + 来源链接`
2. **回家整理**：
   - 实验性发现 → `notebooks/` 对应阶段目录
   - 学习笔记 → `docs/` 或 `.kiro/docs/misc/`
   - 关键决策 → `docs/kiro-log.md`
   - 踩坑经验 → `.kiro/steering/self-evolving-rules.md`
3. **周期复盘**：每周回顾碎片笔记，合并到项目文档，更新 todo.md 进度

---

## 五、推荐学习路径（碎片优先）

按 ai-forge 五阶段顺序，标注哪些适合碎片时间先行学习：

```
阶段一：
  📱 先读 → OpenAI/Anthropic API 文档、prompt guide
  💻 再做 → Colab 跑通各厂商 API、对比实验
  🖥️ 最后 → 回家搭统一接口、写入项目

阶段二：
  📱 先读 → transformers 文档、显存管理文章、vLLM 博客
  💻 再做 → Kaggle 加载小模型体验
  🖥️ 最后 → 4090 部署 vLLM、搭 serving

阶段四：
  📱 先读 → 量化原理（Tim Dettmers）、LoRA 论文、PEFT 文档
  💻 再做 → Kaggle 小模型量化/微调
  🖥️ 最后 → 4090 跑完整量化对比、QLoRA 微调

阶段五：
  📱 先看 → Karpathy 全系列视频（最重要的碎片投入）
  💻 再做 → Colab 跑 nanoGPT
  🖥️ 最后 → 4090 训练自定义模型
```

> 📱 = 手机/平板　💻 = 公司电脑/Colab/Kaggle　🖥️ = 回家用 4090
