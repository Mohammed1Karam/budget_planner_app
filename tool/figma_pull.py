#!/usr/bin/env python3
"""
Pull the full Budget Planner design out of Figma via the REST API.

The REST API quota is independent of the MCP server quota, so this keeps
working on a Starter plan. Needs a personal access token:
  Figma -> Settings -> Security -> Personal access tokens -> Generate new

  export FIGMA_TOKEN=figd_xxx          (or put it in .figma_token, gitignored)
  python3 tool/figma_pull.py

Writes:
  build/figma/file.json     raw document tree
  build/figma/screens.json  one entry per top-level screen frame
  build/figma/styles.json   every fill colour + text style found, with usage counts
"""

from __future__ import annotations

import json
import os
import pathlib
import sys
import urllib.error
import urllib.request

FILE_KEY = "GzilkpBhrhADVljRnVmvaB"
ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "build" / "figma"


def token() -> str:
    tok = os.environ.get("FIGMA_TOKEN", "").strip()
    if not tok:
        path = ROOT / ".figma_token"
        if path.exists():
            tok = path.read_text().strip()
    if not tok:
        sys.exit(
            "No token. Either:\n"
            "  export FIGMA_TOKEN=figd_xxx\n"
            "  echo figd_xxx > .figma_token   (already gitignored)"
        )
    return tok


def get(path: str) -> dict:
    req = urllib.request.Request(
        f"https://api.figma.com/v1/{path}",
        headers={"X-Figma-Token": token()},
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as err:
        body = err.read().decode("utf-8", "replace")[:400]
        sys.exit(f"Figma API {err.code} on /{path}\n{body}")


def hex_of(color: dict, opacity: float | None = None) -> str:
    """Figma stores channels as 0..1 floats; Flutter wants 0xAARRGGBB."""
    a = color.get("a", 1.0) * (1.0 if opacity is None else opacity)
    ch = [round(color[k] * 255) for k in ("r", "g", "b")]
    return "0x{:02X}{:02X}{:02X}{:02X}".format(round(a * 255), *ch)


def walk(node: dict, depth: int = 0):
    yield node, depth
    for child in node.get("children", []) or []:
        yield from walk(child, depth + 1)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    print("fetching document tree ...")
    doc = get(f"files/{FILE_KEY}?geometry=paths")
    (OUT / "file.json").write_text(json.dumps(doc, indent=1))

    pages = doc["document"]["children"]
    design = next((p for p in pages if p["name"] == "Design"), pages[0])

    screens = [
        {
            "id": n["id"],
            "name": n["name"],
            "width": round(n.get("absoluteBoundingBox", {}).get("width", 0)),
            "height": round(n.get("absoluteBoundingBox", {}).get("height", 0)),
            "nodes": sum(1 for _ in walk(n)),
        }
        for n in design["children"]
        if n["type"] == "FRAME"
    ]
    (OUT / "screens.json").write_text(json.dumps(screens, indent=1))

    colors: dict[str, int] = {}
    texts: dict[str, int] = {}
    radii: dict[float, int] = {}

    for node, _ in walk(design):
        for fill in node.get("fills", []) or []:
            if fill.get("type") == "SOLID" and fill.get("visible", True):
                key = hex_of(fill["color"], fill.get("opacity"))
                colors[key] = colors.get(key, 0) + 1
        style = node.get("style")
        if style:
            key = "{}|{}|{}|{}".format(
                style.get("fontFamily"),
                style.get("fontWeight"),
                style.get("fontSize"),
                round(style.get("lineHeightPx", 0), 1),
            )
            texts[key] = texts.get(key, 0) + 1
        r = node.get("cornerRadius")
        if isinstance(r, (int, float)):
            radii[r] = radii.get(r, 0) + 1

    (OUT / "styles.json").write_text(
        json.dumps(
            {
                "colors": dict(sorted(colors.items(), key=lambda kv: -kv[1])),
                "textStyles": dict(sorted(texts.items(), key=lambda kv: -kv[1])),
                "radii": dict(sorted(radii.items(), key=lambda kv: -kv[1])),
            },
            indent=1,
        )
    )

    print(f"  {len(screens)} screens, {len(colors)} colours, {len(texts)} text styles")
    print(f"  -> {OUT}")


if __name__ == "__main__":
    main()
