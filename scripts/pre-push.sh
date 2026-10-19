#!/bin/bash
# pre-push hook: 推送前全面检查（ai-forge）
# 安装: cp scripts/pre-push.sh .git/hooks/pre-push && chmod +x .git/hooks/pre-push

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

REMOTE_HEAD=$(git rev-parse origin/main 2>/dev/null || echo "")
if [ -z "$REMOTE_HEAD" ]; then
    exit 0
fi

CHANGED=$(git diff --name-only "$REMOTE_HEAD" HEAD 2>/dev/null)
if [ -z "$CHANGED" ]; then
    exit 0
fi

WARNINGS=0
ERRORS=0

warn() { echo -e "${YELLOW}⚠ $1${NC}"; WARNINGS=$((WARNINGS + 1)); }
fail() { echo -e "${RED}✗ $1${NC}"; ERRORS=$((ERRORS + 1)); }
ok()   { echo -e "${GREEN}✓ $1${NC}"; }

echo "=== 推送前检查（ai-forge）==="

# ─── 1. 判断提交类型 ───
# 代码变更 = 不在 docs/ .kiro/ data/ models/ configs/ scripts/ 之外的变更
HAS_CODE=$(echo "$CHANGED" | grep -vE '^(docs/|\.kiro/|data/|models/|scripts/|configs/)' | head -1)

# ─── 2. 文档同步（仅代码变更时检查） ───
if [ -n "$HAS_CODE" ]; then
    for DOC in docs/kiro-log.md docs/progress.md docs/requirements.md; do
        if ! echo "$CHANGED" | grep -q "^${DOC}$"; then
            warn "${DOC} 未更新"
        fi
    done
else
    ok "纯文档/配置提交，跳过文档检查"
fi

# ─── 3. 大体积产物误入库检查 ───
if echo "$CHANGED" | grep -qE '\.(bin|safetensors|gguf|ggml|pt|pth|onnx|ckpt)$'; then
    fail "疑似模型/权重文件被加入提交: $(echo "$CHANGED" | grep -E '\.(bin|safetensors|gguf|ggml|pt|pth|onnx|ckpt)$')"
fi
if echo "$CHANGED" | grep -qE '^(models/|data/)'; then
    fail "models/ 或 data/ 下文件被加入提交（应被 gitignore）: $(echo "$CHANGED" | grep -E '^(models/|data/)' | head -3)"
fi

# ─── 4. 敏感文件检查 ───
if echo "$CHANGED" | grep -qE '(\.env|configs/config\.ya?ml|secret|token|wandb.*key)'; then
    fail "可能包含敏感文件/真实配置: $(echo "$CHANGED" | grep -E '(\.env|configs/config\.ya?ml|secret|token)')"
fi

# ─── 5. .kiro/ 未提交变更 ───
KIRO_DIRTY=$(git diff --name-only .kiro/ 2>/dev/null)
KIRO_UNTRACKED=$(git ls-files --others --exclude-standard .kiro/ 2>/dev/null)
if [ -n "$KIRO_DIRTY" ]; then
    fail ".kiro/ 有未提交的修改: $(echo $KIRO_DIRTY | tr '\n' ' ')"
fi
if [ -n "$KIRO_UNTRACKED" ]; then
    warn ".kiro/ 有未跟踪的新文件: $(echo $KIRO_UNTRACKED | tr '\n' ' ')"
fi

# ─── 6. notebook 未清理输出 ───
if echo "$CHANGED" | grep -qE '\.ipynb$'; then
    for nb in $(echo "$CHANGED" | grep -E '\.ipynb$'); do
        [ -f "$nb" ] || continue
        if grep -q '"output_type"' "$nb" 2>/dev/null; then
            warn "$nb 可能未清理输出（含 output_type），提交前清输出"
        fi
    done
fi

# ─── 7. 残留调试代码 ───
if echo "$CHANGED" | grep -qE '\.py$'; then
    for f in $(echo "$CHANGED" | grep -E '\.py$'); do
        [ -f "$f" ] || continue
        if grep -nE '^\s*(breakpoint\(\)|import pdb)' "$f" 2>/dev/null | head -3 | grep -q .; then
            warn "$f 可能有调试代码（breakpoint/pdb）"
        fi
    done
fi

# ─── 结果 ───
echo "---"
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}检查未通过（$ERRORS 错误 + $WARNINGS 警告）。修复后重试，或 git push --no-verify 跳过${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}${WARNINGS} 项警告。确认无需处理请用 git push --no-verify${NC}"
    exit 1
else
    ok "全部检查通过"
fi

# ─── 自动操作：.kiro 变更时同步 kiro-agents ───
if echo "$CHANGED" | grep -q "^\.kiro/"; then
    echo "🔄 同步 kiro-agents..."
    bash ~/Project/Python/kiro-agents/sync.sh 2>/dev/null
fi

exit 0
