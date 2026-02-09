アプリケーション全体の検証を実行してください。
これは最も重要なスキルです。検証ループがあると成果物の品質が2〜3倍になります。

## 検証ステップ

### Step 1: スペック整合性
```bash
./scripts/validate-spec.sh
```
スペックの構造・INDEX整合性・テストトレーサビリティを検証。

### Step 2: ユニット/統合テスト
```bash
./scripts/run-tests.sh --unit
```
全ユニットテストと統合テストを実行。

### Step 3: E2Eテスト
```bash
./scripts/run-tests.sh --e2e
```
Playwrightによるブラウザベースのエンドツーエンドテスト。

### Step 3.5: ビジュアル検証（UIタスクの場合）
UI関連の変更がある場合、Playwright MCPでスクリーンショット検証:
1. 主要画面のスクリーンショット取得（デスクトップ + モバイル）
2. `skills/frontend-design.md` の判定基準と照合
3. UI変更がない場合はスキップ

### Step 4: ビルド検証
プロジェクトのビルドが成功するか確認:
```bash
# package.jsonにbuildスクリプトがあれば実行
npm run build 2>/dev/null || echo "ビルドスクリプトなし"
```

### Step 5: 自己検証
```bash
./scripts/self-verify.sh --full
```

## 判定
- 全ステップ成功 → PASS（次の作業に進んでよい）
- いずれか失敗 → skills/self-improve.md に従って修正ループを実行

## 重要
検証なしでPRを作成しないでください。
「Claudeに検証手段を与えること」がワークフロー全体で最も重要です。
