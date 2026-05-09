import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/coupon_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/popups/full_screen_loader.dart';

class CreateCouponController extends GetxController {
  static CreateCouponController get instance => Get.find();

  final formKey = GlobalKey<FormState>();

  final code = TextEditingController();
  final amount = TextEditingController();
  final minOrder = TextEditingController();
  final maxDiscount = TextEditingController();
  final maxUses = TextEditingController();
  final perUser = TextEditingController();

  final type = 'percentage'.obs;
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
        'perUserLimit': perUser.text.trim().isEmpty ? null : int.tryParse(perUser.text.trim()),
        'active': true,
      };

      final id = await _repo.createCoupon(data);
      YFullScreenLoader.stopLoading();
      Get.back();
      Get.snackbar('Success', 'Coupon created: $id', backgroundColor: YColors.buttonGreen.withValues(alpha: 0.08));
    } catch (e) {
      YFullScreenLoader.stopLoading();
      Get.snackbar('Error', e.toString(), backgroundColor: YColors.error.withValues(alpha: 0.08));
    }
  }
}

