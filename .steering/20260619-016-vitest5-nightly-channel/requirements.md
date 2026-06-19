# Requirements: vitest 5.0.0-beta.5 nightly チャンネル

## 背景

`@nagatatz/rescript-vitest` は現在 vitest `^4.0.0` 対象。vitest 次期メジャー `5.0.0-beta.5`（npm `beta` タグ）が出ているため、安定版を壊さずに vitest5 beta を試せる prerelease チャンネルを用意する。

## ゴール（検証可能）

- vitest `5.0.0-beta.5` 上でドッグフードテスト（`__tests__/**`）が **全件パス**する。
- 安定版 main（vitest4 / npm `latest`）に一切影響を与えない。

## 受け入れ条件

1. 長期並行ブランチ `vitest5` 上で作業する（main へマージしない、vitest5 GA まで保留）。
2. `package.json` の devDependency vitest を `5.0.0-beta.5` に固定、`@vitest/coverage-v8` を整合する版に更新、`peerDependencies.vitest` を `^4.0.0 || ^5.0.0-0` に拡張、`version` を `0.2.0-beta.5` に変更。
3. `pnpm-lock.yaml` を更新（CI は `--frozen-lockfile`）。
4. `release.yml`（vitest5 ブランチのみ）を prerelease 判定で dist-tag 出し分け（prerelease → `--tag next`、stable → `latest`）に変更。
5. vitest5 beta でテストが失敗した API のみバインディング・テストを最小修正する。失敗が無ければバインディング変更ゼロ。
6. `README.md`・`sphinx-docs/user/changelog.md` を更新。API 変更を伴う場合は sphinx 該当ページ + ja 翻訳も full に実施。

## 非対象

- main へのマージ・vitest4 の廃止。
- cron による自動 nightly ビルド（今回は手動タグ push 公開）。
