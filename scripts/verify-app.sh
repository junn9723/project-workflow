#!/usr/bin/env bash
set -euo pipefail

# ================================================================
# verify-app.sh - アプリ全体の統合検証（最重要ゲート）
# ================================================================
# 使用方法:
#   ./scripts/verify-app.sh
# ================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_step() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}========================================${NC}"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

main() {
    log_step "verify-app: 自己検証 (self-verify)"
    if "$SCRIPT_DIR/self-verify.sh" --full; then
        log_pass "self-verify 完了"
    else
        log_fail "self-verify 失敗"
        exit 1
    fi

    log_step "verify-app: MVP完了証跡検証 (mvp-verify)"
    if [ -x "$SCRIPT_DIR/mvp-verify.sh" ]; then
        if "$SCRIPT_DIR/mvp-verify.sh"; then
            log_pass "mvp-verify 完了"
        else
            log_fail "mvp-verify 失敗"
            exit 1
        fi
    else
        log_fail "mvp-verify.sh が見つかりません"
        exit 1
    fi
}

main "$@"
