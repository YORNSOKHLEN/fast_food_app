import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/coupon_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';

class CreateCouponController extends GetxController {
  static CreateCouponController get instance => Get.find();

  final formKey = GlobalKey<FormState>();

  final code = TextEditingController();
  final amount = TextEditingController();
  final minOrder = TextEditingController();
  final maxDiscount = TextEditingController();
  final maxUses = TextEditingController();
  final perUser = TextEditingController(text: '1');
  final targetUserId = TextEditingController();
  final targetProductId = TextEditingController();

  final type = 'percentage'.obs;
  final scope = 'all'.obs;
  final productScope = 'all'.obs;
  final expiresAt = Rxn<DateTime>();

  final _repo = Get.put(CouponRepository());

  @override
  void onClose() {
    code.dispose();
    amount.dispose();
    minOrder.dispose();
    maxDiscount.dispose();
    maxUses.dispose();
    perUser.dispose();
    targetUserId.dispose();
    targetProductId.dispose();
    super.onClose();
  }

  Future<void> pickExpiry(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) expiresAt.value = picked;
  }

  Future<void> createCoupon() async {
    if (!formKey.currentState!.validate()) return;
    if (scope.value == 'single' && targetUserId.text.trim().isEmpty) {
      YLoaders.errorSnackBar(title: 'Error', message: 'Target user ID is required for a single-user coupon');
      return;
    }
    if (productScope.value == 'single' && targetProductId.text.trim().isEmpty) {
      YLoaders.errorSnackBar(title: 'Error', message: 'Target product ID is required for a single-product coupon');
      return;
    }
    try {
      YFullScreenLoader.openLoadingDialog('Creating coupon...', YImage.docerAnimation);

      final data = <String, dynamic>{
        'code': code.text.trim(),
        'type': type.value,
        'amount': double.tryParse(amount.text.trim()) ?? 0.0,
        'minOrderAmount': minOrder.text.trim().isEmpty ? null : double.tryParse(minOrder.text.trim()),
        'maxDiscountAmount': maxDiscount.text.trim().isEmpty ? null : double.tryParse(maxDiscount.text.trim()),
        'expiresAt': expiresAt.value,
        'maxUses': maxUses.text.trim().isEmpty ? null : int.tryParse(maxUses.text.trim()),
        'perUserLimit': perUser.text.trim().isEmpty ? 1 : (int.tryParse(perUser.text.trim()) ?? 1),
        'targetUserId': scope.value == 'single' ? targetUserId.text.trim() : null,
        'targetProductId': productScope.value == 'single' ? targetProductId.text.trim() : null,
        'active': true,
      };

      final id = await _repo.createCoupon(data);
      YFullScreenLoader.stopLoading();

      YLoaders.successSnackBar(
        title: 'Success',
        message: 'Coupon created: $id',
      );

      Get.back();
    } catch (e) {
      YFullScreenLoader.stopLoading();
      YLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}

