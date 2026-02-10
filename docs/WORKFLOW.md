# 生成AI主導 開発ワークフロー

## 0. 前提
- GitHubを**唯一の情報ハブ**とする（仕様・タスク・議事録・エージェント運用・CI/CD）
- メイン開発エージェントは **ClaudeCode**、サブが **Codex**
- 成果物の中心は**スペック**であり、コードは再生成可能であることを前提にする
- 開発/テスト環境はVPS（人間の開発者ごとに割当）
- Agent Teams（ClaudeCode内の並列エージェント）を活用してMVP開発を加速
- **検証済みならmainに直接push**。PRは不要（スピード重視）

### 最重要原則: 検証ループ
**検証ループが成果物の品質を2〜3倍にする。省略は厳禁。**

```
実装 → /verify-app → 失敗 → self-improve（最大5回） → /verify-app → 成功 → push
```

検証なしでpushすることは禁止。`/verify-app`（`scripts/verify-app.sh`）はスペック検証・ユニットテスト・E2Eテスト・自己検証・**MVP証跡検証**を一括実行する。

---

## 1. リポジトリ設計

### 1-1. 情報の「唯一の参照点」
| 情報 | 場所 | 変更方法 |
|------|------|----------|
| 仕様 | `specs/` | 検証後にpush |
| タスク | `tasks/` | 担当者が更新 |
| エージェント運用 | `agents/` | 検証後にpush |
| スキル定義 | `skills/` | 検証後にpush |
| CI/CD | `.github/workflows/` | 検証後にpush |
| 運用ルール | `docs/` | 検証後にpush |

### 1-2. 仕様のバージョニング
- スペックは `specs/<NNN>-<name>.md` の形式で管理
- `specs/SPEC-INDEX.md` で全スペックの状態を一元管理
- 変更は必ず「差分」と「理由」を変更履歴に記載

---

## 2. ワークフロー全体像

### Phase A: 仕様策定（Spec First）
1. `templates/spec-template.md` を複製
2. `specs/` に新規Specを追加（`specs/<NNN>-<name>.md`）
3. `specs/SPEC-INDEX.md` を更新
4. `skills/spec-validate.md` の基準で品質チェック

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
6. 各implemented Specごとに `reports/spec-deliverables/<spec-file>.md` を作成
7. **`/verify-app` で全検証**（検証ループ必須）
8. **`/commit-push` でmainにpush**

### MVP完了ゲート（重要）
MVP完了は「テストが通る」だけでは不十分。**証跡 + 受け入れ条件の充足**が必須。

**必須条件**
- Specの受け入れ条件（AC）が全て満たされている
- `reports/mvp-evidence.md` に Spec: <ファイル名> の証跡がある
- `reports/spec-deliverables/<spec-file>.md` が提出されている（コード以外の成果物）
- `/verify-app` が全パスしている

**証跡の最低要件**
- デモ手順（短い手順でOK）
- 受け入れ条件のチェック（`[x]`）
- スクリーンショット or 動画（パス/リンク）
- Deliverable Doc（`reports/spec-deliverables/<spec-file>.md`）へのリンク

### Phase C: 並列開発開始
1. MVP + 本フレームワークをベースに並列開発を開始
2. Codexを含む複数エージェントで並列タスク実行
3. 並列作業時はブランチ分離を推奨（コンフリクト回避）
4. 仕様に影響する変更は先にSpecを更新
5. `/update-claude-md` で学びを蓄積

---

## 2-1. Codex組み込み方針（ClaudeCode主導）

ClaudeCodeは設計・調整・人間向けインターフェース（デザイン、日本語、小規模開発）を担い、Codexは定型化できる高負荷タスクを担当する。Codexへの依頼は `tasks/` に明示し、成果物フォーマットを統一する。

### Codexの担当領域
- 仕様書レビュー（`skills/spec-validate.md` の観点で差分指摘）
- 大規模テスト実行（`scripts/run-tests.sh --all` / `scripts/self-verify.sh --full`）
- コードレビュー（`skills/code-review.md` に準拠した観点整理）
- 実装（TDDサイクルでの機能実装）

### Codexタスクの標準テンプレ（推奨項目）
- `assignee: codex`
- `depends_on`: 先行Specやタスクを明示
- `done_criteria`: 完了条件（例: 実行コマンド、ログ保存先、レビュー出力形式）
- `artifacts`: 成果物の保存場所（例: `docs/reviews/` / `reports/tests/` など）

### 成果物フォーマットの統一例
- Specレビュー: 指摘箇所 / 根拠 / 修正提案
- テスト結果: 実行コマンド / 成否 / 失敗ログ抜粋
- コードレビュー: 変更概要 / 問題点 / 改善提案

