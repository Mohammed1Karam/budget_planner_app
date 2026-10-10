/// Named routes.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  /// Sign-up for a first-time user.
  static const String createAccount = '/create-account';

  /// The PIN lock a returning user unlocks the app with.
  static const String lock = '/lock';

  /// Sets (and confirms) a new PIN; pops with it.
  static const String pinCode = '/pin-code';

  /// The tab shell: Home, Transactions, Statistics, Settings.
  static const String shell = '/app';

  /// Add a transaction, or edit one when pushed with it as the argument.
  static const String transactionForm = '/transaction';

  static const String categories = '/categories';
  static const String addCategory = '/categories/new';

  static const String profile = '/profile';
  static const String about = '/about';
}
