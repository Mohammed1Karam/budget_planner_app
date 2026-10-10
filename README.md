# Budget Planner

A private, offline budget planner in Flutter + GetX: a daily spending limit,
transactions by category, and monthly statistics. English and Arabic (RTL),
light and dark themes. Everything is stored on the device, behind a PIN.

## Screens

| Flow | Screens |
| --- | --- |
| Launch | Splash, Onboarding (3 pages) |
| Account | Create account, PIN setup (enter + confirm), PIN lock |
| Tabs | Home, Transactions, Statistics, Settings |
| Pushed | Add / edit transaction, Categories, Add category, Edit profile, About |

## Layout

```
lib/
├── api/                 BudgetApi over local storage (ApiClient kept for a future backend)
├── getx_controller/     app, auth, pin, home (ledger), stats, category, operation, onboarding
├── models/              user, operation, category, currency
├── preferences/         SharedPreferences wrapper
├── screen/              one folder per area
├── utils/               palette (AppPalette), theme, format, routes, pages
├── utils_lan/           English and Arabic strings
└── widget/              shared widgets and charts
```

Colours live in `AppPalette` (a `ThemeExtension`, light + dark); widgets read
them with `context.palette` and the type ramp with `context.text`.

## Running

```sh
flutter pub get
flutter run
flutter test
```
# budget_planner_app
