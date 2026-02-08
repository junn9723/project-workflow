# Codex 運用ガイド

## 目的
- ClaudeCodeの補佐として並列タスクを実行。

## 基本方針
- Spec First: `specs/` が唯一の仕様源。
- タスクは `tasks/` に明記されたものに限定。
- 1タスク = 1ブランチ/1PR。

## 作業手順
1. `specs/` と `tasks/` を確認
2. 影響範囲の確認（Spec更新が必要なら先にPR）
3. TDDで実装
4. PR作成時にSpecリンクとテスト結果を記載

