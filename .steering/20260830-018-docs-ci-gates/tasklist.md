# タスクリスト: Sphinx ドキュメント CI ゲートの補完

| 項目 | 内容 |
|---|---|
| 機能名 | Sphinx ドキュメント CI ゲートの補完 |
| 作成日 | 2026-08-30 |
| 進捗 | 24 / 24 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree を作成し、`make install` で Sphinx 依存を用意する
- [x] ローカルで `make a11y` を試行し、Chromium が動くか / 既存違反の有無を把握する（CI 配置の blocking 可否判断）

## フェーズ2: pytest 追加（Red → Green）

- [x] `tests/_po.py` の最小 `.po` パーサを実装する
- [x] `tests/test_po_translations.py` を作成 → 検証: 現状の重複 `msgstr` で **Red**、プロース未訳チェックは既存の空 msgstr（識別子のみ）を誤検出しない
- [x] `.po` 3 ファイルの重複 `msgstr` 行を除去 → 検証: 上記テストと `make check-po` が **Green**
- [x] 一時的にプロース msgstr を空にして未訳チェックが Red になることを確認し、元に戻す
- [x] `tests/test_po_coverage.py` を作成 → 検証: 全ソースに `.po` があり Green
- [x] `tests/test_conf.py` を作成 → 検証: `release == package.json version` で Green
- [x] `Makefile` `test` の exit 5 吸収を撤去 → 検証: `make test` / `make typecheck`（tests/ を含む）/ `make check` が exit 0

## フェーズ3: CI / Dependabot

- [x] `docs.yml` `lint-and-test` に `make typecheck` と `make check-po` を追加
- [x] `docs.yml` `build` に a11y ステップを追加（フェーズ 1 の結果で blocking / continue-on-error を決定し、design.md に追記）
- [x] `dependabot.yml` に `uv`（`/sphinx-docs`）と `npm`（`/sphinx-docs`）を追加

## フェーズ4: ドキュメント

- [x] `sphinx-docs/dev/` の該当ページ（contributing / building）に pytest・check-po・a11y のゲートを記載（既存記述を確認し必要箇所のみ）
- [x] `make update-po` → 追加 msgid の日本語訳 → `make build-ja` 成功
- [x] `docs/repository-structure.md` に `sphinx-docs/tests/` を反映

## フェーズ5: 仕上げ

- [x] ruff（`make lint`）/ `make sphinx-lint` / `make check` が exit 0
- [x] 適切な粒度でコミット（🐛 `.po` 修正 / ✅ pytest 追加 / 🔧 CI・dependabot / 📝 ドキュメント）
- [x] PR を作成し docs CI（typecheck / check-po / pytest / a11y）が green であることを確認
- [x] `AskUserQuestion` で main へのマージ可否を確認
- [x] main へマージ
- [x] worktree / ブランチのクリーンアップと検証

## 完了条件

- [x] すべてのタスクが完了していること
- [x] `make check` と docs CI が成功すること
- [x] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

- `.po` の検査は polib 等を足さず標準ライブラリの最小パーサ（`tests/_po.py`）で実装し、「重複 `msgstr`」と「プロース未訳」を別テストに分けて失敗メッセージが原因を直接示すようにした。
- プロース判定はコードスパン / Markdown リンク / URL を除いた残りに英字単語が 2 つ以上、という規則にし、既存の空 `msgstr`（識別子・バージョン見出し）を 1 件も誤検出しないことを実データで確認してから採用した。ヒューリスティック自体もパラメータ化テストで固定している。
- Red の確認を 2 段階で実施: 重複 `msgstr` は実データで、未訳検出は一時的に `msgstr` を空にして。
- a11y ステップは `Build site` と同じ `SPHINX_SITE_PREFIX` で `make a11y` を呼び、`_build/site` の再ビルドが Pages artifact の内容を変えないようにした。

### 発生した問題と解決策

- `make check-po` が 017 で記入した `.po` の重複 `msgstr` 行（9 件）を構文エラーとして検出 → 本 steering で修正。babel（Sphinx）は寛容に読むため HTML ビルドでは見つからなかった。まさに今回追加したゲートが防ぐ回帰。
- CI の pa11y が全ページで「フッターのコントラスト不足」1 件ずつ失敗 → `.pa11yci.json` の `ignore: ["color-contrast", "region"]` は axe のルール ID で、既定の htmlcs ランナーには効いていなかった。`runners: ["axe"]` を追加して設定意図どおりに動かした（8/8 passed）。
- それでも `make a11y` が exit 2 → Makefile の `pkill -f "http.server 8765"` が自分自身の `sh -c` にマッチして make が Terminated になっていた（ローカル試行でも同じ理由で exit 144）。`[h]ttp.server` パターンに変更。
- ローカル（WSL）では `npx pa11y-ci` の Chromium 取得が完了せず判定できなかったため、blocking で CI に載せて実挙動を確認する方針にした（design.md §6）。
- 引数なしの `git push` は worktree ブランチ名（`worktree-*`）と upstream 名（`chore/*`）が異なるため拒否される（017 の push 漏れも同原因）。`git push origin HEAD:<remote-branch>` を使う。
- worktree 内の pre-commit hook には `node_modules` が必要 → `pnpm install --frozen-lockfile --offline`。

### 設計変更の理由

- a11y の失敗扱いは「blocking」に確定（違反ゼロのため）。設定・Makefile の 2 つの不具合修正が追加で必要になった（design.md の変更コンポーネント表にはない `.pa11yci.json` / Makefile `a11y` の修正）。

### 次回への改善点

- `git-workflow` skill の pr モードに「`git push origin HEAD:<ブランチ名>` で push し、`git status -sb` が `ahead 0` であることを確認してから `gh pr create`」を明記する（017・018 で 2 回踏んだ）。
- `steering` skill の worktree 手順に `pnpm install --frozen-lockfile --offline` を追記する（pre-commit hook が動かない）。
