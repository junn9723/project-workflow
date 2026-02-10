# Changelog

エージェント運用ガイド・ワークフローの変更履歴。

## [v2.0.0] - 2026-02-09

### 追加
- `CLAUDE.md`（ルート）: Claude Code プロジェクト設定を追加
- `agents/TEAMS.md`: Agent Teams連携ガイドを追加
- `skills/`: 自律実行スキル群を追加
  - `test-run.md`: テスト実行・結果分析
  - `spec-validate.md`: スペック整合性検証
  - `self-improve.md`: 自己改善ループ
  - `code-review.md`: コード品質レビュー
  - `best-practices.md`: 業界水準検証
  - `spec-create.md`: スペック作成支援
- `specs/SPEC-INDEX.md`: スペック一覧・状態管理
- `scripts/run-tests.sh`: テスト実行スクリプト
- `scripts/validate-spec.sh`: スペック検証スクリプト
- `scripts/self-verify.sh`: 自己検証スクリプト
- `.github/workflows/spec-validate.yml`: スペック検証ワークフロー
- `tests/README.md`: テストガイド
- `.gitignore`: Git除外設定

### 改善
- `agents/CLAUDE.md`: Agent Teams活用手順、スキル連携を追加
- `agents/CODEX.md`: スキル連携、タスク取得手順を追加
- `templates/spec-template.md`: メタデータ、トレーサビリティ表、設計メモを追加
- `templates/task-template.md`: メタデータ、依存関係、完了チェックを追加
- `scripts/setup_vps.sh`: 実用的なセットアップスクリプトに強化
- `.github/workflows/ci.yml`: スペック検証・構造検証・テスト実行を追加
- `.github/pull_request_template.md`: チェックリスト・テスト結果欄を追加
- `docs/WORKFLOW.md`: Agent Teams、スキル、自己改善ループの記述を追加
- `README.md`: ディレクトリ構成詳細、ワークフロー概要、パイプラインを追加


## [v2.3.0] - 2026-02-10

### 追加
- `reports/manager-logs/README.md`: ClaudeCode（マネージャー）の割当/Skill監査ログの運用ルールを追加

### 改善
- `docs/ORCHESTRATION.md`: マネージャーログ（割当理由・Skill使用実績）を標準成果物として追加
- `docs/WORKFLOW.md`: 実行ループにマネージャーログ記録ステップを追加
- `templates/task-template.md`: オーケストレーション情報にマネージャーログ記録欄を追加
- `README.md`: `reports/manager-logs/` の用途を反映

## [v2.2.0] - 2026-02-10

### 追加
- `templates/spec-deliverable-template.md`: Specごとの非コード成果物（仕様サマリー、検証結果、残課題）テンプレートを追加

### 改善
- `scripts/mvp-verify.sh`: implemented Specごとに `reports/spec-deliverables/<spec-file>.md` の存在と必須セクションを検証するよう強化
- `templates/mvp-evidence-template.md`: Deliverable Docリンクを必須証跡として追加
- `templates/task-template.md`: 完了時チェックに非コード成果物の作成を追加
- `templates/spec-template.md`: MVP完了条件に非コード成果物要件を追加
- `docs/WORKFLOW.md`: MVP作成フェーズ/完了ゲートにDeliverable Doc必須化を追記
- `README.md`: 非コード成果物必須化と新テンプレートを反映

## [v2.1.0] - 2026-02-10

### 追加
- `scripts/verify-app.sh`: 統合検証（self-verify + MVP証跡）
- `scripts/mvp-verify.sh`: MVP完了証跡の検証
- `templates/mvp-evidence-template.md`: MVP証跡テンプレート
- `reports/`: 検証・レビュー証跡の保存先

### 改善
- `docs/WORKFLOW.md`: MVP完了ゲートと証跡要件を明文化
- `templates/spec-template.md`: MVP完了条件セクションを追加
- `scripts/validate-spec.sh`: 新セクションの必須化
- `scripts/self-verify.sh`: MVP証跡検証の追加
- `agents/CLAUDE.md`: MVP証跡の必須化を追記
- `README.md`: ディレクトリ構成を更新

## [v1.0.0] - 初期版

### 追加
- 基本ディレクトリ構成
- ワークフロー概要
- エージェント運用ガイド（ClaudeCode/Codex）
- スペック/タスクテンプレート
- GitHub Actions/PRテンプレート（スケルトン）
- VPSセットアップスクリプト（スケルトン）
