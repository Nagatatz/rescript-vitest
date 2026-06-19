# 設計: Phase 10 — 仕上げ

| 項目 | 内容 |
|---|---|
| 機能名 | 仕上げ（ドキュメント＋残繰延） (Phase 10) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

既存パターンに従い `src/Vitest.res` / `src/Vi.res` へ external を追加。否定 asymmetric は
`module Expect` 内に `module Not` を入れ子にし `@scope(("expect", "not"))` で束ねる。
ドキュメントは README とsphinx を更新。

## 2. 追加する external

### `src/Vitest.res`

```rescript
// toMatchFileSnapshot（snapshot セクション）
@send external toMatchFileSnapshot: (assertion<'a>, string) => promise<unit> = "toMatchFileSnapshot"

// 条件付き test body の async 版（describe は body 同期のため対象外）
@module("vitest") @scope("test") external testSkipIfAsync: bool => (string, unit => promise<unit>) => unit = "skipIf"
@module("vitest") @scope("test") external testRunIfAsync: bool => (string, unit => promise<unit>) => unit = "runIf"

// it.* 変種
@module("vitest") @scope("it") external itTodo: string => unit = "todo"
@module("vitest") @scope("it") external itConcurrent: (string, unit => promise<unit>, ~timeout: int=?) => unit = "concurrent"
@module("vitest") @scope("it") external itEach: array<'a> => (string, 'a => unit) => unit = "each"
@module("vitest") @scope("it") external itFails: (string, unit => unit) => unit = "fails"
@module("vitest") @scope("it") external itSequential: (string, unit => unit) => unit = "sequential"
@module("vitest") @scope("it") external itSkipIf: bool => (string, unit => unit) => unit = "skipIf"
@module("vitest") @scope("it") external itRunIf: bool => (string, unit => unit) => unit = "runIf"

// 否定 asymmetric（module Expect 内）
module Not = {
  @module("vitest") @scope(("expect", "not")) external arrayContaining: array<'a> => 'b = "arrayContaining"
  @module("vitest") @scope(("expect", "not")) external objectContaining: 'a => 'b = "objectContaining"
  @module("vitest") @scope(("expect", "not")) external stringContaining: string => 'a = "stringContaining"
  @module("vitest") @scope(("expect", "not")) external stringMatching: string => 'a = "stringMatching"
  @module("vitest") @scope(("expect", "not")) external stringMatchingRegExp: RegExp.t => 'a = "stringMatching"
  @module("vitest") @scope(("expect", "not")) external closeTo: float => 'a = "closeTo"
  @module("vitest") @scope(("expect", "not")) external closeToWithPrecision: (float, int) => 'a = "closeTo"
}
```

### `src/Vi.res`

```rescript
@module("vitest") @scope("vi") external setTimerTickMode: string => unit = "setTimerTickMode"
```

## 3. データ構造の変更

なし。

## 4. 技術的な判断

| 判断項目 | 採用 | 理由 |
|---|---|---|
| describe の async 条件 body | 提供しない | describe body は suite 登録で常に同期。`describeSkipIf`/`describeRunIf` で十分 |
| 否定 asymmetric の配置 | `Expect.Not` 入れ子 | `expect.not.*` を素直に表す |
| `toMatchFileSnapshot` のテスト | 専用ディレクトリにファイル生成し commit | 初回生成で pass・再実行で比較。標準的運用 |
| `it.*` 網羅範囲 | `test.*` 対称分のみ | 全網羅は YAGNI |
| `test.extend`/`expect.extend` | 非対応維持 | 型安全 faithful 不可（ユーザー決定） |

## 5. 影響範囲

- 公開 API 追加とドキュメント更新のみ。既存 API は不変で後方互換。
- `__tests__/` にスナップショットファイル（`__file_snapshots__/`）が 1 つ追加される。
