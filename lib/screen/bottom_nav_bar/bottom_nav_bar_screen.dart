import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getx_controller/bottom_nav_controller.dart';
import '../../getx_controller/category_controller.dart';
import '../../getx_controller/home_controller.dart';
import '../../getx_controller/stats_controller.dart';
import '../../utils/app_routes.dart';
import '../../widget/app_bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../home/transactions_screen.dart';
import '../setting/setting_screen.dart';
import '../statistics/statistics_screen.dart';

/// The shell the four tabs live in, with the add button between them.
class BottomNavBarScreen extends StatelessWidget {
  const BottomNavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavController nav = Get.put(BottomNavController());
    Get.put(HomeController());
    Get.put(CategoryController());
    Get.put(StatsController());

    const List<Widget> tabs = <Widget>[
      HomeScreen(),
      TransactionsScreen(),
      StatisticsScreen(),
      SettingScreen(),
    ];

    return Obx(
      () => Scaffold(
        extendBody: true,
        body: IndexedStack(index: nav.index.value, children: tabs),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: nav.index.value,
          onSelected: nav.select,
          onAdd: () => Get.toNamed<void>(AppRoutes.transactionForm),
        ),
      ),
    );
  }
}
