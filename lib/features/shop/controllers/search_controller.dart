import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/features/shop/controllers/product/product_controller.dart';

class ProductSearchController extends GetxController {
  static ProductSearchController get instance => Get.find();

  final searchController = TextEditingController();
  final ProductController productController = Get.find();

  @override
  void onInit() {
    super.onInit();
    // Get initial query from arguments if passed
    final initialQuery = Get.arguments as String?;
    if (initialQuery != null && initialQuery.isNotEmpty) {
      searchController.text = initialQuery.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        performSearch(initialQuery.trim());
      });
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Perform product search
  void performSearch(String query) {
    if (query.isNotEmpty) {
      productController.searchProducts(query);
    } else {
      productController.clearSearchResults();
    }
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    productController.clearSearchResults();
  }
}

