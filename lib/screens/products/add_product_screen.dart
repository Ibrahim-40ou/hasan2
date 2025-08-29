import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/products_controller.dart';
import 'package:hasan2/utils/brand_selection.dart';
import 'package:hasan2/utils/helpers/image_picker.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/unit_selection.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/local_image.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class AddProductsScreen extends StatefulWidget {
  const AddProductsScreen({super.key});

  @override
  State<AddProductsScreen> createState() => _AddProductsScreenState();
}

class _AddProductsScreenState extends State<AddProductsScreen> {
  final ProductsController controller = Get.find<ProductsController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController(text: "عدد");
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _massSalePrice = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String brandID = "";
  final _key = GlobalKey<FormState>();
  XFile? image;
  String imageErrorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "اضافة منتج", isBackButtonVisible: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Form(
            key: _key,
            child: ListView(
              children: [
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
                  onTap: () {
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
                  validator: _validateNumber,
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
                    height: 20.h,
                    width: 100.w,
                    child: image != null
                        ? LocalImage(img: image!.path, isFileImage: true, fit: BoxFit.cover, borderRadius: 10)
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
                GetBuilder<ProductsController>(
                  builder: (controller) {
                    return CustomButton(
                      onTap: () {
                        if (_key.currentState!.validate() && image != null) {
                          controller.addProduct(
                            name: _nameController.text.trim(),
                            brandId: brandID,
                            isWeight: _unitController.text.trim() == 'وزن',
                            quantity: double.tryParse(_quantityController.text.trim()) ?? 0,
                            price: double.tryParse(_priceController.text.trim()) ?? 0,
                            cost: double.tryParse(_costController.text.trim()) ?? 0,
                            massSalePrice: double.tryParse(_massSalePrice.text.trim()) ?? 0,
                            imageFile: File(image!.path),
                            imageFileName: DateTime.now().millisecondsSinceEpoch.toString(),
                            description: _descriptionController.text.trim(),
                            note: _noteController.text.trim(),
                          );
                        } else {
                          if (image == null) {
                            setState(() {
                              imageErrorMessage = "الرحاء قم بتحميل صورة للمنتج";
                            });
                          }
                        }
                      },
                      title: "اضافة منتج",
                      loading: controller.isAddProductLoading,
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
}
