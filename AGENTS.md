# AGENTS.md

## 最上位原則: Verification-first

コード変更には、エージェント自身が実行できる検証手段（テスト / lint / 型チェック / ビルド / スクリーンショット）を併設する。曖昧な指示は着手前に検証可能なゴールへ変換する（→ `.claude/rules/testing.md`）。

## プロジェクト概要

Vitest の型安全な ReScript binding。常に最新の Vitest を使えるようにすることを目的とする。

- 言語: ReScript
- ビルドシステム: ReScript compiler + pnpm / Vitest
- 対象プラットフォーム: Node.js (ESM)・Vitest (Vite)。peer は `vitest ^4.0.0 || ^5.0.0`
- パッケージ: `@nagatatz/rescript-vitest`（npm。`v*` tag の push で `.github/workflows/release.yml` が公開する）
- 既定ブランチ: `main`

## ビルド・実行コマンド

```bash
pnpm build                 # ビルド（型チェックを兼ねる）
pnpm clean && pnpm build   # クリーンビルド
pnpm test                  # テスト（__tests__/*_test.res をコンパイルした *_test.res.js を実行）
pnpm test:mutation:diff    # origin/main との差分の mutant だけ実行（→ .claude/rules/testing.md）

# 整形・lint（手書きの JS/JSON だけが対象。生成物の .res.js・lib/ は .gitignore で除外）
pnpm format                # oxfmt で整形
pnpm format:check          # 整形の差分を検査（pre-commit と同じ）
pnpm lint                  # oxlint
```

`pnpm install` の `prepare` が `core.hooksPath` を `.githooks` にし、pre-commit で `format:check` と `lint` が走る。新しい worktree には `node_modules` が無いので、最初に `pnpm install --frozen-lockfile --offline` を実行する（無いと pre-commit で commit に失敗する）。

## Sphinx ドキュメント

日英（`en` / `ja`）の Sphinx ドキュメントを `sphinx-docs/` に置く。英語が正で、英語を変えたら同じコミットで日本語も更新する（→ `.claude/rules/documentation.md`）。

```bash
cd sphinx-docs && make install  # 依存関係インストール（uv）
make html                       # 英語 HTML ビルド
make build-all                  # 全言語ビルド (en/ja) + Pagefind
make check                      # 品質チェック（ruff + sphinx-lint + mypy + pytest）
make check-po                   # 日本語 .po の構文検査（pofilter）
make a11y                       # アクセシビリティ検査（pa11y-ci, WCAG2AA）
make update-po                  # 英語ソース変更後に日本語 .po を更新
make build-ja                   # 日本語 HTML ビルド
```

## プロジェクト構成

ディレクトリ構成・責務・ビルドの流れは `docs/repository-structure.md` を参照。

## Required Rules

`.claude/rules/*.md` が規約の単一ソース。本ファイルには索引だけを置き、ルール本文は写さない（`@import` もしない）。Claude Code は `paths:` の無いルールを常時、`paths:` のあるルールを一致するファイルを扱うときにロードする。

`.claude/rules/` を自動でロードしない環境では、対象ファイルを調査・編集する前に該当ルールの本文を自分で読む。規約を変更する前に `.claude/skills/claude-md-hygiene/SKILL.md` を読む。

| ルール | ロード条件 | 内容 |
|---|---|---|
| [`definition-of-done`](.claude/rules/definition-of-done.md) | 常時 | 作業ごとに Issue へ DoD を書く。計画〜マージ後の完了条件（SSoT） |
| [`git-conventions`](.claude/rules/git-conventions.md) | 常時 | 絵文字プレフィックス + 英語動詞のコミット、1 コミット 1 論理変更、Issue 番号つきブランチ |
| [`issue-workflow`](.claude/rules/issue-workflow.md) | 常時 | 並行作業時の着手（`status/in-progress`）・「要判断」の書き方・手放し方 |
| [`testing`](.claude/rules/testing.md) | 常時 | 曖昧な指示を検証可能なゴールに変換、mutation test、3 回失敗したら相談 |
| [`issue-pr-reference`](.claude/rules/issue-pr-reference.md) | 常時 | 文章中の Issue は 📋 + inline code、PR は 🔀 + リンクで区別 |
| [`documentation`](.claude/rules/documentation.md) | 常時 | sphinx-docs は日英必須、英語が正 |
| [`test-authoring`](.claude/rules/test-authoring.md) | ソースファイル | コード変更にはテストを作成・更新、配置と命名 |
| [`code-comments`](.claude/rules/code-comments.md) | ソースファイル | 周囲に合わせ、名前から復元できない「なぜ」だけを書く |
| [`minimal-change`](.claude/rules/minimal-change.md) | ソースファイル | 要求を満たす最小の差分、ついで改善を混ぜない |
| [`github-actions`](.claude/rules/github-actions.md) | `.github/workflows/**` ほか | 外部 action は SHA 固定 + バージョンコメント |

「ソースファイル」は各ルールの `paths:` に一致するファイル。正確な条件は各ルールの frontmatter を確認する。

## 入口ファイル

規約の本文は本ファイルに置く。repo 直下の `CLAUDE.md` は `@AGENTS.md` の 1 行だけにしている。jpyc-tipjar-widget で確かめた結果（2026-10-28、Claude Code 2.1.312）による。確かめたのは次の 2 点で、上位に `hobby/CLAUDE.md` があることが原因かは確かめていない。`CLAUDE.md` に本文を足さない。

- repo 直下に `CLAUDE.md` が無いと、Claude Code は `AGENTS.md` を読まなかった
- `@AGENTS.md` の 1 行の `CLAUDE.md` を置くと読まれた

`.claude/settings.json` はこの repo に置いていない（`.claude/settings.json.template` だけ）。hooks を使うときは template から作る。

## 個人メモ

チームに共有しない指示は `~/.claude/CLAUDE.md` に書く（全プロジェクトに効く）。`CLAUDE.local.md` は使わない。
