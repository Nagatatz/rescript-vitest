"""Minimal reader for the Japanese ``.po`` catalogues under ``locale/``.

Only what the translation tests need is implemented (no third-party
dependency): entry enumeration with joined ``msgid`` / ``msgstr`` strings,
detection of malformed entries with more than one ``msgstr`` line, and the
"prose" heuristic that decides which entries must carry a translation.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

DOCS_DIR = Path(__file__).resolve().parent.parent
LOCALE_DIR = DOCS_DIR / "locale" / "ja" / "LC_MESSAGES"

_QUOTED = re.compile(r'^"((?:[^"\\]|\\.)*)"$')
_CODE_SPAN = re.compile(r"`[^`]*`")
_MD_LINK = re.compile(r"\[([^\]]*)\]\([^)]*\)")
_URL = re.compile(r"https?://\S+")
_PUNCT = "()[]{},.;:!?\"'*_"


@dataclass(frozen=True)
class Entry:
    """One ``msgid`` / ``msgstr`` pair of a catalogue."""

    path: Path
    line: int
    msgid: str
    msgstr: str
    msgstr_lines: int
    """Number of consecutive ``msgstr "..."`` lines; anything but 1 is malformed."""
    fuzzy: bool

    def location(self) -> str:
        return f"{self.path.relative_to(LOCALE_DIR)}:{self.line}"


def _unquote(line: str) -> str:
    m = _QUOTED.match(line.strip())
    if m is None:
        raise ValueError(f"not a quoted .po string: {line!r}")
    return m.group(1).replace('\\"', '"').replace("\\n", "\n").replace("\\\\", "\\")


def entries(path: Path) -> list[Entry]:
    """Return every non-header, non-obsolete entry of ``path`` in file order."""
    lines = path.read_text(encoding="utf-8").splitlines()
    out: list[Entry] = []
    fuzzy = False
    i = 0
    while i < len(lines):
        line = lines[i]
        if line.startswith("#,") and "fuzzy" in line:
            fuzzy = True
        if not line.startswith("msgid "):
            i += 1
            continue
        start = i
        msgid = _unquote(line[len("msgid ") :])
        i += 1
        while i < len(lines) and lines[i].startswith('"'):
            msgid += _unquote(lines[i])
            i += 1
        msgstr = ""
        msgstr_lines = 0
        # A well-formed entry has exactly one `msgstr` keyword; keep counting so
        # duplicated lines (which babel tolerates but pofilter rejects) show up.
        while i < len(lines) and lines[i].startswith("msgstr "):
            msgstr_lines += 1
            msgstr += _unquote(lines[i][len("msgstr ") :])
            i += 1
            while i < len(lines) and lines[i].startswith('"'):
                msgstr += _unquote(lines[i])
                i += 1
        if msgid:  # the empty msgid is the catalogue header
            out.append(Entry(path, start + 1, msgid, msgstr, msgstr_lines, fuzzy))
        fuzzy = False
    return out


def is_prose(msgid: str) -> bool:
    """Whether ``msgid`` is prose that must be translated.

    Code spans, Markdown link targets and bare URLs are dropped first; the
    remainder counts as prose when it still contains at least two purely
    alphabetic words. Identifiers (``Node.js``), versions (``24+``), single
    product names and heading numbers therefore stay exempt, matching the
    documentation rule that code, commands and proper nouns may fall back to
    English.
    """
    text = _CODE_SPAN.sub(" ", msgid)
    text = _MD_LINK.sub(r"\1", text)
    text = _URL.sub(" ", text)
    words = [tok for tok in text.split() if re.fullmatch(r"[A-Za-z]+", tok.strip(_PUNCT))]
    return len(words) >= 2
