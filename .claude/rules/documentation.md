# ドキュメント規約

## 日英必須（英語が正）

`sphinx-docs/` の英語ソース（`user/`・`dev/` 配下の `.md` / `.rst`）を変えたら、**同じコミットで**日本語訳まで仕上げる。英語だけ更新して `.po` を空のまま残さない（日本語ページが英語にフォールバックするため）。

`sphinx-docs/` で次を行う:

1. `make update-po` で `locale/ja/LC_MESSAGES/**/*.po` の `msgid` を同期する
2. 追加・変更された `msgstr` を日本語で埋める。コードブロック・コマンド例・固有名詞だけの `msgid` は空のままでよい
3. `make build-ja` と `make check-po` が通ることを確かめる

## 置き場所

- `docs/` — 開発者向けの設計メモ。この repo は薄い FFI binding 層なので、構成・責務・ビルドの流れは `docs/repository-structure.md` にまとめている（要求定義書などは必要になったら足す）
- `sphinx-docs/` — 利用者・コントリビューター向けの公開ドキュメント（GitHub Pages）。`user/`（導入・API・changelog）と `dev/`（開発・構成）
- 作業ごとの計画と完了条件は GitHub Issue に書く（→ `definition-of-done.md`）。過去の `.steering/` は記録として残し、新しくは作らない

## 機能を変えたとき

公開 API を足したり変えたりしたら、同じ作業で `README.md` と `sphinx-docs/user/`（`changelog.md` の Unreleased を含む）を両言語で更新する。コマンドや構成が変わったら `AGENTS.md` も直す。Issue の DoD にドキュメントの項目を入れる。
