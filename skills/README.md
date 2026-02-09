# Skills（自律実行スキル）

エージェントが自律的に実行可能な手順書（スキル）の定義。
各スキルは明確な入力・手順・出力・判定基準を持ち、人間の介入なしに完結できる。

## スキル一覧

| スキル | ファイル | 用途 | 実行タイミング |
|--------|----------|------|----------------|
| test-run | `test-run.md` | テスト実行・結果分析 | 実装後・PR前 |
| spec-validate | `spec-validate.md` | スペック整合性検証 | PR前・スペック更新時 |
| self-improve | `self-improve.md` | 自己改善ループ | テスト失敗時 |
| code-review | `code-review.md` | コード品質レビュー | PR前 |
| best-practices | `best-practices.md` | 業界水準検証 | マイルストーン完了時 |
| spec-create | `spec-create.md` | スペック作成支援 | 新機能企画時 |
| frontend-design | `frontend-design.md` | フロントエンドデザイン品質 | UIタスク実装時 |

## スキルの構造

各スキルは以下の構造で定義:

1. **目的**: 何を達成するか
2. **前提条件**: 実行に必要な状態
3. **手順**: ステップバイステップの実行手順
4. **判定基準**: 成功/失敗の判定方法
5. **失敗時の対応**: 失敗した場合の次のアクション
6. **出力**: 実行結果として生成されるもの

## 実行方法

エージェントは必要に応じてスキルファイルを読み込み、手順に従って自律実行する。
スキルの実行は `CLAUDE.md` の「自律実行スキル」セクションで定義されたタイミングに従う。

## スキルの組み合わせ（パイプライン）

### 実装完了パイプライン
```
test-run → code-review → best-practices → spec-validate
```

### 自己改善パイプライン
```
test-run → [失敗] → self-improve → test-run → [成功] → code-review
```

### 新機能パイプライン
```
spec-create → spec-validate → test-run(Red) → 実装 → test-run(Green)
```

### UI実装パイプライン
```
frontend-design(Step1) → test-run(Red) → 実装 → frontend-design(Step2-5) → test-run(Green) → code-review
```
