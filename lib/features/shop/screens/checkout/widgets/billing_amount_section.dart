import 'package:flutter/material.dart';
import 'package:fast_food/utils/helpers/pricing_calculator.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/cart_controller.dart';
import 'package:get/get.dart';
import '../../../controllers/product/coupon_controller.dart';

class YBillingAmountSection extends StatelessWidget {
  const YBillingAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final subTotal = cartController.totalCartPrice.value;
    final couponController = Get.put(CouponController());
    return Column(
      children: [
        /// SubTotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium),
            Text('\$$subTotal', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: YSizes.spaceBtwItems / 2),

        /// Shipping Fee
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping Fee', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '\$${YPricingCalculator.calculateShippingCost(subTotal, '')}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: YSizes.spaceBtwItems / 2),

        /// Tax Fee
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax Fee', style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '\$${YPricingCalculator.calculateTaxAmount(subTotal, '')}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: YSizes.spaceBtwItems / 2),

        /// Coupon Discount (if any)
        Obx(() {
          final discount = couponController.discount.value;
          if (discount <= 0) return const SizedBox.shrink();
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discount', style: Theme.of(context).textTheme.bodyMedium),
                  Text('-\$${discount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: YSizes.spaceBtwItems / 2),
            ],
          );
        }),

        /// Order Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Total', style: Theme.of(context).textTheme.bodyMedium),
            Obx(() {
              final discount = couponController.discount.value;
              final total = YPricingCalculator.calculateTotalPrice(subTotal, '') - discount;
              final safeTotal = total < 0 ? 0.0 : total;
              return Text('\$${safeTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium);
            }),
          ],
        ),
      ],
    );
  }
}
