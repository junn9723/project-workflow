ビルドとリントの検証を実行してください。

## コンテキスト収集
```bash
cat package.json 2>/dev/null | head -30
ls -la tsconfig*.json 2>/dev/null
```

## 検証手順

### 1. リント
```bash
npm run lint 2>/dev/null || npx eslint . 2>/dev/null || echo "リンターなし"
```

### 2. 型チェック（TypeScriptの場合）
```bash
npx tsc --noEmit 2>/dev/null || echo "TypeScriptなし"
```

### 3. ビルド
```bash
npm run build 2>/dev/null || echo "ビルドスクリプトなし"
```

### 4. テスト（高速）
```bash
./scripts/run-tests.sh --unit
```

## 失敗時
- リントエラー → 自動修正を試みる（`npm run lint -- --fix`）
- 型エラー → エラー箇所を特定して修正
- ビルドエラー → エラーメッセージから原因を分析して修正
- テスト失敗 → skills/self-improve.md に従う

修正後は再度このコマンドを実行して全パスを確認してください。
