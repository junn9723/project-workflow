# Codex 運用ガイド

## 役割
- ClaudeCodeの補佐として**並列タスクを実行**
- 割り当てられたタスクの実装に専念
- スペック変更が必要な場合はClaudeCode/人間にエスカレーション

## 基本方針
1. **Spec First**: `specs/` が唯一の仕様源
2. **タスク限定**: `tasks/` に明記されたタスクのみ実行
3. **検証済みなら即push**: 担当タスク以外のファイルを変更しない
4. **自律テスト**: テスト実行・検証は自律的に行う

## 作業手順

### タスク取得
1. `tasks/` で `status: pending` のタスクを確認
2. 依存関係（`depends_on`）が解決済みか確認
3. タスクファイルの `status` を `in_progress`、`assignee` を `codex` に更新

### 実装
1. `specs/` で対応するスペックを読む
2. 受け入れ条件を確認
3. TDDで実装:
   - テスト作成（Red）
   - 最小限の実装（Green）
   - リファクタリング（Refactor）
4. スキルを実行して品質確認

### 完了・push
1. `scripts/validate-spec.sh` を実行
2. `scripts/run-tests.sh --all` を実行
3. 検証全パス → mainにpush
4. `reports/spec-deliverables/<spec-file>.md` を作成し、`reports/mvp-evidence.md` にリンクを追記
5. タスクファイルの `status` を `done` に更新

## 自律実行スキル

### 実装完了時
```
1. skills/test-run.md     → テスト実行
2. skills/code-review.md  → セルフレビュー
3. skills/spec-validate.md → スペック整合性確認
```

### テスト失敗時
```
1. skills/self-improve.md → 自己改善ループ（最大5回）
   → 5回で解決しない場合はIssue作成してエスカレーション
```

## 制約
- スペックの新規作成・大幅変更は行わない（ClaudeCode/人間の役割）
- アーキテクチャに影響する判断は行わない
- 担当タスク外のファイル変更は原則禁止
- 不明点がある場合はIssueで質問
