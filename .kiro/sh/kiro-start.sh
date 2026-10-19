#!/bin/bash
# ai-forge Kiro CLI 启动脚本

cd "$(dirname "$0")/../.." || exit 1
PROJECT_ROOT=$(pwd)

echo "🔥 AI Forge 启动..."

# ── 同步 kiro 配置 ──────────────────────────────
KIRO_AGENTS="$HOME/Project/Python/kiro-agents"
if [ -f "$KIRO_AGENTS/sync.sh" ]; then
    echo "📦 同步 .kiro 配置..."
    bash "$KIRO_AGENTS/sync.sh" --project=ai-forge 2>/dev/null | grep -E '(📤|📥|🆕|✅)' | head -5
fi

# ── 环境检查 ─────────────────────────────────────
echo ""
echo "🖥️  环境检查："
if command -v nvidia-smi &>/dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
    echo "   GPU: $GPU_INFO MB"
else
    echo "   ⚠️  nvidia-smi 不可用"
fi

if command -v python3 &>/dev/null; then
    PY_VER=$(python3 --version 2>&1)
    echo "   Python: $PY_VER"
fi

if command -v uv &>/dev/null; then
    echo "   uv: $(uv --version 2>&1)"
fi

# ── 启动 Kiro CLI ────────────────────────────────
echo ""
echo "🚀 启动 Kiro CLI..."
exec kiro-cli chat --trust-all-tools
