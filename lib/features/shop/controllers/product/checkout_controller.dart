import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/list_tile/payment_tile.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../models/payment_method_model.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();

  final Rx<PaymentMethodModel> selectedPaymentMethod =
      PaymentMethodModel.empty().obs;

  @override
  void onInit() {
    // Default to KHQR so checkout always has a valid payment method.
    selectedPaymentMethod.value = PaymentMethodModel(
      image: YImage.khqr,
      name: 'KHQR',
    );
    super.onInit();
  }

  Future<dynamic> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(YSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const YSectionHeading(
                title: 'Select Payment Method',
                showActionButton: false,
              ),
              const SizedBox(height: YSizes.spaceBtwSections),
              Text(
                'Choose KHQR to pay with a live merchant QR code.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: YSizes.spaceBtwItems),
              YPaymentTile(
                paymentMethod: PaymentMethodModel(
                  image: YImage.khqr,
                  name: 'KHQR',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
