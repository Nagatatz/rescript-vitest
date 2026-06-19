# タスクリスト: .claude ルール群の包括的縮小

| 項目 | 内容 |
|---|---|
| 機能名 | claude-rules-reduction |
| 作成日 | 2026-06-19 |
| 進捗 | 9 / 10 完了（残: コミット） |

> `.claude/` メタ変更。main 直作業（worktree 不要。@import は session 開始時ロードのため作業中に挙動は変わらない）。

## フェーズ1: worktree 手順の skill 集約

- [x] `worktree-safety` skill に worktree マージ・クリーンアップ手順・健全性チェック・CWD 復旧・未コミット時の扱いを追記し、循環参照を解消（SSOT 化、34→88 行）
- [x] `steering-workflow.md` から worktree 手順詳細を削除し、判断基準 + worktree-safety skill 参照に短縮（215→58 行）
- [x] `steering-workflow.md` からアーカイブポリシー詳細を削除し archive-steering skill 参照に一本化（archive-steering の自己 SSOT 参照も整理）

## フェーズ2: rule の圧縮（意味保持）

- [x] `definition-of-done.md` Phase 5 の worktree 検証詳細を worktree-safety skill 参照に短縮
- [x] `git-conventions.md` のブランチ運用手順を git-workflow skill 参照に寄せ、規約本体（絵文字・命名・粒度）を残す
- [x] `permission-modes.md` を判断フロー表 + Think Before Coding に圧縮（48→27 行）
- [x] `claude-md-hygiene.md` を 3 つの自問 + 含める/除外表に圧縮（57→33 行）
- [x] `delegate-investigation.md` を原則 + 判断基準 + 簡約 subagent 表に圧縮（52→37 行）

## フェーズ3: 検証

- [x] リンク切れ検査（`feature-pr-walkthrough.md` の参照を skill へ張り替え、他の残存参照は実在節を指すことを確認）+ @import チェーン健全性確認（全 rule ファイル存在）+ 行数計測（rules 718→479、約 33% 減）
- [ ] docs-only コミットを作成

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] CLAUDE.md の @import 対象 rule ファイルがすべて存在すること
- [ ] rules 合計が約 450 行以下になっていること
- [ ] 規約の意味内容が失われていないこと（手順は skill から参照可能）

---

## 振り返り

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
