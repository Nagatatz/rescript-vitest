# 要求定義: Phase 8 — asymmetric matchers

| 項目 | 内容 |
|---|---|
| 機能名 | asymmetric matchers (Phase 8) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

Vitest 4.1.9 の **asymmetric matchers**（`expect.any` / `expect.anything` /
`expect.arrayContaining` / `expect.objectContaining` / `expect.stringContaining` /
`expect.stringMatching` / `expect.closeTo`）は、`toEqual` / `toMatchObject` /
`toHaveBeenCalledWith` 等の **期待値位置に埋め込む特殊な値** として使う。見積もり計画では
「ReScript の型システムで faithful に表現できるか未検証」の要設計項目（L1）。

### 目的

asymmetric matchers を faithful な薄い FFI として追加し、既存マッチャーの期待値位置に
埋め込めることを PoC（=本実装の build+test）で確定する。

## 2. 変更・追加する機能の説明（`src/Vitest.res` に `module Expect`）

- `anything` — null/undefined 以外の任意の値にマッチ
- `any` — コンストラクタのインスタンスにマッチ
- `arrayContaining` — 指定要素をすべて含む配列にマッチ
- `objectContaining` — 指定サブセットを含むオブジェクトにマッチ
- `stringContaining` — 部分文字列を含む文字列にマッチ
- `stringMatching` / `stringMatchingRegExp` — パターン（文字列 / 正規表現）にマッチ
- `closeTo` / `closeToWithPrecision` — 数値近似にマッチ

対応するドッグフードテストを `__tests__/Expect_test.res` に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 利用者 | `toEqual({"id": Expect.anything()})` | 値の存在のみ検証できる |
| 2 | 利用者 | `toEqual(Expect.arrayContaining([1, 2]))` | 部分配列を検証できる |
| 3 | 利用者 | `toHaveBeenCalledWith(Expect.stringContaining("x"))` | 引数の部分一致を検証できる |

## 4. 受け入れ条件

- [ ] `module Expect` に上記 asymmetric matchers が追加されている
- [ ] 各 API にコメント規約準拠のドキュメントコメントが付与されている
- [ ] `toEqual` / `toMatchObject` / `toHaveBeenCalledWith` の期待値位置に埋め込むドッグフードテストが併設され、全件パスする（= PoC 成立）
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項・設計方針

- 各 matcher は **多相戻り値**（`anything: unit => 'a` 等）の external とし、期待値位置で
  周囲の期待型に単一化させる。これにより既存マッチャー（`toEqual` 等）のシグネチャを変更せずに
  asymmetric matcher を渡せる。distinct な `asymmetricMatcher<'a>` 型は導入しない（過剰）。
- `expect.not.<matcher>`（否定 asymmetric）は本フェーズ対象外（ニッチ）。
- もし多相戻り値アプローチが型エラー/実行時不整合を起こした場合は、design を見直し
  「ReScript で faithful 表現不可」と判断して docs に明記する（要設計フェーズの性質）。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 8, L1）
- Phase 7 ステアリング: `.steering/20260619-007-test-describe-modifiers/`
