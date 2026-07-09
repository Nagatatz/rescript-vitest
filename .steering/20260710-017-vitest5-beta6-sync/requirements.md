# Requirements: vitest5 を 5.0.0-beta.6 に追従

## 背景

`vitest5` ブランチは Vitest 5 beta 追従用の prerelease チャンネル（npm `next` dist-tag）。
本家 Vitest が `5.0.0-beta.5 → 5.0.0-beta.6` に進み、かつ `main` が 16 コミット
（oxfmt/oxlint 導入・dependabot バンプ・docs 更新）先行したため、両者を取り込む。

## 完了条件（検証可能ゴール）

- vitest `5.0.0-beta.6` 上でドッグフードテスト（`__tests__/**`）が **全件パス** する。
- `pnpm build`（ReScript コンパイル）が成功する。
- `pnpm format:check` / `pnpm lint`（main 由来の oxfmt/oxlint）が警告・エラーなし。
- `make build-ja`（日本語 Sphinx）が成功し、beta.6 の changelog に翻訳漏れがない。
- npm publish は**行わない**（ブランチ更新のみ。公開は別途手動判断）。

## 非対象

- git タグ push / npm `next` への `0.2.0-beta.6` 公開（ユーザー判断で今回は見送り）。
- main 側の変更（本作業は `vitest5` 系ブランチに閉じる）。
