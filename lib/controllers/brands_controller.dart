import 'dart:developer';

import 'package:get/get.dart';
import 'package:hasan2/models/brand_model.dart';
import 'package:hasan2/utils/helpers/firebase_consumer.dart';

import '../../../utils/error.dart';

class BrandsController extends GetxController {
  final FirebaseConsumer _firebaseConsumer = FirebaseConsumer();

  @override
  void onInit() async {
    super.onInit();
    await fetchBrands();
  }

  List<BrandModel> brands = [];
  bool isBrandsFetchingError = false;
  bool isBrandsFetchingLoading = false;
  bool isAddBrandLoading = false;
  bool isEditBrandLoading = false;
  bool isDeleteBrandLoading = false;

  Future<void> addBrand({required String brandName}) async {
    try {
      isAddBrandLoading = true;
      update();

      final result = await _firebaseConsumer.addDocument(
        collectionPath: "brands",
        data: BrandModel(name: brandName).toJson(),
      );

      if (result.isSuccess && result.data != null) {
        final docID = result.data!;
        await _firebaseConsumer.updateDocument(path: "brands/$docID", data: {"brand_id": docID});
        brands.add(BrandModel(name: brandName, id: docID));
        showSnackBar("تم اضافة علامة تجارية جديدة");
        Get.back();
      } else {
        log("=== Error while adding brand: ${result.error!}");
        showError("حث خطأ اثناء اضافة العلامة التجارية");
      }
    } on Exception catch (e) {
      showError("حث خطأ غير متوقع اثناء اضافة العلامة التجارية");
      log("=== Exception while adding brand: $e");
    } finally {
      isAddBrandLoading = false;
      update();
    }
  }

  Future<void> fetchBrands() async {
    isBrandsFetchingError = false;
    isBrandsFetchingLoading = true;
    update();
    try {
      final result = await _firebaseConsumer.getCollection(path: "brands", queryBuilder: (query) => query.where("deleted_at", isNull: true));

      if (result.isSuccess && result.data != null) {
        brands = result.data!.map((data) => BrandModel.fromJson(data)).toList();
        isBrandsFetchingError = false;
      } else {
        log("=== Error fetching brands: ${result.error}");
        showError("حدث خطأ أثناء تحميل العلامات التجارية");
        isBrandsFetchingError = true;
      }
    } on Exception catch (e) {
      log("=== Exception while fetching brands: $e");
      showError("حدث خطأ غير متوقع اثناء تحميل العلامات التجارية");
      isBrandsFetchingError = true;
    } finally {
      isBrandsFetchingLoading = false;
      update();
    }
  }

  Future<void> editBrand({required String brandId, required String newName, required int brandIndex}) async {
    try {
      isEditBrandLoading = true;
      update();
      DateTime now = DateTime.now();
      final updateResult = await _firebaseConsumer.updateDocument(
        path: "brands/$brandId",
        data: {"brand_name": newName, "edited_at": now.millisecondsSinceEpoch.toString()},
      );

      if (updateResult.isSuccess) {
        brands[brandIndex].name = newName;
        brands[brandIndex].editedAt = now;
        showSnackBar("تم تعديل العلامة التجارية بنجاح");
        Get.back();
      } else {
        showError("حث خطأ اثناء تعديل العلامة التجارية");
      }
    } catch (e) {
      log("=== Exception while editing brand: $e");
      showError("حدث خطأ غير متوقع أثناء تعديل العلامة التجارية");
    } finally {
      isEditBrandLoading = false;
      update();
    }
  }

  Future<void> deleteBrand({required String brandID, required int brandIndex}) async {
    try {
      isDeleteBrandLoading = true;
      update();

      final result = await _firebaseConsumer.updateDocument(
        path: "brands/$brandID",
        data: {"deleted_at": DateTime.now().millisecondsSinceEpoch.toString()},
      );

      if (result.isSuccess) {
        brands.removeAt(brandIndex);
        showSnackBar("تم حذف العلامة التجارية بنجاح");
      } else {
        showError("حث خطأ اثناء حذف العلامة التجارية");
      }
    } catch (e) {
      log("=== Exception while deleting brand: $e");
      showError("حدث خطأ غير متوقع أثناء حذف العلامة التجارية");
    } finally {
      isDeleteBrandLoading = false;
      update();
    }
  }
}
