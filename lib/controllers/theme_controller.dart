import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  
  final _themeMode = ThemeMode.light.obs;
  
  ThemeMode get themeMode => _themeMode.value;
  
  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
  }
  
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 1; // Default to light mode
    _themeMode.value = ThemeMode.values[themeModeIndex];
    update(); // Notify GetBuilder to rebuild
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    Get.changeThemeMode(mode);
    update(); // Notify GetBuilder to rebuild
  }
  
  void changeThemeMode(ThemeMode mode) {
    setThemeMode(mode);
  }
} 