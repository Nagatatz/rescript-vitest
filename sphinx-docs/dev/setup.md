# Development Setup

This page covers two separate setups: building the **ReScript bindings** (the
library itself) and building this **documentation site**.

## Building the Library

The bindings need only Node.js and pnpm — no Python toolchain.

| Requirement | Version | Note |
|-------------|---------|------|
| Node.js | 24+ | ESM runtime for Vitest |
| pnpm | latest | Package manager |

```bash
git clone https://github.com/Nagatatz/rescript-vitest.git
cd rescript-vitest
pnpm install
pnpm build        # compile .res → in-source .res.js
pnpm test         # run the dogfood test suite (vitest run)
```

See [Building](building.md) for the full command reference.

## Building the Documentation Site

The remaining steps below are only needed to work on this Sphinx documentation
site, not the library.

## Prerequisites

| Requirement | Version | Note |
|-------------|---------|------|
| [uv](https://docs.astral.sh/uv/) | 0.5+ | Python パッケージ管理・仮想環境 |
| Python | 3.12+ | uv が自動インストール |
| Node.js | 24+ | Pagefind 検索インデックス生成に使用 |

### uv のインストール

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Homebrew
brew install uv
```

## Clone the Repository

```bash
git clone https://github.com/Nagatatz/rescript-vitest.git
cd rescript-vitest
```

## Install Dependencies

```bash
cd sphinx-docs
make install    # uv sync で依存関係をインストール
```

## Verify the Setup

```bash
make html       # 英語 HTML ビルド
make serve      # localhost:8000 で確認
```
