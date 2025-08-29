import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';

import 'message_widget.dart';

class DynamicCustomGridView<T> extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final List<T> items;
  final Widget Function(BuildContext, int) itemBuilder;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final Widget? shimmerLoader;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final bool shrinkWrap;
  final VoidCallback? onEndReached;
  final bool isPaginating;

  const DynamicCustomGridView({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding = EdgeInsets.zero,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.shimmerLoader,
    this.errorWidget,
    this.emptyWidget,
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
      child: MasonryGridView.builder(
        itemCount: isLoading ? 4 : items.length + (isPaginating ? 2 : 0),
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        itemBuilder: (context, index) {
          if (isLoading) {
            return shimmerLoader ?? const SizedBox.shrink();
          }

          if (index < items.length) {
            return itemBuilder(context, index);
          } else {
            return shimmerLoader ?? const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
