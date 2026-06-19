# 設計: Phase 6 — グローバル/環境スタブ・モジュールモック補完

| 項目 | 内容 |
|---|---|
| 機能名 | グローバル/環境スタブ・モジュールモック補完 (Phase 6) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/Vi.res` に既存 `@module("vitest") @scope("vi")` パターンで追加する。
M6 は「Module mocking」セクション、M5 は新規「Global / environment stubs」セクション。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vi.res` | M5/M6 の external を追加 | 修正 |
| `__tests__/Vi_test.res` | 各 API の検証テストを追加 | 修正 |

### 追加する external

```rescript
// M6 — module mocking completion
@module("vitest") @scope("vi") external importActual: string => promise<'a> = "importActual"
@module("vitest") @scope("vi") external importMock: string => promise<'a> = "importMock"
@module("vitest") @scope("vi") external doUnmock: string => unit = "doUnmock"
@module("vitest") @scope("vi") external mockObject: 'a => 'a = "mockObject"
@module("vitest") @scope("vi") external dynamicImportSettled: unit => promise<unit> = "dynamicImportSettled"

// M5 — global / environment stubs
@module("vitest") @scope("vi") external stubGlobal: (string, 'a) => unit = "stubGlobal"
@module("vitest") @scope("vi") external stubEnv: (string, string) => unit = "stubEnv"
@module("vitest") @scope("vi") external unstubAllGlobals: unit => unit = "unstubAllGlobals"
@module("vitest") @scope("vi") external unstubAllEnvs: unit => unit = "unstubAllEnvs"
```

## 3. データ構造の変更

なし。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vi.res` の公開 API 追加のみ。既存 API は不変で後方互換。

### 間接的な影響

- ドキュメント（README の `Vi` Modules 行 + 新カテゴリ、EN/JA changelog）更新（仕上げ）。
- テストにグローバル/env 読み出し用の `@val` binding を追加（`stubGlobal`/`stubEnv` 検証）。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| `stubEnv` 値型 | `string` / generic | `string` | `process.env` は文字列 |
| `stubGlobal` 値型 | generic `'a` / 固定 | generic `'a` | 任意の差し替え値に対応 |
| `importActual`/`importMock` 戻り | generic `promise<'a>` | generic `promise<'a>` | モジュール型は呼び出し側で注釈 |
| `mockObject` 型 | `'a => 'a` | `'a => 'a` | 入力と同形・メソッドのみモック化 |
| `doUnmock`/`dynamicImportSettled` 検証 | 強検証 / スモーク | スモーク | 単独で副作用を作るのが難しい（requirements 参照） |
