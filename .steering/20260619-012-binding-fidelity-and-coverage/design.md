# 設計: バインディング忠実性の修正とドッグフード網羅

| 項目 | 内容 |
|---|---|
| 機能名 | binding-fidelity-and-coverage |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

2 部構成で進める。

- **Part A — 実 API 不一致の修正（破壊的）**: 3 箇所のシグネチャを実 API に合わせる。`TestContext` と `disposable` は opaque type として導入し、最小限の表現に留める。
- **Part B — ドッグフード網羅**: 公開済みで未行使の API にテストを追加する。Part A の修正対象（onTestFailed / doMock / setTimerTickMode）の回帰テストも Part B のテスト追加で同時に満たす。

各タスクは「実装 → `pnpm build` → `pnpm test`」の検証ループで確認する。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | `TestContext` opaque type を追加し、`onTestFailed` / `onTestFailedAsync` / `onTestFinished` / `onTestFinishedAsync` のコールバック型を `TestContext => unit` / `TestContext => promise<unit>` に変更 | 修正 |
| `src/Vi.res` | `disposable` opaque type を追加し `doMock` の戻り値を `disposable` に変更。`setTimerTickModeWithInterval` を追加 | 修正 |
| `__tests__/Vitest_*` / `Expect_test.res` | onTestFailed/onTestFinished の回帰テスト、未検証 expect マッチャーのテストを追加 | 修正 |
| `__tests__/Vi_test.res` | doMock / setTimerTickMode の回帰テスト、未検証 mock API のテストを追加 | 修正 |
| `__tests__/VitestConfig_test.res` | `defineConfigFn` 等の未検証 config テストを追加 | 修正 |
| `README.md` | API チートシート更新 + 破壊的変更の明記 | 修正 |
| `sphinx-docs/user/changelog.md`（+ ja .po） | 破壊的変更を changelog に記載 | 修正 |

## 3. データ構造の変更

新規 opaque type を 2 つ導入する。

```rescript
// src/Vitest.res
/** Per-test context passed to `onTestFailed` / `onTestFinished` callbacks. */
type testContext

// src/Vi.res
/** Disposable handle returned by `vi.doMock` (usable with `using`). */
type disposable
```

いずれもフィールドアクセサは設けない（minimal-change）。`TestContext` を expect で使う等の要求が出た時点で拡張する。

`setTimerTickMode` は既存（`string => unit`）を残しつつ、`"interval"` 用に別関数を追加する方針:

```rescript
/** `setTimerTickMode("interval", interval)` — advance on a fixed interval. */
@module("vitest") @scope("vi")
external setTimerTickModeWithInterval: (string, int) => unit = "setTimerTickMode"
```

> 既存パターン（`*With` / `*WithName` 等の補助関数を追加する流儀）に揃える。`setTimerTickMode` 自体のシグネチャは非破壊で維持。

## 4. 影響範囲の分析

### 直接的な影響

- `onTestFailed` / `onTestFinished` 系を `() => ...` で呼んでいた既存利用コードはコンパイルエラーになる（破壊的）。本リポジトリ内の利用箇所は `__tests__/` のみで、同時修正する。
- `doMock` の戻り値を `unit` として束縛していたコードは型変更の影響を受けるが、戻り値を無視する呼び出し（`doMock(...)->ignore` 不要、文として呼ぶ）は影響なし。

### 間接的な影響

- README / changelog の記述更新が必要（documentation.md 規約）。
- 外部利用者には破壊的だが v0.1.0 のため許容（requirements.md 制約参照）。

## 5. 対象 API 一覧（Part B ドッグフード網羅）

調査で「公開済みだが未検証」と判明した API。優先度高・中を本作業の対象とする。

### expect マッチャー（`Expect_test.res`）

| API | 優先度 | 備考 |
|---|---|---|
| `toStrictEqual` / `Async.toStrictEqual` | 高 | `toEqual` との差分検証 |
| `toBeUndefined` / `toBeDefined` / `toBeNaN` | 高 | truthiness 群の穴 |
| `toThrowRegExp` | 高 | 正規表現形式 |
| `not_` の追加組み合わせ（`not_->toHaveBeenCalled` 等） | 中 | 実運用頻出パターン |
| `Async.toEqual` | 中 | resolves/rejects の等値系 |
| `toHaveBeenLastCalledWith2` | 中 | 2 引数版 |

### Vi モック / タイマー（`Vi_test.res`）

| API | 優先度 | 備考 |
|---|---|---|
| `MockFn.calls` / `MockFn.results` | 高 | 最頻出の mock inspection |
| `MockFn.mockReturnValueOnce` / `mockImplementationOnce` | 高 | Once 系の穴 |
| `MockFn.mockClear` / `mockReset`（個別呼び出し） | 高 | 効果差の検証 |
| `Vi.resetAllMocks` / `restoreAllMocks` | 中 | bulk 操作の穴 |
| `Vi.doMock`（回帰） | 高 | Part A 修正の回帰 |
| `Vi.setTimerTickModeWithInterval`（回帰） | 高 | Part A 追加の回帰 |

### テスト構造 / フック（`Expect_test.res` または新規）

| API | 優先度 | 備考 |
|---|---|---|
| `describeAsync` | 高 | 呼び出し型が他 describe と異なる |
| `onTestFailed` / `onTestFinished`（回帰） | 高 | Part A 修正の回帰。TestContext を受ける形 |

### VitestConfig（`VitestConfig_test.res`）

| API | 優先度 | 備考 |
|---|---|---|
| `defineConfigFn`（関数形式） | 中 | `configEnv` クロージャ形式 |

> 低優先度（`it` 基本形 / `testOnly` 系の単純修飾子等）は本作業の対象外とし、必要なら別 steering で扱う。スキップ理由は tasklist.md に明記する。

## 6. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| onTestFailed の互換性 | 破壊的修正 / 新関数追加 | 破壊的修正 | v0.1.0 初版・利用限定。型の嘘を残さない（ユーザー選択） |
| TestContext / disposable の表現 | opaque / record 詳細化 | opaque | minimal-change。フィールド要求が出るまで拡張しない |
| setTimerTickMode の interval | 既存破壊 / 別関数追加 | 別関数 `*WithInterval` | 既存 `string => unit` 利用を壊さず、`*With` 命名の既存流儀に揃う |
| 網羅対象の範囲 | 全15項目 / 高中のみ | 高中のみ | YAGNI。低優先の単純修飾子は別 steering 候補 |
