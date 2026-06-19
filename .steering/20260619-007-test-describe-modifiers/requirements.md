# 要求定義: Phase 7 — test/describe 修飾子

| 項目 | 内容 |
|---|---|
| 機能名 | test/describe 修飾子 (Phase 7) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`src/Vitest.res` のテスト構造修飾子は `only`/`skip`/`todo`/`concurrent`/`each`（test 側）と
`only`/`skip`/`each`（describe 側）を備えるが、Vitest 4.1.9 の **条件付き実行**（`skipIf`/`runIf`）、
**失敗予想**（`fails`）、**直列/並行/シャッフル**（`sequential`/`concurrent`/`shuffle`）、
**`describe.todo`/`describe.for`** が未実装（見積もり計画 M7 / M8）。

### 目的

条件付き・失敗予想・実行順制御の test/describe 修飾子を faithful な薄い FFI として追加する。

## 2. 変更・追加する機能の説明（すべて `src/Vitest.res`）

**M7 — test 修飾子:**
- `testSkipIf` — 条件が真ならスキップ（`bool => (string, body) => unit`）
- `testRunIf` — 条件が真なら実行
- `testFails` / `testFailsAsync` — テストが失敗することを期待（失敗で pass）
- `testSequential` / `testSequentialAsync` — 直列実行を強制

**M8 — describe 修飾子:**
- `describeTodo` — todo スイート（名前のみ）
- `describeConcurrent` — スイート内を並行実行
- `describeSequential` — スイート内を直列実行
- `describeShuffle` — スイート内をランダム順実行
- `describeSkipIf` / `describeRunIf` — 条件付きスイート
- `describeFor` — パラメータ化スイート（`each` の for 形）

対応するドッグフードテストを `__tests__/Expect_test.res` または `__tests__/Vi_test.res` に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 利用者 | `testSkipIf(isCI)("name", body)` | 条件付きでテストをスキップできる |
| 2 | 利用者 | `testFails("name", body)` | 失敗を期待するテストを書ける |
| 3 | 利用者 | `describeSequential("suite", ...)` | スイートを直列実行できる |
| 4 | 利用者 | `describeFor(cases)("name %i", case => ...)` | パラメータ化スイートを書ける |

## 4. 受け入れ条件

- [ ] M7 の 6 修飾子と M8 の 7 修飾子が `src/Vitest.res` に追加されている
- [ ] 各 API にコメント規約準拠のドキュメントコメントが付与されている
- [ ] 各 API のドッグフードテストが併設され、全件パスする
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項

- 条件付き修飾子（`skipIf`/`runIf`）と `describeFor` は、既存 `describeEach` と同じ
  「関数を返す external」パターン（`bool => (string, body) => unit` 等）で束ねる。
- `it.*` の重複バリアントは追加しない（`test.*` で代替可・`it` はエイリアス）。
- `skipIf`/`runIf` の body は同期（`unit => unit`）のみ提供（async body は将来拡張）。
- `describeTodo` は名前のみ受ける（コールバックなし）。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 7, M7/M8）
- Phase 6 ステアリング: `.steering/20260619-006-global-and-module-mocking/`
