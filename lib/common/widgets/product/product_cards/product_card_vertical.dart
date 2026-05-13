import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/common/widgets/product/favourite_icon/favourite_icon.dart';
import 'package:fast_food/common/widgets/texts/brand_title_text_with_verified_icon.dart';
import 'package:fast_food/common/widgets/texts/product_title_text.dart';
import 'package:fast_food/features/shop/models/product_model.dart';
import 'package:fast_food/utils/constants/colors.dart';
import 'package:fast_food/utils/constants/enums.dart';
import 'package:fast_food/utils/constants/sizes.dart';
import 'package:fast_food/utils/helpers/helper_functions.dart';

import '../../../../features/shop/controllers/product/product_controller.dart';
import '../../../../features/shop/screens/cart/widgets/add_to_cart_button.dart';
import '../../../../features/shop/screens/product_details/product_detail.dart';
import '../../../styles/shadows.dart';
import '../../custom_shapes/containers/rounded_container.dart';
import '../../images/rounded_image.dart';
import '../../texts/product_price_text.dart';

class ProductCardVertical extends StatelessWidget {
  const ProductCardVertical({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );
    final dark = YHelperFunctions.isDarkMode(context);
    // Stock tracking removed; products are always available

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreen(product: product)),
      child: Container(
        width: 180,
        padding: EdgeInsets.all(YSizes.xs),
        decoration: BoxDecoration(
          boxShadow: [
            YShadowStyle.verticalProductShadow,
            // Enhanced shadow for depth
            if (!dark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
          ],
          borderRadius: BorderRadius.circular(YSizes.productImageRadius),
          color: dark ? YColors.darkerGrey : YColors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Thumbnail, Wishlist Button, Discount
            YRoundedContainer(
              height: 160,
              padding: const EdgeInsets.all(YSizes.sm),
              backgroundColor: dark ? YColors.darkerGrey : YColors.light,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Thumbnail Image with opacity if out of stock
                  Center(
                    child: YRoundedImage(
                      imageUrl: product.thumbnail,
                      applyImageRadius: true,
                      isNetworkImage: true,
                    ),
                  ),

                  // No out-of-stock overlay (stock removed)

                  // Discount badge - show only when product has a discount
                  if (salePercentage != null && int.tryParse(salePercentage) != null && int.parse(salePercentage) > 0)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: YRoundedContainer(
                        radius: YSizes.sm,
                        backgroundColor: YColors.discount.withValues(alpha: 0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          '-$salePercentage%',
                          style: Theme.of(context).textTheme.labelSmall!.apply(
                            color: YColors.white,
                            fontWeightDelta: 1,
                          ),
                        ),
                      ),
                    ),


                  // Stock status removed

                  // Favourite/Wishlist Button with GetX reactive state
                  Positioned(
                    top: 8,
                    right: 8,
                    child: YFavouriteIcon(productId: product.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: YSizes.spaceBtwItems),

            // Detail Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: YSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Name
                  YBrandTitleWithVerifiedIcon(
                    title: product.brand?.name ?? 'Unknown',
                  ),
                  const SizedBox(height: 4),
                  // Product Title
                  YProductTitleText(
                    title: product.title,
                    smallSize: true,
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Price and Add to Cart Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: YSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Price Section
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Original price with strikethrough if on sale
                            if (product.productType ==
                                    ProductType.single.name &&
                                product.salePrice > 0)
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .apply(
                                      decoration: TextDecoration.lineThrough,
                                      color: YColors.darkGrey,
                                    ),
                              ),

                            // Current/Sale price
                            YProductPriceText(
                              price: controller.getFinalPrice(product),
                            ),
                          ],
                        ),
                      ),

                      // Add to cart button
                      ProductCartAddToCart(product: product),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: YSizes.sm),
          ],
        ),
      ),
    );
  }
}
