import 'package:get/get.dart';

import '../getx_controller/category_controller.dart';
import '../getx_controller/home_controller.dart';
import '../getx_controller/operation_controller.dart';
import '../screen/about/about_screen.dart';
import '../screen/auth/create_account_screen.dart';
import '../screen/auth/lock_screen.dart';
import '../screen/auth/pin_code_screen.dart';
import '../screen/bottom_nav_bar/bottom_nav_bar_screen.dart';
import '../screen/category/add_category_screen.dart';
import '../screen/category/category_screen.dart';
import '../screen/lunch/onboarding_screen.dart';
import '../screen/lunch/splash_screen.dart';
import '../screen/operation/add_operation_screen.dart';
import '../screen/profile/profile_screen.dart';
import 'app_routes.dart';

/// One [GetPage] per route. Screens that can be reached before the tab shell
/// has registered its controllers bind them lazily here.
class AppPages {
  const AppPages._();

  static final Bindings _ledger = BindingsBuilder(() {
    Get.lazyPut(HomeController.new, fenix: true);
    Get.lazyPut(CategoryController.new, fenix: true);
  });

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage<void>(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.createAccount,
      page: () => const CreateAccountScreen(),
    ),
    GetPage<void>(name: AppRoutes.lock, page: () => const LockScreen()),
    GetPage<String>(
      name: AppRoutes.pinCode,
      page: () => const PinCodeScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.shell,
      page: () => const BottomNavBarScreen(),
    ),
    GetPage<void>(
      name: AppRoutes.transactionForm,
      page: () => const AddOperationScreen(),
      fullscreenDialog: true,
      transition: Transition.downToUp,
      binding: BindingsBuilder(() {
        _ledger.dependencies();
        Get.put(OperationController());
      }),
    ),
    GetPage<void>(
      name: AppRoutes.categories,
      page: () => const CategoryScreen(),
      binding: _ledger,
    ),
    GetPage<dynamic>(
      name: AppRoutes.addCategory,
      page: () => const AddCategoryScreen(),
      binding: _ledger,
    ),
    GetPage<void>(name: AppRoutes.profile, page: () => const ProfileScreen()),
    GetPage<void>(name: AppRoutes.about, page: () => const AboutScreen()),
  ];
}
