# 要求定義: Phase 6 — グローバル/環境スタブ・モジュールモック補完

| 項目 | 内容 |
|---|---|
| 機能名 | グローバル/環境スタブ・モジュールモック補完 (Phase 6) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`src/Vi.res` のモジュールモックは `mock`/`mockWithFactory`/`unmock`/`doMock`/`resetModules` を備えるが、
Vitest 4.1.9 の **グローバル/環境変数スタブ**（M5）と **モジュールモック補完**（M6: `importActual` 等）が未実装。

### 目的

グローバル・環境のスタブ操作と、モジュールモックの取得・解除・設定待機 API を faithful な薄い FFI として追加する。

## 2. 変更・追加する機能の説明（すべて `src/Vi.res`）

**M5 — グローバル/環境スタブ:**
- `stubGlobal` — グローバル変数を一時置換
- `stubEnv` — 環境変数を一時置換
- `unstubAllGlobals` — すべてのグローバルスタブを解除
- `unstubAllEnvs` — すべての環境変数スタブを解除

**M6 — モジュールモック補完:**
- `importActual` — 元のモジュールを動的 import（Promise）
- `importMock` — 自動モック済みモジュールを動的 import（Promise）
- `doUnmock` — `doMock` を解除
- `mockObject` — オブジェクトを深くモック化したコピーを返す
- `dynamicImportSettled` — 保留中の動的 import の完了を待機（Promise）

対応するドッグフードテストを `__tests__/Vi_test.res` に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 利用者 | `Vi.stubEnv("API_URL", "x")` | 環境変数を一時置換しテストできる |
| 2 | 利用者 | `Vi.stubGlobal("fetch", mock)` | グローバルを差し替えられる |
| 3 | 利用者 | `await Vi.importActual("mod")` | 元モジュールを取得できる |
| 4 | 利用者 | `Vi.mockObject(obj)` | メソッドがモック化されたコピーを得る |

## 4. 受け入れ条件

- [ ] M5 の 4 API と M6 の 5 API が `src/Vi.res` に追加されている
- [ ] 各 API にコメント規約準拠のドキュメントコメントが付与されている
- [ ] 各 API のドッグフードテストが併設され、全件パスする
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項

- `stubEnv` の値は `string`（`process.env` は文字列）で束ねる。
- `stubGlobal` の値は generic `'a`（任意の差し替え値）。
- `importActual`/`importMock` の戻りは generic `promise<'a>`（呼び出し側で型注釈）。
- `doUnmock`/`dynamicImportSettled` は単独での強検証が難しいためスモーク/解決確認テストとする。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 6, M5/M6）
- Phase 5 ステアリング: `.steering/20260619-005-timers-and-async-spies/`
