---
inclusion: auto
---
# 对话收尾报告

> **用途**：每次对话结束时生成结构化收尾报告，确保每次对话闭环。
> **格式**：四段式——完成事项 / 规则变更 / 文档同步状态 / 遗留事项
> **写入时机**：对话结束时（用户说"结束对话/收工"触发）
> **归档**：同一天多次对话合并为一个日期章节。超过 30 天 → `.kiro/docs/archives/end-reports-{YYYY-MM}.md`

## 报告模板

```markdown
### YYYY-MM-DD HH:MM

#### 完成事项
- [ 具体完成的功能/修复/变更 ]

#### 规则变更
- [ 新增/更新的 self-evolving-rules 条目，或"无" ]

#### 文档同步状态
- README.md: ✅/❌
- docs/progress.md: ✅/❌
- docs/requirements.md: ✅/❌
- docs/kiro-log.md: ✅/❌
- .kiro/ 变更: ✅/❌
- kiro-agents 同步: ✅/❌

#### 遗留事项
- [ 未完成的任务、待跟进的问题，或"无" ]
```

---
