# 要求定義: バインディング忠実性の修正とドッグフード網羅

| 項目 | 内容 |
|---|---|
| 機能名 | binding-fidelity-and-coverage |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

改善調査（4領域横断）で、`src/` の一部バインディングが Vitest 4 の実 API と型シグネチャ上不一致であり、また公開済みだがドッグフードテストで一度も行使されていない API 群があることが判明した。前者は利用者が誤用・コンパイル不能に陥る原因となり、後者は本プロジェクトの最上位原則 Verification-first に反する負債である。

### 目的

1. 実 API と不一致な 3 箇所のバインディングを**正しい型に修正**する（破壊的変更を許容）。
2. 公開済みで未検証の主要 API にドッグフードテストを追加し、エクスポート面の検証カバレッジを引き上げる。

## 2. 変更・追加する機能の説明

### 実 API 不一致の修正（破壊的）

| # | 対象 | 現状 | 正しい型 |
|---|---|---|---|
| 1 | `Vitest.onTestFailed` / `onTestFinished`（同 Async 版含む） | `(unit => unit) => unit` でコールバック引数を無視 | コールバックは `TestContext` を受け取る |
| 2 | `Vi.doMock` | `(string, unit => 'a) => unit` で戻り値を捨てる | 実 API は `Disposable` を返す |
| 3 | `Vi.setTimerTickMode` | `string => unit` で `"interval"` の省略可能 `interval` 引数を渡せない | `"interval"` モードで `interval` を渡せる手段が必要 |

### ドッグフード網羅の追加

公開済みだがテストで未行使の API にテストを追加する（高・中優先度を対象）。詳細は design.md「対象 API 一覧」に列挙。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | バインディング利用者 | `Vi.onTestFailed(ctx => ...)` でテストコンテキストを参照したい | コールバックが `TestContext` を受け取り型が通る |
| 2 | バインディング利用者 | `vi.doMock` の戻り値（Disposable）を使いたい | 戻り値型が `disposable` で表現される |
| 3 | バインディング利用者 | `setTimerTickMode("interval", ~interval=100)` 相当を呼びたい | `interval` を指定できる |
| 4 | メンテナ | 公開 API が実際に動作することを CI で保証したい | 主要 API がドッグフードテストで行使されている |

## 4. 受け入れ条件

- [ ] `onTestFailed` / `onTestFinished`（Async 含む 4 関数）のコールバックが `TestContext` を受け取る型になっている
- [ ] `Vi.doMock` が `disposable` 型を返す
- [ ] `setTimerTickMode` の `"interval"` モードで `interval` を指定できる
- [ ] 上記 3 修正それぞれに対応する回帰テストが `__tests__/` に存在し、パスする
- [ ] design.md「対象 API 一覧」の未検証 API にテストが追加され、全件パスする
- [ ] `pnpm build` が成功し、`pnpm test` が全件パスする
- [ ] README / changelog に破壊的変更が明記されている

## 5. 制約事項

- **破壊的変更を許容**する（v0.1.0 初版・利用限定的のため後方互換ラッパーは設けない）。
- 薄い FFI バインディング層の方針を維持し、過度な抽象化・config ラッピングは行わない（YAGNI / minimal-change）。
- `TestContext` / `disposable` は当面 **opaque type** とし、フィールドアクセサは要求があるまで追加しない（最小範囲主義）。

## 6. 関連ドキュメント

- `docs/repository-structure.md` — レイヤー責務
- `CLAUDE.md` — Verification-first 原則
- `.claude/rules/minimal-change.md` — YAGNI / Surgical Changes
