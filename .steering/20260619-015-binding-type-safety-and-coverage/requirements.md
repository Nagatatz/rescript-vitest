# 要求定義: バインディング型安全性強化・Vitest 4 API 補完・ドッグフードカバレッジ整備

| 項目 | 内容 |
|---|---|
| 機能名 | binding-type-safety-and-coverage |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`@nagatatz/rescript-vitest` のコードレビュー（src バインディング本体 + `__tests__` ドッグフード）の結果、以下の改良余地が判明した。

1. **型安全性の取りこぼし**: `string` で受けている引数が、実際は閉じた union 値（`toBeTypeOf` の typeof / `spyOnAccessor` の `get`/`set` / `coverage.provider`）。コンパイル時に弾けるはずの値が実行時まで検出されない。型安全がこのライブラリの中核価値であるため強化したい。
2. **Vitest 4 主要 API の未バインド**: `aroundAll` / `aroundEach`（Vitest 4 の新ライフサイクルフック、`node_modules` で実在を確認）、`useFakeTimers` のオプション、`waitFor`/`waitUntil` のオプションが未対応。
3. **ドッグフードテストの抜け**: バインド済みだが一度も呼ばれていない API（ライフサイクルフック async 版・スナップショットマッチャー・同期タイマー群など）があり、シグネチャ破壊を検知できない。CI のカバレッジゲートも未設定。

### 目的

- 閉じた union 引数を polymorphic variant で型付けし、無効値をコンパイル時に排除する。
- Vitest 4.1 で実在する主要 API（aroundAll/aroundEach、fake timer オプション、waitFor オプション）をバインドする。
- バインド済み API のドッグフードテストの抜けを埋め、`vitest.config.js` にカバレッジ閾値ゲートを設定して回帰を CI で自動検知する（Verification-first）。

## 2. 変更・追加する機能の説明

### A. 型安全性（閉じた union の poly variant 化）

| 対象 | 現状 | 変更後 |
|---|---|---|
| `Vitest.toBeTypeOf` 第2引数 | `string` | `[#bigint \| #boolean \| #"function" \| #number \| #object \| #string \| #symbol \| #undefined]` |
| `Vi.spyOnAccessor` 第3引数 | `string` | `[#get \| #set]`（`spyOnGetter`/`spyOnSetter` ラッパーは存置し `#get`/`#set` を渡す） |
| `VitestConfig.coverageConfig.provider` | `string` | `[#istanbul \| #v8 \| #custom]` |

**据え置く（faithful 維持の判断）**: `VitestConfig.testConfig.pool` と `environment` は Vitest 型定義上 `BuiltinPool | (string & {})` / `BuiltinEnvironment | (string & {})` の**拡張可能** union。poly variant で閉じるとカスタム pool / カスタム environment パッケージが表現不能になるため、`string` のまま維持する。

### B. Vitest 4 API 補完

| 追加 API | シグネチャ（ReScript） | 備考 |
|---|---|---|
| `Vitest.aroundAll` | `((unit => promise<unit>) => promise<unit>) => unit` | コールバックは `runSuite` を受け取る |
| `Vitest.aroundEach` | `((unit => promise<unit>) => promise<unit>) => unit` | コールバックは `runTest` を受け取る |
| `Vi.useFakeTimersWith` | `fakeTimerOptions => unit` | `FakeTimerInstallOpts` の主要フィールドを optional record で |
| `Vi.waitForWith` | `(unit => 'a, waitForOptions) => promise<'a>` | `{interval?, timeout?}` |
| `Vi.waitUntilWith` | `(unit => 'a, waitForOptions) => promise<'a>` | 同上 |

**意図的に省略**: `suite`（`describe` の純粋エイリアスで新規能力なし。`describe` を既に公開しているため API 表面を増やさない）。`vi.mock`（ホイスティング版）はドッグフードが技術的に困難なためテスト省略（理由を tasklist に明記）。

### C. ドッグフードテスト + カバレッジゲート

- 未テストのバインド済み API にテストを追加（後述「受け入れ条件」）。
- 新規バインド API（B）のテストを追加。
- `expect(true)->toBeTruthy` 止まりの弱いテスト（`resetAllMocks`/`restoreAllMocks`/`doMock` 等）を、可能な範囲で挙動検証に置き換える。
- `vitest.config.js` に `coverage.thresholds` を設定し、実測値に基づくゲートを敷く。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | バインディング利用者 | `toBeTypeOf` に typo の typeof 文字列を渡す | コンパイルエラーになる |
| 2 | バインディング利用者 | `aroundAll`/`aroundEach` でスイート/テストを wrap する | ReScript からフックを登録できる |
| 3 | バインディング利用者 | `useFakeTimersWith` でタイマーオプションを渡す | 型付きでオプションを設定できる |
| 4 | メンテナ | バインドした API のシグネチャを壊す | ドッグフードテスト / カバレッジゲートが CI で失敗する |

## 4. 受け入れ条件

- [ ] `toBeTypeOf` / `spyOnAccessor` / `coverage.provider` が poly variant 型になり、無効値がコンパイルエラーになる
- [ ] `pool` / `environment` は `string` のまま維持されている（カスタム値が引き続き渡せる）
- [ ] `aroundAll` / `aroundEach` / `useFakeTimersWith` / `waitForWith` / `waitUntilWith` がバインドされ、それぞれドッグフードテストがある
- [ ] 以下の未テストだったバインド済み API にテストが追加されている: ライフサイクルフック（`beforeAll`/`beforeEach`/`afterAllAsync` 等）、スナップショット（`toMatchSnapshot`/`toMatchInlineSnapshot`/`toThrowErrorMatchingInlineSnapshot`）、`toBeLessThanOrEqual`、`toHaveReturned`、`fn`/`fnWith`、`mockRejectedValue`、同期タイマー（`runAllTimers`/`runAllTicks`/`runOnlyPendingTimers`/`advanceTimersToNextTimer`/`clearAllTimers`）、`setSystemTime`(Date 版)、VitestConfig の未検証フィールド
- [ ] `resetAllMocks`/`restoreAllMocks`/`doMock` の弱いテストが挙動検証に置き換わっている
- [ ] `vitest.config.js` に `coverage.thresholds` が設定され、`pnpm test:coverage` がゲートを満たして成功する
- [ ] `pnpm build` と `pnpm test` が全件成功する
- [ ] ドキュメント（README / sphinx-docs / changelog）が公開 API 追加・変更に追従している

## 5. 制約事項

- 薄い FFI バインディング層の設計哲学を厳守する（config wrapping をしない、過剰抽象を避ける、namespace 無しのフラット公開）。
- 拡張可能 union（`pool`/`environment`）を閉じないこと（faithful 維持）。
- Vitest 4.1.9 に実在する API のみバインドする（`node_modules` 型定義で検証済み）。
- 後方互換: 既存の公開 API シグネチャの破壊的変更は、型安全化に伴う3点（`toBeTypeOf`/`spyOnAccessor`/`provider`）に限定する。

## 6. 関連ドキュメント

- `docs/repository-structure.md` — リポジトリ構造定義書
- `.claude/rules/testing.md` — テスト規約（Verification-first）
- `.claude/rules/documentation.md` — ドキュメント管理規約（日英二言語整備）
