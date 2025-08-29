import 'package:flutter/material.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

class SettingsComponent extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;

  const SettingsComponent({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;
    final Color defaultIconBgColor = isLightMode
        ? Theme.of(context).colorScheme.secondaryContainer
        : Theme.of(context).colorScheme.secondaryContainer;
    final Color defaultIconColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.5.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(color: iconBackgroundColor ?? defaultIconBgColor, borderRadius: BorderRadius.circular(100)),
                  child: Icon(icon, color: iconColor ?? defaultIconColor, size: 6.w),
                ),
                SizedBox(width: 2.w),
                CustomText(text: title),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 6.w, color: Theme.of(context).colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}
