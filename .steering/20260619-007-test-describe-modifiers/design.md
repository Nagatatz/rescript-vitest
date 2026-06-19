# 設計: Phase 7 — test/describe 修飾子

| 項目 | 内容 |
|---|---|
| 機能名 | test/describe 修飾子 (Phase 7) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/Vitest.res` のテスト構造セクションに、既存の `@module("vitest") @scope("test")` /
`@scope("describe")` パターンで追加する。条件付き・for 修飾子は既存 `describeEach`
（`array<'a> => (string, 'a => unit) => unit`）と同じ「関数を返す external」形を踏襲。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | M7（test）と M8（describe）の修飾子 external を追加 | 修正 |
| `__tests__/Expect_test.res` | M7/M8 の検証テストを追加 | 修正 |

### 追加する external（M7 — test）

```rescript
@module("vitest") @scope("test") external testSkipIf: bool => (string, unit => unit) => unit = "skipIf"
@module("vitest") @scope("test") external testRunIf: bool => (string, unit => unit) => unit = "runIf"
@module("vitest") @scope("test") external testFails: (string, unit => unit) => unit = "fails"
@module("vitest") @scope("test") external testFailsAsync: (string, unit => promise<unit>) => unit = "fails"
@module("vitest") @scope("test") external testSequential: (string, unit => unit) => unit = "sequential"
@module("vitest") @scope("test") external testSequentialAsync: (string, unit => promise<unit>) => unit = "sequential"
```

### 追加する external（M8 — describe）

```rescript
@module("vitest") @scope("describe") external describeTodo: string => unit = "todo"
@module("vitest") @scope("describe") external describeConcurrent: (string, unit => unit) => unit = "concurrent"
@module("vitest") @scope("describe") external describeSequential: (string, unit => unit) => unit = "sequential"
@module("vitest") @scope("describe") external describeShuffle: (string, unit => unit) => unit = "shuffle"
@module("vitest") @scope("describe") external describeSkipIf: bool => (string, unit => unit) => unit = "skipIf"
@module("vitest") @scope("describe") external describeRunIf: bool => (string, unit => unit) => unit = "runIf"
@module("vitest") @scope("describe") external describeFor: array<'a> => (string, 'a => unit) => unit = "for"
```

## 3. データ構造の変更

なし。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vitest.res` の公開 API 追加のみ。既存修飾子は不変で後方互換。

### 間接的な影響

- ドキュメント（README の Test structure 行、EN/JA changelog）更新（仕上げ）。
- テストは修飾子呼び出し自体が test/suite を登録する形になる（body の成否で検証）。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| 条件付き/for の型 | 関数を返す external | 関数を返す external | 既存 `describeEach` と一致。`scope` で `test.skipIf(c)(name, body)` に対応 |
| `skipIf`/`runIf` の body | 同期のみ / 同期+async | 同期のみ | 最小。async body は将来 |
| `fails`/`sequential` の async | 含める | 含める（`*Async`） | 失敗/直列の async ケースは頻出 |
| `it.*` 重複 | 追加 / 非追加 | 非追加 | `it` は `test` のエイリアス。重複を避ける（YAGNI） |
| `testFails` の検証 | 失敗 body を登録 | 失敗 body を登録 | `fails` は body 失敗で pass するため、意図的に失敗する body で検証可能 |
