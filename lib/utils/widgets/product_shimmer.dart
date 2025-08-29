import 'package:flutter/material.dart';
import 'package:hasan2/utils/widgets/shimmer.dart';

class ProductShimmer extends StatelessWidget {
  final double heightImage;
  final double widthImage;
  final double heightTitle;
  final double widthTitle;
  final double heightSubtitle1;
  final double widthSubtitle1;
  final double heightSubtitle2;
  final double widthSubtitle2;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double spacing;

  const ProductShimmer({
    super.key,
    this.heightImage = 100,
    this.widthImage = double.infinity,
    this.heightTitle = 20,
    this.widthTitle = 150,
    this.heightSubtitle1 = 20,
    this.widthSubtitle1 = 100,
    this.heightSubtitle2 = 20,
    this.widthSubtitle2 = 60,
    this.borderRadius = 10,
    this.padding,
    this.backgroundColor,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = backgroundColor ?? Theme.of(context).cardColor;

    return Container(
      padding: padding ?? EdgeInsets.all(spacing),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), color: cardColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomShimmerContainer(height: heightImage, width: widthImage, margin: spacing / 2, borderRadius: borderRadius),
          SizedBox(height: spacing),
          CustomShimmerContainer(height: heightTitle, width: widthTitle, margin: spacing / 2, borderRadius: borderRadius),
          SizedBox(height: spacing / 2),
          CustomShimmerContainer(height: heightSubtitle1, width: widthSubtitle1, margin: spacing / 2, borderRadius: borderRadius),
          SizedBox(height: spacing / 2),
          CustomShimmerContainer(height: heightSubtitle2, width: widthSubtitle2, margin: spacing / 2, borderRadius: borderRadius),
        ],
      ),
    );
  }
}
