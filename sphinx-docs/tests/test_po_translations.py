"""The Japanese catalogues are well-formed and every prose entry is translated.

Encodes the "日英二言語の同時整備" rule from ``.claude/rules/documentation.md``:
an English source change must ship with its Japanese ``msgstr``; only code,
commands and proper nouns may fall back to English.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tests._po import LOCALE_DIR, entries, is_prose

PO_FILES = sorted(LOCALE_DIR.rglob("*.po"))


def _po_id(path: Path) -> str:
    return str(path.relative_to(LOCALE_DIR))


def test_catalogues_exist() -> None:
    assert PO_FILES, f"no .po files under {LOCALE_DIR}; run `make update-po`"


@pytest.mark.parametrize("po", PO_FILES, ids=_po_id)
def test_each_entry_has_exactly_one_msgstr(po: Path) -> None:
    malformed = [e for e in entries(po) if e.msgstr_lines != 1]
    assert not malformed, "malformed entries (expected exactly one msgstr):\n" + "\n".join(
        f"  {e.location()}: {e.msgstr_lines} msgstr lines for {e.msgid[:60]!r}" for e in malformed
    )


@pytest.mark.parametrize("po", PO_FILES, ids=_po_id)
def test_prose_entries_are_translated(po: Path) -> None:
    missing = [e for e in entries(po) if is_prose(e.msgid) and (not e.msgstr or e.fuzzy)]
    assert not missing, "untranslated or fuzzy prose entries:\n" + "\n".join(
        f"  {e.location()}: {e.msgid[:80]!r}" for e in missing
    )


@pytest.mark.parametrize(
    ("msgid", "expected"),
    [
        ("Python package manager and virtual environments", True),
        ("Installing uv", True),
        ("`^12.0.0-0` (12.x, prereleases allowed)", True),
        ("Node.js", False),
        ("24+", False),
        ("[uv](https://docs.astral.sh/uv/)", False),
        ("`@rescript/runtime`", False),
        ("0.2.0 (2026-08-30)", False),
        ("Vitest", False),
        ("#get", False),
    ],
)
def test_is_prose_heuristic(msgid: str, expected: bool) -> None:
    assert is_prose(msgid) is expected
