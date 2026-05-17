import 'package:flutter/material.dart';

import '../../../features/shop/models/brand_model.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../custom_shapes/containers/rounded_container.dart';
import '../images/circular_image.dart';
import '../texts/brand_title_text_with_verified_icon.dart';

class YBrandCard extends StatelessWidget {
  const YBrandCard({
    super.key,
    required this.showBorder,
    this.onTab,
    required this.brand,
  });

  final bool showBorder;
  final void Function()? onTab;
  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    // final dark = YHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTab,
      child: YRoundedContainer(
        padding: const EdgeInsets.all(YSizes.sm),
        showBorder: showBorder,
        backgroundColor: Colors.transparent,
        child: Row(
          children: [
            /// -- Icon
            Flexible(
              child: YCircularImage(
                image: brand.image,
                isNetworkImage: brand.image.startsWith('http'),
                backgroundColor: Colors.transparent,
                // overlayColor: dark ? YColors.white : YColors.black,
              ),
            ),
            const SizedBox(width: YSizes.spaceBtwItems / 2),

            /// Text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YBrandTitleWithVerifiedIcon(
                    title: brand.name,
                    brandTextSize: TextSize.large,
                  ),
                  Text(
                    '${brand.productsCount ?? 0} products',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: YColors.darkGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
