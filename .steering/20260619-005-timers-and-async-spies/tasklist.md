# タスクリスト: Phase 5 — 非同期タイマー・待機・アクセサスパイ

| 項目 | 内容 |
|---|---|
| 機能名 | 非同期タイマー・待機・アクセサスパイ (Phase 5) |
| 作成日 | 2026-06-19 |
| 進捗 | 11 / 11 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree (`timers-async-spies`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [x] M2: `waitFor` / `waitUntil` を追加
- [x] M3: async フェイクタイマー 5 種を追加
- [x] M4: `isFakeTimers` / `getTimerCount` / `getMockedSystemTime`(`@return(nullable)`) / `getRealSystemTime` を追加
- [x] M10: `spyOnAccessor` external と `spyOnGetter` / `spyOnSetter` ラッパを追加

## フェーズ3: テスト

- [x] M2 の待機テスト（async）を追加
- [x] M3/M4 のタイマーテストを追加
- [x] M10 のアクセサスパイテスト（`%%raw` ファクトリ使用）を追加
- [x] `pnpm build` が型エラーなしで通ることを確認
- [x] `pnpm test` が全件パスすることを確認（53 件パス）

## フェーズ4: 仕上げ

- [x] ドキュメント更新（`README.md` の `Vi` 行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja` 成功）
- [x] コミット（`✨` プレフィックス）後、main へのマージ可否を確認 → 承認後マージ・worktree クリーンアップ

## 完了条件

- [x] すべてのタスクが完了していること
- [x] ビルドが成功すること
- [x] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
