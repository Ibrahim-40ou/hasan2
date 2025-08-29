import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:hasan2/utils/helpers/permissions.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/theme/colors.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  final PermissionHandlerService _permissionService = PermissionHandlerService();

  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();

  Future<XFile?> pickAndProcessImage(BuildContext context) async {
    try {
      final source = await _showImageSourceSheet(context);
      if (source == null) return null;

      final XFile? pickedFile = await _pickImage(source);
      if (pickedFile == null) return null;

      final File? croppedFile = await _cropImage(File(pickedFile.path));

      if (croppedFile == null) return null;

      final XFile? compressedFile = await _compressImage(croppedFile);
      return compressedFile;
    } catch (e) {
      debugPrint('Image processing error: $e');
      return null;
    }
  }

  Future<ImageSource?> _showImageSourceSheet(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return Container(
          width: 100.w,
          padding: EdgeInsets.only(right: 5.w, left: 5.w, top: 3.h, bottom: 3.h),
          decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: "اختر صورة", fontSize: 6, fontWeight: FontWeight.w600),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onTap: () {
                        _permissionService.requestPermission(
                          permission: AppPermission.camera,
                          onGranted: () {
                            Get.back(result: ImageSource.camera);
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.camera, color: Colors.white),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                            child: CustomText(text: "الكاميرا", height: 1, color: Colors.white, fontSize: 5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 1.h),

                  Expanded(
                    child: CustomButton(
                      color: Colors.transparent,
                      borderColor: Theme.of(context).primaryColor,
                      onTap: () {
                        Platform.isIOS
                            ? _permissionService.requestPermission(
                                permission: AppPermission.photos,
                                onGranted: () {
                                  Get.back(result: ImageSource.gallery);
                                },
                              )
                            : Get.back(result: ImageSource.gallery);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.gallery, color: Theme.of(context).primaryColor),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                            child: CustomText(
                              text: "المعرض",
                              height: 1,
                              color: Theme.of(context).primaryColor,
                              fontSize: 5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
            ],
          ),
        );
      },
    );
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      return pickedFile;
    } catch (e) {
      log('error picking image: $e');
      return null;
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final CroppedFile? croppedFile = await _cropper.cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      aspectRatio: const CropAspectRatio(ratioX: 1080, ratioY: 1080),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "قص الصورة",
          toolbarColor: AppColors.primaryLight,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: "قص الصورة", doneButtonTitle: "انتهاء", cancelButtonTitle: "الغاء"),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<XFile?> _compressImage(File imageFile) async {
    try {
      log('step3.8');

      // Create a proper output path in the same directory
      final directory = imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/compressed_$timestamp.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        outputPath,
        quality: 88,
        rotate: 0,
        minWidth: 512,
        minHeight: 512,
      );

      log('step3.9');

      if (result == null) {
        log('Compression failed - result is null');
        return null;
      }

      log('Compression successful: ${result.path}');
      return XFile(result.path);
    } catch (e) {
      log('Compression error: $e');
      return null;
    }
  }
}
