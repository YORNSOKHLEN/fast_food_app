import 'package:get/get.dart';

import '../../../../data/repositories/product/product_repository.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/product_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final isLoading = false.obs;
  final productRepository = Get.put(ProductRepository());
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxList<ProductModel> randomProducts = <ProductModel>[].obs;
  RxList<ProductModel> allProducts = <ProductModel>[].obs;
  RxList<ProductModel> categoryProducts = <ProductModel>[].obs;
  RxList<ProductModel> brandProducts = <ProductModel>[].obs;
  RxList<ProductModel> searchResults = <ProductModel>[].obs;

  @override
  void onInit() {
    fetchFeaturedProducts();
    loadRandomProducts(limit: 100);
    super.onInit();
  }

  void fetchFeaturedProducts() async {
    try {
      // Show loader while loading Products
      isLoading.value = true;

      // Prefer popular products (based on order count), fallback to featured.
      var products = await productRepository.getPopularProducts(limit: 4);
      if (products.isEmpty) {
        products = await productRepository.getFeaturedProducts();
      }

      // Assign Products
      featuredProducts.assignAll(products);
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      // Stop Loader
      isLoading.value = false;
    }
  }

  Future<List<ProductModel>> fetchAllFeaturedProducts() async {
    try {
      // Prefer popular products (based on order count), fallback to featured.
      var products = await productRepository.getPopularProducts(limit: 20);
      if (products.isEmpty) {
        products = await productRepository.getFeaturedProducts();
      }
      return products;
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  Future<List<ProductModel>> fetchRandomProducts({int limit = 6}) async {
    try {
      final products = await productRepository.getRandomProducts(limit: limit);
      return products;
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  Future<void> loadRandomProducts({int limit = 8}) async {
    try {
      isLoading.value = true;
      final products = await productRepository.getRandomProducts(limit: limit);
      randomProducts.assignAll(products);
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the product price or price range for variations
  String? getProductPrice(ProductModel product) {
    // Show ONLY original price
    if (product.price > 0) {
      return product.price.toStringAsFixed(2);
    }

    // No valid price
    return null;
  }

  /// -- Calculate Discount Percentage
  String? calculateSalePercentage(double originalPrice, double? salePrice) {
    if (salePrice == null || salePrice <= 0.0) return null;
    if (originalPrice <= 0) return null;

    double percentage = ((originalPrice - salePrice) / originalPrice) * 100;
    return percentage.toStringAsFixed(0);
  }

  /// Final price

  String getFinalPrice(ProductModel product) {
    if (product.salePrice > 0 &&
        product.price > 0 &&
        product.salePrice < product.price) {
      return product.salePrice.toStringAsFixed(2);
    }

    return product.price.toStringAsFixed(2);
  }

  /// -- Check Product Stock Status
  String getProductStockStatus(int stock) {
    return stock > 0 ? 'In Stock' : 'Out of Stock';
  }

  /// Clear any active search state.
  void clearSearchResults() {
    searchResults.clear();
    isLoading.value = false;
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    try {
      final trimmedQuery = query.trim();

      if (trimmedQuery.isEmpty) {
        clearSearchResults();
        return;
      }

      isLoading.value = true;
      final products = await productRepository.searchProducts(trimmedQuery);
      searchResults.assignAll(products);
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

}
