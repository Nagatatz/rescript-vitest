"""``conf.py`` derives the documented version from the npm package manifest."""

from __future__ import annotations

import json
import runpy

from tests._po import DOCS_DIR


def test_release_matches_package_json() -> None:
    conf = runpy.run_path(str(DOCS_DIR / "conf.py"))
    package = json.loads((DOCS_DIR.parent / "package.json").read_text(encoding="utf-8"))
    assert conf["release"] == package["version"]
    assert conf["version"] == ".".join(package["version"].split(".")[:2])
