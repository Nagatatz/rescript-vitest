# 設計: Phase 5 — 非同期タイマー・待機・アクセサスパイ

| 項目 | 内容 |
|---|---|
| 機能名 | 非同期タイマー・待機・アクセサスパイ (Phase 5) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/Vi.res` に既存 `@module("vitest") @scope("vi")` パターンで追加する。
M3/M4 は「Fake timers」セクション、M2 は新規「Waiting」セクション、M10 は spyOn の近傍。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vi.res` | M2/M3/M4/M10 の external（M10 は let ラッパ含む）を追加 | 修正 |
| `__tests__/Vi_test.res` | 各 API の検証テストを追加 | 修正 |

### 追加する external

```rescript
// M2 — Waiting
@module("vitest") @scope("vi") external waitFor: (unit => 'a) => promise<'a> = "waitFor"
@module("vitest") @scope("vi") external waitUntil: (unit => 'a) => promise<'a> = "waitUntil"

// M3 — async fake timers
@module("vitest") @scope("vi") external advanceTimersByTimeAsync: int => promise<unit> = "advanceTimersByTimeAsync"
@module("vitest") @scope("vi") external runAllTimersAsync: unit => promise<unit> = "runAllTimersAsync"
@module("vitest") @scope("vi") external runOnlyPendingTimersAsync: unit => promise<unit> = "runOnlyPendingTimersAsync"
@module("vitest") @scope("vi") external advanceTimersToNextTimerAsync: unit => promise<unit> = "advanceTimersToNextTimerAsync"
@module("vitest") @scope("vi") external advanceTimersToNextFrame: unit => unit = "advanceTimersToNextFrame"

// M4 — timer inspection
@module("vitest") @scope("vi") external isFakeTimers: unit => bool = "isFakeTimers"
@module("vitest") @scope("vi") external getTimerCount: unit => int = "getTimerCount"
@module("vitest") @scope("vi") @return(nullable) external getMockedSystemTime: unit => option<Date.t> = "getMockedSystemTime"
@module("vitest") @scope("vi") external getRealSystemTime: unit => float = "getRealSystemTime"

// M10 — accessor spies
@module("vitest") @scope("vi") external spyOnAccessor: ('obj, string, string) => MockFn.t<'fn> = "spyOn"
let spyOnGetter = (obj, key) => spyOnAccessor(obj, key, "get")
let spyOnSetter = (obj, key) => spyOnAccessor(obj, key, "set")
```

## 3. データ構造の変更

なし（`getMockedSystemTime` のみ `@return(nullable)` で option 化）。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vi.res` の公開 API 追加のみ。既存 API は不変で後方互換。

### 間接的な影響

- ドキュメント（README の `Vi` Timers/Waiting/Create 行、EN/JA changelog）更新（仕上げ）。
- テストに getter/setter オブジェクト生成用の `%%raw` ファクトリと `@get`/`@set` アクセサ binding を追加。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| `waitFor`/`waitUntil` のオプション | コールバックのみ / +options | コールバックのみ | デフォルトで十分・最小。options 版は将来 |
| `getMockedSystemTime` 戻り | `Date.t` / `option<Date.t>` | `option<Date.t>` | `null` を返しうる。`@return(nullable)` |
| アクセサスパイの型付け | 文字列引数を露出 / let ラッパ | let ラッパ | 呼び出し側で `"get"`/`"set"` を意識させず型安全 |
| `advanceTimersToNextFrame` | 同期 / async | 同期 | Vitest 側が同期 API |
| `setTimerTickMode` | 含める / 外す | 外す | ニッチ・引数形 awkward・検証困難（requirements 参照） |
