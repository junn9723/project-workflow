# Project Workflow - Claude Code 運用設定

このファイルはClaude Codeがプロジェクトに参加した際に自動的に読み込まれる運用ルールです。

## プロジェクト概要

生成AI主導の開発ワークフロー基盤。**スペックが最重要成果物**であり、コードは再生成可能。

## 基本原則

1. **Spec First**: `specs/` が唯一の仕様源。実装前に必ずスペックを確認
2. **TDD**: スペック → テスト → 実装 の順序を厳守
3. **1タスク = 1ブランチ = 1PR**: コンフリクト防止の最小ルール
4. **GitHub = 唯一のHub**: 情報はすべてGitHub上で管理

## ディレクトリ構造と役割

```
specs/          → 仕様書（最重要。変更はPR必須）
tasks/          → タスク分解・実行計画
agents/         → エージェント運用ガイド・チーム設定
skills/         → 自律実行スキル定義（テスト・検証・改善）
scripts/        → 自動化スクリプト（テスト実行・検証・VPSセットアップ）
templates/      → 仕様/タスクテンプレート
tests/          → テストコード（スペックに紐づく）
docs/           → ワークフロー・運用ドキュメント
.github/        → CI/CD・PRテンプレート
```

## Agent Teams 運用ルール

### タスク実行前の必須手順
1. `specs/SPEC-INDEX.md` でスペック一覧を確認
2. `tasks/` で自分が担当するタスクを確認
3. 担当タスクのステータスを `in_progress` に更新
4. 専用ブランチを作成: `task/<task-id>-<短い説明>`

### ブランチ戦略
- `main`: 安定版。直接pushは禁止
- `task/<id>-<name>`: タスク実装用（1タスク1ブランチ）
- `spec/<id>-<name>`: スペック変更用
- `fix/<description>`: バグ修正用

### コンフリクト防止
- タスクファイルの `status` フィールドで作業中を明示
- スペック変更が必要な場合、実装PRより先にスペックPRを作成
- `specs/` 以外の場所で仕様を記述しない

## 自律実行スキル

以下のスキルを必要に応じて実行する:

| スキル | 用途 | 参照 |
|--------|------|------|
| test-run | テスト実行・結果分析 | `skills/test-run.md` |
| spec-validate | スペック整合性検証 | `skills/spec-validate.md` |
| self-improve | 自己改善ループ（テスト→修正→再テスト） | `skills/self-improve.md` |
| code-review | コード品質レビュー | `skills/code-review.md` |
| best-practices | 業界水準・ベストプラクティス検証 | `skills/best-practices.md` |

### スキル実行タイミング
- **実装完了時**: `test-run` → `code-review` → `best-practices`
- **テスト失敗時**: `self-improve` （自動修正ループ）
- **PR作成前**: `spec-validate` （スペック整合性確認）
- **マイルストーン完了時**: 全スキルを順次実行

## TDD ワークフロー

```
1. スペック読み込み (specs/<spec>.md)
2. 受け入れ条件からテストケース生成
3. テスト実装 (tests/)
4. テスト実行 → 失敗を確認 (Red)
5. 最小限の実装
6. テスト実行 → 成功を確認 (Green)
7. リファクタリング (Refactor)
8. スペック受け入れ条件の全項目チェック
```

## PR作成ルール

- PRテンプレート（`.github/pull_request_template.md`）に従う
- 種別（Spec / Task / Code）を明記
- スペックへのリンクを必ず含める
- テスト結果を貼付
- レビュー依頼前に `scripts/validate-spec.sh` を実行

## CI/CD

- PR作成時: GitHub Actionsで自動テスト・スペック検証
- main merge時: 統合テスト実行
- VPS環境: E2E・統合テストの実行環境

## 重要な注意事項

- **スペックが正**: コードとスペックが矛盾したら、スペックを正とする
- **小さなPR**: 大きな変更は分割して段階的にマージ
- **自己検証**: PR作成前に必ずローカルでテストを実行
- **ドキュメント同期**: 実装変更に伴うスペック更新を忘れない
