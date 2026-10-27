---
description: git worktree を作成・削除・整理するとき、または "ENOENT: no such file or directory" / posix_spawn エラーで CWD が壊れたときの復旧に使用。削除順序の必須規約、マージ・クリーンアップ、健全性チェック、Agent ツールでの復旧。
allowed-tools: Read, Bash, Agent
---

# Git Worktree 安全ルール（SSOT）

`EnterWorktree` / `claude --worktree` / Agent の `isolation: "worktree"` で作った worktree のマージ・削除・整理・復旧はここに従う。

## CWD を先に移す（最重要）

worktree 内を CWD にしたまま `git worktree remove` / `git branch -d|-D` / `git worktree prune` を実行すると、シェルの CWD が消えて全 Bash が `ENOENT ... posix_spawn '/bin/sh'` で失敗し、続行できなくなる。

- 削除・prune の前に、**単独の Bash 呼び出しで `cd <メインリポジトリ>`** する。
- `git -C` は CWD を動かさないので代用にならない。使わない。

## 健全性チェック（worktree を使う前）

```bash
git worktree list                 # 存在しないパスが無いか
git worktree prune                # 孤立参照を削除
git branch --list 'worktree-*'    # 対応 worktree の無いブランチ
ls .claude/worktrees/ 2>/dev/null # 登録外の孤立ディレクトリ
```

異常があれば: `git worktree prune` → 孤立ディレクトリを `rm -rf`（`bash-safety` skill に従う）→ 不要な `worktree-*` を `git branch -D` → `git worktree list` が main のみになるまで確認。

## マージ・クリーンアップ（この順序）

```bash
cd <メインリポジトリ>                                       # 1. 必ず最初・単独で
rm -rf .steering/<作業ディレクトリ>/                          # 2. 未追跡ステアリングがマージと競合する場合のみ
git merge <ブランチ名> --no-ff -m "Merge branch '<ブランチ名>'"   # 3. cd とは別コマンドで
git worktree remove .claude/worktrees/<名前>                 # 4. または git worktree prune
git branch -d <ブランチ名>                                    # 5. 未 push なら -D
```

完了の検証（1 つでも残れば未完了）:

```bash
git worktree list                 # main のみ
git branch --list 'worktree-*'    # 空
ls .claude/worktrees/ 2>/dev/null # 空または不在
```

## セッション終了前

自動クリーンアップに頼らない。最終応答の前に `pwd` がメインリポジトリを指すことを確認し（worktree なら `cd`）、上の検証コマンドを実行する。

## 作業を中断する場合（未コミット変更あり）

worktree 内で WIP コミット → `cd <メインリポジトリ>` → worktree は**削除しない** → worktree のパスとブランチ名をユーザーに伝える。

## CWD が既に壊れている場合

通常の Bash は何も実行できない。**Agent tool（`subagent_type=general-purpose`）** で別プロセスからクリーンアップする。

## 関連

- アーカイブ: `archive-steering` skill / ワークフロー: `.claude/rules/steering-workflow.md`・`steering` skill
