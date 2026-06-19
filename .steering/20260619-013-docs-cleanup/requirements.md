# 要求定義: ドキュメント整理

| 項目 | 内容 |
|---|---|
| 機能名 | docs-cleanup |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

改善調査で、API ドキュメント（README / changelog / user 配下）の整合性は健全な一方、周辺に以下の負債が判明した: (1) 規約が参照する `docs/` 設計ファイルの不在、(2) `sphinx-docs/dev/` のテンプレートスタブ放置、(3) 製品と無関係なテンプレ残骸ファイル、(4) 規約と公開ページの不整合（コミット絵文字、stray fuzzy フラグ等）。

### 目的

ソースコードを変更せず、ドキュメント単独で上記負債を解消し、規約と実態・日英ドキュメントの整合を回復する。

## 2. 変更・追加する機能の説明

ドキュメントのみの変更。実コード（`src/`）には触れない。日英二言語整備（documentation.md 規約）に従い、英語ソース変更は同一作業で ja `.po` まで完成させる。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | コントリビューター | `sphinx-docs/dev/` を読む | building / architecture / setup が実態を説明している |
| 2 | メンテナ | `documentation.md` の docs 表を見る | 実在するファイルのみが列挙されている |
| 3 | OSS 閲覧者 | `docs/` を見る | 製品と無関係なテンプレ残骸が無い |

## 4. 受け入れ条件

- [ ] テンプレ残骸 3 ファイル（`docs/mcp-servers.md` / `migration-to-plugins.md` / `quality-measurement.md`）を削除した
- [ ] `documentation.md` / `repository-structure.md` の `docs/` 参照を実在ファイル（`repository-structure.md` のみ）に合わせた
- [ ] `sphinx-docs/dev/building.md` / `architecture.md` / `setup.md` のスタブを実態で埋めた
- [ ] `sphinx-docs/user/installation.md` の Verify / Troubleshooting プレースホルダを埋めた
- [ ] `sphinx-docs/dev/project-structure.md` に `src/*.res` 3 ファイルを記載した
- [ ] `sphinx-docs/dev/contributing.md` のコミット絵文字を 9 種に揃えた
- [ ] `sphinx-docs/locale/ja/.../quickstart.po` の stray `fuzzy` フラグを除去した
- [ ] 英語ソース変更すべてに対し `make update-po` + ja `msgstr` を記入し、`make build-ja` が通る
- [ ] `make html` / `make build-ja` が成功する

## 5. 制約事項

- ソースコード（`src/`）は変更しない。
- 日英二言語の同時整備（documentation.md 規約）を厳守する。
- 既存の正確な記述（API チートシート等）は改変しない（minimal-change）。

## 6. 関連ドキュメント

- `.claude/rules/documentation.md` — ドキュメント管理規約
- 改善調査結果（本セッションのドキュメント領域エージェント報告）
