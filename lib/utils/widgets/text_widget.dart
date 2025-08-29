import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hasan2/utils/size_config.dart';

class CustomText extends StatelessWidget {
  final String text;
  final int? maxLines;
  final int maxChars;
  final Color? color;
  final TextAlign textAlign;
  final double fontSize;
  final double? height;
  final double? horizontalPadding;
  final bool isLink;
  final bool underline;
  final bool isSubTitle;
  final FontWeight fontWeight;

  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 5,
    this.maxLines,
    this.height,
    this.horizontalPadding,
    this.isLink = false,
    this.underline = false,
    this.isSubTitle = false,
    this.color,
    this.fontWeight = FontWeight.w500,
    this.textAlign = TextAlign.center,
    this.maxChars = 100000,
  });

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return text == ""
        ? const SizedBox()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding?.w ?? 0.0),
            child: Text(
              text.length > maxChars ? text.substring(0, maxChars) : text.tr(),
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontFamily: locale != Locale('fa', 'IR') ? 'Cairo' : 'Nrt',
                fontSize: fontSize.sp,
                height: height,
                decoration: underline ? TextDecoration.underline : TextDecoration.none,
                color: isSubTitle ? Theme.of(context).colorScheme.secondary : color ?? Theme.of(context).colorScheme.onSurface,
                fontWeight: fontWeight,
              ),
            ),
          );
  }
}
