import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

class CustomMessageWidget extends StatelessWidget {
  final String title;
  final IconData iconData;
  final String subTitle;
  final double? height;
  final bool isNotScrollable;

  const CustomMessageWidget({
    super.key,
    required this.title,
    required this.iconData,
    required this.subTitle,
    this.height,
    this.isNotScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: isNotScrollable ? null : AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: height ?? 75.h,
        width: 100.w,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              height != null ? SizedBox.shrink() : SizedBox(height: 10.h),
              Icon(iconData, size: 22.w),
              SizedBox(height: 1.h),
              CustomText(text: title.tr(), fontSize: 7.5, fontWeight: FontWeight.bold),
              CustomText(text: subTitle.tr(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
