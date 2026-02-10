#!/usr/bin/env bash
set -euo pipefail

# ================================================================
# self-verify.sh - 自己検証・改善ループ実行スクリプト
# ================================================================
# 使用方法:
#   ./scripts/self-verify.sh              # 全検証実行
#   ./scripts/self-verify.sh --quick      # テスト+スペック検証のみ
#   ./scripts/self-verify.sh --full       # 全検証+ベストプラクティス
# ================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
SKIP=0

log_step() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}========================================${NC}"; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASS=$((PASS + 1)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; FAIL=$((FAIL + 1)); }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; SKIP=$((SKIP + 1)); }

# Step 1: スペック検証
verify_specs() {
    log_step "Step 1: スペック検証"

    if [ -x "$SCRIPT_DIR/validate-spec.sh" ]; then
        if "$SCRIPT_DIR/validate-spec.sh"; then
            log_pass "スペック検証"
        else
            log_fail "スペック検証"
        fi
    else
        log_skip "validate-spec.sh が見つかりません"
    fi
}

# Step 2: テスト実行
verify_tests() {
    log_step "Step 2: テスト実行"

    if [ -x "$SCRIPT_DIR/run-tests.sh" ]; then
        if "$SCRIPT_DIR/run-tests.sh" --all; then
            log_pass "テスト実行"
        else
            log_fail "テスト実行"
        fi
    else
        log_skip "run-tests.sh が見つかりません"
    fi
}

# Step 3: プロジェクト構造検証
verify_structure() {
    log_step "Step 3: プロジェクト構造検証"

    # 必須ディレクトリ
    local required_dirs=("specs" "tasks" "agents" "skills" "scripts" "templates" "docs" "reports" ".github")
    for dir in "${required_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            log_pass "ディレクトリ: $dir/"
        else
            log_fail "ディレクトリ不足: $dir/"
        fi
    done

    # 必須ファイル
    local required_files=(
        "CLAUDE.md"
        "README.md"
        "agents/CLAUDE.md"
        "agents/CODEX.md"
        "agents/TEAMS.md"
        "specs/SPEC-INDEX.md"
        "templates/spec-template.md"
        "templates/task-template.md"
        ".github/pull_request_template.md"
    )
    for file in "${required_files[@]}"; do
        if [ -f "$PROJECT_ROOT/$file" ]; then
            log_pass "ファイル: $file"
        else
            log_fail "ファイル不足: $file"
        fi
    done
}

# Step 4: Git状態検証
verify_git() {
    log_step "Step 4: Git状態検証"

    # .gitignoreの存在
    if [ -f "$PROJECT_ROOT/.gitignore" ]; then
        log_pass ".gitignore が存在"

        # 最低限のエントリ
        local required_ignores=("node_modules" ".env" "__pycache__")
        for pattern in "${required_ignores[@]}"; do
            if grep -q "$pattern" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
                log_pass ".gitignore: $pattern"
            else
                log_skip ".gitignore: $pattern が未登録（必要に応じて追加）"
            fi
        done
    else
        log_fail ".gitignore が存在しません"
    fi

    # 未コミットの変更確認
    if git -C "$PROJECT_ROOT" diff --quiet 2>/dev/null; then
        log_pass "未コミットの変更なし"
    else
        log_skip "未コミットの変更があります"
    fi
}

# Step 5: CI/CD検証
verify_cicd() {
    log_step "Step 5: CI/CD検証"

    if [ -f "$PROJECT_ROOT/.github/workflows/ci.yml" ]; then
        log_pass "ci.yml が存在"

        # プレースホルダーチェック
        if grep -q "Placeholder\|placeholder\|Add.*here" "$PROJECT_ROOT/.github/workflows/ci.yml" 2>/dev/null; then
            log_fail "ci.yml にプレースホルダーが残っています"
        else
            log_pass "ci.yml がカスタマイズ済み"
        fi
    else
        log_fail "ci.yml が存在しません"
    fi

    if [ -f "$PROJECT_ROOT/.github/workflows/spec-validate.yml" ]; then
        log_pass "spec-validate.yml が存在"
    else
        log_fail "spec-validate.yml が存在しません"
    fi
}

# Step 6: スキル定義検証
verify_skills() {
    log_step "Step 6: スキル定義検証"

    local required_skills=("test-run" "spec-validate" "self-improve" "code-review" "best-practices" "spec-create" "frontend-design")
    for skill in "${required_skills[@]}"; do
        if [ -f "$PROJECT_ROOT/skills/${skill}.md" ]; then
            log_pass "スキル: $skill"

            # スキルの必須セクション
            local has_purpose has_steps has_criteria
            has_purpose=$(grep -c "## 目的" "$PROJECT_ROOT/skills/${skill}.md" 2>/dev/null || echo 0)
            has_steps=$(grep -c "## 手順" "$PROJECT_ROOT/skills/${skill}.md" 2>/dev/null || echo 0)
            has_criteria=$(grep -c "## 判定基準" "$PROJECT_ROOT/skills/${skill}.md" 2>/dev/null || echo 0)

            if [ "$has_purpose" -gt 0 ] && [ "$has_steps" -gt 0 ] && [ "$has_criteria" -gt 0 ]; then
                log_pass "  構造: 目的・手順・判定基準あり"
            else
                log_fail "  構造不備: 必須セクション不足"
            fi
        else
            log_fail "スキル不足: $skill"
        fi
    done
}

# 結果サマリー
show_summary() {
    local total=$((PASS + FAIL + SKIP))

    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  自己検証サマリー${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "  総チェック項目: $total"
    echo -e "  ${GREEN}成功: $PASS${NC}"
    echo -e "  ${RED}失敗: $FAIL${NC}"
    echo -e "  ${YELLOW}スキップ: $SKIP${NC}"

    if [ "$total" -gt 0 ]; then
        local rate=$((PASS * 100 / total))
        echo -e "  成功率: ${rate}%"
    fi

    if [ "$FAIL" -gt 0 ]; then
        echo -e "\n${RED}自己検証失敗: $FAIL 件の問題があります${NC}"
        return 1
    else
        echo -e "\n${GREEN}自己検証成功${NC}"
        return 0
    fi
}

# Step 7: MVP完了証跡検証
verify_mvp_evidence() {
    log_step "Step 7: MVP完了証跡検証"

    if [ -x "$SCRIPT_DIR/mvp-verify.sh" ]; then
        if "$SCRIPT_DIR/mvp-verify.sh"; then
            log_pass "MVP証跡検証"
        else
            log_fail "MVP証跡検証"
        fi
    else
        log_skip "mvp-verify.sh が見つかりません"
    fi
}

# メイン処理
main() {
    local mode="${1:---quick}"

    echo "=== 自己検証開始 ==="
    echo "プロジェクト: $PROJECT_ROOT"
    echo "モード: $mode"

    verify_structure
    verify_specs

    case "$mode" in
        --quick)
            verify_tests
            ;;
        --full)
            verify_tests
            verify_git
            verify_cicd
            verify_skills
            ;;
        *)
            verify_tests
            ;;
    esac

    verify_mvp_evidence
    show_summary
}

main "$@"
