# 要求定義: Phase 2 — Vi モック中核

| 項目 | 内容 |
|---|---|
| 機能名 | Vi モック中核 (Phase 2) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`src/Vi.res` の `MockFn` モジュールは `mockReturnValue`/`mockImplementation` 等の主要 API を
備えるが、Vitest 4.1.9 が提供する **once 系の async バリアント・モック名操作・実装取得・一時実装差し替え**
が未実装。また vi 名前空間に **モック検査（`mocked`/`isMockFunction`）とホイスト（`hoisted`）**
が欠落している（見積もり計画の優先度「高」H3/H4）。

### 目的

モック関数のライフサイクル制御と検査を Vitest 本来の水準まで引き上げ、
faithful な薄い FFI として追加する。

## 2. 変更・追加する機能の説明

**H3 — `MockFn` モジュール追加（`src/Vi.res`）:**
- `mockResolvedValueOnce` — 次の呼び出しのみ解決値を設定
- `mockRejectedValueOnce` — 次の呼び出しのみ拒否理由を設定
- `mockReturnThis` — `this` を返すよう設定（メソッドチェーン用）
- `getMockName` — 設定済みモック名を取得
- `mockName` — モック名を設定（チェーン可）
- `getMockImplementation` — 現在の実装を取得（未設定なら `None`）
- `withImplementation` — コールバック実行中のみ実装を一時差し替え

**H4 — vi 名前空間追加（`src/Vi.res`）:**
- `mocked` — 値をモックとして型付け（実行時は恒等関数）
- `isMockFunction` — モック関数かどうかを判定
- `hoisted` — import 評価前にファクトリを実行し結果を返す

各 API に対応するドッグフードテストを `__tests__/Vi_test.res` に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 利用者 | `mock->Vi.MockFn.mockResolvedValueOnce(v)` | 次の呼び出しだけ `v` で解決する async モックを得る |
| 2 | 利用者 | `Vi.mocked(importedFn)->Vi.MockFn.mockReturnValue(v)` | 自動モック済み関数を型付きモックとして操作できる |
| 3 | 利用者 | `Vi.isMockFunction(f)` | モック関数判定を `bool` で得る |
| 4 | 利用者 | `Vi.hoisted(() => setup())` | import より先に実行される値を得る |

## 4. 受け入れ条件

- [ ] H3 の 7 API が `MockFn` モジュールに追加されている
- [ ] H4 の 3 API が vi 名前空間に追加されている
- [ ] 各 API にコメント規約準拠のドキュメントコメントが付与されている
- [ ] 各 API のドッグフードテストが `__tests__/Vi_test.res` に併設され、全件パスする
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項

- `getMockImplementation` は Vitest が `T | undefined` を返すため `@return(nullable)` で `option<'fn>` に写す。
- `withImplementation` は同期コールバック版のみ提供（async 版は YAGNI で対象外、必要時に追加）。
- `vi.mocked` は実行時恒等であり型ビューを与えるだけ。返り値を `MockFn.t<'fn>` として型付ける。
- 非推奨 API・既存シグネチャの変更はしない（最小変更）。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 2, H3/H4）
- Phase 1 ステアリング: `.steering/20260619-001-expect-mock-matchers/`
