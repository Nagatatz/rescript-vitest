# タスクリスト: バインディング型安全性強化・Vitest 4 API 補完・ドッグフードカバレッジ整備

| 項目 | 内容 |
|---|---|
| 機能名 | binding-type-safety-and-coverage |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 23 完了 |

## フェーズ1: 準備

- [ ] T1-1: `EnterWorktree` で worktree (`binding-type-safety-and-coverage`) を作成し隔離環境を用意する

## フェーズ2: 実装 — 型安全化（コミット①）

- [ ] T2-1: `src/Vitest.res` `toBeTypeOf` を poly variant 化
- [ ] T2-2: `src/Vi.res` `spyOnAccessor` を poly variant 化し `spyOnGetter`/`spyOnSetter` を `#get`/`#set` に更新
- [ ] T2-3: `src/VitestConfig.res` `coverageConfig.provider` を poly variant 化
- [ ] T2-4: 既存ドッグフードテストの該当呼び出し（typeof/accessor/provider）を新型に更新
- [ ] T2-5: `pnpm build` + `pnpm test` で型安全化分が通ることを確認しコミット①

## フェーズ3: 実装 — Vitest 4 API 補完（コミット②）

- [ ] T3-1: `src/Vitest.res` に `aroundAll` / `aroundEach` を追加（ドキュメントコメント付き）
- [ ] T3-2: `src/Vi.res` に `fakeTimerOptions` 型 + `useFakeTimersWith` を追加
- [ ] T3-3: `src/Vi.res` に `waitForOptions` 型 + `waitForWith` / `waitUntilWith` を追加
- [ ] T3-4: 新 API のドッグフードテストを追加（aroundAll/aroundEach/useFakeTimersWith/waitForWith/waitUntilWith）
- [ ] T3-5: `pnpm build` + `pnpm test` 確認しコミット②

## フェーズ4: 実装 — ドッグフードテスト拡充（コミット③）

- [ ] T4-1: ライフサイクルフックのテスト追加（`beforeAll`/`beforeEach`/`afterAllAsync`/`beforeEachAsync` 等の発火順序検証）
- [ ] T4-2: スナップショットマッチャーのテスト追加（`toMatchSnapshot`/`toMatchInlineSnapshot`/`toThrowErrorMatchingInlineSnapshot`）
- [ ] T4-3: 数値・戻り値マッチャーの抜け追加（`toBeLessThanOrEqual`/`toHaveReturned`）
- [ ] T4-4: モック生成・解決系の抜け追加（`fn`/`fnWith`/`mockRejectedValue`）
- [ ] T4-5: 同期タイマー群のテスト追加（`runAllTimers`/`runAllTicks`/`runOnlyPendingTimers`/`advanceTimersToNextTimer`/`clearAllTimers`/`setSystemTime`(Date)）
- [ ] T4-6: 弱いテスト（`resetAllMocks`/`restoreAllMocks`/`doMock`）を挙動検証に置き換え
- [ ] T4-7: `VitestConfig_test.res` に provider poly variant + 未検証フィールド round-trip テスト追加
- [ ] T4-8: `vi.mock`（ホイスティング版）のテスト省略理由をコメントで明記
- [ ] T4-9: `pnpm build` + `pnpm test` 確認しコミット③

## フェーズ5: カバレッジゲート（コミット④）

- [ ] T5-1: `pnpm test:coverage` を実行し実測カバレッジを確認
- [ ] T5-2: `vitest.config.js` に `coverage.thresholds`（実測値 floor）を設定し、`pnpm test:coverage` がゲートを満たすことを確認しコミット④

## フェーズ6: ドキュメント（コミット⑤）

- [ ] T6-1: `README.md` Features セクションに新 API（around フック / fake timer オプション / waitFor オプション / 型安全化）を追記
- [ ] T6-2: `sphinx-docs/` 該当ページを更新し、`make update-po` → `msgstr` 日本語記入 → `make build-ja` で日英両ビルド確認
- [ ] T6-3: `sphinx-docs/user/changelog.md` Unreleased に追記（日英）しコミット⑤

## フェーズ7: 仕上げ・マージ

- [ ] T7-1: 完了定義 (`definition-of-done.md`) 全 Phase を確認
- [ ] T7-2: `tasklist.md` の全タスクを `[x]` に更新（マージタスク含む）してコミット
- [ ] T7-3: `AskUserQuestion` で main へのマージ可否を確認
- [ ] T7-4: 承認後、worktree マージ・クリーンアップ手順に従いマージ → worktree 削除 → ブランチ削除 → クリーンアップ検証

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] `pnpm build` が成功すること
- [ ] `pnpm test` / `pnpm test:coverage` が全件成功しゲートを満たすこと
- [ ] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
