import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/widgets/product/cart/add_remove_button.dart';
import '../../../../../common/widgets/product/cart/cart_item.dart';
import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/product/cart_controller.dart';
import '../../../models/cart_item_model.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    super.key,
    this.showAddRemoveButton = true,
    this.items,
  });

  final bool showAddRemoveButton;
  final List<CartItemModel>? items;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    final dark = YHelperFunctions.isDarkMode(context);

    Widget buildList(List<CartItemModel> sourceItems) {
      final canModify = showAddRemoveButton && items == null;
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sourceItems.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: YSizes.spaceBtwSections),
        itemBuilder: (_, index) {
          final item = sourceItems[index];
          return YRoundedContainer(
            showBorder: true,
            padding: const EdgeInsets.all(YSizes.md),
            backgroundColor: dark ? YColors.dark : YColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                YCartItem(cartItem: item),
                if (canModify) ...[
                  const SizedBox(height: YSizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: YProductQuantityWithAddRemoveButton(
                          quantity: item.quantity,
                          add: () => cartController.addOneToCart(item),
                          remove: () => cartController.removeOneFromCart(item),
                        ),
                      ),
                      const SizedBox(width: YSizes.spaceBtwItems),
                      YProductPriceText(
                        price: (item.price * item.quantity).toStringAsFixed(1),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      );
    }

    if (items != null) {
      return buildList(items!);
    }

    return Obx(() => buildList(cartController.cartItems));
  }
}
