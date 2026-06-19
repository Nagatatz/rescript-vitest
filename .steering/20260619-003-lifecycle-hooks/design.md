# 設計: Phase 3 — テストライフサイクルフック

| 項目 | 内容 |
|---|---|
| 機能名 | テストライフサイクルフック (Phase 3) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/Vitest.res` のライフサイクルフックセクション（`src/Vitest.res:107-118`）末尾に、
既存 `beforeAll`/`beforeAllAsync` と同じ `@module("vitest")` パターンで追加する。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | ライフサイクルフックに `onTestFailed`/`onTestFinished`（同期・async）を追加 | 修正 |
| `__tests__/Vi_test.res` | 検証テストを追加 | 修正 |

### 追加する external

```rescript
@module("vitest") external onTestFailed: (unit => unit) => unit = "onTestFailed"
@module("vitest") external onTestFailedAsync: (unit => promise<unit>) => unit = "onTestFailed"
@module("vitest") external onTestFinished: (unit => unit) => unit = "onTestFinished"
@module("vitest") external onTestFinishedAsync: (unit => promise<unit>) => unit = "onTestFinished"
```

## 3. データ構造の変更

なし。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vitest.res` の公開 API 追加のみ。既存フックは不変で後方互換。

### 間接的な影響

- ドキュメント（README Features の `Vitest` フック行、EN/JA changelog）更新（Phase 4 仕上げ）。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| コールバック型 | コンテキスト引数を受ける / `unit => unit` | `unit => unit` | 既存ライフサイクルフックと一貫。引数は大半の用途で不要 |
| async 対応 | 同期のみ / 同期+async | 同期+async | `beforeAllAsync` 等と対称。async クリーンアップが必要なケースに対応 |
| `onTestFailed` の検証 | 失敗テストで実発火 / スモーク | スモーク | 失敗テストはスイートを落とす。`test.fails`(Phase 7) 導入後に強検証へ昇格可 |
| `onTestFinished` の検証 | スモーク / ref 挙動テスト | ref 挙動テスト | 成否問わず発火するため、ref を後続テストで検証でき実発火を確認できる |
