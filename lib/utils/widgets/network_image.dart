import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/shimmer.dart';
import 'package:iconsax/iconsax.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    required this.url,
    this.radius = 3,
    this.height,
    this.width,
    this.onEmptyIconSize = 2.5,
    this.onEmptyIconData,
    this.fit = BoxFit.cover,
    super.key,
    this.errorColor,
    this.backgroundColor,
  });

  final String url;
  final double radius;
  final double? height;
  final double? width;
  final double onEmptyIconSize;
  final IconData? onEmptyIconData;
  final Color? backgroundColor;
  final Color? errorColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: url != ''
            ? CachedNetworkImage(
                imageUrl: url,
                imageBuilder: (context, imageProvider) => Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    image: DecorationImage(image: imageProvider, fit: fit),
                  ),
                ),
                placeholder: (context, url) => CustomShimmerContainer(height: height, width: width, borderRadius: radius),
                errorWidget: (context, url, error) {
                  log('Error loading network image, error : $error');
                  return Container(
                    color: backgroundColor ?? Theme.of(context).colorScheme.surface,
                    height: height,
                    width: width,
                    padding: EdgeInsets.all(1.h),
                    child: Icon(Iconsax.info_circle),
                  );
                },
              )
            : Container(
                color: backgroundColor ?? Theme.of(context).colorScheme.surface,
                height: height,
                width: width,
                padding: EdgeInsets.all(1.h),
                child: Icon(onEmptyIconData ?? Iconsax.user, size: onEmptyIconSize.h),
              ),
      );
    } catch (e) {
      log('Error loading network image, error : $e');
      return Container(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        height: height,
        width: width,
        padding: EdgeInsets.all(1.h),
        child: Icon(Iconsax.info_circle),
      );
    }
  }
}
