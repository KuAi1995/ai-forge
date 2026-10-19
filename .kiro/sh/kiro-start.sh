#!/bin/bash
# ai-forge Kiro CLI 启动脚本
# 启动流程：
# 1. 同步 kiro-agents 配置
# 2. 环境检查（GPU / Python / uv）
# 3. 归档检查（conversation-context / kiro-log）
# 4. 对话文件日期轮转（dialogs/current.md）
# 5. Git 状态检查
# 6. 启动 Kiro CLI 并传入上下文恢复 prompt

cd "$(dirname "$0")/../.." || exit 1
PROJECT_ROOT=$(pwd)

echo "🔥 AI Forge 启动..."

# ── 1. 同步 kiro 配置 ────────────────────────────────────
KIRO_AGENTS="$HOME/Project/Python/kiro-agents"
if [ -f "$KIRO_AGENTS/sync.sh" ]; then
    echo "📦 同步 .kiro 配置..."
    bash "$KIRO_AGENTS/sync.sh" --project=ai-forge 2>/dev/null | grep -E '(📤|📥|🆕|✅)' | head -5
fi

# ── 2. 环境检查 ─────────────────────────────────────────
echo ""
echo "🖥️  环境检查："
if command -v nvidia-smi &>/dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
    echo "   GPU: $GPU_INFO MB"
else
    echo "   ⚠️  nvidia-smi 不可用"
fi
command -v python3 &>/dev/null && echo "   Python: $(python3 --version 2>&1)"
command -v uv &>/dev/null && echo "   uv: $(uv --version 2>&1)"

# ── 3. 归档检查 ─────────────────────────────────────────
echo ""
echo "📋 归档检查："
mkdir -p "$PROJECT_ROOT/.kiro/docs/archives"

CONTEXT_FILE="$PROJECT_ROOT/.kiro/docs/conversation-context.md"
if [ -f "$CONTEXT_FILE" ]; then
    CONTEXT_LINES=$(wc -l < "$CONTEXT_FILE")
    if [ "$CONTEXT_LINES" -gt 500 ]; then
        echo "   ⚠️  conversation-context.md 超过 500 行（${CONTEXT_LINES} 行），需归档"
    else
        echo "   ✅ conversation-context.md: ${CONTEXT_LINES} 行"
    fi
fi

KIRO_LOG="$PROJECT_ROOT/docs/kiro-log.md"
if [ -f "$KIRO_LOG" ]; then
    LOG_LINES=$(wc -l < "$KIRO_LOG")
    if [ "$LOG_LINES" -gt 1000 ]; then
        echo "   ⚠️  kiro-log.md 超过 1000 行（${LOG_LINES} 行），需归档"
    else
        echo "   ✅ kiro-log.md: ${LOG_LINES} 行"
    fi
fi

# ── 4. 对话文件日期轮转 ──────────────────────────────────
echo ""
echo "📝 对话文件轮转："
DIALOGS_DIR="$PROJECT_ROOT/.kiro/docs/dialogs"
CURRENT_MD="$DIALOGS_DIR/current.md"
DIALOG_ARCHIVES="$DIALOGS_DIR/archives"
mkdir -p "$DIALOG_ARCHIVES"
TODAY=$(date +%Y-%m-%d)

if [ -f "$CURRENT_MD" ]; then
    FILE_DATE=$(head -1 "$CURRENT_MD" | grep -oP '\d{4}-\d{2}-\d{2}' || echo "")
    if [ -n "$FILE_DATE" ] && [ "$FILE_DATE" != "$TODAY" ]; then
        mv "$CURRENT_MD" "$DIALOG_ARCHIVES/dialog-${FILE_DATE}.md"
        echo "   📦 归档 current.md → archives/dialog-${FILE_DATE}.md"
        printf '# 对话记录 — %s\n\n## 对话轮次\n' "$TODAY" > "$CURRENT_MD"
        echo "   ✅ 已创建今日对话文件"
    else
        echo "   ✅ current.md 日期是今天，无需轮转"
    fi
else
    printf '# 对话记录 — %s\n\n## 对话轮次\n' "$TODAY" > "$CURRENT_MD"
    echo "   ✅ 已创建今日对话文件"
fi

# ── 5. Git 状态检查 ─────────────────────────────────────
echo ""
echo "🔍 Git 状态："
UNCOMMITTED=$(git status --porcelain 2>/dev/null | grep -vc '^??')
if [ "$UNCOMMITTED" -gt 0 ]; then
    echo "   ⚠️  有 ${UNCOMMITTED} 个未提交变更"
    git status --short 2>/dev/null | head -10
else
    echo "   ✅ 工作区干净"
fi
UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | wc -l)
if [ "$UNPUSHED" -gt 0 ]; then
    echo "   ⚠️  有 ${UNPUSHED} 个未推送 commit"
else
    echo "   ✅ 所有 commit 已推送"
fi

# ── 6. 启动 Kiro CLI ────────────────────────────────────
echo ""
echo "🚀 启动 Kiro CLI..."

PROMPT="开始对话恢复（按 kiro-usage.md 规则执行）：
1. 读取 .kiro/docs/conversation-context.md 最近 3 天 + docs/kiro-log.md 最近 3 个日期条目
2. 读取 .kiro/docs/todo.md 待处理列表
3. 阅读 docs/progress.md 了解当前阶段进度
4. 检查未关闭的 [问题] 和 [待办] 标签
5. 汇报上下文摘要，然后等待指令"

exec kiro-cli chat --trust-all-tools --model claude-opus-4.6 "$PROMPT"
