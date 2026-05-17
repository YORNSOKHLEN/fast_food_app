import 'package:get/get.dart';
import 'package:fast_food/features/shop/controllers/product/checkout_controller.dart';

import '../data/repositories/authentication/authentication_repository.dart';
import '../data/repositories/brand/brand_repository.dart';
import '../data/repositories/category/category_repository.dart';
import '../data/repositories/review/review_repository.dart';
import '../data/repositories/product/product_repository.dart';
import '../data/services/cloud_storage/firebase_storage_service.dart';
import '../data/services/data_upload_service.dart';
import '../features/personalization/controllers/account_privacy_controller.dart';
import '../features/personalization/controllers/notification_controller.dart';
import '../features/shop/controllers/product/cart_controller.dart';
import '../features/shop/controllers/product/favourite_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// Network (global)
    Get.put(NetworkManager(), permanent: true);
    // Get.put(FavouriteController(), permanent: true);

    /// Authentication (global)
    Get.put(AuthenticationRepository(), permanent: true);

    /// Repositories (lazy + auto recreate)
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(), fenix: true);
    Get.lazyPut<BrandRepository>(() => BrandRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<ReviewRepository>(() => ReviewRepository(), fenix: true);

    /// Services ADD THIS
    Get.lazyPut<DataUploadService>(() => DataUploadService(), fenix: true);
    Get.lazyPut<YFirebaseStorageService>(
      () => YFirebaseStorageService(),
      fenix: true,
    );

    /// Controllers (lazy + auto recreate)
    Get.lazyPut<CartController>(CartController.new, fenix: true);
    Get.lazyPut<FavouriteController>(() => FavouriteController(), fenix: true);
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
    Get.lazyPut<AccountPrivacyController>(() => AccountPrivacyController(), fenix: true);
  }
}
