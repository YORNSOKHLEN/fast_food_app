import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:fast_food/features/shop/controllers/product/coupon_controller.dart';
import 'package:fast_food/features/shop/controllers/product/cart_controller.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../custom_shapes/containers/rounded_container.dart';

class YCouponCode extends StatelessWidget {
  const YCouponCode({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = YHelperFunctions.isDarkMode(context);
    final couponController = Get.put(CouponController());
    return YRoundedContainer(
      showBorder: true,
      backgroundColor: dark ? YColors.dark : YColors.white,
      padding: const EdgeInsets.only(
        top: YSizes.sm,
        bottom: YSizes.sm,
        right: YSizes.sm,
        left: YSizes.md,
      ),
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              controller: couponController.couponCode,
              decoration: const InputDecoration(
                hintText: 'Have a promo code? Enter here',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),

          /// Button
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () async {
                final subtotal = CartController.instance.totalCartPrice.value;
                final message = await couponController.applyCoupon(
                  couponController.couponCode.text,
                  subtotal,
                );
                if (message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(message),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Coupon applied'),
                  ));
                }
              },
                style: ElevatedButton.styleFrom(
                foregroundColor: dark
                    ? YColors.white.withValues(alpha: 0.5)
                    : YColors.dark.withValues(alpha: 0.5),
                backgroundColor: YColors.grey.withValues(alpha: 0.2),
                side: BorderSide(color: YColors.grey.withValues(alpha: 0.1)),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
