#!/usr/bin/env bash
set -euo pipefail

# ================================================================
# validate-spec.sh - スペック整合性検証スクリプト
# ================================================================
# 使用方法:
#   ./scripts/validate-spec.sh              # 全スペック検証
#   ./scripts/validate-spec.sh specs/001.md # 指定スペック検証
# ================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SPECS_DIR="$PROJECT_ROOT/specs"
TEMPLATE="$PROJECT_ROOT/templates/spec-template.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0
TOTAL=0

log_pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; }
log_fail() { echo -e "  ${RED}[FAIL]${NC} $1"; ERRORS=$((ERRORS + 1)); }
log_warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; WARNINGS=$((WARNINGS + 1)); }

# スペックファイルの構造検証
validate_structure() {
    local spec_file="$1"
    local filename
    filename=$(basename "$spec_file")

    echo -e "\n--- $filename ---"
    TOTAL=$((TOTAL + 1))

    # 必須セクション
    local required_sections=(
        "## 1. 目的"
        "## 2. スコープ"
        "## 3. ユースケース"
        "## 4. 要件"
        "## 5. 受け入れ条件"
        "## 6. テスト方針"
        "## 7. 仕様変更履歴"
    )

    for section in "${required_sections[@]}"; do
        if grep -q "$section" "$spec_file"; then
            log_pass "$section"
        else
            log_fail "セクション不足: $section"
        fi
    done

    # 受け入れ条件にチェックボックスがあるか
    if grep -q '\- \[[ x]\]' "$spec_file"; then
        log_pass "受け入れ条件にチェックボックスあり"
    else
        log_fail "受け入れ条件にチェックボックスがありません"
    fi

    # 変更履歴が初期状態のままでないか
    local history_content
    history_content=$(sed -n '/## 7. 仕様変更履歴/,$ p' "$spec_file" | tail -n +2)
    if [ -n "$history_content" ] && [ "$history_content" != "- Initial" ]; then
        log_pass "変更履歴が記載されている"
    else
        log_warn "変更履歴が初期状態のままです"
    fi

    # スペックIDとファイル名の整合性
    if echo "$filename" | grep -qE '^[0-9]{3}-[a-z0-9-]+\.md$'; then
        log_pass "ファイル名規約準拠: $filename"
    else
        log_warn "ファイル名が規約（NNN-name.md）に従っていません: $filename"
    fi
}

# SPEC-INDEXとの整合性検証
validate_index() {
    local index_file="$SPECS_DIR/SPEC-INDEX.md"

    echo -e "\n=== SPEC-INDEX 整合性 ==="

    if [ ! -f "$index_file" ]; then
        log_fail "SPEC-INDEX.md が存在しません"
        return
    fi

    # スペックファイルがインデックスに登録されているか
    for spec_file in "$SPECS_DIR"/*.md; do
        local filename
        filename=$(basename "$spec_file")
        [ "$filename" = "README.md" ] && continue
        [ "$filename" = "SPEC-INDEX.md" ] && continue

        if grep -q "$filename" "$index_file"; then
            log_pass "$filename がインデックスに登録済み"
        else
            log_fail "$filename がインデックスに未登録"
        fi
    done

    # インデックスに登録されたファイルが実在するか
    grep -oE '[0-9]{3}-[a-z0-9-]+\.md' "$index_file" 2>/dev/null | while read -r indexed_file; do
        if [ -f "$SPECS_DIR/$indexed_file" ]; then
            log_pass "$indexed_file が実在"
        else
            log_fail "$indexed_file がインデックスにあるが実ファイルが存在しない"
        fi
    done
}

# テストとのトレーサビリティ検証
validate_traceability() {
    echo -e "\n=== トレーサビリティ検証 ==="

    local tests_dir="$PROJECT_ROOT/tests"
    if [ ! -d "$tests_dir" ]; then
        log_warn "tests/ ディレクトリが存在しません"
        return
    fi

    for spec_file in "$SPECS_DIR"/*.md; do
        local filename
        filename=$(basename "$spec_file")
        [ "$filename" = "README.md" ] && continue
        [ "$filename" = "SPEC-INDEX.md" ] && continue

        local spec_id
        spec_id=$(echo "$filename" | grep -oE '^[0-9]{3}')

        # テストファイル内でスペック参照を検索
        local test_refs
        test_refs=$(grep -rl "@spec.*$filename\|spec.*$spec_id" "$tests_dir" 2>/dev/null | wc -l)

        if [ "$test_refs" -gt 0 ]; then
            log_pass "$filename: テストからの参照 ${test_refs}件"
        else
            log_warn "$filename: テストからの参照なし"
        fi
    done
}

# メイン処理
main() {
    echo "=== スペック検証開始 ==="
    echo "プロジェクト: $PROJECT_ROOT"

    local target="${1:-}"

    if [ -n "$target" ] && [ -f "$target" ]; then
        # 特定のスペックのみ検証
        validate_structure "$target"
    else
        # 全スペック検証
        local spec_count=0
        for spec_file in "$SPECS_DIR"/*.md; do
            local filename
            filename=$(basename "$spec_file")
            [ "$filename" = "README.md" ] && continue
            [ "$filename" = "SPEC-INDEX.md" ] && continue
            spec_count=$((spec_count + 1))
            validate_structure "$spec_file"
        done

        if [ "$spec_count" -eq 0 ]; then
            log_warn "specs/ にスペックファイルが見つかりません"
        fi

        validate_index
        validate_traceability
    fi

    echo -e "\n=== 検証結果サマリー ==="
    echo "  検証スペック数: $TOTAL"
    echo -e "  エラー: ${RED}$ERRORS${NC}"
    echo -e "  警告: ${YELLOW}$WARNINGS${NC}"

    if [ "$ERRORS" -gt 0 ]; then
        echo -e "\n${RED}検証失敗: $ERRORS 件のエラーがあります${NC}"
        exit 1
    elif [ "$WARNINGS" -gt 0 ]; then
        echo -e "\n${YELLOW}検証通過（警告あり）: $WARNINGS 件の警告${NC}"
        exit 0
    else
        echo -e "\n${GREEN}検証成功${NC}"
        exit 0
    fi
}

main "$@"
