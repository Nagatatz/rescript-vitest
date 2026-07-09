# 設計: oxlint/oxfmt による JS/JSON 整形・lint 導入

| 項目 | 内容 |
|---|---|
| 機能名 | oxlint/oxfmt による JS/JSON 整形・lint 導入 |
| 作成日 | 2026-06-30 |

## 1. 実装アプローチ

1. `oxlint` / `oxfmt` を devDependencies に追加する。
2. 設定ファイル `.oxfmtrc.json`（整形）と `.oxlintrc.json`（lint）を最小構成で追加する。
3. `package.json` に `format` / `format:check` / `lint` スクリプトを追加する。
4. `.githooks/pre-commit` を追加し、`prepare` スクリプトで `core.hooksPath` を有効化する（追加ランタイム依存なし）。
5. 既存の手書き JS/JSON に初回整形を適用する（= 実際の「整形」）。
6. 検証（`format:check` / `lint` / `build` / `test`）が通ることを確認し、ドキュメントを更新する。

両ツールとも `.gitignore` を自動尊重するため、生成物 `*.res.js` / `lib/` / `node_modules` は明示除外不要で対象から外れる。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `package.json` | devDeps（oxlint/oxfmt）、`format`/`format:check`/`lint`/`prepare` スクリプト追加 | 修正 |
| `.oxfmtrc.json` | oxfmt 設定（最小） | 新規 |
| `.oxlintrc.json` | oxlint 設定（最小、correctness 中心） | 新規 |
| `.githooks/pre-commit` | コミット前に `format:check` + `lint` 実行 | 新規 |
| `vitest.config.js` ほか手書き JSON | 初回整形の適用 | 修正 |
| `CLAUDE.md` | ビルド・実行コマンドに format/lint を追記 | 修正 |
| `README.md` | `## Development` に整形・lint 手順を追記 | 修正 |
| `docs/repository-structure.md` | 追加した設定ファイル・`.githooks/` を構成図へ反映 | 修正 |
| `sphinx-docs/dev/contributing.md` + `locale/ja` .po | 整形・lint の手順を追記し日本語訳を同期 | 修正 |

## 3. データ構造の変更

なし（型・データモデルの変更は伴わない）。

## 4. 影響範囲の分析

### 直接的な影響

- 手書き JS/JSON のフォーマットが oxfmt 準拠に統一される（初回コミットで差分が出る）。
- `pnpm install` 時に `prepare` が走り、`core.hooksPath` が `.githooks` に設定される。

### 間接的な影響

- 生成 `.res.js` は `.gitignore` 済みで対象外のため、ReScript ビルドフローには影響しない。
- 公開パッケージの `files` は変更せず、配布物・公開 API に影響なし（changelog 更新は不要）。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| 整形対象の除外 | 明示 ignore 設定 / `.gitignore` 尊重 | `.gitignore` 尊重 | oxfmt/oxlint が既定で `.gitignore` を読む。生成 `.res.js`/`lib/` は gitignore 済みで自動除外でき、設定を最小化できる |
| JSON 整形 | oxfmt / 別ツール | oxfmt | 検証の結果 oxfmt が JSON も整形可能と確認。ツールを 1 つに集約できる |
| pre-commit 実装 | simple-git-hooks 等の依存 / `.githooks` + `prepare` で `core.hooksPath` | `.githooks` + `prepare` | 追加ランタイム依存ゼロ（YAGNI）。`prepare` は registry 経由の利用者では実行されず配布に無害 |
| hook の動作 | `--write`(自動整形) / `--check`(検査のみ) | `--check`（+ lint） | コミット時に予期せぬファイル変更を起こさず決定的。修正は `pnpm format` で明示実行 |
| 隔離環境 | worktree / 通常ブランチ | 通常ブランチ `chore/oxlint-oxfmt-formatting` | 本作業は devDeps 追加（非 frozen install）を伴う。worktree は親の `node_modules` を共有する既知の落とし穴があり隔離が成立しないため、通常ブランチで実施する（steering-workflow の worktree 規定からの意図的逸脱） |
| lint 追加スクリプト | `lint` のみ / `lint:fix` も | `lint` のみ | 要求にない自動修正は導入しない（YAGNI）。必要時に追加 |

### テスト方針（testing.md の例外適用）

本変更はツール設定であり、対応するユニットテストは存在しない。検証手段は **`pnpm format:check` / `pnpm lint` / `pnpm build` / `pnpm test` がすべて成功すること**で代替する（→ verification-first）。tasklist にテスト省略理由として明記する。
