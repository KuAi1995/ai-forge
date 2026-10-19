# Kiro 对话日志（ai-forge）

> 与 Kiro 的对话记录。每次对话开始先读最近 3 个日期条目恢复上下文。
> 标签：`[决策]` `[问题]` `[待办]` `[已解决]`
> 超过 1000 行归档到 `docs/archive/kiro-log-{YYYYMMDD}.md`。

---

### 2026-10-19 20:55

- [决策] 启动脚本 `kiro-start.sh` 默认模型设为 `claude-opus-4.6`。
- [决策] 参考 Media-Library 成熟 .kiro 实践优化本项目配置，原则是**裁剪而非照搬**：
  - 新增 project 级 steering：`kiro-usage.md`、`commit-conventions.md`、`code-review.md`
  - `code-review.md` 全部检查项改写为 AI 场景（GPU 显存/模型缓存/量化基准/推理参数/API 成本），不保留 Media-Library 的 NFO/刮削/水印/云盘项
  - `commit-conventions.md` 模块→文档映射表改为 AI 五阶段模块
  - 启动脚本增加上下文恢复 PROMPT
  - 初始化 `docs/`：progress.md、kiro-log.md、requirements.md
- [待办] 后续开始阶段一时，补全 `configs/config.example.yaml` 与 API 客户端骨架。

### 2026-10-19 21:05

- [决策] 补齐通用机制：新增 `scripts/pre-push.sh` 并安装为 `.git/hooks/pre-push`，作为文档同步最后防线。
  - 裁剪 Media-Library 版：去掉数据库/db_images/云盘专属检查，保留文档同步/.kiro 未提交/敏感文件/kiro-agents 自动同步，新增 AI 专属项（模型权重误入库、notebook 未清输出）。
- [决策] 复制通用 `README-sync.md` 到 `.kiro/sh/`，在 `commit-conventions.md` 补充"技术保障（pre-push hook）"章节。
- [已解决] 确认 kiro-agents sync.sh 已注册 ai-forge。
