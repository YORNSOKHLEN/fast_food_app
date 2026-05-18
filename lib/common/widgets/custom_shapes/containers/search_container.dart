import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fast_food/utils/helpers/helper_functions.dart';

import '../../../../features/shop/screens/search/search_screen.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utility.dart';

class YSearchContainer extends StatelessWidget {
  const YSearchContainer({
    super.key,
    required this.text,
    this.icon,
    this.showBackground = true,
    this.showBorder = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: YSizes.defaultSpace),
    this.initialQuery,
  });

  final String text;
  final String? initialQuery;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = YHelperFunctions.isDarkMode(context);
    return GestureDetector(
      // If an explicit onTap is provided use it, otherwise open SearchScreen.
      // Pass initialQuery via Get.arguments
      onTap: onTap ?? () => Get.to(
        () => const SearchScreen(),
        arguments: initialQuery,
      ),
      child: Padding(
        padding: padding,
        child: Container(
          width: YDeviceUtils.getScreenWidth(context),
          padding: EdgeInsets.all(YSizes.md),
          decoration: BoxDecoration(
            color: showBackground
                ? dark
                      ? YColors.dark
                      : YColors.light
                : Colors.transparent,
            borderRadius: BorderRadius.circular(YSizes.borderRadiusLg),
            border: showBorder ? Border.all(color: YColors.grey) : null,
          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal, color: YColors.grey),
              SizedBox(width: YSizes.spaceBtwItems),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: dark ? YColors.darkGrey : YColors.darkerGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
