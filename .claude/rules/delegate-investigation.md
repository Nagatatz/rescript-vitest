# 調査タスクの subagent 分離規約

> 出典: Anthropic 公式ベストプラクティス。「context is your fundamental constraint, **subagents are one of the most powerful tools available**.」

コードベース調査・コード読み込みの多いタスクは、メイン会話のコンテキストを汚さないため **subagent に分離**する。メイン会話は「決定」と「実装」に集中させる。

## 判定基準

以下に該当するタスクは subagent に分離する:

- **3 ファイル以上を横断的に読む探索**
- シンボル / キーワードの所在検索（「どこで X が定義/参照されるか」）
- 不慣れな領域の理解、PR / ブランチ差分要約、既存実装パターンの抽出
- コードレビュー（別コンテキストで批評させる Writer/Reviewer）

逆に、**1〜2 ファイルの該当箇所が判明している場合は直接 Read**（subagent は過剰）。

## subagent タイプの選び方

| タスク | 推奨 |
|--------|------|
| ファイル名 / シンボルの所在特定 | `Explore`（read-only・最速） |
| 軽量検索（grep / glob） | `quick-search`（Haiku） |
| 横断的な深掘り | `general-purpose` / `Plan` |
| コード品質 / セキュリティレビュー | `code-reviewer` / `security-reviewer` |
| ビルド・テスト失敗 / バグ分析 | `build-resolver` / `debugger` |
| PR 差分要約 / トピック徹底調査 | `pr-summary` / `deep-research` skill |

## 原則

- subagent には**自己完結したプロンプト**を渡す（「本会話のここまで」ではなく初見で必要な情報を全て含める）
- 結果は**要約のみ**受け取る（生 grep 出力をメインに持ち込まない）
- 独立した調査は 1 メッセージで**並列起動**する
- subagent の主張は**検証してから採用**する（「memory says X exists ≠ X exists now」）

## 関連

- `token-optimization` skill（モデル選択）/ `context-management` skill（コンテキスト圧迫時）
