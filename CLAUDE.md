# Project Workflow - Claude Code 運用設定

このファイルはClaude Codeがプロジェクトに参加した際に自動的に読み込まれる運用ルールです。
チーム全員で改善し、git管理する（目安: 2.5kトークン以内）。

## 基本原則

1. **検証ループが最重要**: テスト・ビルド・E2Eなど検証手段を必ず使う。検証なしでPRを出さない
2. **Spec First**: `specs/` が唯一の仕様源。実装前に必ずスペックを確認
3. **Plan → Implement**: いきなりコードを書かない。まず計画し、承認後に実装
4. **TDD**: スペック → テスト → 実装 の順序を厳守
5. **1タスク = 1ブランチ = 1PR**: コンフリクト防止の最小ルール

## 作業の流れ

```
1. /plan-and-implement で計画→承認
2. TDD: テスト(Red) → 実装(Green) → リファクタ
3. /verify-app で全検証（スペック・テスト・E2E・ビルド）
4. 失敗 → skills/self-improve.md で自動修正（最大5回）
5. /commit-push-pr でPR作成
6. /update-claude-md で学びを記録
```

## スラッシュコマンド（.claude/commands/）

| コマンド | 用途 |
|----------|------|
| `/commit-push-pr` | コミット→プッシュ→PR作成を一括実行 |
| `/verify-app` | アプリ全体検証（最重要。品質2〜3倍） |
| `/build-validator` | ビルド・リント・型チェック検証 |
| `/code-simplifier` | コード簡素化・不要コード削除 |
| `/plan-and-implement` | 計画→承認→TDD実装 |
| `/update-claude-md` | 学びをCLAUDE.mdに反映 |

## ディレクトリ構造

```
specs/           → 仕様書（最重要成果物）
tasks/           → タスク分解・実行計画
agents/          → エージェント運用ガイド
skills/          → 自律実行スキル定義
scripts/         → 自動化スクリプト
tests/           → テスト（unit/ integration/ e2e/）
templates/       → テンプレート
.claude/commands → スラッシュコマンド（チーム共有）
.claude/         → 権限・フック設定
```

## Agent Teams 運用

### タスク実行前
1. `specs/SPEC-INDEX.md` でスペック確認
2. `tasks/` で担当タスク確認 → `in_progress` に更新
3. ブランチ作成: `task/<task-id>-<名前>`

### ブランチ戦略
- `main`: 安定版（直接push禁止）
- `task/<id>-<name>` / `spec/<id>-<name>` / `fix/<name>`

## 検証コマンド

```bash
./scripts/run-tests.sh --unit    # ユニットテスト
./scripts/run-tests.sh --e2e     # E2E（Playwright）
./scripts/run-tests.sh --all     # 全テスト
./scripts/validate-spec.sh       # スペック検証
./scripts/self-verify.sh --full  # フル自己検証
```

## ミスログ・学習記録

Claudeがやらかしたミスと対策をここに記録する。PRレビュー時に `/update-claude-md` で更新。

<!-- 例:
- [2026-02-09] [E2E] テスト間で状態が共有されていた → beforeEachでリセットAPI呼び出し必須
- [2026-02-09] [Jest] JestがPlaywright E2Eファイルを拾った → --testPathIgnorePatterns tests/e2e/ で除外
-->

## チーム貢献ルール

- CLAUDE.mdは**週次でチーム全員がレビュー・改善**する
- PRレビューで発見した学びは即座に追記
- 古い・解決済みのエントリは定期的に整理
- 一般的すぎる内容は書かない（プロジェクト固有の知見のみ）
