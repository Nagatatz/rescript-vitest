# 要求定義: Phase 1 — expect mock マッチャー

| 項目 | 内容 |
|---|---|
| 機能名 | expect mock マッチャー (Phase 1) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`@nagatatz/rescript-vitest` の現状 `src/Vitest.res` は mock 検証マッチャーとして
`toHaveBeenCalled` / `toHaveBeenCalledOnce` / `toHaveBeenCalledTimes` / `toHaveReturned`
のみを公開している（`src/Vitest.res:248-251`）。Vitest 4.1.9 が提供する
「**どの引数で呼ばれたか**」「**何を返したか**」を検証するマッチャー群が未実装で、
モック検証の実用上の欠落が大きい（見積もり計画の優先度「高」H1/H2）。

### 目的

mock の呼び出し引数・返り値を検証するマッチャーを faithful な薄い FFI として追加し、
ReScript からも Vitest 本来のモック検証が型付きで行えるようにする。

## 2. 変更・追加する機能の説明

`src/Vitest.res` の「Mock / spy matchers」セクションに以下を追加する。

**H1 — 呼び出し引数マッチャー:**
- `toHaveBeenCalledWith` — 指定引数で呼ばれたことを検証
- `toHaveBeenLastCalledWith` — 最後の呼び出しが指定引数であることを検証
- `toHaveBeenNthCalledWith` — n 番目の呼び出しが指定引数であることを検証
- `toHaveBeenCalledExactlyOnceWith` — 正確に 1 回、指定引数で呼ばれたことを検証

**H2 — 返り値マッチャー:**
- `toHaveReturnedTimes` — 指定回数だけ正常に返ったことを検証
- `toHaveReturnedWith` — 指定値を返したことを検証
- `toHaveLastReturnedWith` — 最後の返り値が指定値であることを検証
- `toHaveNthReturnedWith` — n 番目の返り値が指定値であることを検証

各マッチャーに対応するドッグフードテストを `__tests__/Expect_test.res` に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | バインディング利用者 | `expect(mock->Vi.MockFn.asAssertion)->toHaveBeenCalledWith(arg)` | 指定引数での呼び出しを型付きで検証できる |
| 2 | バインディング利用者 | `expect(mock->Vi.MockFn.asAssertion)->toHaveReturnedWith(value)` | mock の返り値を型付きで検証できる |
| 3 | バインディング利用者 | `toHaveBeenNthCalledWith(2, arg)` | n 番目の呼び出し引数を検証できる |

## 4. 受け入れ条件

- [ ] H1 の 4 マッチャー（必要な arity 変種含む）が `src/Vitest.res` に追加されている
- [ ] H2 の 4 マッチャーが `src/Vitest.res` に追加されている
- [ ] 各マッチャーにコメント規約準拠のドキュメントコメントが付与されている
- [ ] 各マッチャーのドッグフードテストが `__tests__/Expect_test.res` に併設され、全件パスする
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項

- **循環参照制約:** `assertion<'a>` 型は `Vitest.res`、`MockFn.t<'fn>` は `Vi.res` で定義され、`Vi.res` が `Vitest` に依存する。よって `Vitest.res` のマッチャーは `MockFn.t` を参照できず、既存 mock マッチャーと同様に `assertion<'a>` 上の generic 定義とする。
- 非推奨エイリアス（`toBeCalledWith` 等）は追加しない（`minimal-change.md` の YAGNI）。
- 既存マッチャーのシグネチャ・命名規約を変更しない（最小変更）。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 1, H1/H2）
- `docs/repository-structure.md` — レイヤー責務
