# 生成AI主導 開発ワークフロー（GitHub Hub）

生成AI主導の開発ワークフローを軽量に開始するための初期セット。**成果物の主軸はスペック**であり、コードは再生成可能であることを前提に設計しています。

## 特徴
- **Spec First**: スペックが最重要成果物。コードは再生成可能
- **Agent Teams対応**: ClaudeCodeのAgent Teamsで並列MVP開発
- **自律実行スキル**: テスト・検証・自己改善を自律的に実行
- **TDD前提**: スペック → テスト → 実装の順序を厳守
- **検証済みなら即push**: 検証ループ通過後にmainへ直接push（スピード重視）

## 最短の開始手順
1. 本リポジトリをClone
2. `scripts/setup_vps.sh` でVPS環境をセットアップ
3. `docs/WORKFLOW.md` で運用ルールを確認
4. `specs/` にスペックを作成
5. MVP開発 → 並列開発へ移行

## ディレクトリ構成

```
├── CLAUDE.md          → Claude Code プロジェクト設定（自動読み込み）
├── specs/             → 仕様書（最重要成果物）
│   └── SPEC-INDEX.md  → スペック一覧・状態管理
├── tasks/             → タスク分解・実行計画
├── agents/            → エージェント運用ガイド
│   ├── CLAUDE.md      → ClaudeCode運用ガイド
│   ├── CODEX.md       → Codex運用ガイド
│   └── TEAMS.md       → Agent Teams連携ガイド
├── skills/            → 自律実行スキル定義
│   ├── test-run.md    → テスト実行・結果分析
│   ├── spec-validate.md → スペック整合性検証
│   ├── self-improve.md → 自己改善ループ
│   ├── code-review.md → コード品質レビュー
│   ├── best-practices.md → 業界水準検証
│   ├── spec-create.md → スペック作成支援
│   └── frontend-design.md → フロントエンドデザイン品質
├── scripts/           → 自動化スクリプト
│   ├── run-tests.sh   → テスト実行
│   ├── validate-spec.sh → スペック検証
│   ├── self-verify.sh → 自己検証
│   └── setup_vps.sh   → VPS環境セットアップ
├── templates/         → テンプレート
│   ├── spec-template.md → スペックテンプレート
│   └── task-template.md → タスクテンプレート
├── docs/              → ワークフロー・運用ドキュメント
└── .github/           → CI/CD
```

## ワークフロー概要

```
Phase A: 仕様策定 → Phase B: MVP開発（Agent Teams） → Phase C: 並列開発
```

| Phase | 担当 | 内容 |
|-------|------|------|
| A | 人間 + ClaudeCode | スペック策定 |
| B | ClaudeCode（Agent Teams） | MVP開発（TDD） |
| C | ClaudeCode + Codex + 人間 | 並列タスク実行 |

詳細は `docs/WORKFLOW.md` を参照。

## 自律実行パイプライン

```
【実装完了】 test-run → code-review → best-practices → spec-validate
【テスト失敗】 test-run → self-improve → test-run → code-review
【新機能】 spec-create → spec-validate → test-run(Red) → 実装 → test-run(Green)
【UI実装】 frontend-design(Step1) → test-run(Red) → 実装 → frontend-design(Step2-5) → test-run(Green) → code-review
```

## まず読むファイル
1. `docs/WORKFLOW.md` - ワークフロー全体像
2. `agents/CLAUDE.md` - ClaudeCode運用ガイド
3. `agents/TEAMS.md` - Agent Teams連携ガイド
4. `skills/README.md` - スキル一覧
