#!/usr/bin/env bash
set -euo pipefail

# ================================================================
# setup_vps.sh - VPS開発/テスト環境セットアップ
# ================================================================
# 使用方法:
#   ./scripts/setup_vps.sh              # インタラクティブセットアップ
#   ./scripts/setup_vps.sh --node       # Node.js環境
#   ./scripts/setup_vps.sh --python     # Python環境
#   ./scripts/setup_vps.sh --both       # 両方
# ================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 基本ツールの確認
check_prerequisites() {
    log_info "=== 前提条件チェック ==="

    local tools=("git" "curl" "wget")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_info "$tool: $(command -v "$tool")"
        else
            log_error "$tool が見つかりません。インストールしてください。"
            exit 1
        fi
    done
}

# Git設定
setup_git() {
    log_info "=== Git設定 ==="

    # グローバル設定（未設定の場合のみ）
    if ! git config --global user.name >/dev/null 2>&1; then
        log_warn "git user.name が未設定です。設定してください:"
        log_warn "  git config --global user.name 'Your Name'"
    fi

    if ! git config --global user.email >/dev/null 2>&1; then
        log_warn "git user.email が未設定です。設定してください:"
        log_warn "  git config --global user.email 'your@email.com'"
    fi

    # 推奨設定
    git config --global pull.rebase true
    git config --global push.autoSetupRemote true
    log_info "Git推奨設定を適用しました"
}

# Node.js環境セットアップ
setup_node() {
    log_info "=== Node.js環境セットアップ ==="

    if command -v node >/dev/null 2>&1; then
        log_info "Node.js: $(node --version)"
    else
        log_info "Node.jsをインストールします（nvm経由）"
        if ! command -v nvm >/dev/null 2>&1; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            # shellcheck source=/dev/null
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        fi
        nvm install --lts
        nvm use --lts
        log_info "Node.js: $(node --version)"
    fi

    if command -v npm >/dev/null 2>&1; then
        log_info "npm: $(npm --version)"
    fi
}

# Python環境セットアップ
setup_python() {
    log_info "=== Python環境セットアップ ==="

    if command -v python3 >/dev/null 2>&1; then
        log_info "Python: $(python3 --version)"
    else
        log_info "Python3をインストールしてください"
        log_info "  Ubuntu: sudo apt install python3 python3-pip python3-venv"
        return 1
    fi

    # pipの確認
    if command -v pip3 >/dev/null 2>&1; then
        log_info "pip: $(pip3 --version)"
    fi

    # テストツール
    if command -v pytest >/dev/null 2>&1; then
        log_info "pytest: $(pytest --version 2>&1 | head -1)"
    else
        log_info "pytestをインストールします"
        pip3 install pytest pytest-cov
    fi
}

# Docker環境（オプション）
setup_docker() {
    log_info "=== Docker確認 ==="

    if command -v docker >/dev/null 2>&1; then
        log_info "Docker: $(docker --version)"
    else
        log_warn "Dockerが未インストールです（オプション）"
    fi

    if command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1; then
        log_info "Docker Compose: 利用可能"
    fi
}

# GitHub CLI
setup_gh() {
    log_info "=== GitHub CLI確認 ==="

    if command -v gh >/dev/null 2>&1; then
        log_info "gh: $(gh --version | head -1)"
        if gh auth status >/dev/null 2>&1; then
            log_info "gh: 認証済み"
        else
            log_warn "gh: 未認証。'gh auth login' を実行してください"
        fi
    else
        log_warn "GitHub CLI (gh) が未インストールです"
        log_info "インストール: https://cli.github.com/"
    fi
}

# プロジェクトディレクトリ準備
setup_project_dirs() {
    log_info "=== プロジェクトディレクトリ確認 ==="

    local dirs=("tests" "tests/unit" "tests/integration" "tests/e2e")
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_info "作成: $dir/"
        else
            log_info "存在: $dir/"
        fi
    done
}

# セットアップ完了サマリー
show_summary() {
    echo ""
    log_info "=== セットアップ完了 ==="
    echo ""
    echo "次のステップ:"
    echo "  1. docs/WORKFLOW.md を読んで運用ルールを確認"
    echo "  2. specs/ でスペックを確認"
    echo "  3. tasks/ でタスクを確認"
    echo "  4. 開発を開始"
    echo ""
    echo "テスト実行:"
    echo "  ./scripts/run-tests.sh"
    echo ""
    echo "スペック検証:"
    echo "  ./scripts/validate-spec.sh"
    echo ""
    echo "自己検証:"
    echo "  ./scripts/self-verify.sh --full"
}

# メイン処理
main() {
    local mode="${1:---both}"

    log_info "=== VPS開発環境セットアップ ==="

    check_prerequisites
    setup_git
    setup_gh

    case "$mode" in
        --node) setup_node ;;
        --python) setup_python ;;
        --both)
            setup_node
            setup_python
            ;;
    esac

    setup_docker
    setup_project_dirs
    show_summary
}

main "$@"
