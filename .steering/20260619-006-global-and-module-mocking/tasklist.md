# タスクリスト: Phase 6 — グローバル/環境スタブ・モジュールモック補完

| 項目 | 内容 |
|---|---|
| 機能名 | グローバル/環境スタブ・モジュールモック補完 (Phase 6) |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 10 完了 |

## フェーズ1: 準備

- [ ] `EnterWorktree` で worktree (`global-module-mocking`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [ ] M6: `importActual` / `importMock` / `doUnmock` / `mockObject` / `dynamicImportSettled` を追加
- [ ] M5: `stubGlobal` / `stubEnv` / `unstubAllGlobals` / `unstubAllEnvs` を追加

## フェーズ3: テスト

- [ ] M5 の stub テスト（グローバル/env 読み出しで検証）を追加
- [ ] M6 のモジュールモックテスト（importActual/importMock/mockObject 等）を追加
- [ ] `pnpm build` が型エラーなしで通ることを確認
- [ ] `pnpm test` が全件パスすることを確認

## フェーズ4: 仕上げ

- [ ] ドキュメント更新（`README.md` の `Vi` 行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja`）
- [ ] コミット（`✨` プレフィックス）後、main へのマージ可否を確認 → 承認後マージ・worktree クリーンアップ

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] ビルドが成功すること
- [ ] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
