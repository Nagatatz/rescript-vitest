# タスクリスト: Vitest 5 対応

| 項目 | 内容 |
|---|---|
| 機能名 | Vitest 5 対応 |
| 作成日 | 2026-10-25 |
| 進捗 | 11 / 12 完了 |

## フェーズ1: 準備

- [x] PR #38 のブランチから `feature/vitest-5-support` を作成し `main` をマージ
- [x] ベースライン確認: `Expect_test` が `describe.sequential is not a function` で失敗
- [x] Vitest 4.1.12 / 5.0.5 で全バインディングの実行時存在を確認

## フェーズ2: 実装

- [x] sequential ヘルパーを `{concurrent: false}` に束縛 → 検証: 生成 JS が `describe(name, {"concurrent": false}, ...)`
- [x] 逐次性テスト追加 → 検証: `testConcurrent` / `describe` に差し替えると 2 件失敗
- [x] peer を `^4.0.0 || ^5.0.0` に
- [x] Vitest 5 / Vitest 4 の両方で `pnpm build && pnpm test` 全件パス
- [x] CI に `test-vitest-4` ジョブ追加

## フェーズ3: ドキュメント

- [x] README / CLAUDE.md / docs/repository-structure.md
- [x] Sphinx 英語ページと CHANGELOG（Unreleased）
- [x] `make update-po` → 日本語 `msgstr` 記入 → `make check-po` / `make build-ja`

## フェーズ4: PR

- [ ] PR 作成（#38 を supersede）、CI グリーン確認。マージ・リリースはオーナー判断
