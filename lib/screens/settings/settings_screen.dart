import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/auth_controller.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/theme_selection.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/settings_component.dart';
import 'package:hasan2/utils/dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "الإعدادات"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsComponent(
                icon: Icons.dark_mode,
                title: "الوضع الليلي",
                onTap: () {
                  Get.bottomSheet(
                    DarkModeSelectionBottomSheet(
                      onThemeModeSelected: (ThemeMode mode) {
                        // Theme change is handled by the controller
                      },
                    ),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
              SettingsComponent(icon: Icons.logout, title: "تسجيل الخروج", onTap: () {
                showConfirmationDialog(
                  buildContext: context,
                  content: "هل أنت متأكد من تسجيل الخروج؟",
                  confirm: () async {
                    await Get.find<AuthController>().logout();
                  },
                  reject: () {},
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
