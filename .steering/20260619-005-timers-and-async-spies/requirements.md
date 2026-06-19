# 要求定義: Phase 5 — 非同期タイマー・待機・アクセサスパイ

| 項目 | 内容 |
|---|---|
| 機能名 | 非同期タイマー・待機・アクセサスパイ (Phase 5) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`src/Vi.res` のフェイクタイマーは同期 API のみで、Vitest 4.1.9 の **async タイマー進行**、
**待機ユーティリティ** `waitFor`/`waitUntil`、**タイマー検査** API、**getter/setter スパイ** が未実装
（見積もり計画 M2 / M3 / M4 / M10）。

### 目的

非同期タイマー制御・ポーリング待機・タイマー状態検査・アクセサスパイを faithful な薄い FFI として追加する。

## 2. 変更・追加する機能の説明（すべて `src/Vi.res`）

**M2 — 待機:**
- `waitFor` — コールバックが例外を投げなくなるまでリトライし結果を解決
- `waitUntil` — コールバックが truthy を返すまでリトライし値を解決

**M3 — async フェイクタイマー:**
- `advanceTimersByTimeAsync` / `runAllTimersAsync` / `runOnlyPendingTimersAsync` /
  `advanceTimersToNextTimerAsync` / `advanceTimersToNextFrame`

**M4 — タイマー検査:**
- `isFakeTimers` / `getTimerCount` / `getMockedSystemTime` / `getRealSystemTime`

**M10 — アクセサスパイ:**
- `spyOnGetter` / `spyOnSetter`（`vi.spyOn(obj, key, "get"|"set")` のラッパ）

対応するドッグフードテストを `__tests__/Vi_test.res` に併設する。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | 利用者 | `await Vi.waitFor(() => assertReady())` | 条件成立まで待機できる |
| 2 | 利用者 | `await Vi.advanceTimersByTimeAsync(ms)` | async タイマーを進められる |
| 3 | 利用者 | `Vi.getTimerCount()` | 保留中タイマー数を取得できる |
| 4 | 利用者 | `Vi.spyOnGetter(obj, "prop")` | getter 呼び出しをスパイできる |

## 4. 受け入れ条件

- [ ] M2 / M3 / M4（setTimerTickMode 除く）/ M10 の各 API が `src/Vi.res` に追加されている
- [ ] 各 API にコメント規約準拠のドキュメントコメントが付与されている
- [ ] 各 API のドッグフードテストが併設され、全件パスする
- [ ] `pnpm build` が型エラーなしで通る
- [ ] `pnpm test` が全件パスする

## 5. 制約事項・スコープ判断

- **`setTimerTickMode`（M4）は本フェーズ対象外**。理由: ニッチな API で、`mode` 文字列（`"manual"`/`"nextTimerAsync"`/`"interval"`）＋オプション interval の引数形が型表現として awkward。挙動の自動検証も難しい。需要が出た時点で別途追加する。
- `waitFor`/`waitUntil` はコールバックのみ受ける形（デフォルトの timeout/interval）で束ねる。オプション（timeout/interval）指定版は将来拡張（デフォルトで本フェーズのテストは成立）。
- `getMockedSystemTime` は `Date | null` を返すため `@return(nullable)` で `option<Date.t>` に写す。
- `spyOnGetter`/`spyOnSetter` は 3 引数 external `spyOnAccessor` を `let` ラッパで包み、アクセサ種別をベイクする。getter/setter を持つオブジェクトはテスト用に `%%raw` ファクトリで生成する（ReScript レコードは data プロパティのみのため）。

## 6. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（Phase 5, M2/M3/M4/M10）
- Phase 4 ステアリング: `.steering/20260619-004-matcher-expansion/`
