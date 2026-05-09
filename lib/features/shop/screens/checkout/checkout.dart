import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/features/shop/controllers/product/cart_controller.dart';
import 'package:fast_food/features/shop/screens/checkout/widgets/billing_amount_section.dart';
import 'package:fast_food/features/shop/screens/checkout/widgets/billing_payment_section.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/product/cart/coupon_widget.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/helpers/pricing_calculator.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/product/order_controller.dart';
import '../../controllers/product/coupon_controller.dart';
import '../cart/widgets/cart_item.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = YHelperFunctions.isDarkMode(context);
    final cartController = CartController.instance;
    final subTotal = cartController.totalCartPrice.value;
    final orderController = Get.put(OrderController());
    // ensure coupon controller is available
    final couponController = Get.put(CouponController());

    return Scaffold(
      appBar: YAppBar(
        showBackArrow: true,
        title: Text(
          'Order Review',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),

      /// Checkout Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: Obx(() {
          final discount = couponController.discount.value;
          final totalAmount = YPricingCalculator.calculateTotalPrice(subTotal, '') - discount;
          final safeTotal = totalAmount < 0 ? 0.0 : totalAmount;

          return ElevatedButton(
          // onPressed: () => Get.to(
          //   () => SuccessScreen(
          //     image: YImage.paymentSuccess,
          //     title: 'Payment Success!',
          //     subTitle: 'Your item will be shipped soon!',
          //     onPressed: () => Get.offAll(() => const NavigationMenu()),
          //   ),
          //
          // ),
          // child: Text(
          //   'Checkout \$${YPricingCalculator.calculateTotalPrice(subTotal, '')}',
          // ),
            onPressed: subTotal > 0
                ? () => orderController.processOrder(safeTotal)
                : () => YLoaders.warningSnackBar(
                    title: 'Empty Cart',
                    message: 'Add items in the cart in order to proceed.',
                  ),
            child: Text('Checkout \$$safeTotal'),
          );
        }),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(YSizes.defaultSpace),
          child: Column(
            children: [
              /// -- Items in Cart
              const CartItem(showAddRemoveButton: false),
              const SizedBox(height: YSizes.spaceBtwSections),

              /// -- Coupon TextField
              YCouponCode(),
              const SizedBox(height: YSizes.spaceBtwSections),

              /// -- Billing Section
              YRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(YSizes.md),
                backgroundColor: dark ? YColors.black : YColors.white,
                child: Column(
                  children: [
                    // Pricing
                    YBillingAmountSection(),
                    SizedBox(height: YSizes.spaceBtwItems),

                    // Divider
                    Divider(),
                    SizedBox(height: YSizes.spaceBtwItems),

                    // Payment Methods
                    YBillingPaymentSection(),
                    SizedBox(height: YSizes.spaceBtwItems),

                    // Address
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
