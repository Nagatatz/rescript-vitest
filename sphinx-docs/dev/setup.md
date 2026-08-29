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
| [uv](https://docs.astral.sh/uv/) | 0.5+ | Python package manager and virtual environments |
| Python | 3.12+ | Installed automatically by uv |
| Node.js | 24+ | Used to build the Pagefind search index |

### Installing uv

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
make install    # installs the dependencies via uv sync
```

## Verify the Setup

```bash
make html       # builds the English HTML
make serve      # serves the site on localhost:8000
```
