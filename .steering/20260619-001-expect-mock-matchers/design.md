# 設計: Phase 1 — expect mock マッチャー

| 項目 | 内容 |
|---|---|
| 機能名 | expect mock マッチャー (Phase 1) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/Vitest.res` の「Mock / spy matchers」セクション（`src/Vitest.res:244-251`）に、
既存 `toHaveBeenCalledTimes`（`:250`）と同じ `@send external` パターンで追加する。
faithful binding 方針（JS 名へそのまま委譲、失敗時は Vitest が例外を投げる）を踏襲。

引数を取るマッチャーは Vitest 側で可変長引数（rest args）だが、ReScript の `@send` は
固定 arity でコンパイルされる。既存の `fn0`/`fn1`/`fn2`・`toBeCloseTo`/`toBeCloseToWithDigits`
と同じ「同一 JS 名に複数 ReScript binding」の慣行に倣い、**arity-1 を主、arity-2 を変種**
として提供する（`<name>` / `<name>2`）。3 引数以上は YAGNI で本フェーズ対象外（必要時に追加）。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | Mock matchers セクションに H1/H2 の external を追加 | 修正 |
| `__tests__/Expect_test.res` | `describe("Expect — mock matchers", ...)` を追加し各マッチャーを検証 | 修正 |

### 追加する external（H1 — 呼び出し引数）

```rescript
@send external toHaveBeenCalledWith: (assertion<'a>, 'b) => unit = "toHaveBeenCalledWith"
@send external toHaveBeenCalledWith2: (assertion<'a>, 'b, 'c) => unit = "toHaveBeenCalledWith"
@send external toHaveBeenLastCalledWith: (assertion<'a>, 'b) => unit = "toHaveBeenLastCalledWith"
@send external toHaveBeenLastCalledWith2: (assertion<'a>, 'b, 'c) => unit = "toHaveBeenLastCalledWith"
@send external toHaveBeenNthCalledWith: (assertion<'a>, int, 'b) => unit = "toHaveBeenNthCalledWith"
@send external toHaveBeenNthCalledWith2: (assertion<'a>, int, 'b, 'c) => unit = "toHaveBeenNthCalledWith"
@send external toHaveBeenCalledExactlyOnceWith: (assertion<'a>, 'b) => unit = "toHaveBeenCalledExactlyOnceWith"
@send external toHaveBeenCalledExactlyOnceWith2: (assertion<'a>, 'b, 'c) => unit = "toHaveBeenCalledExactlyOnceWith"
```

### 追加する external（H2 — 返り値）

```rescript
@send external toHaveReturnedTimes: (assertion<'a>, int) => unit = "toHaveReturnedTimes"
@send external toHaveReturnedWith: (assertion<'a>, 'b) => unit = "toHaveReturnedWith"
@send external toHaveLastReturnedWith: (assertion<'a>, 'b) => unit = "toHaveLastReturnedWith"
@send external toHaveNthReturnedWith: (assertion<'a>, int, 'b) => unit = "toHaveNthReturnedWith"
```

## 3. データ構造の変更

なし（既存の `assertion<'a>` を再利用。新規型は導入しない）。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vitest.res` の公開 API 追加のみ。既存マッチャーのシグネチャは不変のため後方互換。

### 間接的な影響

- `__tests__/Expect_test.res` に mock を使うテストを追加するため `Vi` モジュールへの依存が増えるが、テストファイルでは既に `open Vitest`、`Vi` は完全修飾で利用可能。
- ドキュメント（`README.md` Features / `sphinx-docs/` / changelog）の更新が必要（Phase 3 仕上げで実施）。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| マッチャーの配置 | (A) Vitest.res に generic / (B) Vi.res に MockFn.t 制約付き | A | `Vi.res`→`Vitest` 依存により循環参照不可。既存 mock マッチャーも Vitest.res で generic。一貫性優先 |
| 可変長引数の扱い | (A) arity 変種 / (B) tuple / (C) array | A | `@send` は固定 arity。tuple/array は JS の rest args と不整合。既存 fn0/1/2 慣行に一致 |
| 提供 arity | 1〜2 / 1〜3+ | 1〜2 | fn1/fn2 と同水準。3 引数以上は YAGNI、需要発生時に追加 |
| 引数の型付け | mock 署名に連動 / generic `'b` | generic `'b` | 循環参照制約により mock 署名を参照できない。既存 mock マッチャーと同じ generic 方針 |
