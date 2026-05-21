import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/coupon_model.dart';
import '../../models/cart_item_model.dart';
import '../../../../data/repositories/coupon_repository.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../personalization/controllers/coupon_list_controller.dart';
import 'cart_controller.dart';

class CouponController extends GetxController {
  static CouponController get instance => Get.find();

  final couponCode = TextEditingController();
  final Rxn<CouponModel> appliedCoupon = Rxn<CouponModel>();
  final RxDouble discount = 0.0.obs;
  final couponRepository = Get.put(CouponRepository());

  @override
  void onClose() {
    couponCode.dispose();
    super.onClose();
  }

  /// Compute discount amount based on coupon and order total
  double _computeDiscount(CouponModel coupon, double orderTotal) {
    if (coupon.type == 'percentage') {
      final raw = orderTotal * (coupon.amount / 100.0);
      if (coupon.maxDiscountAmount != null && raw > coupon.maxDiscountAmount!) {
        return coupon.maxDiscountAmount!;
      }
      return raw;
    }
    // fixed
    return coupon.amount > orderTotal ? orderTotal : coupon.amount;
  }

  /// Try to apply coupon. Returns message on failure or null on success.
  Future<String?> applyCoupon(String code, double orderTotal) async {
    try {
      final normalized = code.trim();
      if (normalized.isEmpty) return 'Enter coupon code';

      final user = AuthenticationRepository.instance.authUser;
      if (user == null) return 'You must be logged in to use coupons';

      final coupon = await couponRepository.fetchCouponByCode(
        normalized,
        userId: user.uid,
      );
      if (coupon == null) return 'Invalid coupon code';

      // check active
      if (!coupon.active) return 'Coupon is not active';

      final now = DateTime.now();
      if (coupon.startsAt != null && now.isBefore(coupon.startsAt!)) return 'Coupon not valid yet';
      if (coupon.expiresAt != null && now.isAfter(coupon.expiresAt!)) return 'Coupon has expired';

      // min order
      if (coupon.minOrderAmount != null && orderTotal < coupon.minOrderAmount!) {
        return 'Order total must be at least \$${coupon.minOrderAmount} to use this coupon';
      }

      final targetProductId = coupon.targetProductId;
      if (targetProductId != null && targetProductId.isNotEmpty) {
        final cartItems = CartController.instance.cartItems;
        final hasTargetProduct = cartItems.any((CartItemModel item) => item.productId == targetProductId);
        if (!hasTargetProduct) {
          return 'This coupon is only valid for a specific product in your cart';
        }
      }

      // one customer can use a coupon only once
      final userUsage = await couponRepository.userUsageCount(coupon.id, user.uid);
      if (userUsage > 0) {
        return 'You have already used this coupon';
      }

      // global usage
      if (coupon.maxUses != null && coupon.usageCount >= coupon.maxUses!) {
        return 'Coupon usage limit reached';
      }

      // compute discount
      final d = _computeDiscount(coupon, orderTotal);
      appliedCoupon.value = coupon;
      discount.value = d;
      couponCode.text = coupon.code;

      return null;
    } catch (e) {
      return 'Failed to apply coupon';
    }
  }

  /// Remove coupon locally (does not rollback claimed usage)
  void removeCoupon() {
    appliedCoupon.value = null;
    discount.value = 0.0;
    couponCode.text = '';
  }

  /// Claim coupon on order (persist usage). Throws on failure.
  Future<void> claimCouponForOrder(String orderId) async {
    final coupon = appliedCoupon.value;
    final user = AuthenticationRepository.instance.authUser;
    if (coupon == null || user == null) return;
    await couponRepository.claimCouponUsage(couponId: coupon.id, userId: user.uid, orderId: orderId);

    // Immediately remove used coupon from the list so it disappears right away
    if (Get.isRegistered<CouponListController>()) {
      final controller = Get.find<CouponListController>();
      controller.removeCouponById(coupon.id);
      // Refresh from server to ensure the user-specific list stays in sync.
      await controller.fetchCoupons();
    }
  }
}
