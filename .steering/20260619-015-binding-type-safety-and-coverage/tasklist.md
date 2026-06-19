# タスクリスト: バインディング型安全性強化・Vitest 4 API 補完・ドッグフードカバレッジ整備

| 項目 | 内容 |
|---|---|
| 機能名 | binding-type-safety-and-coverage |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 23 完了 |

## フェーズ1: 準備

- [x] T1-1: worktree (`binding-type-safety-and-coverage`) を HEAD から作成し隔離環境を用意した（settings.local.json 経由の baseRef 設定が auto モードで拒否されたため `git worktree add ... HEAD` + `EnterWorktree(path)` で head ベースを実現）

## フェーズ2: 実装 — 型安全化（コミット①）

- [x] T2-1: `src/Vitest.res` `toBeTypeOf` を poly variant 化（`typeOf` 型を追加）
- [x] T2-2: `src/Vi.res` `spyOnAccessor` を poly variant 化し `spyOnGetter`/`spyOnSetter` を `#get`/`#set` に更新
- [x] T2-3: `src/VitestConfig.res` `coverageConfig.provider` を poly variant 化（`[#istanbul | #v8 | #custom]`）
- [x] T2-4: 既存ドッグフードテストの該当呼び出し（typeof/provider）を新型に更新（直接 `spyOnAccessor` 呼び出しは無し）
- [x] T2-5: `pnpm build` + `pnpm test`（119 passed / 3 expected fail）で型安全化分が通ることを確認しコミット①

## フェーズ3: 実装 — Vitest 4 API 補完（コミット②）

- [x] T3-1: `src/Vitest.res` に `aroundAll` / `aroundEach` を追加（ドキュメントコメント付き）
- [x] T3-2: `src/Vi.res` に `fakeTimerOptions` 型 + `useFakeTimersWith` を追加
- [x] T3-3: `src/Vi.res` に `waitForOptions` 型 + `waitForWith` / `waitUntilWith` を追加
- [x] T3-4: 新 API のドッグフードテストを追加（aroundAll/aroundEach は `Lifecycle_test.res` 新規、useFakeTimersWith/waitForWith/waitUntilWith は `Vi_test.res`）
- [x] T3-5: `pnpm build` + `pnpm test`（128 passed）確認しコミット②（T4-1 のライフサイクルフックテストも同一新規ファイルに含めて同時コミット）

## フェーズ4: 実装 — ドッグフードテスト拡充（コミット③）

- [x] T4-1: ライフサイクルフックのテスト追加（`Lifecycle_test.res` に beforeAll/beforeEach/afterEach の sync・async と発火回数検証）※ commit② に同梱
- [x] T4-2: スナップショットマッチャーのテスト追加（`toMatchSnapshot`/`WithName`/`toMatchInlineSnapshot`/`toThrowErrorMatchingSnapshot`/`Inline`）。外部 snap は `__tests__/__snapshots__/Expect_test.res.js.snap` に生成
- [x] T4-3: 数値・戻り値マッチャーの抜け追加（`toBeLessThanOrEqual`/`toHaveReturned`）
- [x] T4-4: モック生成・解決系の抜け追加（`fn`/`fnWith`/`mockRejectedValue`）
- [x] T4-5: 同期タイマー群のテスト追加（`runAllTimers`/`runAllTicks`/`runOnlyPendingTimers`/`advanceTimersToNextTimer`/`clearAllTimers`/`setSystemTime`(Date)）
- [x] T4-6: 弱いテストを挙動検証に置き換え（`resetAllMocks`→実装消去確認 / `restoreAllMocks`→原実装復帰確認 / `doMock`→動的 import で差し替え確認）
- [x] T4-7: `VitestConfig_test.res` に provider poly variant（T2 で更新済）+ 未検証フィールド round-trip + カスタム environment テスト追加
- [x] T4-8: `vi.mock`（ホイスティング版）のテスト省略理由をコメントで明記
- [x] T4-9: `pnpm build` + `pnpm test`（146 passed / 3 expected fail）確認しコミット③。※環境の node_modules が nightly で v5 化していたため worktree ローカルに v4 を `pnpm install --frozen-lockfile` で導入し検証

## フェーズ5: カバレッジ方針（ゲートは設けず文書化 — コミット④）

- [x] T5-1: `pnpm test:coverage` を実行し実測カバレッジを確認 → external は消去され計測可能コードがほぼ無く（VitestConfig.res.js は完全に空）、statement/line % は無意味と判明
- [x] T5-2: しきい値ゲートは設けない方針をユーザー承認。design.md に技術判断を記録し、検証手段は「コンパイル + ドッグフードテスト」であることを README/sphinx に明記（コミット④はドキュメントフェーズに統合）。`test:coverage` スクリプトはローカル検査用に存置

## フェーズ6: ドキュメント（コミット⑤）

- [x] T6-1: `README.md` Features / cheat sheet / Development を更新（around フック / useFakeTimersWith / waitForWith / 型安全化 / カバレッジ非ゲート方針）
- [x] T6-2: `sphinx-docs/user/configuration.md` を更新（provider #v8 例修正 + poly variant 注記 + useFakeTimersWith）。`make update-po` → `msgstr` 日本語記入 → `make build-ja` 成功（warning は pre-existing の sitemap のみ）、check-po クリーン
- [x] T6-3: `sphinx-docs/user/changelog.md` Unreleased に追記（日英 .po 記入）しコミット⑤

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
