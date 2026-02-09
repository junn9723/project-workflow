# 生成AI主導 開発ワークフロー

## 0. 前提
- GitHubを**唯一の情報ハブ**とする（仕様・タスク・議事録・エージェント運用・CI/CD）
- メイン開発エージェントは **ClaudeCode**、サブが **Codex**
- 成果物の中心は**スペック**であり、コードは再生成可能であることを前提にする
- 開発/テスト環境はVPS（人間の開発者ごとに割当）
- Agent Teams（ClaudeCode内の並列エージェント）を活用してMVP開発を加速

### 最重要原則: 検証ループ
**検証ループが成果物の品質を2〜3倍にする。省略は厳禁。**

```
実装 → /verify-app → 失敗 → self-improve（最大5回） → /verify-app → 成功 → PR
```

検証なしでPRを出すことは禁止。`/verify-app` はスペック検証・ユニットテスト・E2Eテスト・ビルド・自己検証を一括実行する。

---

## 1. リポジトリ設計

### 1-1. 情報の「唯一の参照点」
| 情報 | 場所 | 変更方法 |
|------|------|----------|
| 仕様 | `specs/` | PR必須 |
| タスク | `tasks/` | 担当者が更新 |
| エージェント運用 | `agents/` | PR必須 |
| スキル定義 | `skills/` | PR必須 |
| CI/CD | `.github/workflows/` | PR必須 |
| 運用ルール | `docs/` | PR必須 |

### 1-2. 仕様のバージョニング
- スペックは `specs/<NNN>-<name>.md` の形式で管理
- `specs/SPEC-INDEX.md` で全スペックの状態を一元管理
- 変更は必ず「差分」と「理由」を変更履歴に記載
- PRでレビュー・承認後にマージ

---

## 2. ワークフロー全体像

### Phase A: 仕様策定（Spec First）
1. `templates/spec-template.md` を複製
2. `specs/` に新規Specを追加（`specs/<NNN>-<name>.md`）
3. `specs/SPEC-INDEX.md` を更新
4. PRにてレビューし承認
5. `skills/spec-validate.md` の基準で品質チェック

### Phase B: MVP作成（Plan → Agent Teams → 検証）
1. **`/plan-and-implement` で計画→承認**（いきなりコードを書かない）
2. ClaudeCodeが `specs/` から全体設計
3. タスク分解（`tasks/`、`templates/task-template.md` を使用）
4. **Agent Teamsで並列実装**:
   - タスクをモジュール/レイヤー/TDDペアで分割（`agents/TEAMS.md` 参照）
   - 各Agentが担当タスクをTDDで実装
   - リーダー（ClaudeCode）が統合・検証
5. 自律実行スキルによる品質担保:
   - `skills/test-run.md` → テスト実行
   - `skills/self-improve.md` → テスト失敗時の自動修正
   - `skills/code-review.md` → コード品質レビュー
   - `skills/spec-validate.md` → スペック整合性確認
6. **`/verify-app` で全検証**（検証ループ必須）
7. MVPをGitHubへpush

### Phase C: 並列開発開始
1. MVP + 本フレームワークをベースに並列開発を開始
2. Codexを含む複数エージェントで並列タスク実行
3. 衝突回避: **1タスク = 1ブランチ = 1PR**
4. 仕様に影響する変更は先にSpec PRを出す
5. PRレビュー → `/update-claude-md` で学びを蓄積

---

## 3. コンフリクト/不整合対策

### 3-1. 仕様と実装の一貫性
- **Spec変更が先**、実装は後
- `specs/` 以外で仕様を書くことは禁止
- スペック ↔ テストのトレーサビリティを維持

### 3-2. タスクの粒度とルール
- `tasks/` に「実装単位のタスク」を定義
- **タスク1つにつき1ブランチ/1PR**
- タスクファイルで `status` / `assignee` を管理し、二重着手を防止

### 3-3. エージェントファイル共有
- `agents/` にClaude/Codex運用ガイドを置き、変更はPR運用
- 変更内容を `docs/CHANGELOG.md` に記録

### 3-4. ブランチ戦略
| ブランチ名パターン | 用途 |
|---------------------|------|
| `main` | 安定版（直接push禁止） |
| `task/<id>-<name>` | タスク実装用 |
| `spec/<id>-<name>` | スペック変更用 |
| `fix/<description>` | バグ修正用 |

---

## 4. TDD & 自己改善ループ

### 4-1. VPS環境
- 各開発者にVPSを割当
- `scripts/setup_vps.sh` で共通セットアップ
- テスト実行: `scripts/run-tests.sh`

