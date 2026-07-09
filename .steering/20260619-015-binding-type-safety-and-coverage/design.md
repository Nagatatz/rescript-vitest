# 設計: バインディング型安全性強化・Vitest 4 API 補完・ドッグフードカバレッジ整備

| 項目 | 内容 |
|---|---|
| 機能名 | binding-type-safety-and-coverage |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

3 つの独立した改良を 1 worktree 内で順に実装する。各改良はコード変更とテストをセットでコミットする。

1. **型安全化**: 閉じた union を polymorphic variant に置換。引数なし poly variant は ReScript ランタイムで自身のタグ名の文字列にコンパイルされる（`#v8` → `"v8"`）ため、FFI の挙動は不変で型だけ締まる。
2. **API 補完**: Vitest 4.1.9 の型定義（`node_modules` で確認済み）に基づき新規 external を追加。
3. **テスト + ゲート**: ドッグフードテストの抜けを埋め、`vitest.config.js` にカバレッジ閾値を設定。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | `toBeTypeOf` を poly variant 化 / `aroundAll`・`aroundEach` 追加 | 修正 |
| `src/Vi.res` | `spyOnAccessor` を poly variant 化（ラッパー更新）/ `useFakeTimersWith`・`fakeTimerOptions` 追加 / `waitForWith`・`waitUntilWith`・`waitForOptions` 追加 | 修正 |
| `src/VitestConfig.res` | `coverageConfig.provider` を poly variant 化 | 修正 |
| `__tests__/Expect_test.res` | 未テストマッチャー（typeof/数値/スナップショット/toHaveReturned 等）追加 | 修正 |
| `__tests__/Vi_test.res` | ライフサイクル/同期タイマー/fn/mockRejectedValue/新 API テスト追加、弱いテストの挙動検証化 | 修正 |
| `__tests__/VitestConfig_test.res` | provider poly variant・未検証フィールドの round-trip テスト追加 | 修正 |
| `__tests__/Lifecycle_test.res` | ライフサイクルフック（around 含む）専用テスト | 新規（必要に応じて） |
| `vitest.config.js` | `coverage.thresholds` 追加 | 修正 |
| `README.md` | Features セクション追記 | 修正 |
| `sphinx-docs/` 該当ページ + `locale/ja/*.po` | 新 API 説明（日英） | 修正 |
| `sphinx-docs/user/changelog.md` | Unreleased セクション追記（日英） | 修正 |

## 3. データ構造の変更

### 新規型（`src/Vi.res`）

```rescript
// useFakeTimers のオプション（FakeTimerInstallOpts の主要フィールド）
type fakeTimerOptions = {
  now?: float,                       // 起点 epoch（ms）
  toFake?: array<string>,            // フェイクする timer メソッド名
  loopLimit?: int,
  shouldAdvanceTime?: bool,
  advanceTimeDelta?: int,
  shouldClearNativeTimers?: bool,
  ignoreMissingTimers?: bool,
}

// waitFor / waitUntil のオプション
type waitForOptions = {
  interval?: int,                    // チェック間隔（ms）
  timeout?: int,                     // タイムアウト（ms）
}
```

### poly variant 化（既存型の引数）

- `Vitest.toBeTypeOf`: 第2引数 → `[#bigint | #boolean | #"function" | #number | #object | #string | #symbol | #undefined]`
- `Vi.spyOnAccessor`: 第3引数 → `[#get | #set]`
- `VitestConfig.coverageConfig.provider`: `[#istanbul | #v8 | #custom]`

`#"function"` は予約語のためクォート表記。ランタイムでは `"function"` 文字列にコンパイルされる。

## 4. 影響範囲の分析

### 直接的な影響

- `toBeTypeOf` / `spyOnAccessor` / `coverage.provider` を文字列で呼んでいる既存コードはコンパイルエラーになる（破壊的変更）。リポジトリ内では `spyOnGetter`/`spyOnSetter` ラッパーが該当 → ラッパー側を `#get`/`#set` に更新して吸収する。ドッグフードテストの呼び出し箇所も更新する。

### 間接的な影響

- カバレッジ閾値ゲート導入により、今後バインドのみ追加してテストを欠くと CI が失敗する（意図した抑止力）。
- `coverage.thresholds` の値は実測に基づき設定するため、初回は `pnpm test:coverage` の出力を確認してから決定する。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| 閉じた union の型付け | string / poly variant / 通常 variant + @as | poly variant | 引数なし poly variant はタグ名文字列にコンパイルされ FFI 挙動が不変。`@as` 不要で最小。 |
| `pool`/`environment` | poly variant 化 / string 維持 | string 維持 | Vitest 型が `Builtin | (string & {})` の拡張可能 union。閉じるとカスタム値が表現不能になり faithful でなくなる。 |
| `aroundAll`/`aroundEach` の callback 型 | フル（runSuite+context+suite）/ 最小（runSuite のみ） | 最小（`(unit => promise<unit>) => promise<unit>`） | context/suite は現状アクセサ未整備。JS は余剰引数を無視するため `runSuite` のみで安全に動く。必要時に拡張。 |
| `suite` エイリアス | 追加 / 省略 | 省略 | `describe` の純粋エイリアスで新規能力ゼロ。API 表面を増やさない（minimal-change）。 |
| `useFakeTimers` オプション | 既存を可変に変更 / 別名 `useFakeTimersWith` 追加 | 別名追加 | 既存 `useFakeTimers: unit => unit` を壊さず、オプション版を共存させる（後方互換）。 |
| `waitFor` オプション | 既存を可変に変更 / 別名追加 | 別名 `waitForWith`/`waitUntilWith` 追加 | 同上。Vitest は `number | options` を取るが record 版に統一。 |
| カバレッジ閾値 | 固定 100% / 実測ベース / ゲート無し | **ゲート無し（文書化）** | 実測の結果、`external` はコンパイル時に消去され計測可能なランタイムコードがほぼ存在しない（VitestConfig.res.js は完全に空、Vitest/Vi.res.js も空モジュール+spy ラッパー 2 関数のみ）。statement/line % は未テストバインディングを検知できず、しきい値ゲートは無意味かつ誤解を招く。網羅性は「コンパイル（型チェック）+ 各バインディングを呼ぶドッグフードテスト」で担保し文書化する。`test:coverage` はローカル検査用に存置。 |
| around テストの配置 | 既存ファイルに追加 / 新規 Lifecycle_test.res | 実装時に判断 | ライフサイクルは副作用順序の検証が必要。独立ファイルが読みやすければ新規作成。 |
