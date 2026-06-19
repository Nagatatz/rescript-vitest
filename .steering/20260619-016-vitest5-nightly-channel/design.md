# Design: vitest 5.0.0-beta.5 nightly チャンネル

承認済みプラン（`/Users/ngtz/.claude/plans/functional-jingling-pony.md`）に準拠。

## 方針

- 公開形態: prerelease 版番号 + npm dist-tag `next`。`latest` は vitest4 系のまま。
- ブランチ: 長期並行ブランチ `vitest5`（main へマージしない）。通常の worktree フローは不使用。
- peerDeps: `^4.0.0 || ^5.0.0-0`。

## release.yml の dist-tag 出し分け（vitest5 ブランチのみ）

```yaml
- name: Publish to npm (OIDC trusted publishing)
  run: |
    if [[ "${GITHUB_REF_NAME}" == *-* ]]; then
      npm publish --access public --provenance --tag next
    else
      npm publish --access public --provenance
    fi
```

- semver prerelease は必ず `-` を含む。`GITHUB_REF_NAME` はタグ名（例 `v0.2.0-beta.5`）。
- タグ push 時に発火するワークフローはタグが指すコミット（vitest5 ブランチ）のもの。main の release.yml は不変。
- npmjs.com Trusted Publisher 設定が ref を限定していないか要確認（外部運用事項）。

## バインディング修正

FFI 文字列のため `rescript build` は vitest 版に非依存。互換性は `pnpm test`（vitest run）で初めて判明する発見タスク。失敗した API のみ `src/*.res` + `__tests__/*.res` を最小修正。

## ドキュメント

- `README.md` Requirements 表 + `@next` install 手順。
- `sphinx-docs/user/changelog.md` `0.2.0-beta.5` エントリ。
- API 変更時のみ sphinx ページ + `make update-po` → ja `msgstr` → `make build-ja`。
