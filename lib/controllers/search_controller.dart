import 'dart:developer';

import 'package:get/get.dart';
import 'package:hasan2/models/product_model.dart';
import 'package:hasan2/utils/error.dart';
import 'package:hasan2/utils/helpers/firebase_consumer.dart';

enum SortOption { newest, oldest, nameAsc, nameDesc, priceAsc, priceDesc, soldAsc, soldDesc, quantityAsc, quantityDesc }

class SearchController extends GetxController {
  final FirebaseConsumer _firebaseConsumer = FirebaseConsumer();

  List<ProductModel> searchResults = [];
  bool isSearchLoading = false;
  bool isSearchError = false;
  bool isLoadingMoreResults = false;
  bool hasMoreResults = true;

  String searchQuery = '';
  SortOption currentSortOption = SortOption.newest;

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      hasMoreResults = true;
      update();
      return;
    }

    searchQuery = query.trim();
    isSearchLoading = true;
    isSearchError = false;
    hasMoreResults = true;
    update();

    try {
      final result = await _firebaseConsumer.getCollection(
        path: "products",
        queryBuilder: (query) => query.where("deleted_at", isNull: true),
        limit: 20,
        resetPagination: true,
      );

      if (result.isSuccess && result.data != null) {
        final allProducts = result.data!.map((data) => ProductModel.fromJson(data)).toList();

        searchResults = allProducts.where((product) {
          return product.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        _applySorting();
        isSearchError = false;
      } else {
        searchResults.clear();
        log("=== Error fetching products for search: ${result.error}");
        showError("حدث خطأ أثناء تحميل المنتجات");
        isSearchError = true;
      }
    } catch (e) {
      log("=== Exception while fetching products for search: $e");
      searchResults.clear();
      showError("حدث خطأ غير متوقع أثناء تحميل المنتجات");
      isSearchError = true;
    } finally {
      isSearchLoading = false;
      update();
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMoreResults || !hasMoreResults || searchQuery.isEmpty) return;

    isLoadingMoreResults = true;
    update();

    try {
      final result = await _firebaseConsumer.getCollection(
        path: "products",
        queryBuilder: (query) => query.where("deleted_at", isNull: true),
        limit: 20,
        getNextPage: true,
      );

      if (result.isSuccess && result.data != null) {
        final allProducts = result.data!.map((data) => ProductModel.fromJson(data)).toList();

        final filteredProducts = allProducts.where((product) {
          return product.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        searchResults.addAll(filteredProducts);

        _applySorting();

        hasMoreResults = _firebaseConsumer.hasMoreData("products");
      } else {
        log("=== Error loading more products for search: ${result.error}");
        showError("حدث خطأ أثناء تحميل المزيد من المنتجات");
        hasMoreResults = false;
      }
    } catch (e) {
      log("=== Exception while loading more products for search: $e");
      showError("حدث خطأ غير متوقع أثناء تحميل المزيد من المنتجات");
      hasMoreResults = false;
    } finally {
      isLoadingMoreResults = false;
      update();
    }
  }

  void setSortOption(SortOption sortOption) {
    currentSortOption = sortOption;
    if (searchResults.isNotEmpty) {
      _applySorting();
      update();
    }
  }

  void _applySorting() {
    switch (currentSortOption) {
      case SortOption.newest:
        searchResults.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        searchResults.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.nameAsc:
        searchResults.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        searchResults.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.priceAsc:
        searchResults.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        searchResults.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.soldAsc:
        searchResults.sort((a, b) => a.sold.compareTo(b.sold));
        break;
      case SortOption.soldDesc:
        searchResults.sort((a, b) => b.sold.compareTo(a.sold));
        break;
      case SortOption.quantityAsc:
        searchResults.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case SortOption.quantityDesc:
        searchResults.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
    }
  }

  void clearSearch() {
    searchQuery = '';
    searchResults.clear();
    update();
  }

  String getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return "الأحدث";
      case SortOption.oldest:
        return "الأقدم";
      case SortOption.nameAsc:
        return "الاسم (أ-ي)";
      case SortOption.nameDesc:
        return "الاسم (ي-أ)";
      case SortOption.priceAsc:
        return "السعر (منخفض-عالي)";
      case SortOption.priceDesc:
        return "السعر (عالي-منخفض)";
      case SortOption.soldAsc:
        return "المبيعات (منخفض-عالي)";
      case SortOption.soldDesc:
        return "المبيعات (عالي-منخفض)";
      case SortOption.quantityAsc:
        return "الكمية (منخفض-عالي)";
      case SortOption.quantityDesc:
        return "الكمية (عالي-منخفض)";
    }
  }

  List<SortOption> getSortOptions() {
    return SortOption.values;
  }
}
