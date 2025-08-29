import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:hasan2/controllers/search_controller.dart';
import 'package:hasan2/models/product_model.dart';
import 'package:hasan2/models/transaction_model.dart';
import 'package:hasan2/controllers/statistics_controller.dart';
import 'package:hasan2/utils/helpers/firebase_consumer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../utils/error.dart';
import 'package:hasan2/utils/supabase_config.dart';

class ProductsController extends GetxController {
  final FirebaseConsumer _firebaseConsumer = FirebaseConsumer();
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  // Create a service role client for storage operations
  late final SupabaseClient _serviceClient;
  
  final String _bucketName = SupabaseConfig.storageBucketName;
  
  ProductsController() {
    // Initialize service role client
    _serviceClient = SupabaseClient(
      SupabaseConfig.supabaseUrl,
      SupabaseConfig.supabaseServiceRoleKey,
    );
  }

  bool hasMoreProducts = true;

  @override
  void onInit() async {
    super.onInit();
    await fetchProducts();
  }

  // Products
  List<ProductModel> products = [];
  List<ProductModel> brandProducts = [];
  bool isLoadingMoreBrandProducts = false;
  bool hasMoreBrandProducts = true;
  bool isBrandProductsLoading = false;
  bool isBrandProductsError = false;
  bool isProductsFetchingError = false;
  bool isProductsFetchingLoading = false;
  bool isAddProductLoading = false;
  bool isEditProductLoading = false;
  bool isDeleteProductLoading = false;
  bool isLoadingMoreProducts = false;

  /// Upload image to Supabase storage and return the public URL
  Future<String?> uploadImageToSupabase({required dynamic imageFile, required String fileName}) async {
    try {
      log("=== Uploading image to Supabase - File type: ${imageFile.runtimeType}");
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(fileName);
      final uniqueFileName = 'products/${timestamp}_$fileName';

      String uploadPath;

      if (imageFile is File) {
        log("=== Uploading File object");
        uploadPath = await _serviceClient.storage.from(_bucketName).upload(uniqueFileName, imageFile);
      } else if (imageFile is XFile) {
        log("=== Uploading XFile object - path: ${imageFile.path}");
        // Convert XFile to File for upload
        final file = File(imageFile.path);
        if (!await file.exists()) {
          throw Exception('Image file does not exist at path: ${imageFile.path}');
        }
        uploadPath = await _serviceClient.storage.from(_bucketName).upload(uniqueFileName, file);
      } else if (imageFile is Uint8List) {
        log("=== Uploading Uint8List object");
        uploadPath = await _serviceClient.storage.from(_bucketName).uploadBinary(uniqueFileName, imageFile);
      } else if (imageFile is String) {
        log("=== Uploading String object (base64)");
        final bytes = Uri.dataFromString(imageFile).data?.contentAsBytes();
        if (bytes != null) {
          uploadPath = await _serviceClient.storage.from(_bucketName).uploadBinary(uniqueFileName, bytes);
        } else {
          throw Exception('Invalid base64 image data');
        }
      } else {
        throw Exception('Unsupported image file type: ${imageFile.runtimeType}');
      }

      final publicUrl = _serviceClient.storage.from(_bucketName).getPublicUrl(uniqueFileName);
      log("=== Image uploaded successfully: $publicUrl");
      return publicUrl;
    } catch (e) {
      log("=== Error uploading image to Supabase: $e");
      return null;
    }
  }

  /// Update existing image in Supabase storage
  Future<String?> updateImageInSupabase({required dynamic imageFile, required String fileName, required String existingImageUrl}) async {
    try {
      // First, try to delete the existing image
      await _deleteImageFromSupabase(existingImageUrl);

      // Then upload the new image
      return await uploadImageToSupabase(imageFile: imageFile, fileName: fileName);
    } catch (e) {
      log("=== Error updating image in Supabase: $e");
      return null;
    }
  }

