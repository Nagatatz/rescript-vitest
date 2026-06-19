# 要求定義: Phase 9 — フィクスチャ・カスタムマッチャー（実現可否の切り分け）

| 項目 | 内容 |
|---|---|
| 機能名 | フィクスチャ・カスタムマッチャー (Phase 9) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

見積もりロードマップ最後の要設計フェーズ（L2 フィクスチャ / L3 カスタムマッチャー）。
ReScript の型システムで faithful に表現できるかが未検証で、PoC で「対応可能」と
「非対応（docs 明記）」を切り分ける必要がある。

### 目的

実現可能な API を faithful に追加し、ReScript の型システムでは faithful 表現が困難な API を
理由付きで「非対応」と明示する。

## 2. 変更・追加する機能の説明

**実装する（実現可能）:**
- `testFor`（`test.for`）— `test.each` の for 形（`src/Vitest.res`）
- `module Expect` に以下（`src/Vitest.res`）:
  - `assertions` — 実行されたアサーション数を厳密検証
  - `hasAssertions` — 最低 1 アサーションを検証
  - `soft` — 失敗で中断せず収集する soft アサーション（`assertion<'a>` を返す）
  - `poll` — マッチャーが通るまでポーリング（`asyncAssertion<'a>` を返す）
  - `unreachable` / `unreachableWithMessage` — 到達不能マーカ（throw）

**非対応とする（docs 明記）:**
- `test.extend`（L2 フィクスチャ）— フィクスチャオブジェクト型と `use` コールバック注入を
  ReScript で型安全/ergonomic に表現できない。
- `expect.extend`（L3 カスタムマッチャー）— 登録したマッチャーを `assertion<'a>` 上に
  型安全に露出できず、マッチャーごとに手動 `@send` が必要になり faithful なエルゴノミクスを欠く。

対応するドッグフードテストを `__tests__/Expect_test.res` に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 利用者 | `testFor(cases)("name %i", case => ...)` | for 形のパラメータ化テストを書ける |
| 2 | 利用者 | `Expect.soft(x)->toBe(y)` | 失敗を収集する soft アサーションを書ける |
| 3 | 利用者 | `await Expect.poll(() => v)->Async.toBe(x)` | 条件成立までポーリング検証できる |
| 4 | 利用者 | `Expect.assertions(2)` | アサーション数を保証できる |

## 4. 受け入れ条件

- [ ] `testFor` と `module Expect` の 6 API（assertions/hasAssertions/soft/poll/unreachable/unreachableWithMessage）が追加されている
- [ ] 各 API にコメント規約準拠のドキュメントコメントが付与されている
- [ ] 各 API のドッグフードテストが併設され、全件パスする
- [ ] `test.extend` / `expect.extend` の非対応理由が docs（README / steering）に明記されている
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項・設計方針

- `soft` は既存 `assertion<'a>` を返し、既存マッチャーをそのまま使える。
- `poll` は既存 `asyncAssertion<'a>` を返し、`Async` モジュールのマッチャーで await して使う。
- `unreachable` は throw するため `unit => 'a`。`expect(() => Expect.unreachable())->toThrow` で検証。
- もし `soft`/`poll`/`assertions` 等が 4.1.9 ランタイムに存在せずテストが失敗した場合は、当該 API のみ
  非対応に切り替え docs 明記する。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 9, L2/L3）
- Phase 8 ステアリング: `.steering/20260619-008-asymmetric-matchers/`
