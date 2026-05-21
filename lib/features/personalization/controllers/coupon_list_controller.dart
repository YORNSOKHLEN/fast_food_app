import 'package:get/get.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/coupon_repository.dart';
import '../../personalization/controllers/user_controller.dart';
import '../../shop/models/coupon_model.dart';

class CouponListController extends GetxController {
  static CouponListController get instance => Get.find();

  final couponRepository = Get.put(CouponRepository());
  final coupons = <CouponModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final userId = AuthenticationRepository.instance.authUser?.uid;
      final userRole = Get.isRegistered<UserController>()
          ? UserController.instance.user.value.role
          : '';

      final isAdmin = userRole == 'admin';
      if (userId == null || userId.isEmpty) {
        coupons.assignAll(await couponRepository.fetchActiveCoupons());
      } else if (isAdmin) {
        coupons.assignAll(await couponRepository.fetchActiveCoupons(includeTargetedCoupons: true));
      } else {
        coupons.assignAll(await couponRepository.fetchActiveCouponsForUser(userId));
      }
    } catch (_) {
      hasError.value = true;
      coupons.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove a coupon from the current list immediately after it has been used.
  void removeCouponById(String couponId) {
    coupons.removeWhere((coupon) => coupon.id == couponId);
  }
}


