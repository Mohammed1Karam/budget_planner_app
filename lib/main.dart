import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'getx_controller/app_controller.dart';
import 'preferences/app_preferences.dart';
import 'utils/app_pages.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'utils_lan/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The whole app reads its state out of here, so it has to be ready before
  // the first frame.
  await AppPreferences.init();
  await initializeDateFormatting();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  Get.put(AppController(), permanent: true);

  runApp(const BudgetPlannerApp());
}

class BudgetPlannerApp extends StatelessWidget {
  const BudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController app = Get.find<AppController>();

    return GetMaterialApp(
      title: 'Budget Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: app.themeMode.value,
      translations: AppTranslations(),
      locale: AppController.localeOf(app.localeCode.value),
      fallbackLocale: AppTranslations.fallback,
      supportedLocales: AppTranslations.supported,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
