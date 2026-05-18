import 'package:get/get.dart';
import 'package:fast_food/features/shop/controllers/navigation_controller.dart';
import 'package:fast_food/features/shop/controllers/home_controller.dart';
import 'package:fast_food/features/shop/controllers/category_controller.dart';
import 'package:fast_food/features/shop/controllers/banner_controller.dart';
import 'package:fast_food/features/shop/controllers/brand_controller.dart';
import 'package:fast_food/features/shop/controllers/all_product_controller.dart';
import 'package:fast_food/features/shop/controllers/poster_controller.dart';
import 'package:fast_food/features/shop/controllers/product/product_controller.dart';
import 'package:fast_food/features/shop/controllers/product/variation_controller.dart';
import 'package:fast_food/features/shop/controllers/product/order_controller.dart';
import 'package:fast_food/features/shop/controllers/checkout/billing_address_controller.dart';
import 'package:fast_food/features/shop/controllers/search_controller.dart';
import 'package:fast_food/features/shop/controllers/product_reviews_controller.dart';

class ShopBindings extends Bindings {
  @override
  void dependencies() {
    // Navigation
    Get.lazyPut<NavigationController>(() => NavigationController(), fenix: true);

    // Home & Browse
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<BannerController>(() => BannerController(), fenix: true);
    Get.lazyPut<BrandController>(() => BrandController(), fenix: true);
    Get.lazyPut<AllProductsController>(() => AllProductsController(), fenix: true);
    Get.lazyPut<PosterController>(() => PosterController(), fenix: true);

    // Products
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
    Get.lazyPut<VariationController>(() => VariationController(), fenix: true);

    // Orders & Checkout
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    Get.lazyPut<BillingAddressController>(() => BillingAddressController(), fenix: true);

    // Search & Reviews
    Get.lazyPut<ProductSearchController>(() => ProductSearchController(), fenix: true);
    Get.lazyPut<ProductReviewsController>(
      () => ProductReviewsController(),
      fenix: true,
    );
  }
}

