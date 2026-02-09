#!/usr/bin/env bash
set -euo pipefail

# ================================================================
# run-tests.sh - 統合テストランナー
# ================================================================
# 使用方法:
#   ./scripts/run-tests.sh              # ユニット+統合テスト実行
#   ./scripts/run-tests.sh --all        # 全テスト実行（ユニット+E2E）
#   ./scripts/run-tests.sh --unit       # ユニットテストのみ
#   ./scripts/run-tests.sh --e2e        # E2Eテスト（Playwright）のみ
#   ./scripts/run-tests.sh --changed    # 変更ファイルに関連するテストのみ
#   ./scripts/run-tests.sh --coverage   # カバレッジレポート付き
#   ./scripts/run-tests.sh [path]       # 指定パスのテスト実行
# ================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# E2E (Playwright) 検出
has_playwright() {
    [ -f "$PROJECT_ROOT/playwright.config.js" ] || [ -f "$PROJECT_ROOT/playwright.config.ts" ]
}

# テストフレームワーク自動検出
detect_test_framework() {
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        if grep -q '"jest"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            echo "jest"
        elif grep -q '"vitest"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            echo "vitest"
        elif grep -q '"mocha"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            echo "mocha"
        elif grep -q '"test"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
            echo "npm-test"
        else
            echo "none"
        fi
    elif [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/setup.py" ]; then
        if command -v pytest >/dev/null 2>&1; then
            echo "pytest"
        else
            echo "python-unittest"
        fi
    elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
        echo "cargo-test"
    elif [ -f "$PROJECT_ROOT/go.mod" ]; then
        echo "go-test"
    else
        echo "none"
    fi
}

# E2Eテスト実行 (Playwright)
run_e2e_tests() {
    if ! has_playwright; then
        log_warn "playwright.config が見つかりません。E2Eテストをスキップします。"
        return 0
    fi

    log_info "--- E2Eテスト (Playwright) ---"
    cd "$PROJECT_ROOT" && npx playwright test
}

# テスト実行
run_tests() {
    local framework="$1"
    local target="${2:-}"
    local coverage="${3:-false}"

    log_info "テストフレームワーク: $framework"
    log_info "対象: ${target:-全テスト}"

    case "$framework" in
        jest)
            local cmd="npx jest --testPathIgnorePatterns tests/e2e/"
            [ -n "$target" ] && cmd="$cmd $target"
            [ "$coverage" = "true" ] && cmd="$cmd --coverage"
            eval "$cmd"
            ;;
        vitest)
            local cmd="npx vitest run"
            [ -n "$target" ] && cmd="$cmd $target"
            [ "$coverage" = "true" ] && cmd="$cmd --coverage"
            eval "$cmd"
            ;;
        pytest)
            local cmd="pytest --ignore=tests/e2e"
            [ -n "$target" ] && cmd="$cmd $target"
            [ "$coverage" = "true" ] && cmd="$cmd --cov --cov-report=term-missing"
            eval "$cmd"
            ;;
        cargo-test)
            cargo test ${target:+--test "$target"}
            ;;
        go-test)
            go test ${target:-./...}
            ;;
        npm-test)
            npm test
            ;;
        none)
            log_warn "テストフレームワークが検出されませんでした"
            log_info "tests/ ディレクトリを確認してください"
            if [ -d "$PROJECT_ROOT/tests" ]; then
                log_info "tests/ ディレクトリは存在します。テストフレームワークをセットアップしてください。"
            else
                log_warn "tests/ ディレクトリが存在しません。テストを作成してください。"
            fi
            return 1
            ;;
    esac
}

# 変更ファイルに関連するテスト取得
get_changed_test_targets() {
    local changed_files
    changed_files=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only 2>/dev/null || echo "")

    if [ -z "$changed_files" ]; then
        echo ""
        return
    fi

    local test_targets=""
    while IFS= read -r file; do
        if echo "$file" | grep -qE '(test|spec)\.' ; then
            test_targets="$test_targets $file"
        fi
        local basename
        basename=$(basename "$file" | sed 's/\.[^.]*$//')
        local test_file
        test_file=$(find "$PROJECT_ROOT/tests" -name "*${basename}*test*" -o -name "*${basename}*spec*" 2>/dev/null | head -1)
        if [ -n "$test_file" ]; then
            test_targets="$test_targets $test_file"
        fi
    done <<< "$changed_files"

    echo "$test_targets" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# メイン処理
main() {
    local mode="unit"
    local target=""
    local coverage="false"

    while [ $# -gt 0 ]; do
        case "$1" in
            --all) mode="all"; shift ;;
            --unit) mode="unit"; shift ;;
            --e2e) mode="e2e"; shift ;;
            --changed) mode="changed"; shift ;;
            --coverage) coverage="true"; shift ;;
            --help|-h)
                echo "使用方法: $0 [--all|--unit|--e2e|--changed|--coverage|path]"
                exit 0
                ;;
            *) target="$1"; shift ;;
        esac
    done

    log_info "=== テスト実行開始 ==="
    log_info "プロジェクト: $PROJECT_ROOT"
    log_info "モード: $mode"

    local framework
    framework=$(detect_test_framework)

    if [ "$mode" = "changed" ]; then
        target=$(get_changed_test_targets)
        if [ -z "$target" ]; then
            log_info "変更ファイルに関連するテストが見つかりません。全テストを実行します。"
        fi
    fi

    local start_time
    start_time=$(date +%s)
    local unit_ok=true
    local e2e_ok=true

    # ユニット/統合テスト
    if [ "$mode" != "e2e" ]; then
        log_info "--- ユニット/統合テスト ---"
        if ! run_tests "$framework" "$target" "$coverage"; then
            unit_ok=false
        fi
    fi

    # E2Eテスト
    if [ "$mode" = "all" ] || [ "$mode" = "e2e" ]; then
        if ! run_e2e_tests; then
            e2e_ok=false
        fi
    fi

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if $unit_ok && $e2e_ok; then
        log_info "=== テスト成功 (${duration}秒) ==="
        exit 0
    else
        $unit_ok || log_error "ユニット/統合テスト失敗"
        $e2e_ok || log_error "E2Eテスト失敗"
        log_error "=== テスト失敗 (${duration}秒) ==="
        exit 1
    fi
}

main "$@"