---

## 2-2. AIエージェント オーケストレーション

**目的**: 仕様 → タスク → 実行 → 検証 → 統合を切れ目なく回し、並列化しても品質が落ちない仕組みを作る。

### オーケストレータ（ClaudeCode）の責務
- **全体設計とスコープ分割**: Specからタスクを「独立可能な単位」に切る
- **状態遷移の管理**: タスク状態（pending → in_progress → done）と担当の更新
- **品質ゲート管理**: `/verify-app` と各スキルパイプラインの順序保証
- **マネージャーログ管理**: Agent割当とSkill使用状況をサマリ記録
- **成果物の集約**: レビュー・テストログ・決定事項をGitHubに集約

### ジョブパケット（タスクの実行単位）
タスクファイルは「**ジョブパケット**」として扱い、以下を必ず含める。

- 目的/受け入れ条件
- 依存関係（depends_on）
- 実行範囲（変更ファイル or モジュール）
- 完了条件と成果物の保存先（artifacts）
- 失敗時のハンドオフ（escalation / fallback）

### 実行ループ（オーケストレーション・サイクル）
```
Spec更新
  ↓
タスク分解（ジョブパケット生成）
  ↓
リソース割当（ClaudeCode/Codex/Agent Teams）
  ↓
実装/検証（TDD + 自己改善ループ）
  ↓
成果物集約（レビュー/ログ/更新点）
  ↓
マネージャーログ記録（割当/Skill使用サマリ）
  ↓
統合検証（/verify-app）
  ↓
push → 学びをCLAUDE.mdに追記
```

### 競合回避の仕組み
- **Single-writerルール**: 1タスク1エージェント。共有ファイルは分割して割当
- **Lease（期限付き担当）**: 進捗が止まったタスクはpendingに戻す
- **マージ前の統合検証**: すべての変更は/verify-app経由

### 実行の可視化（Heartbeat）
- 進捗が止まった場合、**30分以上の無更新は再割当候補**
- 進捗はタスクの `status` と `notes` に記録
- タスク完了時に `reports/manager-logs/` へ割当・Skill使用サマリを保存

詳細は `docs/ORCHESTRATION.md` を参照。

---

## 3. コンフリクト/不整合対策

### 3-1. 仕様と実装の一貫性
- **Spec変更が先**、実装は後
- `specs/` 以外で仕様を書くことは禁止
- スペック ↔ テストのトレーサビリティを維持

### 3-2. タスクの粒度とルール
- `tasks/` に「実装単位のタスク」を定義
- タスクファイルで `status` / `assignee` を管理し、二重着手を防止

### 3-3. エージェントファイル共有
- `agents/` にClaude/Codex運用ガイドを置き、変更はpush運用
- 変更内容を `docs/CHANGELOG.md` に記録

### 3-4. ブランチ戦略
| ブランチ | 用途 |
|----------|------|
| `main` | 開発用（検証済みなら直接push） |
| `feature/*` | 任意。並列作業・リスクの高い変更時に使用 |
| `release/*` | 本番リリース用（リリース時のみ作成） |

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

# 統合検証（MVP証跡含む）
./scripts/verify-app.sh
```

---

## 5. GitHub運用

### 5-1. pushルール
- **検証済み → 即push**がデフォルト
- `/verify-app` が全パスしていることがpushの前提条件
- コミットメッセージは変更の「Why」を書く

### 5-2. CI/CD
- **push時**: GitHub Actionsで自動実行
  - スペック構造検証
  - プロジェクト構造検証
  - テスト実行（テストが存在する場合）

### 5-3. 学習サイクル
1. 作業中に発見した学びを特定
2. **`/update-claude-md` でCLAUDE.mdに記録**
3. チームの集合知を蓄積

---

## 6. スラッシュコマンド（`.claude/commands/`）

チーム共有のワークフローコマンド。Claude Codeから `/コマンド名` で実行。

| コマンド | 用途 |
|----------|------|
| `/commit-push` | コミット→mainにプッシュ |
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
| `test-run` | 実装後・push前 | テスト実行・結果分析 |
| `spec-validate` | push前・スペック更新時 | スペック整合性検証 |
| `self-improve` | テスト失敗時 | 自己改善ループ |
| `code-review` | push前 | コード品質レビュー |
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
- 検証済みなら即push（PRの儀式は不要）
- テンプレートを活用し、作業を高速化
- Agent Teamsで並列化してMVP開発を加速
- 自律実行スキルで人間の介入を最小化
- **検証ループを省略しない**（品質2〜3倍の効果）
- ブランチは必要な時だけ使う（デフォルトはmain直接push）

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
