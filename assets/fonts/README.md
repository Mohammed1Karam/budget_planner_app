# Fonts

Montserrat, which is the family `UI_Budget_Planner_Light_mode` is set in —
confirmed from `build/figma/styles.json`, where it accounts for every text
style in the file bar a handful of Roboto nodes in the date picker.

It ships as one variable font covering the 100–900 axis. Flutter maps
`fontWeight` onto that axis, so the four weights the design uses (400, 500, 600
and 700) all render from this single file, and nothing is fetched at runtime.

To swap the family: drop the new files in, update the `fonts:` block in
`pubspec.yaml`, and change `AppTextStyles.family`. Nothing else names a font,
and `test/design/design_tokens_test.dart` asserts the whole ramp stays on one.

Montserrat is licensed under the SIL Open Font License 1.1 — see `OFL.txt`.
