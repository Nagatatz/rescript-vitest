# 設計: Sphinx ドキュメント CI ゲートの補完

| 項目 | 内容 |
|---|---|
| 機能名 | Sphinx ドキュメント CI ゲートの補完 |
| 作成日 | 2026-08-30 |

## 1. 実装アプローチ

Makefile 既存ターゲット（`typecheck` / `check-po` / `a11y`）を CI から呼ぶだけに留め、新規ロジックは pytest に集約する。pytest は外部ツールに依存せず標準ライブラリのみで `.po` / `package.json` / `conf.py` を検査する（mypy 対象になるため型注釈を付ける）。`.po` の重複 `msgstr` はテストで Red を確認してから修正する。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `sphinx-docs/locale/ja/LC_MESSAGES/dev/setup.po` | 重複 `msgstr` 行 4 件除去 | 修正 |
| `sphinx-docs/locale/ja/LC_MESSAGES/user/installation.po` | 重複 `msgstr` 行 4 件除去 | 修正 |
| `sphinx-docs/locale/ja/LC_MESSAGES/dev/project-structure.po` | 重複 `msgstr` 行 1 件除去 | 修正 |
| `sphinx-docs/tests/_po.py` | `.po` 最小パーサ（エントリ列挙・msgid/msgstr 連結・重複検出）。テスト間で共有 | 新規 |
| `sphinx-docs/tests/test_po_translations.py` | 構文（重複 msgstr）と未訳プロースの検出 | 新規 |
| `sphinx-docs/tests/test_po_coverage.py` | ソース `.md` ごとの `.po` 存在 | 新規 |
| `sphinx-docs/tests/test_conf.py` | `conf.py` の `release` == `package.json` `version` | 新規 |
| `sphinx-docs/Makefile` | `test` ターゲットの exit 5 吸収を撤去（`uv run pytest` のみ） | 修正 |
| `.github/workflows/docs.yml` | `lint-and-test` に Typecheck / Check translations ステップ、`build` に Accessibility ステップ | 修正 |
| `.github/dependabot.yml` | `uv` / `npm` の `/sphinx-docs` エントリ追加 | 修正 |
| `docs/repository-structure.md` | `sphinx-docs/tests/` の言及（存在すれば） | 修正 |
| `sphinx-docs/dev/contributing.md` または `building.md` | `make check` に pytest が含まれること / `check-po` / `a11y` の記載（既存記述を確認して必要箇所のみ） | 修正 |
| `sphinx-docs/locale/ja/LC_MESSAGES/dev/*.po` | 上記英語変更に伴う `.po` 同期 | 修正 |

## 3. データ構造の変更

```python
# sphinx-docs/tests/_po.py
@dataclass
class Entry:
    msgid: str        # 連結・アンエスケープ済み
    msgstr: str
    line: int         # msgid 行番号（失敗メッセージ用）
    msgstr_lines: int # 連続する `msgstr "` 行数（1 以外は構文エラー）

def entries(path: Path) -> list[Entry]: ...
def is_prose(msgid: str) -> bool:
    """バッククォート span / Markdown リンク / URL を除いた残りに
    英字単語が 2 つ以上あればプロース（翻訳必須）とみなす。"""
```

プロース判定の除外例（既存の空 `msgstr` がすべて該当）: `Node.js`, `24+`, `pnpm`, `[uv](https://docs.astral.sh/uv/)`, `` `@rescript/runtime` ``, `Vitest`, `` `^4.0.0` ``, `0.2.0 (2026-08-30)`, `#get`, `✨`。

## 4. 影響範囲の分析

### 直接的な影響

- docs CI（`sphinx-docs/**` 変更時のみ発火）の所要時間が増える（a11y は build-all を再実行するため +1〜2 分）
- 以後、英語ソースのみ更新した PR は Pytest で失敗する（規約どおり）

### 間接的な影響

- Dependabot が `sphinx-docs/` の uv / npm 依存の PR を週次で作る（`open-pull-requests-limit` 5 に含める）
- mypy の対象に `tests/` が加わる（`exclude` は `conf.py` のみ）

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| `.po` パース | (a) `polib` を dev 依存に追加 (b) 標準ライブラリで最小パーサ | (b) | 必要なのは msgid/msgstr 連結と重複検出のみ。依存追加より 40 行程度のパーサの方が軽い |
| a11y の CI 配置 | (a) 独立ジョブ (b) `build` ジョブのステップ | (b) | `build-all` 済みの成果物を流用でき、Node も同ジョブで用意済み |
| a11y の失敗扱い | (a) blocking (b) `continue-on-error` | ローカル / CI 初回の結果で決定 | 既存違反が多数なら (b) から始めて別途是正。違反ゼロなら (a) |
| Makefile `test` の exit 5 吸収 | 撤去 | 撤去 | テストが存在する以上、収集 0 は異常 |
| `.po` 未訳判定 | (a) 全 msgid (b) プロースのみ | (b) | documentation.md の例外（コード・コマンド・固有名詞は英語フォールバック可）に一致させる |
