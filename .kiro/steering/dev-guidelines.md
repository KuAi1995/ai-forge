---
inclusion: auto
---
# ai-forge 开发规范

## 项目定位
AI 全链路学习与实践项目，从 API 调用到模型训练，5 个阶段递进。

## 硬件环境
- 主力：RTX 4090 (24GB) — 量化/微调/推理/训练
- 辅助：3080 Ti 笔记本 (16GB) — 轻量推理、移动开发
- 系统：Ubuntu 26.04，CUDA 12.x

## 目录结构
```
ai-forge/
├── api/              ← 阶段一：云端 API 调用
├── serving/          ← 阶段二：本地部署
├── tools/            ← 阶段三：工具搭建
├── training/         ← 阶段四：量化与微调
├── pretrain/         ← 阶段五：自主训练
├── notebooks/        ← 交互式实验
├── configs/          ← 配置文件（gitignore）
├── docs/             ← 文档
├── models/           ← 模型文件（gitignore）
└── data/             ← 数据集（gitignore）
```

## 代码规范
- 遵循系统级 dev-guidelines.md
- 实验代码放 notebooks/，成熟后提取到对应模块
- 每个阶段的模块独立可运行，不强耦合
- 配置通过 configs/ 下的 yaml 管理，提供 example 模板
- 模型路径、API key 不硬编码

## 环境管理
- 使用 uv 管理 Python 依赖
- pyproject.toml 声明依赖，按阶段分 optional groups
- GPU 相关依赖（torch、vllm 等）单独标注安装方式

## Commit 规范
```
<type>(<scope>): <subject>
```
- scope 对应阶段模块：api / serving / tools / training / pretrain / docs
- 实验性代码用 `exp(scope):` 前缀
