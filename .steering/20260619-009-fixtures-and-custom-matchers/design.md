# 設計: Phase 9 — フィクスチャ・カスタムマッチャー

| 項目 | 内容 |
|---|---|
| 機能名 | フィクスチャ・カスタムマッチャー (Phase 9) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

実現可能な API を既存パターンで追加する。`testFor` は `testEach` の隣、
`assertions`/`hasAssertions`/`soft`/`poll`/`unreachable` は `module Expect` 内。
非対応 2 件は README に理由付きで明記する。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | `testFor` と `module Expect` への追加 | 修正 |
| `__tests__/Expect_test.res` | 検証テストを追加 | 修正 |
| `README.md` | 非対応 API（`test.extend`/`expect.extend`）の注記を追加 | 修正 |

### 追加する external

```rescript
// test.for — alongside testEach
@module("vitest") @scope("test") external testFor: array<'a> => (string, 'a => unit) => unit = "for"

// in module Expect
@module("vitest") @scope("expect") external assertions: int => unit = "assertions"
@module("vitest") @scope("expect") external hasAssertions: unit => unit = "hasAssertions"
@module("vitest") @scope("expect") external soft: 'a => assertion<'a> = "soft"
@module("vitest") @scope("expect") external poll: (unit => 'a) => asyncAssertion<'a> = "poll"
@module("vitest") @scope("expect") external unreachable: unit => 'a = "unreachable"
@module("vitest") @scope("expect") external unreachableWithMessage: string => 'a = "unreachable"
```

## 3. データ構造の変更

なし（既存 `assertion<'a>` / `asyncAssertion<'a>` を再利用）。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vitest.res` の API 追加のみ。既存 API は不変で後方互換。

### 間接的な影響

- README に「非対応 API」注記を追加。EN/JA changelog に実装分を追記。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| `soft` の戻り | `assertion<'a>` | `assertion<'a>` | 既存マッチャーをそのまま使える |
| `poll` の戻り | `asyncAssertion<'a>` | `asyncAssertion<'a>` | matcher が promise を返す。`Async` モジュールで await |
| `unreachable` の型 | `unit => 'a` | `unit => 'a` | throw するため never 相当。`toThrow` で検証可能 |
| `test.extend` | 実装 / 非対応 | **非対応** | フィクスチャ obj 型 + `use` 注入を型安全に表現不可。docs 明記 |
| `expect.extend` | 実装 / 非対応 | **非対応** | 登録マッチャーを `assertion<'a>` に型安全露出不可。マッチャー毎手動 `@send` が必要 |
| 非対応の周知 | コードコメント / README | README + steering | ユーザー可視に理由を残す |
