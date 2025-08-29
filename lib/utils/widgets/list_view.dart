import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'message_widget.dart';

class CustomListView<T> extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final List<T> items;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? shimmerLoader;
  final Widget? Function(BuildContext, int)? listShimmerLoader;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget? separatorBuilder;
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final VoidCallback? onEndReached;
  final bool isPaginating;

  const CustomListView({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.items,
    required this.itemBuilder,
    this.shimmerLoader,
    this.listShimmerLoader,
    this.errorWidget,
    this.emptyWidget,
    this.separatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.onEndReached,
    this.isPaginating = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return errorWidget ??
          CustomMessageWidget(title: "حدث خطأ في جلب البيانات", iconData: Iconsax.close_circle, subTitle: "اسحب للأسفل لإعادة المحاولة");
    }

    if (!isLoading && !hasError && items.isEmpty) {
      return emptyWidget ??
          CustomMessageWidget(title: "لا توجد بيانات", iconData: Iconsax.box_search, subTitle: "لا توجد بيانات لجلبها وعرضها");
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!isLoading && !isPaginating && onEndReached != null && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.9) {
          onEndReached!();
        }
        return false;
      },
      child: ListView.separated(
        padding: padding,
        physics: physics,
        scrollDirection: scrollDirection,
        shrinkWrap: shrinkWrap,
        itemCount: isLoading ? 4 : items.length + (isPaginating ? 2 : 0),
        itemBuilder: (context, index) {
          if (isLoading) {
            if (listShimmerLoader != null) {
              return listShimmerLoader!(context, index);
            } else {
              return shimmerLoader;
            }
          }

          if (index < items.length) {
            return itemBuilder(context, index);
          } else {
            // Show pagination loader
            if (listShimmerLoader != null) {
              return listShimmerLoader!(context, index);
            } else {
              return shimmerLoader ?? const SizedBox.shrink();
            }
          }
        },
        separatorBuilder: (context, index) => separatorBuilder ?? const SizedBox.shrink(),
      ),
    );
  }
}
