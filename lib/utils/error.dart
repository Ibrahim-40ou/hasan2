import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showError(String text) async {
  final preferences = await SharedPreferences.getInstance();
  final isSnackBarActive = preferences.getBool('isSnackBarActive') ?? false;

  if (!isSnackBarActive) {
    await preferences.setBool('isSnackBarActive', true);

    Get.snackbar(
      "",
      "",
      backgroundColor: Colors.redAccent.withAlpha(179),
      snackPosition: SnackPosition.TOP,
      titleText: CustomText(text: "حدث خطأ", fontSize: 6, fontWeight: FontWeight.bold, color: Colors.white),
      messageText: CustomText(text: _handleErrorText(text), fontSize: 6, color: Colors.white),
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
    );

    await Future.delayed(Duration(seconds: 3));
    await preferences.setBool('isSnackBarActive', false);
  }
}

Future<void> showSnackBar(String text) async {
  final preferences = await SharedPreferences.getInstance();
  final isSnackBarActive = preferences.getBool('isSnackBarActive') ?? false;

  if (!isSnackBarActive) {
    await preferences.setBool('isSnackBarActive', true);

    Get.snackbar(
      "",
      "",
      backgroundColor: Get.theme.primaryColor,
      snackPosition: SnackPosition.TOP,
      titleText: CustomText(text: "تمت العملية", fontSize: 6, fontWeight: FontWeight.bold, color: Colors.white),
      messageText: CustomText(
        text: text,
        fontSize: 6,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        textAlign: TextAlign.center,
        maxLines: 4,
      ),
      duration: const Duration(seconds: 3),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );

    await Future.delayed(const Duration(seconds: 3));
    await preferences.setBool('isSnackBarActive', false);
  }
}

String _handleErrorText(String error) {
  String text = error.toLowerCase().trim();
  if (text.contains("no internet connection")) {
    return "حدث خطأ في الشبكة";
  } else {
    return "حدث خطأ غير معروف";
  }
}