### 4-2. TDDルール
- **スペック → テスト → 実装** の順で進行
- テストは必ずSpecの受け入れ条件に紐づける
- テストファイル内で `@spec: specs/<file>.md` でトレーサビリティを記録

### 4-3. 自己改善ループ
```
テスト失敗
  → 原因分析（実装バグ / 設計不備 / スペック不整合 / テスト不備）
  → 修正実施
  → 再テスト
  → 成功するまで繰り返し（上限5回）
  → 5回で未解決 → Issue作成・エスカレーション
```
詳細は `skills/self-improve.md` を参照。

### 4-4. 自己検証
```bash
# クイック検証（構造+スペック+テスト）
./scripts/self-verify.sh --quick

# フル検証（全項目）
./scripts/self-verify.sh --full
```

---

## 5. GitHub運用

### 5-1. PRルール
- PRは **Spec / Task / Code** のいずれかに分類
- PRテンプレート（`.github/pull_request_template.md`）に従い記入
- 必須項目: Specリンク・テスト結果・変更内容
- PR作成には `/commit-push-pr` スラッシュコマンドを活用

### 5-2. CI/CD
- **PR作成時**: GitHub Actionsで自動実行
  - スペック構造検証
  - プロジェクト構造検証
  - テスト実行（テストが存在する場合）
  - スペック変更時はSPEC-INDEX更新確認
- **VPS環境**: E2E・統合テスト

### 5-3. レビューフロー（PRレビュー → 学習サイクル）
1. PR作成 → CI自動実行
2. CI全パス → レビュー依頼
3. レビュー承認 → マージ
4. タスクステータス更新
5. **`/update-claude-md` でレビューの学びをCLAUDE.mdに記録**

このサイクルがチームの集合知を蓄積する最重要フィードバックループ。
PRレビューは単なるコード品質チェックではなく、ワークフロー改善の機会。

---

## 6. スラッシュコマンド（`.claude/commands/`）

チーム共有のワークフローコマンド。Claude Codeから `/コマンド名` で実行。

| コマンド | 用途 |
|----------|------|
| `/commit-push-pr` | コミット→プッシュ→PR作成を一括実行 |
| `/verify-app` | アプリ全体検証（最重要。品質2〜3倍） |
| `/build-validator` | ビルド・リント・型チェック検証 |
| `/code-simplifier` | コード簡素化・不要コード削除 |
| `/plan-and-implement` | 計画→承認→TDD実装 |
| `/update-claude-md` | 学びをCLAUDE.mdに反映 |

---

## 7. スキル（自律実行手順）

エージェントが自律的に実行可能な手順書。詳細は `skills/` を参照。

| スキル | 実行タイミング | 目的 |
|--------|----------------|------|
| `test-run` | 実装後・PR前 | テスト実行・結果分析 |
| `spec-validate` | PR前・スペック更新時 | スペック整合性検証 |
| `self-improve` | テスト失敗時 | 自己改善ループ |
| `code-review` | PR前 | コード品質レビュー |
| `best-practices` | マイルストーン完了時 | 業界水準検証 |
| `spec-create` | 新機能企画時 | スペック作成支援 |
| `frontend-design` | UIタスク実装時 | フロントエンドデザイン品質 |

### スキルパイプライン
```
【実装完了】 test-run → code-review → best-practices → spec-validate
【テスト失敗】 test-run → self-improve → test-run → code-review
【新機能】 spec-create → spec-validate → test-run(Red) → 実装 → test-run(Green)
【UI実装】 frontend-design(Step1) → test-run(Red) → 実装 → frontend-design(Step2-5) → test-run(Green) → code-review
```

---

## 8. 軽量でスピード感を出すための原則
- **Spec > Code** を徹底（スペックがあればコードは再生成可能）
- PRは小さく、1タスク1PR
- テンプレートを活用し、レビューを高速化
- Agent Teamsで並列化してMVP開発を加速
- 自律実行スキルで人間の介入を最小化
- **検証ループを省略しない**（品質2〜3倍の効果）

---

## 9. 開始手順

### 新規プロジェクト開始
1. 本リポジトリをClone
2. `scripts/setup_vps.sh` でVPS環境をセットアップ
3. `docs/WORKFLOW.md`（本ファイル）で運用ルールを確認
4. `CLAUDE.md` で運用原則・スラッシュコマンドを把握
5. `.mcp.json` のMCPサーバーを必要に応じて有効化
6. `specs/` に最初のスペックを作成（`skills/spec-create.md` を参照）
7. `/plan-and-implement` で計画→承認
8. ClaudeCodeでMVP開発を開始（Agent Teams活用）
9. `/verify-app` で全検証を実行
10. MVP完了後に並列開発へ移行