  /// Delete image from Supabase storage
  Future<void> _deleteImageFromSupabase(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3) {
        final filePath = pathSegments.sublist(2).join('/');
        await _serviceClient.storage.from(_bucketName).remove([filePath]);
      }
    } catch (e) {
      log("=== Error deleting image from Supabase: $e");
    }
  }

  Future<void> addProduct({
    required String name,
    required String brandId,
    required bool isWeight,
    required double quantity,
    required double price,
    required double cost,
    required double massSalePrice,
    required dynamic imageFile,
    required String imageFileName,
    String? description,
    String? note,
  }) async {
    try {
      isAddProductLoading = true;
      update();

      final imageUrl = await uploadImageToSupabase(imageFile: imageFile, fileName: imageFileName);

      if (imageUrl == null) {
        showError("حدث خطأ أثناء رفع الصورة");
        return;
      }

      final now = DateTime.now();
      final newProduct = ProductModel(
        name: name,
        brandId: brandId,
        isWeight: isWeight,
        quantity: quantity,
        massSalePrice: massSalePrice,
        price: price,
        cost: cost,
        image: imageUrl,
        createdAt: now,
        sold: 0,
        description: description,
        note: note,
      );

      final result = await _firebaseConsumer.addDocument(collectionPath: "products", data: newProduct.toJson());

      if (result.isSuccess && result.data != null) {
        final docID = result.data!;
        await _firebaseConsumer.updateDocument(path: "products/$docID", data: {"product_id": docID});

        newProduct.id = docID;

        products.add(newProduct);
        showSnackBar("تم اضافة منتج جديد");
        Get.back();
      } else {
        log("=== Error while adding product: ${result.error!}");
        showError("حدث خطأ أثناء إضافة المنتج");
      }
    } catch (e) {
      log("=== Exception while adding product: $e");
      showError("حدث خطأ غير متوقع أثناء إضافة المنتج");
    } finally {
      isAddProductLoading = false;
      update();
    }
  }

  Future<void> fetchProducts({bool getNextPage = false, bool resetPagination = false}) async {
    if (getNextPage && !_firebaseConsumer.hasMoreData("products")) return;

    if (!getNextPage || resetPagination) {
      isProductsFetchingLoading = true;
    }

    isProductsFetchingError = false;
    update();

    try {
      final result = await _firebaseConsumer.getCollection(
        path: "products",
        queryBuilder: (query) => query.where("deleted_at", isNull: true),
        limit: 20,
        getNextPage: getNextPage,
        resetPagination: resetPagination,
      );

      if (result.isSuccess && result.data != null) {
        final fetchedProducts = result.data!.map((data) => ProductModel.fromJson(data)).toList();

        if (getNextPage && !resetPagination) {
          products.addAll(fetchedProducts);
        } else {
          products = fetchedProducts;
        }

        isProductsFetchingError = false;
      } else {
        if (!getNextPage) {
          products.clear();
        }
        log("=== Error fetching products: ${result.error}");
        showError("حدث خطأ أثناء تحميل المنتجات");
        isProductsFetchingError = true;
      }
    } catch (e) {
      log("=== Exception while fetching products: $e");
      if (!getNextPage) {
        products.clear();
      }
      showError("حدث خطأ غير متوقع أثناء تحميل المنتجات");
      isProductsFetchingError = true;
    } finally {
      isProductsFetchingLoading = false;
      update();
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMoreProducts || !_firebaseConsumer.hasMoreData("products")) return;

    isLoadingMoreProducts = true;
    update();

    try {
      await fetchProducts(getNextPage: true);
    } finally {
      isLoadingMoreProducts = false;
      update();
    }
  }

  Future<void> editProduct({
    required String productId,
    required String newName,
    required String newBrandId,
    required bool newIsWeight,
    required double newQuantity,
    required double newSold,
    required double newPrice,
    required double massSalePrice,
    required double newCost,
    dynamic newImageFile,
    String? newImageFileName,
    required int productIndex,
    String? newDescription,
    String? newNote,
  }) async {
    try {
      isEditProductLoading = true;
      update();

      String imageUrl = products[productIndex].image;

      if (newImageFile != null && newImageFileName != null) {
        final uploadedImageUrl = await updateImageInSupabase(
          imageFile: newImageFile,
          fileName: newImageFileName,
          existingImageUrl: products[productIndex].image,
        );

        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        } else {
          showError("حدث خطأ أثناء تحديث الصورة");
          return;
        }
      }

      final now = DateTime.now();
      final updateData = {
        "name": newName,
        "brand_id": newBrandId,
        "is_weight": newIsWeight,
        "quantity": newQuantity,
        "sold": newSold,
        "price": newPrice,
        "mass_sale_price": massSalePrice,
        "cost": newCost,
        "image": imageUrl,
        "updated_at": now.millisecondsSinceEpoch,
        "description": newDescription,
        "note": newNote,
      };

      final updateResult = await _firebaseConsumer.updateDocument(path: "products/$productId", data: updateData);

      if (updateResult.isSuccess) {
        final product = products[productIndex];
        product.name = newName;
        product.brandId = newBrandId;
        product.isWeight = newIsWeight;
        product.quantity = newQuantity;
        product.sold = newSold;
        product.price = newPrice;
        product.cost = newCost;
        product.image = imageUrl;
        product.updatedAt = now;
        product.description = newDescription;
        product.note = newNote;

        showSnackBar("تم تعديل المنتج بنجاح");
        Get.back();
      } else {
        showError("حدث خطأ أثناء تعديل المنتج");
      }
    } catch (e) {
      log("=== Exception while editing product: $e");
      showError("حدث خطأ غير متوقع أثناء تعديل المنتج");
    } finally {
      isEditProductLoading = false;
      update();
    }
  }

  // /// Optional: Delete image from Supabase storage
  // Future<void> _deleteImageFromSupabase(String imageUrl) async {
  //   try {
  //     final uri = Uri.parse(imageUrl);
  //     final pathSegments = uri.pathSegments;
  //     if (pathSegments.length >= 3) {
  //       final filePath = pathSegments.sublist(2).join('/');
  //       await _supabaseClient.storage.from(_bucketName).remove([filePath]);
  //     }
  //   } catch (e) {
  //     log("=== Error deleting image from Supabase: $e");
  //   }
  // }

  Future<void> deleteProduct({required String productId, required int productIndex}) async {
    try {
      isDeleteProductLoading = true;
      update();

      final result = await _firebaseConsumer.updateDocument(
        path: "products/$productId",
        data: {"deleted_at": DateTime.now().millisecondsSinceEpoch.toString()},
      );

      if (result.isSuccess) {
        products.removeAt(productIndex);
        showSnackBar("تم حذف المنتج بنجاح");
        Get.back();
      } else {
        showError("حدث خطأ أثناء حذف المنتج");
      }
    } catch (e) {
      log("=== Exception while deleting product: $e");
      showError("حدث خطأ غير متوقع أثناء حذف المنتج");
    } finally {
      isDeleteProductLoading = false;
      update();
    }
  }

  List<ProductModel> getFilteredProductsByIndex(int index) {
    List<ProductModel> filtered;

    switch (index) {
      case 1:
        filtered = List<ProductModel>.from(products)..sort((a, b) => b.sold.compareTo(a.sold));
        break;
      case 2:
        filtered = List<ProductModel>.from(products)..sort((a, b) => a.sold.compareTo(b.sold));
        break;
      case 3:
        filtered = products.where((p) => p.quantity > 0 && p.quantity <= 10).toList();
        break;
      case 4:
        filtered = products.where((p) => p.quantity <= 0).toList();
        break;
      case 0:
      default:
        filtered = products;
        break;
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<void> fetchBrandProducts({required String brandId, bool getNextPage = false, bool resetPagination = false}) async {
    final trackingKey = "products_brand_$brandId";

    if (getNextPage && !_firebaseConsumer.hasMoreData(trackingKey)) return;

    if (!getNextPage || resetPagination) {
      isBrandProductsLoading = true;
    }

    isBrandProductsError = false;
    update();

    try {
      final result = await _firebaseConsumer.getCollection(
        path: "products",
        queryBuilder: (query) => query.where("deleted_at", isNull: true).where("brand_id", isEqualTo: brandId),
        limit: 20,
        getNextPage: getNextPage,
        resetPagination: resetPagination,
        trackingKey: trackingKey,
      );

      if (result.isSuccess && result.data != null) {
        final fetchedProducts = result.data!.map((data) => ProductModel.fromJson(data)).toList();

        if (getNextPage && !resetPagination) {
          brandProducts.addAll(fetchedProducts);
        } else {
          brandProducts = fetchedProducts;
        }

        brandProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        isBrandProductsError = false;
      } else {
        if (!getNextPage) {
          brandProducts.clear();
        }
        log("=== Error fetching brand products: ${result.error}");
        showError("حدث خطأ أثناء تحميل منتجات الماركة");
        isBrandProductsError = true;
      }
    } catch (e) {
      log("=== Exception while fetching brand products: $e");
      if (!getNextPage) {
        brandProducts.clear();
      }
      showError("حدث خطأ غير متوقع أثناء تحميل منتجات الماركة");
      isBrandProductsError = true;
    } finally {
      isBrandProductsLoading = false;
      update();
    }
  }

  Future<void> loadMoreBrandProducts(String brandId) async {
    final trackingKey = "products_brand_$brandId";

    if (isLoadingMoreBrandProducts || !_firebaseConsumer.hasMoreData(trackingKey)) return;

    isLoadingMoreBrandProducts = true;
    update();

    try {
      await fetchBrandProducts(brandId: brandId, getNextPage: true);
    } finally {
      isLoadingMoreBrandProducts = false;
      update();
    }
  }

  Future<String?> getBrandNameByID(String brandId) async {
    try {
      final result = await _firebaseConsumer.getDocument(
        collectionPath: "brands",
        queryBuilder: (query) => query.where("brand_id", isEqualTo: brandId).where("deleted_at", isNull: true),
      );

      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        final name = data['brand_name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          return name;
        } else {
          log("=== Brand name not found or empty for ID: $brandId");
          return "";
        }
      } else {
        log("=== Failed to fetch brand name: ${result.error}");
        showError("حدث خطأ أثناء تحميل اسم الماركة");
        return null;
      }
    } catch (e) {
      log("=== Exception while fetching brand name: $e");
      showError("حدث خطأ غير متوقع أثناء تحميل اسم الماركة");
      return null;
    }
  }

  Future<void> sellProduct({required ProductModel product, required double soldQuantity}) async {
    try {
      isEditProductLoading = true;
      update();

      final newQuantity = product.quantity - soldQuantity;
      final newSold = product.sold + soldQuantity;
      final saleAmount = product.price * soldQuantity;
      final profitMargin = product.price - product.cost;
      final now = DateTime.now();

      final updateData = {
        "quantity": newQuantity,
        "sold": newSold,
        "updated_at": now.millisecondsSinceEpoch,
      };

      final updateResult = await _firebaseConsumer.updateDocument(path: "products/${product.id}", data: updateData);

      if (updateResult.isSuccess) {
        final productIndex = products.indexWhere((p) => p.id == product.id);
        if (productIndex != -1) {
          products[productIndex].quantity = newQuantity;
          products[productIndex].sold = newSold;
          products[productIndex].updatedAt = now;
        }

        // Create transaction record for statistics
        final transaction = TransactionModel(
          productId: product.id!,
          productName: product.name,
          brandId: product.brandId,
          saleAmount: saleAmount,
          profitMargin: profitMargin,
          soldQuantity: soldQuantity,
          unitPrice: product.price,
          unitCost: product.cost,
          timestamp: now,
          createdAt: now,
        );

        // Add transaction to statistics (fire and forget - don't block UI)
        final statisticsController = Get.find<StatisticsController>();
        statisticsController.addTransaction(transaction).catchError((error) {
          log("=== Error adding transaction to statistics: $error");
        });

        final searchController = Get.find<SearchController>();
        final index = searchController.searchResults.indexWhere((item) => item.id == product.id);
        searchController.searchResults[index].quantity -= soldQuantity;
        searchController.searchResults[index].sold += soldQuantity;
        searchController.update();

        showSnackBar("تم بيع المنتج بنجاح");
        Get.back();
      } else {
        showError("حدث خطأ أثناء بيع المنتج");
      }
    } catch (e) {
      log("=== Exception while selling product: $e");
      showError("حدث خطأ غير متوقع أثناء بيع المنتج");
    } finally {
      isEditProductLoading = false;
      update();
    }
  }
}
