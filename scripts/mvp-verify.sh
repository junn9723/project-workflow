#!/usr/bin/env bash
set -euo pipefail

# ================================================================
# mvp-verify.sh - MVP完了証跡の検証スクリプト
# ================================================================
# 使用方法:
#   ./scripts/mvp-verify.sh
# ================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }

SPEC_INDEX="$PROJECT_ROOT/specs/SPEC-INDEX.md"
EVIDENCE_FILE="$PROJECT_ROOT/reports/mvp-evidence.md"

collect_implemented_specs() {
    if [ ! -f "$SPEC_INDEX" ]; then
        echo ""
        return
    fi

    # Table rows: | ID | ファイル | タイトル | ステータス | 依存 | 最終更新 |
    awk -F'|' '
        $0 ~ /^\|/ {
            gsub(/^[ \t]+|[ \t]+$/, "", $4);
            gsub(/^[ \t]+|[ \t]+$/, "", $3);
            if ($4 == "implemented" && $3 ~ /\.md$/) {
                print $3;
            }
        }
    ' "$SPEC_INDEX"
}

main() {
    echo "=== MVP完了証跡 検証 ==="

    local specs
    specs=$(collect_implemented_specs | tr '\n' ' ' | sed 's/[[:space:]]*$//')

    if [ -z "$specs" ]; then
        log_skip "implemented のスペックがありません（検証不要）"
        exit 0
    fi

    if [ ! -f "$EVIDENCE_FILE" ]; then
        log_fail "reports/mvp-evidence.md が存在しません"
        exit 1
    fi

    log_pass "mvp-evidence.md が存在"

    local failed=0
    for spec_file in $specs; do
        if ! grep -q "Spec: ${spec_file}" "$EVIDENCE_FILE"; then
            log_fail "証跡不足: Spec: ${spec_file} が mvp-evidence.md に見つかりません"
            failed=1
            continue
        fi

        # Specセクション内に完了チェックがあるか（[x]）
        if ! awk -v s="Spec: ${spec_file}" '
            $0 ~ s {in_section=1; next}
            in_section && $0 ~ /^## / {in_section=0}
            in_section {print}
        ' "$EVIDENCE_FILE" | grep -q '\[x\]'; then
            log_fail "証跡不足: ${spec_file} セクションに完了チェックがありません"
            failed=1
        else
            log_pass "証跡OK: ${spec_file}"
        fi
    done

    if [ "$failed" -eq 1 ]; then
        exit 1
    fi

    echo -e "${GREEN}MVP証跡検証成功${NC}"
}

main "$@"
