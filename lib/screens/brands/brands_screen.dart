import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/utils/dialog.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/list_view.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/brands_controller.dart';
import '../../utils/widgets/button.dart';
import '../../utils/widgets/shimmer.dart';
import '../../utils/widgets/text_form_field.dart';
import '../../utils/widgets/text_widget.dart';
import '../products/brand_products_screen.dart';

class BrandsScreen extends StatelessWidget {
  BrandsScreen({super.key});

  final BrandsController controller = Get.find<BrandsController>();
  final TextEditingController _brandController = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "العلامات التجارية"),
      body: SafeArea(
        child: GetBuilder<BrandsController>(
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: () async {
                controller.fetchBrands();
              },
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: CustomListView(
                isLoading: controller.isBrandsFetchingLoading,
                hasError: controller.isBrandsFetchingError,
                items: controller.brands,
                listShimmerLoader: (context, index) => Container(
                  margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).primaryColor.withAlpha((0.15 * 255).toInt()), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withAlpha((0.07 * 255).toInt()),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomShimmerContainer(height: 10.w, width: 10.w, borderRadius: 8, margin: 0),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomShimmerContainer(height: 1.5.h, width: 35.w, borderRadius: 6, margin: 0),
                            SizedBox(height: 1.h),
                            CustomShimmerContainer(height: 1.5.h, width: 18.w, borderRadius: 6, margin: 0),
                          ],
                        ),
                      ),
                      SizedBox(width: 5.w),
                      CustomShimmerContainer(height: 5.5.w, width: 5.5.w, borderRadius: 8, margin: 0),
                    ],
                  ),
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => BrandProductsScreen(brand: controller.brands[index]));
                    },
                    onLongPress: () {
                      _showBrandOptionsDialog(context, controller.brands[index].id!, index);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).cardColor,
                        border: Border.all(color: Theme.of(context).primaryColor.withAlpha((0.15 * 255).toInt()), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withAlpha((0.07 * 255).toInt()),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.5.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withAlpha((0.09 * 255).toInt()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Iconsax.tag, size: 6.w, color: Theme.of(context).primaryColor),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: controller.brands[index].name,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 4.5,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 0.5.h),
                                CustomText(text: 'عرض المنتجات', fontSize: 3.5, color: Theme.of(context).colorScheme.secondary),
                              ],
                            ),
                          ),
                          Icon(Iconsax.arrow_left_2, color: Theme.of(context).primaryColor, size: 5.5.w),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _brandController.clear();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Form(
                    key: _key,
                    child: Container(
                      width: 100.w,
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(text: "اضافة علامة تجارية", fontSize: 6, fontWeight: FontWeight.w700),
                          SizedBox(height: 1.h),
                          CustomField(
                            controller: _brandController,
                            labelText: "اسم العلامة",
                            validator: _validateNotEmpty,
                            textInputAction: TextInputAction.done,
                          ),
                          SizedBox(height: 2.h),
                          GetBuilder<BrandsController>(
                            builder: (controller) {
                              return CustomButton(
                                onTap: () {
                                  if (_key.currentState!.validate()) {
                                    controller.addBrand(brandName: _brandController.text.trim());
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                                title: "اضافة",
                                loading: controller.isAddBrandLoading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        elevation: 0,
        child: Center(
          child: Icon(Iconsax.add, size: 6.w, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  void _showBrandOptionsDialog(BuildContext context, String brandID, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.tag,
                    size: 8.w,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: "خيارات العلامة التجارية",
                  fontSize: 5.5,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _editBrand(context, brandID, index);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withAlpha(51),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Iconsax.edit,
                                size: 6.w,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(height: 1.h),
                              CustomText(
                                text: "تعديل",
                                fontSize: 4,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _deleteBrand(context, brandID, index);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error.withAlpha(51),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Iconsax.trash,
                                size: 6.w,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              SizedBox(height: 1.h),
                              CustomText(
                                text: "حذف",
                                fontSize: 4,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: CustomText(
                      text: "إلغاء",
                      fontSize: 4,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editBrand(BuildContext context, String brandID, int index) {
    final TextEditingController editBrandController = TextEditingController();
    final editBrandFormKey = GlobalKey<FormState>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Form(
                key: editBrandFormKey,
                child: Container(
                  width: 100.w,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(text: "تعديل علامة تجارية", fontSize: 6, fontWeight: FontWeight.w700),
                      SizedBox(height: 1.h),
                      CustomField(
                        controller: editBrandController,
                        labelText: "اسم العلامة",
                        validator: _validateNotEmpty,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 2.h),
                      GetBuilder<BrandsController>(
                        builder: (controller) {
                          return CustomButton(
                            onTap: () {
                              if (editBrandFormKey.currentState!.validate()) {
                                controller.editBrand(brandId: brandID, newName: editBrandController.text.trim(), brandIndex: index);
                                FocusScope.of(context).unfocus();
                              }
                            },
                            title: "تعديل",
                            loading: controller.isEditBrandLoading,
                          );
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
    );
  }

  void _deleteBrand(BuildContext context, String brandID, int index) {
    showConfirmationDialog(
      buildContext: context,
      content: 'هل أنت متأكد من حذف العلامة التجارية؟',
      confirm: () async {
        await controller.deleteBrand(brandID: brandID, brandIndex: index);
      },
      reject: () {},
    );
  }
}
