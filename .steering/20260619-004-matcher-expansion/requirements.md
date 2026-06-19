# 要求定義: Phase 4 — マッチャー拡充

| 項目 | 内容 |
|---|---|
| 機能名 | マッチャー拡充 (Phase 4) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`src/Vitest.res` の expect マッチャーは充実しているが、Vitest 4.1.9 の
**型・述語マッチャー**（`toBeTypeOf` / `toBeInstanceOf` / `toBeOneOf` / `toSatisfy`）と
**非同期モックの resolve 系マッチャー**（`toHaveResolved*`）が未実装（見積もり計画 M1 / M9）。

### 目的

型判定・述語ベースのアサーションと、async モックの解決値検証を faithful な薄い FFI として追加する。

## 2. 変更・追加する機能の説明

**M1 — 型・述語マッチャー（`src/Vitest.res`）:**
- `toBeTypeOf` — `typeof` による型名一致（`"string"`/`"number"` 等）
- `toBeInstanceOf` — `instanceof` によるクラス一致
- `toBeOneOf` — 候補配列のいずれかに一致
- `toSatisfy` — 述語関数 `'a => bool` を満たす

**M9 — resolve 系 mock マッチャー（`src/Vitest.res` mock matchers）:**
- `toHaveResolved` — 少なくとも一度 Promise が解決した
- `toHaveResolvedTimes` — 指定回数解決した
- `toHaveResolvedWith` — 指定値で解決した
- `toHaveLastResolvedWith` — 最後の解決値が指定値
- `toHaveNthResolvedWith` — n 番目の解決値が指定値

対応するドッグフードテストを `__tests__/Expect_test.res`（M1）/ `__tests__/Vi_test.res`（M9）に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 利用者 | `expect(x)->toSatisfy(pred)` | 述語で柔軟に検証できる |
| 2 | 利用者 | `expect(v)->toBeOneOf([a, b, c])` | 候補集合への所属を検証できる |
| 3 | 利用者 | await 後 `mock->...->toHaveResolvedWith(v)` | async モックの解決値を検証できる |

## 4. 受け入れ条件

- [ ] M1 の 4 マッチャーと M9 の 5 マッチャーが `src/Vitest.res` に追加されている
- [ ] 各マッチャーにコメント規約準拠のドキュメントコメントが付与されている
- [ ] 各マッチャーのドッグフードテストが併設され、全件パスする
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項・スコープ判断

- **`toMatchFileSnapshot`（L4）は本フェーズ対象外**とする。理由: ディスク上にスナップショットファイル成果物を生成し、その更新・管理ライフサイクルが必要になるため。既存のスナップショットマッチャー（`toMatchSnapshot` 等）も型チェックのみでドッグフードテストを持たない前例があり、クリーンに検証できない。将来スナップショット専用ユニットでまとめて扱う。
- `toBeTypeOf` の型引数は Vitest が受け取る文字列（`"string"` 等）をそのまま `string` で束ねる（既存 `toMatch` 等と一貫。型付き variant 化は将来拡張）。
- resolve 系マッチャーは同期マッチャーだが、解決値を記録するため検証前に mock の Promise を `await` する。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 4, M1/M9/L4）
- Phase 3 ステアリング: `.steering/20260619-003-lifecycle-hooks/`
