import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';

import 'loading.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.loading = false,
    this.color,
    this.textColor,
    this.title,
    required this.onTap,
    this.fontWeight,
    this.borderColor = Colors.transparent,
    this.width = 100,
    this.verticalPadding = 1.25,
    this.child,
    this.loadingColor,
  });

  final bool loading;
  final String? title;
  final Widget? child;
  final Color? color;
  final Color? textColor;
  final double width;
  final double verticalPadding;
  final FontWeight? fontWeight;
  final Color borderColor;
  final Function()? onTap;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      child: MaterialButton(
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: verticalPadding.h, horizontal: 0.5.w),
        minWidth: double.infinity,
        color: color ?? Theme.of(context).primaryColor,
        onPressed: !loading ? onTap : () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.sp),
          side: BorderSide(color: borderColor, width: 0.5.w),
        ),
        child: !loading
            ? child ??
                  Padding(
                    padding: EdgeInsets.all(1.h),
                    child: CustomText(
                      text: title!.tr(),
                      height: 1,
                      color: textColor ?? Colors.white,
                      fontSize: 5,
                      fontWeight: fontWeight ?? FontWeight.bold,
                    ),
                  )
            : Center(child: CustomLoading(loadingColor: loadingColor)),
      ),
    );
  }
}
