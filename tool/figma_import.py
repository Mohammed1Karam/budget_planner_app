#!/usr/bin/env python3
"""
Ingest an export taken straight out of the Figma UI.

No token needed. In Figma select the frames, Export as SVG, then point this at
whatever came out -- a folder or a .zip:

  python3 tool/figma_import.py ~/Downloads/UI_Budget_Planner_Light_mode.zip

It does three things:

1. Reads every colour and font-family out of the SVG source and writes
   build/figma/observed.json, ordered by how often each is used. Those are the
   real values from the file, not an estimate.
2. Copies the artwork into assets/, renaming Figma's layer names to the slugs
   lib/utils/app_assets.dart already expects.
3. Prints what it could not place, so nothing goes missing silently.
"""

from __future__ import annotations

import argparse
import collections
import json
import pathlib
import re
import shutil
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"
OUT = ROOT / "build" / "figma"

# Figma layer name (slugged) -> the path AppAssets already points at. Anything
# not listed here is still copied, under its own slug, and reported.
RENAMES = {
    "logo": "icons/logo.svg",
    "ic_budget": "icons/ic_budget.svg",
    "ic_done": "icons/ic_done.svg",
    "ic_users": "icons/ic_users.svg",
    "ic_user": "icons/ic_user.svg",
    "ic_arrow_left_dark": "icons/ic_arrow_left_dark.svg",
    "ic_arrow_litle": "icons/ic_arrow_litle.svg",
    "ic_close": "icons/ic_close.svg",
    "ic_share_dark": "icons/ic_share_dark.svg",
    "ic_other": "icons/ic_other.svg",
    "info_black_24dp_1": "icons/info_black_24dp_1.svg",
    "language_black_24dp_1": "icons/language_black_24dp_1.svg",
    "logout_black_24dp_1": "icons/logout_black_24dp_1.svg",
    "delete_forever_black_24dp_1": "icons/delete_forever_black_24dp_1.svg",
    "person_remove_black_24dp_1": "icons/person_remove_black_24dp_1.svg",
    "settings_black_24dp_1": "icons/settings_black_24dp_1.svg",
    "add_circle_black_24dp_1": "icons/add_circle_black_24dp_1.svg",
    "search": "icons/search.svg",
    "lg_onboarding_0": "images/yana_ui_kit_illustration_01.svg",
    "lg_onboarding_1": "images/yana_ui_kit_illustration_02.svg",
    "lg_onboarding_2": "images/yana_ui_kit_illustration_03.svg",
    "tip_article": "images/tip_article_hero.svg",
    # The designer's own illustration names, and the slugs this project already
    # uses, so re-running over an earlier import is a no-op rather than a move.
    "yana_ui_kit_illustration_01": "images/yana_ui_kit_illustration_01.svg",
    "yana_ui_kit_illustration_02": "images/yana_ui_kit_illustration_02.svg",
    "yana_ui_kit_illustration_03": "images/yana_ui_kit_illustration_03.svg",
    "tip_article_hero": "images/tip_article_hero.svg",
}

# An unmapped file is filed by what its name suggests. Anything that reads as
# artwork belongs beside the illustrations, not in the icon set.
IMAGE_HINTS = ("illustration", "hero", "pic", "image", "img", "photo", "bg")

HEX = re.compile(r"#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})\b")


def slug(name: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "_", name.strip().lower())
    return re.sub(r"_+", "_", s).strip("_")


def unpack(source: pathlib.Path, workdir: pathlib.Path) -> pathlib.Path:
    """Accepts whatever Figma produced: a folder, a .zip, or a single .svg.

    Exporting selected layers gives a folder or a zip; exporting the page with
    nothing selected gives one .svg holding every frame. Both are useful -- the
    single file still carries all the colours and the typeface.
    """
    if source.is_dir():
        return source
    if source.suffix.lower() == ".zip":
        with zipfile.ZipFile(source) as archive:
            archive.extractall(workdir)
        return workdir
    if source.suffix.lower() == ".svg":
        shutil.copy2(source, workdir / source.name)
        return workdir
    sys.exit(f"{source} is not a folder, a .zip or an .svg")


def normalise(value: str) -> str:
    """Expand #abc to #aabbcc and upper-case, so counts do not split."""
    v = value.lstrip("#")
    if len(v) == 3:
        v = "".join(c * 2 for c in v)
    return "#" + v.upper()


def harvest(svgs: list[pathlib.Path]) -> dict:
    colors: collections.Counter = collections.Counter()
    fonts: collections.Counter = collections.Counter()

    for path in svgs:
        text = path.read_text(errors="replace")
        for match in HEX.findall(text):
            colors[normalise(match)] += 1

        try:
            tree = ET.fromstring(text)
        except ET.ParseError:
            continue
        for node in tree.iter():
            family = node.get("font-family")
            if family:
                fonts[family.strip("'\" ")] += 1
            style = node.get("style") or ""
            found = re.search(r"font-family\s*:\s*([^;]+)", style)
            if found:
                fonts[found.group(1).strip("'\" ")] += 1

    return {
        "colors": dict(colors.most_common()),
        "fonts": dict(fonts.most_common()),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", help="the exported folder or .zip")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="report what would happen without writing to assets/",
    )
    args = parser.parse_args()

    source = pathlib.Path(args.source).expanduser()
    if not source.exists():
        sys.exit(f"{source} does not exist")

    with tempfile.TemporaryDirectory() as tmp:
        root = unpack(source, pathlib.Path(tmp))
        svgs = sorted(root.rglob("*.svg"))
        if not svgs:
            sys.exit(f"no .svg files under {root}")

        whole_page = len(svgs) == 1
        print(f"found {len(svgs)} svg file{'' if whole_page else 's'}")

        OUT.mkdir(parents=True, exist_ok=True)
        observed = harvest(svgs)
        (OUT / "observed.json").write_text(json.dumps(observed, indent=1))

        print(f"\n{len(observed['colors'])} distinct colours, most used first:")
        for value, count in list(observed["colors"].items())[:12]:
            print(f"  {value}  x{count}")

        if observed["fonts"]:
            print("\nfonts:")
            for family, count in observed["fonts"].items():
                print(f"  {family}  x{count}")
        else:
            print("\nno font-family found -- the export outlined its text")

        if whole_page:
            # One file holding the whole page: the palette and the typeface are
            # the point, and there is nothing to split into named assets.
            print(
                "\nthis is a single whole-page export, so the colours and font "
                "above are the useful part -- no artwork was filed.\nTo get the "
                "assets too, select the frames in Figma before exporting."
            )
            print(f"\nfull report -> {OUT / 'observed.json'}")
            return

        placed, extra = 0, []
        for path in svgs:
            name = slug(path.stem)
            target = RENAMES.get(name)
            if target is None:
                extra.append(name)
                folder = (
                    "images"
                    if any(hint in name for hint in IMAGE_HINTS)
                    else "icons"
                )
                target = f"{folder}/{name}.svg"
            dest = ASSETS / target
            if not args.dry_run:
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, dest)
            placed += 1

        verb = "would copy" if args.dry_run else "copied"
        print(f"\n{verb} {placed} files into assets/")
        if extra:
            print(
                f"{len(extra)} had no mapping and {verb.split()[-1]} under their own "
                f"slug: {', '.join(sorted(extra)[:10])}"
                f"{' ...' if len(extra) > 10 else ''}"
            )

        print(f"\nfull report -> {OUT / 'observed.json'}")
        print("next: flutter test test/design")


if __name__ == "__main__":
    main()
