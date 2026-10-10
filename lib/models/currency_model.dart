import 'package:get/get.dart';

/// A currency the user keeps their budget in.
class CurrencyModel {
  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.flag,
  });

  final String code;
  final String symbol;
  final String flag;

  /// The localised name, e.g. "US Dollar" / "دولار أمريكي".
  String get name => 'currency_$code'.tr;

  static const CurrencyModel usd =
      CurrencyModel(code: 'USD', symbol: r'$', flag: '🇺🇸');

  static const List<CurrencyModel> all = <CurrencyModel>[
    usd,
    CurrencyModel(code: 'EUR', symbol: '€', flag: '🇪🇺'),
    CurrencyModel(code: 'GBP', symbol: '£', flag: '🇬🇧'),
    CurrencyModel(code: 'JOD', symbol: 'JD', flag: '🇯🇴'),
    CurrencyModel(code: 'SAR', symbol: 'SR', flag: '🇸🇦'),
    CurrencyModel(code: 'AED', symbol: 'AED', flag: '🇦🇪'),
    CurrencyModel(code: 'KWD', symbol: 'KD', flag: '🇰🇼'),
    CurrencyModel(code: 'EGP', symbol: 'E£', flag: '🇪🇬'),
    CurrencyModel(code: 'ILS', symbol: '₪', flag: '🇵🇸'),
    CurrencyModel(code: 'JPY', symbol: '¥', flag: '🇯🇵'),
  ];

  static CurrencyModel byCode(String code) =>
      all.firstWhere((c) => c.code == code, orElse: () => usd);
}
