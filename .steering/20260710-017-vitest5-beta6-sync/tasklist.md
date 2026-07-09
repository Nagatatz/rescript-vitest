# Tasklist: vitest5 を 5.0.0-beta.6 に追従

- [x] `origin/vitest5` から `chore/vitest5-beta6` を作成
- [x] `origin/main` をマージし 4 衝突を解消（package.json / pnpm-lock / README / changelog.po）
- [x] `package.json`: vitest → `5.0.0-beta.6` / `@vitest/coverage-v8` → `5.0.0-beta.6` / version → `0.2.0-beta.6` / peerDeps `^4.0.0 || ^5.0.0-0` 維持
- [x] `pnpm install` でロック再生成（インストール版が `5.0.0-beta.6` であることを検証）
- [x] **検証: `pnpm build` 成功（7 modules）**
- [x] **検証: `pnpm test` 全件パス（vitest 5.0.0-beta.6, 142 passed）**
- [x] **検証: `pnpm format:check` / `pnpm lint` 警告なし**
- [x] `changelog.md` に `0.2.0-beta.6` エントリ追加
- [x] `make update-po` → `changelog.po` の beta.6 msgstr を記入（空・fuzzy なし）
- [x] **検証: `make build-ja` 成功**
- [x] ステアリングドキュメント作成
- [x] コミット（ステアリング同梱）→ push → PR（base=`vitest5`）作成
- [ ] CI 全パス確認
- [ ] マージ確認（AskUserQuestion）→ 承認後マージ・ブランチ削除

## テスト省略なし

バインディングのランタイム検証は既存ドッグフードテスト（`__tests__/**`）で担保。
新規バインディング追加はないため追加テストは不要。
