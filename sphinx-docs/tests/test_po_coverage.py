"""Every English source page has a Japanese catalogue (``make update-po`` ran)."""

from __future__ import annotations

from pathlib import Path

import pytest

from tests._po import DOCS_DIR, LOCALE_DIR

SOURCES = sorted(
    [DOCS_DIR / "index.md", *(DOCS_DIR / "user").glob("*.md"), *(DOCS_DIR / "dev").glob("*.md")]
)


def _source_id(path: Path) -> str:
    return str(path.relative_to(DOCS_DIR))


def test_sources_found() -> None:
    assert SOURCES, f"no Markdown sources found under {DOCS_DIR}"


@pytest.mark.parametrize("source", SOURCES, ids=_source_id)
def test_source_has_catalogue(source: Path) -> None:
    po = LOCALE_DIR / source.relative_to(DOCS_DIR).with_suffix(".po")
    assert po.is_file(), f"missing {po.relative_to(DOCS_DIR)}; run `make update-po`"
