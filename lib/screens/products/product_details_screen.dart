import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:hasan2/models/product_model.dart';
import 'package:hasan2/utils/dialog.dart';
import 'package:hasan2/utils/error.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/products_controller.dart';
import '../../utils/brand_selection.dart';
import '../../utils/helpers/image_picker.dart';
import '../../utils/unit_selection.dart';
import '../../utils/widgets/button.dart';
import '../../utils/widgets/local_image.dart';
import '../../utils/widgets/network_image.dart';
import '../../utils/widgets/text_form_field.dart';
import '../../utils/widgets/text_widget.dart';
import '../../utils/helpers/price_formatter.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductsController controller = Get.find<ProductsController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _soldController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _massSalePrice = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String brandID = "";
  final _key = GlobalKey<FormState>();
  XFile? image;
  String imageErrorMessage = "";
  String? networkImageLink;
  String? brandName = "";
  double originalQuantity = 0.0;
  double originalSold = 0.0;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController.text = product.name;
    brandID = product.brandId;
    _unitController.text = product.isWeight ? "وزن" : "عدد";
    _quantityController.text = product.quantity.toInt().toString();
    _soldController.text = product.sold.toInt().toString();
    _priceController.text = formatPrice(product.price);
    _costController.text = formatPrice(product.cost);
    _massSalePrice.text = formatPrice(product.massSalePrice);
    networkImageLink = product.image;
    originalQuantity = product.quantity;
    originalSold = product.sold;
    _descriptionController.text = product.description ?? '';
    _noteController.text = product.note ?? '';
    _getBrandName();
  }

  Future<void> _getBrandName() async {
    brandName = await controller.getBrandNameByID(widget.product.brandId);
    setState(() {
      _brandNameController.text = brandName ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "تعديل المنتج", isBackButtonVisible: true),
      floatingActionButton: widget.product.quantity > 0
          ? FloatingActionButton.extended(
              onPressed: () => _showSellBottomSheet(context, widget.product),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icon(Iconsax.shopping_cart, size: 6.w),
              label: CustomText(
                text: "بيع المنتج",
                fontSize: 4,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Form(
            key: _key,
            child: ListView(
              children: [
                SizedBox(height: 2.h),
                GestureDetector(
                  onTap: () async {
                    final pickedImage = await ImagePickerHelper().pickAndProcessImage(context);
                    if (pickedImage != null) {
                      setState(() {
                        image = pickedImage;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
                    ),
                    height: 30.h,
                    width: 100.w,
                    child: image != null
                        ? LocalImage(img: image!.path, isFileImage: true, fit: BoxFit.cover, borderRadius: 10)
                        : networkImageLink != null
                        ? CustomNetworkImage(url: networkImageLink!, fit: BoxFit.cover, radius: 10)
                        : Center(
                            child: Icon(Iconsax.camera, size: 10.w, color: Theme.of(context).primaryColor),
                          ),
                  ),
                ),
                if (imageErrorMessage.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  CustomText(text: imageErrorMessage, color: Theme.of(context).colorScheme.error, textAlign: TextAlign.start),
                ],
                SizedBox(height: 2.h),
                CustomField(
                  controller: _nameController,
                  labelText: "اسم المنتج",
                  textInputAction: TextInputAction.next,
                  validator: _validateNotEmpty,
                ),
                SizedBox(height: 2.h),
                CustomField(
                  controller: _brandNameController,
                  labelText: "اسم العلامة التجارية",
                  readOnly: true,
                  hintText: brandName == null
                      ? "حدث خطأ اثناء جلب اسم العلامة"
                      : brandName!.isEmpty
                      ? ""
                      : null,
                  onTap: brandName == null
                      ? () {}
                      : () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => SelectBrandBottomSheet(
                              onBrandSelected: (String id, String name) {
                                setState(() {
                                  _brandNameController.text = name;
                                  brandID = id;
                                });
                              },
                            ),
                          );
                        },
                ),
                SizedBox(height: 2.h),
                CustomField(
                  controller: _unitController,
                  labelText: "الوحدة",
                  readOnly: true,
                  validator: _validateNotEmpty,
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => UnitSelectionBottomSheetCustom(
                        initialSelection: _unitController.text.trim(),
                        onUnitSelected: (selectedUnit) {
                          setState(() {
                            _unitController.text = selectedUnit;
                          });
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 2.h),
                CustomField(
                  controller: _quantityController,
                  labelText: _unitController.text.isEmpty ? "الكمية" : "الكمية بال${_unitController.text}",
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'هذا الحقل مطلوب';
                    }
                    final quantity = double.tryParse(value) ?? 0;
                    if (quantity < 0) {
                      return 'الكمية لا يمكن أن تكون سالبة';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomField(
                  controller: _soldController,
                  labelText: _unitController.text.isEmpty ? "المباع" : "المباع بال${_unitController.text}",
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'هذا الحقل مطلوب';
                    }
                    final sold = double.tryParse(value) ?? 0;
                    if (sold < 0) {
                      return 'المباع لا يمكن أن يكون سالب';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                CustomField(
                  controller: _priceController,
                  labelText: "السعر بالدينار العراقي",
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _validateNumber,
                ),
                SizedBox(height: 2.h),
                CustomField(
                  controller: _massSalePrice,
                  labelText: "سعر الجملة بالدينار العراقي",
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _validateNumber,
                ),
                SizedBox(height: 2.h),
                CustomField(
                  controller: _costController,
                  labelText: "التكلفة بالدينار العراقي",
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: _validateNumber,
                ),
                SizedBox(height: 2.h),
                CustomField(controller: _descriptionController, labelText: "الوصف", textInputAction: TextInputAction.next, maxLines: 3),
                SizedBox(height: 2.h),
                CustomField(controller: _noteController, labelText: "ملاحظات", textInputAction: TextInputAction.done, maxLines: 3),
                SizedBox(height: 3.h),
                GetBuilder<ProductsController>(
                  builder: (controller) {
                    return Column(
                      children: [
                        CustomButton(
                          onTap: () {
                            if (_key.currentState!.validate()) {
                              final newQuantity = double.tryParse(_quantityController.text.trim()) ?? 0;
                              final newSold = double.tryParse(_soldController.text.trim()) ?? 0;

                              // Find the product index
                              final productIndex = controller.products.indexWhere((p) => p.id == widget.product.id);
                              if (productIndex == -1) {
                                showError("لم يتم العثور على المنتج");
                                return;
                              }

                              controller.editProduct(
                                productId: widget.product.id!,
                                newName: _nameController.text.trim(),
                                newBrandId: brandID,
                                newIsWeight: _unitController.text.trim() == 'وزن',
                                newQuantity: newQuantity,
                                massSalePrice: double.tryParse(_massSalePrice.text.trim().replaceAll(",", "")) ?? 0,
                                newSold: newSold,
                                newPrice: double.tryParse(_priceController.text.trim().replaceAll(",", "")) ?? 0,
                                newCost: double.tryParse(_costController.text.trim().replaceAll(",", "")) ?? 0,
                                newImageFile: image,
                                newImageFileName: image != null ? DateTime.now().millisecondsSinceEpoch.toString() : null,
                                productIndex: productIndex,
                                newDescription: _descriptionController.text.trim(),
                                newNote: _noteController.text.trim(),
                              );
                            }
                          },
                          title: "تعديل",
                          loading: controller.isEditProductLoading,
                        ),
                        SizedBox(height: 1.h),
                        CustomButton(
                          onTap: () {
                            showConfirmationDialog(
                              buildContext: context,
                              content: "هل أنت متأكد من حذف المنتج؟ لا يمكن التراجع عن هذا الاجراء",
                              confirm: () async {
                                _deleteProduct(controller);
                              },
                              reject: () {},
                            );
                          },
                          title: "حذف المنتج",
                          loading: controller.isDeleteProductLoading,
                          color: Colors.red,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (double.tryParse(value.replaceAll(",", "")) == null) {
      return 'الرجاء إدخال رقم صحيح';
    }
    return null;
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  void _deleteProduct(ProductsController controller) {
    final productIndex = controller.products.indexWhere((p) => p.id == widget.product.id);
    if (productIndex == -1) {
      showError("لم يتم العثور على المنتج");
      return;
    }

    controller.deleteProduct(productId: widget.product.id!, productIndex: productIndex);
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
