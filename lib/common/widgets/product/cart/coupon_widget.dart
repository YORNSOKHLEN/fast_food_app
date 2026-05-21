import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fast_food/features/shop/controllers/product/coupon_controller.dart';
import 'package:fast_food/features/shop/controllers/product/cart_controller.dart';
import 'package:fast_food/features/personalization/controllers/coupon_list_controller.dart';
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
            flex: 3,
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
          const SizedBox(width: YSizes.spaceBtwItems),

          /// Button
          Obx(() {
            final hasAppliedCoupon = couponController.appliedCoupon.value != null;
            return SizedBox(
              width: hasAppliedCoupon ? 110 : 80,
              child: hasAppliedCoupon
                  ? ElevatedButton.icon(
                      onPressed: () {
                        couponController.removeCoupon();
                        // Refresh coupon list so removed coupon is available again
                        if (Get.isRegistered<CouponListController>()) {
                          try {
                            Get.find<CouponListController>().fetchCoupons();
                          } catch (e) {
                            // Controller not registered yet
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: dark
                            ? YColors.white.withValues(alpha: 0.5)
                            : YColors.dark.withValues(alpha: 0.5),
                        backgroundColor: YColors.grey.withValues(alpha: 0.2),
                        side: BorderSide(color: YColors.grey.withValues(alpha: 0.1)),
                      ),
                      icon: const Icon(Iconsax.trash, size: 14),
                      label: const Text('Remove', style: TextStyle(fontSize: 12)),
                    )
                  : ElevatedButton(
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
            );
          }),
        ],
      ),
    );
  }
}
