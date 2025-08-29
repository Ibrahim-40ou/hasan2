import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/products_controller.dart';
import 'package:hasan2/models/brand_model.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';

import '../../utils/widgets/grid_view.dart';
import '../../utils/widgets/product_card.dart';
import '../../utils/widgets/product_shimmer.dart';

class BrandProductsScreen extends StatefulWidget {
  final BrandModel brand;

  const BrandProductsScreen({super.key, required this.brand});

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  final ProductsController controller = Get.find<ProductsController>();

  @override
  void initState() {
    super.initState();
    controller.fetchBrandProducts(brandId: widget.brand.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "منتجات ${widget.brand.name}", isBackButtonVisible: true),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            controller.fetchBrandProducts(brandId: widget.brand.id!);
          },
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: GetBuilder<ProductsController>(
            builder: (controller) {
              return Padding(
                padding: EdgeInsets.all(4.w),
                child: DynamicCustomGridView(
                  isPaginating: controller.isLoadingMoreBrandProducts,
                  isLoading: controller.isBrandProductsLoading,
                  hasError: controller.isBrandProductsError,
                  items: controller.brandProducts, // ✅ Using brandProducts for items count
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.w,
                  onEndReached: () {
                    controller.loadMoreBrandProducts(widget.brand.id!);
                  },
                  shimmerLoader: ProductShimmer(
                    heightImage: 10.h,
                    widthImage: 100.w,
                    heightTitle: 2.h,
                    widthTitle: 40.w,
                    heightSubtitle1: 2.h,
                    widthSubtitle1: 25.w,
                    heightSubtitle2: 2.h,
                    widthSubtitle2: 15.w,
                    borderRadius: 10,
                    spacing: 4.w,
                  ),
                  itemBuilder: (context, index) {
                    final product = controller.brandProducts[index];
                    return ProductCard(product: product);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
