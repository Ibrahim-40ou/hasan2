import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:iconsax/iconsax.dart';

class BackButtonCustom extends StatelessWidget {
  const BackButtonCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.back,
      child: Icon(
        Localizations.localeOf(context).toString() == 'en_US' ? Iconsax.arrow_right_34 : Iconsax.arrow_left_24,
        size: 6.w,
      ),
    );
  }
}
