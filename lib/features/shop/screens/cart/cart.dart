import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/features/shop/controllers/product/cart_controller.dart';
import 'package:fast_food/features/shop/screens/cart/widgets/cart_item.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/loaders/animation_loader.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../checkout/checkout.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    return Scaffold(
      appBar: YAppBar(
        showBackArrow: true,
        title: Text('Cart', style: Theme.of(context).textTheme.headlineSmall),
      ),
      // Bottom checkout bar (sticky)
      bottomNavigationBar: Obx(() {
        if (controller.cartItems.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(YSizes.defaultSpace),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: Theme.of(context).textTheme.bodyLarge),
                    Obx(() => Text('\$${controller.totalCartPrice.value.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall)),
                  ],
                ),
              ),
              const SizedBox(width: YSizes.defaultSpace),
              ElevatedButton(
                onPressed: () => Get.to(() => CheckoutScreen()),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22)),
                child: Obx(() => Text('Checkout (${controller.noOfCartItems.value})')),
              ),
            ],
          ),
        );
      }),

      body: Obx(() {
        // Empty state
        final emptyWidget = Center(
          child: Padding(
            padding: const EdgeInsets.all(YSizes.defaultSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                YAnimationLoaderWidget(
                  text: 'Whoops! Cart is EMPTY.',
                  animation: YImage.docerAnimation,
                  showAction: true,
                  actionText: 'Let\'s fill it',
                  onActionPressed: () => Get.off(() => const NavigationMenu()),
                ),
              ],
            ),
          ),
        );

        if (controller.cartItems.isEmpty) {
          return emptyWidget;
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              controller.updateCart();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(YSizes.defaultSpace),
                child: Column(
                  children: [
                    /// -- Items in Cart
                    CartItem(),
                  ],
                ),
              ),
            ),
          );
        }
      }),
    );
  }
}
