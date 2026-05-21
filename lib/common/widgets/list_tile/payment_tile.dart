import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/shop/controllers/product/checkout_controller.dart';
import '../../../features/shop/models/payment_method_model.dart';

/// Simplified payment tile. Payment functionality removed; this widget only selects a method name.
class YPaymentTile extends StatelessWidget {
  const YPaymentTile({super.key, required this.paymentMethod});

  final PaymentMethodModel paymentMethod;

  @override
  Widget build(BuildContext context) {
    final controller = CheckoutController.instance;

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      onTap: () {
        controller.selectedPaymentMethod.value = paymentMethod;
        Get.back();
      },
      title: Text(paymentMethod.name),
      trailing: const Icon(Icons.arrow_forward),
    );
  }
}
