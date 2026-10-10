#!/usr/bin/env python3
"""
Render Figma nodes to SVG from the cached document, with no network calls.

`tool/figma_pull.py` fetches the tree with `geometry=paths`, which means every
vector already carries its outline as SVG path data. That is everything needed
to draw the artwork locally, so this sidesteps the /v1/images endpoint and the
rate limit that comes with it.

  python3 tool/figma_pull.py     # once, to cache the tree
  python3 tool/figma_render.py   # as often as you like

Node ids and their destinations live in tool/figma_assets.py, so the two
exporters stay in agreement about what the app needs.
"""

from __future__ import annotations

import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from figma_assets import EXPORTS  # noqa: E402
from figma_pull import OUT, ROOT  # noqa: E402

Matrix = tuple[float, float, float, float, float, float]

IDENTITY: Matrix = (1.0, 0.0, 0.0, 1.0, 0.0, 0.0)


def to_matrix(transform: list[list[float]] | None) -> Matrix:
    """Figma stores [[a, c, e], [b, d, f]]; SVG wants (a, b, c, d, e, f)."""
    if not transform:
        return IDENTITY
    (a, c, e), (b, d, f) = transform
    return (a, b, c, d, e, f)


def multiply(m: Matrix, n: Matrix) -> Matrix:
    a1, b1, c1, d1, e1, f1 = m
    a2, b2, c2, d2, e2, f2 = n
    return (
        a1 * a2 + c1 * b2,
        b1 * a2 + d1 * b2,
        a1 * c2 + c1 * d2,
        b1 * c2 + d1 * d2,
        a1 * e2 + c1 * f2 + e1,
        b1 * e2 + d1 * f2 + f1,
    )


def fmt(value: float) -> str:
    return f"{value:.4f}".rstrip("0").rstrip(".") or "0"


def hex_of(color: dict) -> str:
    return "#{:02X}{:02X}{:02X}".format(
        *(round(color[k] * 255) for k in ("r", "g", "b"))
    )


class Renderer:
    """Flattens one Figma subtree into a list of SVG elements."""

    def __init__(self) -> None:
        self.defs: list[str] = []
        self.body: list[str] = []
        self._gradients = 0

    def paint(self, fill: dict, opacity: float) -> tuple[str, float] | None:
        """Returns (svg paint value, alpha), or None for a paint we skip."""
        kind = fill.get("type")
        alpha = fill.get("opacity", 1.0) * opacity

        if kind == "SOLID":
            colour = fill["color"]
            return hex_of(colour), colour.get("a", 1.0) * alpha

        if kind in ("GRADIENT_LINEAR", "GRADIENT_RADIAL"):
            self._gradients += 1
            name = f"g{self._gradients}"
            handles = fill.get("gradientHandlePositions") or []
            stops = "".join(
                '<stop offset="{}" stop-color="{}" stop-opacity="{}"/>'.format(
                    fmt(s.get("position", 0)),
                    hex_of(s["color"]),
                    fmt(s["color"].get("a", 1.0)),
                )
                for s in fill.get("gradientStops", [])
            )
            if kind == "GRADIENT_LINEAR" and len(handles) >= 2:
                x1, y1 = handles[0]["x"], handles[0]["y"]
                x2, y2 = handles[1]["x"], handles[1]["y"]
                self.defs.append(
                    f'<linearGradient id="{name}" x1="{fmt(x1)}" y1="{fmt(y1)}"'
                    f' x2="{fmt(x2)}" y2="{fmt(y2)}">{stops}</linearGradient>'
                )
            else:
                self.defs.append(
                    f'<radialGradient id="{name}">{stops}</radialGradient>'
                )
            return f"url(#{name})", alpha

        # Image fills need the bitmap, which is not in the cached tree.
        return None

    def geometry(self, paths: list[dict], paints: list[dict],
                 matrix: Matrix, opacity: float) -> None:
        for fill in paints:
            if not fill.get("visible", True):
                continue
            resolved = self.paint(fill, opacity)
            if resolved is None:
                continue
            value, alpha = resolved
            for entry in paths:
                d = entry.get("path")
                if not d:
                    continue
                rule = entry.get("windingRule", "NONZERO")
                attrs = [
                    f'd="{d}"',
                    f'fill="{value}"',
                    'fill-rule="evenodd"' if rule == "EVENODD" else "",
                    f'fill-opacity="{fmt(alpha)}"' if alpha < 1 else "",
                    f'transform="matrix({",".join(fmt(v) for v in matrix)})"'
                    if matrix != IDENTITY
                    else "",
                ]
                self.body.append(
                    "<path " + " ".join(a for a in attrs if a) + "/>"
                )

    def visit(self, node: dict, parent: Matrix, opacity: float) -> None:
        if node.get("visible", True) is False:
            return

        matrix = multiply(parent, to_matrix(node.get("relativeTransform")))
        alpha = opacity * node.get("opacity", 1.0)

        self.geometry(
            node.get("fillGeometry") or [], node.get("fills") or [],
            matrix, alpha,
        )
        self.geometry(
            node.get("strokeGeometry") or [], node.get("strokes") or [],
            matrix, alpha,
        )

        for child in node.get("children") or []:
            self.visit(child, matrix, alpha)


def render(node: dict, label: str) -> str:
    box = node.get("absoluteBoundingBox") or {}
    width = round(box.get("width", 0)) or 1
    height = round(box.get("height", 0)) or 1

    renderer = Renderer()
    # The subtree's own transform places it on the page; drop it so the export
    # starts at the origin of its own viewBox.
    for child in node.get("children") or []:
        renderer.visit(child, IDENTITY, 1.0)
    renderer.geometry(
        node.get("fillGeometry") or [], node.get("fills") or [],
        IDENTITY, 1.0,
    )

    defs = f"<defs>{''.join(renderer.defs)}</defs>" if renderer.defs else ""
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}"'
        f' width="{width}" height="{height}" role="img" aria-label="{label}">\n'
        f"  {defs}{''.join(renderer.body)}\n</svg>\n"
    )


def main() -> None:
    cached = OUT / "file.json"
    if not cached.exists():
        sys.exit("Run tool/figma_pull.py first.")

    doc = json.loads(cached.read_text())

    index: dict[str, dict] = {}

    def walk(node: dict) -> None:
        index[node["id"]] = node
        for child in node.get("children") or []:
            walk(child)

    walk(doc["document"])

    written, empty, missing = 0, [], []
    for node_id, target in EXPORTS.items():
        node = index.get(node_id)
        if node is None:
            missing.append(f"{node_id} -> {target}")
            continue

        label = pathlib.Path(target).stem.replace("_", " ")
        svg = render(node, label)

        if "<path" not in svg:
            empty.append(f"{node_id} -> {target} ({node.get('name')})")
            continue

        dest = ROOT / "assets" / target
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(svg)
        written += 1
        print(f"  {target}  {len(svg) / 1024:.1f} KB")

    print(f"\nrendered {written}/{len(EXPORTS)} into assets/")
    for title, items in (("no such node", missing), ("drew nothing", empty)):
        if items:
            print(f"{title}:")
            for item in items:
                print(f"  {item}")
    print("next: flutter test test/design")


if __name__ == "__main__":
    main()
