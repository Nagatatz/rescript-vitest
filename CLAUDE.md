# CLAUDE.md

## 強制的な行動指示

本ファイルおよび `@import` で読み込まれるルール、`.claude/skills/` 配下のスキル本文に書かれている規約は **すべて強制** であり、ユーザーから明示的に解除されない限り例外なく従うこと。違反した場合は即座に修正する。

## 最上位原則: Verification-first

> 公式: 「Give Claude a way to verify its work. **This is the single highest-leverage thing you can do.**」

すべてのコード変更には、Claude 自身が検証可能な手段（ユニットテスト / lint / typecheck / ビルド / スクリーンショット）を併設すること。検証手段が無い変更は出荷しない。曖昧な指示（「動くようにして」等）を受けた場合は、実装着手前に検証可能なゴールに変換すること（→ `@.claude/rules/testing.md` の「検証可能ゴール変換」表）。

## プロジェクト概要

Type-safe ReScript bindings for Vitest

- 言語: ReScript
- ビルドシステム: ReScript compiler + pnpm / Vitest 4
- 対象プラットフォーム: Node.js (ESM), Vitest 4 (Vite 6/7)

## ビルド・実行コマンド

```bash
# ビルド
pnpm build

# クリーンビルド
pnpm clean && pnpm build

# テスト
pnpm test
```

## Sphinx ドキュメント

日英対応（`en` / `ja`）の Sphinx ドキュメントを `sphinx-docs/` に配置している。

```bash
cd sphinx-docs && make install  # 依存関係インストール (uv 必須)
make html                       # 英語 HTML ビルド
make build-all                  # 全言語ビルド (en/ja) + Pagefind
make serve                      # ローカルサーバーで確認
make check                      # 品質チェック (lint + test)

# 日本語翻訳ワークフロー
make gettext                    # ソースから .pot 抽出
make update-po                  # locale/ja/LC_MESSAGES/*.po を更新
make build-ja                   # 日本語 HTML ビルド
```

## プロジェクト構成

@docs/repository-structure.md

## 開発規約

- パッケージ: @nagatatz/rescript-vitest

> `.claude/` 配下の rule / skill / agent / command の役割分担と新規追加判断基準は README.md「規約とスキルの住み分け」セクション参照。

### 常時適用される規約 (rules)

以下のルールはすべてのセッションで `@import` され、常に適用される。

@.claude/rules/testing.md
@.claude/rules/code-comments.md
@.claude/rules/git-conventions.md
@.claude/rules/steering-workflow.md
@.claude/rules/documentation.md
@.claude/rules/definition-of-done.md
@.claude/rules/permission-modes.md
@.claude/rules/minimal-change.md
@.claude/rules/claude-md-hygiene.md
@.claude/rules/delegate-investigation.md

<!--
  /learn skill が `.claude/rules/learnings.md` を生成したら、以下のコメントを外して有効化する。
  存在しないファイルを @import すると Claude Code が警告する可能性があるため、生成前は無効化しておく。

  @.claude/rules/learnings.md
-->


### 状況発火型の知識 (skills)

以下は `.claude/skills/` に配置されており、該当状況になると Claude が自動でロードする。手動呼び出しは不要。

| スキル | 発火タイミング |
|------|--------------|
| **bash-safety** | 破壊的な Bash 操作（rm, rm -r, ディレクトリ削除等）を実行する直前 |
| **worktree-safety** | git worktree の作成・削除・整理時 / CWD 壊れの復旧時 |
| **context-management** | コンテキスト圧迫時 / 探索→実装の切替時 |
| **token-optimization** | サブエージェント / モデル選択時 |

## 個人ノート

`CLAUDE.local.md` を作成すると、git 追跡対象外の個人メモとして扱われる（`.gitignore` 済み）。チームに共有しない作業手順、個人 API キー操作メモ、デバッグ用一時情報などを記述してよい。`@CLAUDE.local.md` で CLAUDE.md から取り込むこともできる。
