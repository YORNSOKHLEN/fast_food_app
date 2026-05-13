import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:fast_food/common/widgets/images/circular_image.dart';
import 'package:fast_food/common/widgets/texts/brand_title_text_with_verified_icon.dart';
import 'package:fast_food/features/shop/controllers/product/product_controller.dart';
import 'package:fast_food/features/shop/models/product_model.dart';
import 'package:fast_food/features/shop/models/brand_model.dart';
import 'package:fast_food/data/repositories/brand/brand_repository.dart';
import 'package:fast_food/utils/constants/colors.dart';
import 'package:fast_food/utils/constants/enums.dart';
import 'package:fast_food/utils/constants/sizes.dart';

import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../common/widgets/texts/product_title_text.dart';

class YProductMetaData extends StatelessWidget {
  const YProductMetaData({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final salePercentage = controller.calculateSalePercentage(
      product.price,
      product.salePrice,
    );
    final finalPrice = controller.getFinalPrice(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price & sale Price
        Row(
          children: [
            // Sale Tag
            if (salePercentage != null)
              YRoundedContainer(
                radius: YSizes.sm,
                backgroundColor: YColors.secondary.withValues(alpha: 0.8),
                padding: EdgeInsets.symmetric(
                  horizontal: YSizes.sm,
                  vertical: YSizes.xs,
                ),
                child: Text(
                  '$salePercentage%',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.apply(color: YColors.black),
                ),
              ),
            if (salePercentage != null)
              const SizedBox(width: YSizes.spaceBtwItems),

            /// Price
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                decoration: TextDecoration.lineThrough,
                decorationThickness: 2,
              ),
            ),
            if (product.salePrice > 0)
              const SizedBox(width: YSizes.spaceBtwItems),
            YProductPriceText(price: finalPrice, isLarge: true),
          ],
        ),
        const SizedBox(height: YSizes.spaceBtwItems / 1.5),

        /// Title
        YProductTitleText(title: product.title),
        const SizedBox(height: YSizes.spaceBtwItems / 1.5),

        /// Brand - Fetch by ID if available, otherwise use nested brand object
        _buildBrandSection(context),
      ],
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    // Prefer using brandId if available
    if (product.brandId != null && product.brandId!.isNotEmpty) {
      return _BrandByIdWidget(brandId: product.brandId!);
    }

    // Fallback to nested brand object
    if (product.brand != null) {
      return Row(
        children: [
          YCircularImage(
            image: product.brand!.image,
            height: 32,
            width: 32,
            isNetworkImage: product.brand!.image.startsWith('http'),
          ),
          const SizedBox(width: YSizes.spaceBtwItems / 6),
          YBrandTitleWithVerifiedIcon(
            title: product.brand!.name,
            brandTextSize: TextSize.medium,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// Widget to fetch and display brand by ID
class _BrandByIdWidget extends StatelessWidget {
  const _BrandByIdWidget({required this.brandId});

  final String brandId;

  @override
  Widget build(BuildContext context) {
    final brandRepository = BrandRepository.instance;
    final brand = Rxn<BrandModel>();

    // Fetch brand by ID
    _fetchBrand(brandRepository, brand);

    return Obx(() {
      if (brand.value == null) {
        return const SizedBox.shrink();
      }

      final brandData = brand.value!;
      return Row(
        children: [
          YCircularImage(
            image: brandData.image,
            height: 32,
            width: 32,
            isNetworkImage: brandData.image.startsWith('http'),
          ),
          const SizedBox(width: YSizes.spaceBtwItems / 6),
          YBrandTitleWithVerifiedIcon(
            title: brandData.name,
            brandTextSize: TextSize.medium,
          ),
        ],
      );
    });
  }

  void _fetchBrand(BrandRepository brandRepository, Rxn<BrandModel> brand) {
    if (brand.value == null) {
      brandRepository.getBrandById(brandId).then((fetchedBrand) {
        brand.value = fetchedBrand;
      }).catchError((_) {
        brand.value = BrandModel.empty();
      });
    }
  }
}
