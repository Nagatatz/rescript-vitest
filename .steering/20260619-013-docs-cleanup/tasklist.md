# タスクリスト: ドキュメント整理

| 項目 | 内容 |
|---|---|
| 機能名 | docs-cleanup |
| 作成日 | 2026-06-19 |
| 進捗 | 12 / 12 完了 |

> docs-only のため main 直作業（git-conventions の例外）。worktree は使わない。

## フェーズ1: 削除・規約整合（内部 docs / rules）

- [x] テンプレ残骸を `git rm`（`docs/mcp-servers.md` / `migration-to-plugins.md`）。**`quality-measurement.md` は削除せず保持**: `empirical-prompt-tuning` / `retrospective-codify` スキルと `quality-datasets/README.md` から参照されるアクティブな運用ガイドで、残骸ではないため（要 user 確認事項）
- [x] `.claude/rules/documentation.md` の「docs/ ファイルの役割」表を実在ファイル（`repository-structure.md`）のみに整理。併せて「機能実装時のドキュメント更新」表の存在しない `product-requirements.md` 行を `changelog.md` 行に差し替え
- [x] 重複は誤検出（`docs/repository-structure.md` は単一ファイルを CLAUDE.md が 1 回 `@import` するのみ）。対応不要

## フェーズ2: 公開ページのスタブ充填（sphinx-docs en）

- [x] `sphinx-docs/dev/building.md` を実ビルド（`pnpm build` / `pnpm test` / CI=ci.yml）で埋める
- [x] `sphinx-docs/dev/architecture.md` をバインディング層の実態（faithful matcher / Vitest・Vi・VitestConfig 責務）で埋める
- [x] `sphinx-docs/dev/setup.md` に ReScript バインディング自体のビルド手順を追記
- [x] `sphinx-docs/user/installation.md` の Verify / Troubleshooting を埋める
- [x] `sphinx-docs/dev/project-structure.md` に `src/*.res` 3 ファイルを記載
- [x] `sphinx-docs/dev/contributing.md` のコミット絵文字を 9 種に揃える

## フェーズ3: 翻訳同期と検証

- [x] `sphinx-docs/locale/ja/.../user/quickstart.po` の stray `fuzzy` フラグを除去（line 28、ヘッダの fuzzy は保持）
- [x] `make update-po` 実行 → 追加・変更 `msgstr` をすべて日本語で記入（コード/固有名詞は規約例外で英語フォールバック）
- [x] `make html` と `make build-ja` の成功を確認（en: 成功 / ja: 成功）し、docs-only コミットを作成

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] `make html` / `make build-ja` が成功すること
- [ ] 受け入れ条件をすべて満たしていること

---

## 振り返り

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
