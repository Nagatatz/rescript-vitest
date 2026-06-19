# Tasklist: vitest 5.0.0-beta.5 nightly チャンネル

## Phase 1: 準備
- [x] `vitest5` ブランチを main から作成
- [x] `.steering/20260619-016-vitest5-nightly-channel/` に requirements / design / tasklist を作成

## Phase 2: vitest5 対応（依存 bump + バインディング修正を 1 論理コミットに集約）
- [x] `package.json`: vitest → `5.0.0-beta.5` / `@vitest/coverage-v8` `5.0.0-beta.5` / peerDeps `^4.0.0 || ^5.0.0-0` / version `0.2.0-beta.5`（vite `^7.0.0` は据え置きで peer 警告なし）
- [x] `pnpm install` で lockfile 更新
- [x] 破壊的変更対応: vitest5 で `describe/test/it.sequential` が削除 → `describeSequential` / `testSequential` / `testSequentialAsync` / `itSequential` バインディングと対応テストを削除
- [x] `pnpm build` 成功確認
- [x] **検証: `pnpm test` 全件パス**（vitest 5.0.0-beta.5 上、115 passed）
- [x] `pnpm test:coverage` 確認（coverage-v8 5.x 整合）
- [ ] コミット ①（vitest5 対応: deps + bindings + tests + lockfile + version）

## Phase 4: リリースワークフロー
- [x] `.github/workflows/release.yml` dist-tag 出し分け
- [ ] コミット ②（release.yml）

## Phase 5: ドキュメント
- [x] `README.md` Requirements 表 + `@next` install 手順 + vitest5 nightly セクション
- [x] `sphinx-docs/user/changelog.md` `0.2.0-beta.5` エントリ（Changed / Removed）
- [x] `make update-po` → ja `msgstr` 記入 → `make build-ja` 成功（sphinx ページには sequential 記載なし、changelog のみ翻訳）
- [ ] コミット ④（ドキュメント）

## Phase 6: 仕上げ
- [x] `pnpm test:coverage` 確認（coverage-v8 5.x 整合）
- [ ] `vitest5` ブランチを remote へ push
- [ ] （任意）`v0.2.0-beta.5` タグで nightly 公開
