import 'package:flutter/material.dart';
import 'package:fast_food/common/widgets/images/circular_image.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class YVerticalImageText extends StatelessWidget {
  const YVerticalImageText({
    super.key,
    this.onTap,
    required this.image,
    required this.title,
    this.backgroundColor,
    this.isNetworkImage = true,
    this.textColor = YColors.white,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final bool isNetworkImage;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: YSizes.spaceBtwItems),
        child: Column(
          children: [
            /// Circular Icon
            YCircularImage(
              image: image,
              fit: BoxFit.fitWidth,
              padding: YSizes.sm * 1.4,
              isNetworkImage: isNetworkImage,
              backgroundColor: backgroundColor,
              // overlayColor: YHelperFunctions.isDarkMode(context)
              //     ? YColors.light
              //     : YColors.dark,
            ),
            // Text
            const SizedBox(height: YSizes.spaceBtwItems / 2),
            SizedBox(
              width: 56,
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.apply(color: YColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
