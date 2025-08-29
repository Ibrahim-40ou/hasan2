import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:hasan2/models/product_model.dart';
import 'package:hasan2/models/brand_model.dart';
import 'package:hasan2/screens/products/product_details_screen.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/network_image.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:hasan2/utils/helpers/price_formatter.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/products_controller.dart';
import '../../controllers/brands_controller.dart';
import 'button.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isFromSellButton;

  const ProductCard({super.key, required this.product, this.isFromSellButton = false});

  String? _getBrandName() {
    try {
      final BrandsController brandsController = Get.find<BrandsController>();
      final brand = brandsController.brands.firstWhere(
        (brand) => brand.id == product.brandId,
        orElse: () => BrandModel(name: '', id: ''),
      );
      return brand.name.isNotEmpty ? brand.name : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isFromSellButton) {
          _showSellBottomSheet(context, product);
        } else {
          Get.to(() => ProductDetailsScreen(product: product));
        }
      },
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20.h,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomNetworkImage(url: product.image, radius: 0, height: 20.h, width: 100.w, fit: BoxFit.cover),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(2.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: product.name, fontSize: 5, fontWeight: FontWeight.w700, maxLines: 2, textAlign: TextAlign.start),

                  if (_getBrandName() != null) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(100), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.tag, size: 3.w, color: Theme.of(context).colorScheme.secondary),
                          SizedBox(width: 1.w),
                          Flexible(
                            child: CustomText(
                              text: _getBrandName()!,
                              fontSize: 3.5,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: _getBrandName() != null ? 1.h : 2.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              flex: 5,
                              child: CustomText(
                                text: formatPrice(product.price),
                                fontSize: 6.8,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Flexible(
                              flex: 1,
                              child: CustomText(text: "د.ع", fontSize: 4, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),

                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(10)),
                          child: CustomText(
                            text: product.isWeight ? "وزن" : "عدد",
                            fontSize: 3.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: product.quantity > 10
                                ? Theme.of(context).primaryColor.withAlpha(26)
                                : product.quantity > 0
                                ? Colors.orange.withAlpha(26)
                                : Colors.red.withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: product.quantity > 10
                                  ? Theme.of(context).primaryColor.withAlpha(77)
                                  : product.quantity > 0
                                  ? Colors.orange.withAlpha(77)
                                  : Colors.red.withAlpha(77),
                            ),
                          ),
                          child: Column(
                            children: [
                              CustomText(
                                text: product.quantity.toInt().toString(),
                                fontSize: 4.8,
                                fontWeight: FontWeight.w800,
                                color: product.quantity > 10
                                    ? Theme.of(context).primaryColor
                                    : product.quantity > 0
                                    ? Colors.orange
                                    : Colors.red,
                              ),
                              CustomText(text: "متوفر", fontSize: 3.5, color: Theme.of(context).colorScheme.onSurface.withAlpha(179)),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 2.w),

                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Theme.of(context).colorScheme.tertiary.withAlpha(100)),
                          ),
                          child: Column(
                            children: [
                              CustomText(
                                text: product.sold.toInt().toString(),
                                fontSize: 4.8,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              CustomText(text: "مباع", fontSize: 3.5, color: Theme.of(context).colorScheme.onSurface.withAlpha(179)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Sell Button
                  if (product.quantity > 0)
                    CustomButton(
                      onTap: () => _showSellBottomSheet(context, product),
                      title: "بيع المنتج",
                      loading: false,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSellBottomSheet(BuildContext context, ProductModel product) {
    final TextEditingController quantityController = TextEditingController();
    final ProductsController productsController = Get.find<ProductsController>();
    final key = GlobalKey<FormState>();
    final ValueNotifier<double> totalPriceNotifier = ValueNotifier<double>(0.0);
    final ValueNotifier<double> totalMassPriceNotifier = ValueNotifier<double>(0.0);

    quantityController.addListener(() {
      final quantity = double.tryParse(quantityController.text) ?? 0.0;
      totalPriceNotifier.value = quantity * product.price;
      totalMassPriceNotifier.value = quantity * product.massSalePrice;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Form(
              key: key,
              child: Container(
                width: 100.w,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(text: "بيع المنتج", fontSize: 6, fontWeight: FontWeight.w700),
                    SizedBox(height: 1.h),
                    ValueListenableBuilder<double>(
                      valueListenable: totalPriceNotifier,
                      builder: (context, totalPrice, child) {
                        return Column(
                          children: [
                            CustomText(text: "السعر البيع بالمفرد: ${formatPrice(totalPrice)}", fontSize: 5, fontWeight: FontWeight.w600),
                            SizedBox(height: 0.5.h),
                            ValueListenableBuilder<double>(
                              valueListenable: totalMassPriceNotifier,
                              builder: (context, totalMassPrice, child) {
                                return CustomText(
                                  text: "سعر البيع بالجملة: ${formatPrice(totalMassPrice)}",
                                  fontSize: 5,
                                  fontWeight: FontWeight.w600,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 1.h),
                    CustomField(
                      controller: quantityController,
                      labelText: "الكمية المباعة",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "الرجاء إدخال الكمية";
                        }
                        if (double.tryParse(value) == null) {
                          return "الرجاء إدخال رقم صحيح";
                        }
                        if (double.parse(value) > product.quantity) {
                          return "الكمية المطلوبة أكبر من المتوفرة";
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 2.h),
                    GetBuilder<ProductsController>(
                      builder: (controller) {
                        return CustomButton(
                          onTap: () async {
                            if (key.currentState!.validate()) {
                              final soldQuantity = double.parse(quantityController.text);
                              await productsController.sellProduct(product: product, soldQuantity: soldQuantity);
                            }
                          },
                          title: "بيع",
                          loading: productsController.isEditProductLoading,
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
  }
}
