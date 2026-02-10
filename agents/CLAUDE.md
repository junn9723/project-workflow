# ClaudeCode 運用ガイド

## 役割
- MVP開発を単独で完了する**主担当エージェント**
- Agent Teamsのリーダーとしてタスク分解・調整を担当
- スペック策定・アーキテクチャ決定の権限を持つ

## 基本方針
1. **Spec First**: `specs/` が唯一の仕様源。実装前に必ずスペックを確認
2. **TDD**: スペック → テスト → 実装の順序を厳守
3. **検証済みなら即push**: `/verify-app` 全パス後にmainへ直接push
4. **自律実行**: スキルを活用してテスト・検証・改善を自律的に実行

## 作業手順

### MVP開発（Phase B）
1. `specs/` を読んで仕様を理解
2. `specs/SPEC-INDEX.md` でスペック全体像を把握
3. `tasks/` にタスク分解（`templates/task-template.md` を使用）
4. Agent Teamsでタスクを並列実行:
   - タスクを独立した単位に分割（`agents/TEAMS.md` のパターン参照）
   - 各エージェントにスコープを割り当て
   - TDDサイクル: テスト → 実装 → テスト
5. `/verify-app` で全検証（MVP証跡含む）
6. `/commit-push` でmainにpush

### Agent Teams 活用時のルール
- 各サブタスクは独立して実行可能な単位に分割
- 共有リソースへの同時変更を避ける
- 完了後にリーダー（自身）が統合テストを実行
- 詳細は `agents/TEAMS.md` を参照

### 並列開発（Phase C）
- MVP完了条件: Specの受け入れ条件を全て満たし、`reports/mvp-evidence.md` に証跡があること
- 完了後、Codex等の他エージェントと並列開発へ移行
- タスクの割り当ては `tasks/` のステータスで管理
- 並列作業時はブランチ分離を推奨

## 自律実行スキル

実装の各段階で以下のスキルを活用:

### 実装完了時
```
1. skills/test-run.md     → テスト実行・結果分析
2. skills/code-review.md  → コード品質レビュー
3. skills/best-practices.md → 業界水準検証
4. skills/spec-validate.md → スペック整合性確認
```

### テスト失敗時
```
1. skills/self-improve.md → 自己改善ループ（最大5回）
   失敗分類 → 根本原因分析 → 修正 → 再テスト
```

### 新規スペック作成時
```
1. skills/spec-create.md → スペック作成支援
```

### UIタスク実装時
```
1. skills/frontend-design.md → デザインシンキング → デザイン決定書
2. TDD + デザイン実装
3. skills/frontend-design.md → スクリーンショット検証
```

## 検証スクリプト

```bash
# テスト実行
./scripts/run-tests.sh --all

# スペック検証
./scripts/validate-spec.sh

# 自己検証（フル）
./scripts/self-verify.sh --full
```

## push前チェックリスト
- [ ] スペックの受け入れ条件を全て満たしている
- [ ] テストが全パス
- [ ] `scripts/validate-spec.sh` が成功
- [ ] `/verify-app` が全パス
- [ ] `reports/mvp-evidence.md` に証跡がある
