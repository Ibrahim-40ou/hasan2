import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/brands_controller.dart';
import '../models/brand_model.dart';

class SelectBrandBottomSheet extends StatefulWidget {
  final Function(String id, String name) onBrandSelected;

  const SelectBrandBottomSheet({super.key, required this.onBrandSelected});

  @override
  State<SelectBrandBottomSheet> createState() => _SelectBrandBottomSheetState();
}

class _SelectBrandBottomSheetState extends State<SelectBrandBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final BrandsController _brandsController = Get.isRegistered<BrandsController>()
      ? Get.find<BrandsController>()
      : Get.put(BrandsController());
  List<BrandModel> _filteredBrands = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.addListener(_filterBrands);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBrands);
    _searchController.dispose();
    super.dispose();
  }

  void _filterBrands() {
    final searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredBrands = _brandsController.brands.where((brand) {
        return brand.name.toLowerCase().contains(searchText);
      }).toList();
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.close_circle, size: 12.w, color: Theme.of(context).colorScheme.error),
            SizedBox(height: 0.5.h),
            CustomText(
              text: 'حدث خطأ أثناء تحميل العلامات التجارية',
              fontSize: 5.5,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 2.h),
            CustomButton(
              onTap: () async {
                await _brandsController.fetchBrands();
              },
              title: 'إعادة المحاولة',
              width: 40,
            ),
            // ElevatedButton.icon(
            //   onPressed: () async {},
            //   icon: Icon(Iconsax.refresh, size: 5.w),
            //   label: CustomText(text: 'إعادة المحاولة', fontSize: 5, color: Theme.of(context).colorScheme.onPrimary),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Theme.of(context).colorScheme.primary,
            //     foregroundColor: Theme.of(context).colorScheme.onPrimary,
            //     padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.sp)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_status, size: 8.w, color: Theme.of(context).colorScheme.outline),
            SizedBox(height: 2.h),
            CustomText(text: 'لا توجد علامات تجارية مطابقة للبحث', fontSize: 5.5, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandsList(List<BrandModel> brands) {
    return ListView.builder(
      itemCount: brands.length,
      itemBuilder: (_, index) {
        final brand = brands[index];
        return GestureDetector(
          onTap: () {
            Get.back();
            widget.onBrandSelected(brand.id ?? '', brand.name);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 5.w),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
            child: CustomText(text: brand.name, fontSize: 6.5, height: 1),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(topRight: Radius.circular(3.sp), topLeft: Radius.circular(3.sp)),
      ),
      child: GetBuilder<BrandsController>(
        builder: (_) {
          final brands = _filteredBrands.isNotEmpty || _searchController.text.isNotEmpty ? _filteredBrands : _brandsController.brands;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 0.5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: CustomText(text: 'اختر العلامة التجارية', fontSize: 6.5, height: 2, fontWeight: FontWeight.w700),
              ),
              // Search Field - only show if not in error state
              if (!_brandsController.isBrandsFetchingError)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  child: CustomField(
                    controller: _searchController,
                    hintText: 'البحث في العلامات التجارية...',
                    suffixIcon: Iconsax.search_normal,
                    onChanged: (_) {},
                  ),
                ),
              Expanded(
                child: _brandsController.isBrandsFetchingLoading
                    ? Center(child: CircularProgressIndicator())
                    : _brandsController.isBrandsFetchingError
                    ? _buildErrorState()
                    : brands.isNotEmpty
                    ? _buildBrandsList(brands)
                    : _buildEmptyState(),
              ),
            ],
          );
        },
      ),
    );
  }
}
