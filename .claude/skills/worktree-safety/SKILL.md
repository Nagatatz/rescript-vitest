---
description: git worktree を作成・削除・整理する際、または "ENOENT: no such file or directory" / posix_spawn エラーで CWD が壊れた状態の復旧時に参照する。worktree 削除順序の必須規約、マージ・クリーンアップ手順、健全性チェック、Agent ツール経由の復旧手順。
allowed-tools: Read, Bash, Agent
---

# Git Worktree 安全ルール（SSOT）

worktree のマージ・削除・整理・復旧手順の唯一の正（SSOT）。Claude Code ビルトイン worktree 機能（`EnterWorktree` / `claude --worktree`）で隔離実装した後のクリーンアップはここに従う。

## 問題（なぜ順序が重要か）

worktree ディレクトリ**内**を CWD としたまま `git worktree remove` / `git branch -D` を実行すると、シェルの CWD が無効になり Claude Code が続行不能になる（`ENOENT: no such file or directory, posix_spawn '/bin/sh'`）。`git -C` での代用は禁止 — **CWD 自体をメインリポジトリへ移動**すること。

## セッション開始時の健全性チェック

worktree を使う前に孤立参照を検出・削除する:

```bash
git worktree list            # 存在しないパスが出ていないか
git worktree prune           # 孤立参照を削除
git branch --list 'worktree-*'   # 対応 worktree の無い残存ブランチ
ls .claude/worktrees/ 2>/dev/null  # 登録外の孤立ディレクトリ
```

異常（存在しないパス表示 / prune で参照削除 / 孤立ディレクトリ / 対応 worktree 無しブランチ）を検出したら: `git worktree prune` → 孤立ディレクトリを `rm -rf` → 不要 `worktree-*` ブランチを `git branch -D` → `git worktree list` が main のみになることを確認。

## マージ・クリーンアップ手順（必須順序）

**最重要: CWD の移動が最優先。worktree を削除・prune する前に必ず CWD をメインリポジトリへ移す。**

```bash
# Step 1: CWD をメインリポジトリへ（必ず最初・単独の Bash 呼び出しで実行）
#         ⚠️ git -C で代用しない。CWD 自体を移動する。
cd /path/to/main-repo

# Step 2: 未追跡ステアリングファイルの競合を事前解消（存在する場合）
rm -rf .steering/<作業ディレクトリ>/

# Step 3: マージ（CWD 変更後の別コマンドとして実行）
git merge <ブランチ名> --no-ff -m "Merge branch '<ブランチ名>'"

# Step 4: worktree 削除（CWD がメインリポジトリであることを確認済みで）
git worktree remove .claude/worktrees/<名前>   # または git worktree prune

# Step 5: ブランチ削除
git branch -d <ブランチ名>   # 未 push の場合は -D
```

### クリーンアップ完了の検証（1 つでも残れば未完了）

```bash
git worktree list                 # → main のみ
git branch --list 'worktree-*'    # → 出力が空
ls .claude/worktrees/ 2>/dev/null # → 空またはディレクトリ不在
```

## セッション終了前のチェック

自動クリーンアップに頼らない。終了前（最終応答前）に CWD がメインリポジトリを指していることを保証する:

```bash
pwd                              # worktree パスを指していたら即 cd で移動
git worktree list                # main のみ
git branch --list 'worktree-*'   # 空
```

## worktree が未コミット変更を含む場合（作業中断時）

マージせず終了する必要がある場合: worktree 内で WIP コミット → CWD をメインへ移動 → worktree は**削除しない**（次回継続のため）→ worktree とブランチ名をユーザーに伝える。

## Agent tool の `isolation: "worktree"` 使用時

エージェント完了後のクリーンアップにも本ルールが適用される。worktree 内に CWD がある状態で削除コマンドを実行しない。

## 禁止事項

- worktree ディレクトリ内での `git worktree remove` / `git branch -d|-D` 実行
- メインリポジトリへ `cd` せずに worktree を削除すること
- `git -C` で CWD 移動を代用すること

## CWD が既に壊れている場合

CWD が削除済みディレクトリを指し通常 Bash が一切実行できなくなった場合は、**Agent tool（subagent_type=general-purpose）** で別プロセスからクリーンアップを実行する。

## 関連

- アーカイブ棚卸し: `archive-steering` skill
- steering ワークフロー全体: `.claude/rules/steering-workflow.md`（判断基準）/ `steering` skill（実行手順）
