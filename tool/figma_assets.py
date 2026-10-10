#!/usr/bin/env python3
"""
Export the artwork this app needs from Figma, by node id.

Run tool/figma_pull.py first -- this reuses the tree it cached.

  python3 tool/figma_assets.py

Rather than guessing from layer names, each asset below names the exact Figma
node it comes from, so re-running always produces the same files. The render
endpoint rate-limits aggressively, so requests go out in small batches and back
off when it says to.
"""

from __future__ import annotations

import pathlib
import sys
import time
import urllib.error
import urllib.request

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from figma_pull import FILE_KEY, OUT, ROOT, get  # noqa: E402

# Figma node id -> the path in assets/ that lib/utils/app_assets.dart expects.
# Ids were read off the Design page; a node that appears on several frames is
# taken from whichever frame shows it largest.
EXPORTS: dict[str, str] = {
    # Brand marks
    "6:1578": "icons/logo.svg",
    "6:1083": "icons/ic_budget.svg",
    "6:2021": "icons/ic_done.svg",
    "6:1014": "icons/ic_users.svg",
    # Navigation glyphs
    "6:1078": "icons/ic_close.svg",
    "7:827": "icons/ic_arrow_left_dark.svg",
    "7:828": "icons/ic_share_dark.svg",
    "6:1989": "icons/ic_arrow_litle.svg",
    "6:1135": "icons/ic_other.svg",
    # The Material icons the designer dropped into Settings
    "20:525": "icons/info_black_24dp_1.svg",
    "22:562": "icons/language_black_24dp_1.svg",
    "20:542": "icons/logout_black_24dp_1.svg",
    "20:554": "icons/delete_forever_black_24dp_1.svg",
    "20:566": "icons/person_remove_black_24dp_1.svg",
    "16:527": "icons/settings_black_24dp_1.svg",
    "14:399": "icons/add_circle_black_24dp_1.svg",
    "7:792": "icons/search.svg",
    # Illustrations
    "6:1595": "images/yana_ui_kit_illustration_01.svg",
    "6:1709": "images/yana_ui_kit_illustration_02.svg",
    "6:1838": "images/yana_ui_kit_illustration_03.svg",
    "7:799": "images/tip_article_hero.svg",
}

BATCH = 6
PAUSE = 4.0


def render(ids: list[str]) -> dict[str, str]:
    """Ask Figma for SVG URLs, backing off while it rate-limits us."""
    urls: dict[str, str] = {}

    for start in range(0, len(ids), BATCH):
        chunk = ids[start : start + BATCH]
        query = f"images/{FILE_KEY}?ids={','.join(chunk)}&format=svg"

        for attempt in range(6):
            try:
                result = get(query)
            except SystemExit as stop:
                if "429" not in str(stop):
                    raise
                wait = PAUSE * (2**attempt)
                print(f"  rate limited, waiting {wait:.0f}s")
                time.sleep(wait)
                continue

            if result.get("err"):
                print(f"  ! {result['err']}")
            urls.update(
                {k: v for k, v in (result.get("images") or {}).items() if v}
            )
            break
        else:
            sys.exit("Figma kept rate-limiting; try again in a few minutes.")

        done = min(start + BATCH, len(ids))
        print(f"  rendered {done}/{len(ids)}")
        if done < len(ids):
            time.sleep(PAUSE)

    return urls


def download(url: str, dest: pathlib.Path) -> int:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(url, timeout=120) as response:
        payload = response.read()
    dest.write_bytes(payload)
    return len(payload)


def main() -> None:
    if not (OUT / "file.json").exists():
        sys.exit("Run tool/figma_pull.py first.")

    ids = list(EXPORTS)
    print(f"exporting {len(ids)} assets")

    urls = render(ids)

    written, missing = 0, []
    for node_id, target in EXPORTS.items():
        url = urls.get(node_id)
        if not url:
            missing.append(f"{node_id} -> {target}")
            continue
        try:
            size = download(url, ROOT / "assets" / target)
        except urllib.error.URLError as err:
            missing.append(f"{target} ({err})")
            continue
        written += 1
        print(f"  {target}  {size / 1024:.1f} KB")

    print(f"\nwrote {written}/{len(EXPORTS)} into assets/")
    if missing:
        print("did not render:")
        for item in missing:
            print(f"  {item}")
    print("next: flutter test test/design")


if __name__ == "__main__":
    main()
