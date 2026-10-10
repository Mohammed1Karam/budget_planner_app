# Assets

All artwork here is exported from the Figma file
`UI_Budget_Planner_Light_mode`, not hand-drawn.

`tool/figma_render.py` produces it from the document tree that
`tool/figma_pull.py` caches. Because that tree is fetched with
`geometry=paths`, every vector already carries its outline, so the renderer
draws the SVGs locally and never calls Figma's `/v1/images` endpoint — which
rate-limits hard enough to make a full export impractical.

## Regenerating

```sh
python3 tool/figma_pull.py      # refresh the cached tree (needs the token)
python3 tool/figma_render.py    # redraw every asset, no network
```

`tool/figma_assets.py` holds the node-id → path map that both exporters share,
so adding an asset means adding one line there. It can also fetch through the
image endpoint instead, with back-off, if a node ever renders incorrectly
locally.

## Fonts

Montserrat, the family the Figma file is set in, bundled as a single variable
font. See `fonts/README.md`.

## One omission

`ic_user` — the avatar slot in the Home header — is an empty 180×44 tap target
in Figma with no artwork inside it. Nothing to export, so `AppAssets` does not
declare it and `HomeScreen` draws the initial in a circle instead.
