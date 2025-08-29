import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:hasan2/controllers/search_controller.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/sort_selection.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/grid_view.dart';
import 'package:hasan2/utils/widgets/product_card.dart';
import 'package:hasan2/utils/widgets/product_shimmer.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:iconsax/iconsax.dart';

class SearchScreen extends StatefulWidget {
  final bool isFromSellButton;
  const SearchScreen({super.key, this.isFromSellButton = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchController _searchControllerInstance = Get.put(SearchController());

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    _searchControllerInstance.searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _searchControllerInstance.clearSearch();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: "البحث", isBackButtonVisible: true),
        body: GetBuilder<SearchController>(
          builder: (controller) {
            return Column(
              children: [
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomField(
                          controller: _searchController,
                          hintText: "ابحث عن منتج...",
                          suffixIcon: Iconsax.search_normal,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _onSearchSubmitted,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              controller.clearSearch();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                        child: IconButton(
                          onPressed: () {
                            Get.bottomSheet(
                              SortSelectionBottomSheet(
                                onSortOptionSelected: (SortOption option) {
                                  controller.setSortOption(option);
                                },
                              ),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          },
                          icon: Icon(Iconsax.sort, color: Colors.white, size: 6.w),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _buildResultsView(controller),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsView(SearchController controller) {
    if (controller.isSearchError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.close_circle, size: 12.w, color: Theme.of(context).colorScheme.error),
            SizedBox(height: 2.h),
            CustomText(text: "حدث خطأ في البحث", fontSize: 6, fontWeight: FontWeight.w600),
            SizedBox(height: 0.5.h),
            CustomText(text: "يرجى المحاولة مرة أخرى", fontSize: 4.5, color: Theme.of(context).colorScheme.secondary),
            SizedBox(height: 2.h),
            CustomButton(
              onTap: () {
                if (controller.searchQuery.isNotEmpty) {
                  controller.searchProducts(controller.searchQuery);
                }
              },
              title: "إعادة المحاولة",
              width: 40,
            ),
          ],
        ),
      );
    }

    if (controller.searchQuery.isEmpty && !controller.isSearchLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_normal, size: 12.w, color: Theme.of(context).colorScheme.secondary),
            SizedBox(height: 2.h),
            CustomText(text: "ابحث عن المنتجات", fontSize: 6, fontWeight: FontWeight.w600),
            SizedBox(height: 1.h),
            CustomText(text: "اكتب اسم المنتج واضغط على أيقونة البحث", fontSize: 4.5, color: Theme.of(context).colorScheme.secondary),
          ],
        ),
      );
    }

    if (controller.searchQuery.isNotEmpty && !controller.isSearchLoading && controller.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.box_search, size: 12.w, color: Theme.of(context).colorScheme.secondary),
            SizedBox(height: 2.h),
            CustomText(text: "لا توجد نتائج", fontSize: 6, fontWeight: FontWeight.w600),
            SizedBox(height: 1.h),
            CustomText(text: "لم يتم العثور على منتجات تطابق البحث", fontSize: 4.5, color: Theme.of(context).colorScheme.secondary),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.searchQuery.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(text: "نتائج البحث (${controller.searchResults.length})", fontSize: 5.5, fontWeight: FontWeight.w600),
                CustomText(
                  text: controller.getSortOptionName(controller.currentSortOption),
                  fontSize: 4.5,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        Expanded(
          child: DynamicCustomGridView(
            isPaginating: controller.isLoadingMoreResults,
            isLoading: controller.isSearchLoading,
            hasError: controller.isSearchError,
            items: controller.searchResults,
            crossAxisCount: 2,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.w,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            onEndReached: () {
              if (controller.searchQuery.isNotEmpty) {
                controller.loadMoreProducts();
              }
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
              final product = controller.searchResults[index];
              return ProductCard(product: product, isFromSellButton: widget.isFromSellButton);
            },
          ),
        ),
      ],
    );
  }
}
