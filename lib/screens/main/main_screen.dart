import 'package:flutter/material.dart';
import 'package:hasan2/screens/debt/debts_screen.dart';
import 'package:hasan2/screens/home/home_screen.dart';
import 'package:hasan2/screens/settings/settings_screen.dart';
import 'package:hasan2/screens/statistics/statistics_screen.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/widgets/local_image.dart';
import '../brands/brands_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          pageSnapping: false,
          children: [HomeScreen(), BrandsScreen(), const DebtsScreen(), const StatisticsScreen(), SettingsScreen()],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home, size: 7.w),
            activeIcon: Icon(Iconsax.home_15, size: 7.2.w),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.tag, size: 7.w),
            activeIcon: Icon(Iconsax.tag5, size: 7.2.w),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.money_change, size: 7.w),
            activeIcon: Icon(Iconsax.money_change5, size: 7.2.w),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.chart_square, size: 7.w),
            activeIcon: Icon(Iconsax.chart_square5, size: 7.2.w),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting_2, size: 7.w),
            activeIcon: LocalImage(img: "settings", type: "svg", height: 7.2.w, width: 7.2.w, color: Theme.of(context).colorScheme.primary),
            label: '',
          ),
        ],
      ),
    );
  }
}
