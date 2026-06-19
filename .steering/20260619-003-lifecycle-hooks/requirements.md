# 要求定義: Phase 3 — テストライフサイクルフック

| 項目 | 内容 |
|---|---|
| 機能名 | テストライフサイクルフック (Phase 3) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`src/Vitest.res` のライフサイクルフックは `beforeAll`/`afterAll`/`beforeEach`/`afterEach`
（同期・async）を備えるが、Vitest 4.1.9 の **テスト単位フック** `onTestFailed` / `onTestFinished`
が未実装（見積もり計画の優先度「高」H5）。これらはテスト本体内で登録し、当該テストの
失敗時 / 終了時にクリーンアップやデバッグ出力を行う用途で頻用される。

### 目的

`onTestFailed` / `onTestFinished` を faithful な薄い FFI として追加する。

## 2. 変更・追加する機能の説明

`src/Vitest.res` のライフサイクルフックセクションに以下を追加する。

- `onTestFailed` — 現在のテストが失敗したときに実行されるコールバックを登録
- `onTestFinished` — 現在のテストが（成否問わず）終了したときに実行されるコールバックを登録
- それぞれの async バリアント（`onTestFailedAsync` / `onTestFinishedAsync`）

対応するドッグフードテストを `__tests__/Vi_test.res`（または `Expect_test.res`）に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 利用者 | テスト本体内で `onTestFinished(() => cleanup())` | テスト終了時にクリーンアップが走る |
| 2 | 利用者 | テスト本体内で `onTestFailed(() => dumpState())` | テスト失敗時のみデバッグ出力が走る |

## 4. 受け入れ条件

- [ ] `onTestFailed` / `onTestFinished` と各 async バリアントが `src/Vitest.res` に追加されている
- [ ] 各 API にコメント規約準拠のドキュメントコメントが付与されている
- [ ] ドッグフードテストが併設され、全件パスする
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項

- コールバックは Vitest 側でテストコンテキスト引数を受け取るが、既存ライフサイクルフック
  （`beforeAll` 等）と同様に `unit => unit` / `unit => promise<unit>` で束ね、引数は無視する。
- `onTestFailed` の「失敗時に発火する」挙動の強検証は、意図的に失敗するテストが必要で
  スイートを失敗させてしまうため本フェーズでは行わない（`test.fails` は Phase 7）。
  本フェーズではスモークテスト（成功テスト内で登録し例外が出ないこと）で検証する。
  `onTestFinished` は ref を用いた挙動テストで実発火を検証する。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 3, H5）
- Phase 2 ステアリング: `.steering/20260619-002-vi-mock-core/`
