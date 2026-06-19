# 設計: Phase 8 — asymmetric matchers

| 項目 | 内容 |
|---|---|
| 機能名 | asymmetric matchers (Phase 8) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/Vitest.res` に `module Expect = { ... }` を追加し、`expect` の静的メソッドを
`@module("vitest") @scope("expect")` で束ねる。各 matcher は **多相戻り値** とし、
`toEqual` 等の期待値位置に埋め込んだとき周囲の型に単一化させる。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | `module Expect`（asymmetric matchers）を追加 | 修正 |
| `__tests__/Expect_test.res` | 埋め込み検証テストを追加 | 修正 |

### 追加する external（`module Expect` 内）

```rescript
module Expect = {
  @module("vitest") @scope("expect") external anything: unit => 'a = "anything"
  @module("vitest") @scope("expect") external any: 'ctor => 'a = "any"
  @module("vitest") @scope("expect") external arrayContaining: array<'a> => 'b = "arrayContaining"
  @module("vitest") @scope("expect") external objectContaining: 'a => 'b = "objectContaining"
  @module("vitest") @scope("expect") external stringContaining: string => 'a = "stringContaining"
  @module("vitest") @scope("expect") external stringMatching: string => 'a = "stringMatching"
  @module("vitest") @scope("expect") external stringMatchingRegExp: RegExp.t => 'a = "stringMatching"
  @module("vitest") @scope("expect") external closeTo: float => 'a = "closeTo"
  @module("vitest") @scope("expect") external closeToWithPrecision: (float, int) => 'a = "closeTo"
}
```

In JS each compiles to `vitest.expect.<name>(...)`.

## 3. データ構造の変更

なし（distinct な matcher 型は導入しない）。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vitest.res` に namespaced API 追加のみ。既存マッチャーは不変で後方互換。

### 間接的な影響

- ドキュメント（README に asymmetric matchers 行、EN/JA changelog）更新（仕上げ）。
- `any` テスト用に JS コンストラクタ（`String`/`Number`）の `@val` binding を追加。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| matcher の型表現 | 多相戻り値 / distinct `asymmetricMatcher<'a>` 型 | 多相戻り値 | 既存マッチャーのシグネチャ変更不要・JS の埋め込み値の実態に忠実・最小 |
| 配置 | トップレベル / `module Expect` | `module Expect` | `expect` 関数と名前衝突せず namespace が明快 |
| `stringMatching`/`closeTo` の variant | 単一 / 文字列+正規表現・精度付き | variant 提供 | 既存 `toMatchRegExp`/`toBeCloseToWithDigits` の前例に倣う |
| 否定 asymmetric (`expect.not.*`) | 含める / 外す | 外す | ニッチ（requirements 参照） |
| PoC の扱い | 別途 PoC / 本実装で兼ねる | 本実装で兼ねる | build+test 成功が型整合の検証になる。失敗時は不可と判断し docs 明記 |
