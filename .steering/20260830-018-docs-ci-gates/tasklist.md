# タスクリスト: Sphinx ドキュメント CI ゲートの補完

| 項目 | 内容 |
|---|---|
| 機能名 | Sphinx ドキュメント CI ゲートの補完 |
| 作成日 | 2026-08-30 |
| 進捗 | 0 / 21 完了 |

## フェーズ1: 準備

- [ ] `EnterWorktree` で worktree を作成し、`make install` で Sphinx 依存を用意する
- [ ] ローカルで `make a11y` を試行し、Chromium が動くか / 既存違反の有無を把握する（CI 配置の blocking 可否判断）

## フェーズ2: pytest 追加（Red → Green）

- [ ] `tests/_po.py` の最小 `.po` パーサを実装する
- [ ] `tests/test_po_translations.py` を作成 → 検証: 現状の重複 `msgstr` で **Red**、プロース未訳チェックは既存の空 msgstr（識別子のみ）を誤検出しない
- [ ] `.po` 3 ファイルの重複 `msgstr` 行を除去 → 検証: 上記テストと `make check-po` が **Green**
- [ ] 一時的にプロース msgstr を空にして未訳チェックが Red になることを確認し、元に戻す
- [ ] `tests/test_po_coverage.py` を作成 → 検証: 全ソースに `.po` があり Green
- [ ] `tests/test_conf.py` を作成 → 検証: `release == package.json version` で Green
- [ ] `Makefile` `test` の exit 5 吸収を撤去 → 検証: `make test` / `make typecheck`（tests/ を含む）/ `make check` が exit 0

## フェーズ3: CI / Dependabot

- [ ] `docs.yml` `lint-and-test` に `make typecheck` と `make check-po` を追加
- [ ] `docs.yml` `build` に a11y ステップを追加（フェーズ 1 の結果で blocking / continue-on-error を決定し、design.md に追記）
- [ ] `dependabot.yml` に `uv`（`/sphinx-docs`）と `npm`（`/sphinx-docs`）を追加

## フェーズ4: ドキュメント

- [ ] `sphinx-docs/dev/` の該当ページ（contributing / building）に pytest・check-po・a11y のゲートを記載（既存記述を確認し必要箇所のみ）
- [ ] `make update-po` → 追加 msgid の日本語訳 → `make build-ja` 成功
- [ ] `docs/repository-structure.md` に `sphinx-docs/tests/` を反映

## フェーズ5: 仕上げ

- [ ] ruff（`make lint`）/ `make sphinx-lint` / `make check` が exit 0
- [ ] 適切な粒度でコミット（🐛 `.po` 修正 / ✅ pytest 追加 / 🔧 CI・dependabot / 📝 ドキュメント）
- [ ] PR を作成し docs CI（typecheck / check-po / pytest / a11y）が green であることを確認
- [ ] `AskUserQuestion` で main へのマージ可否を確認
- [ ] main へマージ
- [ ] worktree / ブランチのクリーンアップと検証

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] `make check` と docs CI が成功すること
- [ ] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
