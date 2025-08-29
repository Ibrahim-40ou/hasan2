import 'package:flutter/material.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

class InfoCard extends StatelessWidget {
  final double width;
  final IconData iconData;
  final String title;
  final String amountText;
  final double titleSize;
  final bool isSelected;
  final Function() onTap;
  const InfoCard({
    super.key,
    required this.width,
    required this.iconData,
    required this.title,
    required this.amountText,
    required this.titleSize,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(iconData, size: 6.w, color: isSelected ? Colors.white : null),
                SizedBox(width: 2.w),
                Flexible(
                  child: CustomText(text: title, fontWeight: FontWeight.w900, fontSize: titleSize, color: isSelected ? Colors.white : null),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Flexible(
                  child: CustomText(text: amountText, fontWeight: FontWeight.w900, fontSize: 6, color: isSelected ? Colors.white : null),
                ),
                SizedBox(width: 1.w),
                Flexible(
                  child: CustomText(text: "/منتج", color: isSelected ? Colors.white : null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
