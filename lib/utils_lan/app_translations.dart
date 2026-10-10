import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'lang_ar.dart';
import 'lang_en.dart';

/// Wires the per-language maps into GetX, so a key resolves with `.tr`.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => <String, Map<String, String>>{
        'en_US': langEn,
        'ar_JO': langAr,
      };

  static const Locale fallback = Locale('en', 'US');

  static const List<Locale> supported = <Locale>[
    Locale('en', 'US'),
    Locale('ar', 'JO'),
  ];
}
