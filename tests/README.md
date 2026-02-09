# Tests

テストコードはスペックの受け入れ条件に紐づけて管理する。

## ディレクトリ構成
```
tests/
├── unit/         → 単体テスト
├── integration/  → 統合テスト
└── e2e/          → E2Eテスト
```

## ルール
- テストファイル内で対応するスペックを明記: `@spec: specs/<file>.md`
- テスト名にスペックの受け入れ条件IDを含める: `AC-1: ...`
- TDDの原則: テストを先に書き、失敗を確認してから実装

## 実行
```bash
# 全テスト
./scripts/run-tests.sh --all

# 変更ファイルに関連するテストのみ
./scripts/run-tests.sh --changed

# カバレッジ付き
./scripts/run-tests.sh --coverage
```

## テスト ↔ スペック対応例
```javascript
// @spec: specs/001-mvp.md
describe('AC-1: ユーザーがログインできること', () => {
  test('正しい認証情報でログイン成功', () => { ... });
  test('誤った認証情報でログイン失敗', () => { ... });
});
```
