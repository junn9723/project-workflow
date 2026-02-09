# Tests

テストコードはスペックの受け入れ条件に紐づけて管理する。

## ディレクトリ構成
```
tests/
├── unit/         → 単体テスト
├── integration/  → 統合テスト
└── e2e/          → E2Eテスト（Playwright）
```

## ルール
- テストファイル内で対応するスペックを明記: `@spec: specs/<file>.md`
- テスト名にスペックの受け入れ条件IDを含める: `AC-1: ...`
- TDDの原則: テストを先に書き、失敗を確認してから実装

## 実行
```bash
# ユニット/統合テストのみ
./scripts/run-tests.sh --unit

# E2Eテストのみ（Playwright）
./scripts/run-tests.sh --e2e

# 全テスト（ユニット + E2E）
./scripts/run-tests.sh --all

# 変更ファイルに関連するテストのみ
./scripts/run-tests.sh --changed

# カバレッジ付き
./scripts/run-tests.sh --coverage
```

## テスト ↔ スペック対応例

### ユニットテスト（Jest / Vitest / pytest）
```javascript
// @spec: specs/001-feature.md
describe('AC-1: ユーザーがログインできること', () => {
  test('正しい認証情報でログイン成功', () => { ... });
  test('誤った認証情報でログイン失敗', () => { ... });
});
```

### E2Eテスト（Playwright）
```javascript
// @spec: specs/001-feature.md
const { test, expect } = require('@playwright/test');

test.describe('AC-1: ログイン画面', () => {
  test('ユーザーがブラウザからログインできる', async ({ page }) => {
    await page.goto('/login');
    await page.fill('#email', 'user@example.com');
    await page.fill('#password', 'password');
    await page.click('#login-btn');
    await expect(page.locator('#dashboard')).toBeVisible();
  });
});
```

## E2E (Playwright) セットアップ

```bash
# Playwrightインストール
npm install --save-dev @playwright/test
npx playwright install chromium

# 設定ファイルをテンプレートからコピー
cp templates/playwright.config.js playwright.config.js

# E2Eテスト実行
npx playwright test

# UIモードで実行（デバッグ用）
npx playwright test --ui
```

### E2Eテストの設計指針
- **各テストは独立**: テスト間で状態を共有しない（リセットAPIを使用）
- **スペックのユースケースに準拠**: UC-1, UC-2... をE2Eでカバー
- **安定性重視**: セレクタはID/data属性を使用、タイミングはawaitで制御
- **CI対応**: headlessモード、失敗時のスクリーンショット保存
