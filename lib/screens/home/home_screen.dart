import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/products_controller.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/info_card.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/widgets/grid_view.dart';
import '../../utils/widgets/product_card.dart';
import '../../utils/widgets/product_shimmer.dart';
import '../products/add_product_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int statsIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "الصفحة الرئيسية",
        onTap: () {
          Get.to(() => const SearchScreen());
        },
        iconData: Iconsax.search_normal,
      ),
      body: GetBuilder<ProductsController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchProducts();
            },
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!controller.isProductsFetchingLoading &&
                    !controller.isLoadingMoreProducts &&
                    scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.9) {
                  controller.loadMoreProducts();
                }
                return false;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 0.5.h),
                        InfoCard(
                          width: 100.w,
                          iconData: Iconsax.box,
                          title: "المنتجات الكلية",
                          amountText: "${controller.getFilteredProductsByIndex(0).length}",
                          titleSize: 6,
                          isSelected: statsIndex == 0,
                          onTap: () {
                            setState(() {
                              statsIndex = 0;
                            });
                          },
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoCard(
                              width: 45.w,
                              iconData: Iconsax.box_tick,
                              title: "الأكثر مبيعاً",
                              amountText: "${controller.getFilteredProductsByIndex(1).length}",
                              titleSize: 5,
                              isSelected: statsIndex == 1,
                              onTap: () {
                                setState(() {
                                  statsIndex = 1;
                                });
                              },
                            ),
                            SizedBox(width: 2.w),
                            InfoCard(
                              width: 45.w,
                              iconData: Iconsax.box_remove,
                              title: "الأقل مبيعاً",
                              amountText: "${controller.getFilteredProductsByIndex(2).length}",
                              titleSize: 5,
                              isSelected: statsIndex == 2,
                              onTap: () {
                                setState(() {
                                  statsIndex = 2;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoCard(
                              width: 45.w,
                              iconData: Iconsax.box_time,
                              title: "قريبة الانتهاء",
                              amountText: "${controller.getFilteredProductsByIndex(3).length}",
                              titleSize: 5,
                              isSelected: statsIndex == 3,
                              onTap: () {
                                setState(() {
                                  statsIndex = 3;
                                });
                              },
                            ),
                            SizedBox(width: 2.w),
                            InfoCard(
                              width: 45.w,
                              iconData: Iconsax.box_add,
                              title: "منتهية",
                              amountText: "${controller.getFilteredProductsByIndex(4).length}",
                              titleSize: 5,
                              isSelected: statsIndex == 4,
                              onTap: () {
                                setState(() {
                                  statsIndex = 4;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        DynamicCustomGridView(
                          isPaginating: controller.isLoadingMoreProducts,
                          isLoading: controller.isProductsFetchingLoading,
                          hasError: controller.isProductsFetchingError,
                          items: controller.getFilteredProductsByIndex(statsIndex),
                          crossAxisCount: 2,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 2.w,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                            final product = controller.products[index];
                            return ProductCard(product: product);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_product_fab',
            onPressed: () {
              Get.to(() => const AddProductsScreen());
            },
            elevation: 0,
            child: Center(
              child: Icon(Iconsax.add, size: 6.w, color: Colors.white),
            ),
          ),
          SizedBox(height: 1.h),
          FloatingActionButton(
            heroTag: 'sell_product_fab',
            onPressed: () {
              Get.to(() => const SearchScreen(isFromSellButton: true));
            },
            elevation: 0,
            child: Center(
              child: Icon(Iconsax.money_send, size: 6.w, color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
