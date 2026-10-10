/// Every key written to SharedPreferences, so no two call sites can disagree.
class PreferenceKeys {
  const PreferenceKeys._();

  static const String onboardingSeen = 'onboarding_seen';
  static const String user = 'user';
  static const String operations = 'operations';
  static const String categories = 'categories';
  static const String locale = 'locale';
  static const String loggedIn = 'logged_in';
  static const String themeMode = 'theme_mode';
}
