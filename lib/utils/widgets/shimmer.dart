import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmerContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;
  final BoxShape? shape;
  final double margin;
  const CustomShimmerContainer({super.key, this.height, this.width, this.borderRadius, this.shape, this.margin = 0});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      direction: ShimmerDirection.rtl,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: margin),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius ?? 0),
        ),
      ),
    );
  }
}
