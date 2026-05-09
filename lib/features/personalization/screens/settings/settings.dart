import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fast_food/common/widgets/appbar/appbar.dart';
import 'package:fast_food/features/personalization/screens/profile/profile.dart';
import 'package:fast_food/features/shop/screens/order/order.dart';
import 'package:fast_food/utils/constants/colors.dart';
import 'package:fast_food/utils/constants/sizes.dart';

import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/list_tile/settings_menu_tile.dart';
import '../../../../common/widgets/list_tile/user_profile_tile.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import 'coupon_list.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../shop/screens/cart/cart.dart';
import '../../../../utils/helpers/helper_functions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = YHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? YColors.dark : YColors.light,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          YPrimaryHeaderContainer(
            child: Column(
              children: [
                // AppBar
                YAppBar(
                  title: Text(
                    'Account',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.apply(color: YColors.white),
                  ),
                ),

                // User Profile Tile
                YUserProfileTile(
                  onPressed: () => Get.to(() => const ProfileScreen()),
                ),

                const SizedBox(height: YSizes.spaceBtwSections),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(YSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// -- Account Settings
                const YSectionHeading(
                  title: 'Account Settings',
                  showActionButton: false,
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                YRoundedContainer(
                  showBorder: true,
                  backgroundColor: dark ? YColors.darkerGrey : YColors.white,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // YSettingsMenuTile(
                      //   icon: Iconsax.safe_home,
                      //   title: 'My Addresses',
                      //   subTitle: 'Set shopping delivery address',
                      //   onTap: () => Get.to(() => const UserAddressScreen()),
                      // ),
                      YSettingsMenuTile(
                        icon: Iconsax.shopping_cart,
                        title: 'My Cart',
                        subTitle: 'Add, remove products and move to checkout',
                        onTap: () => Get.to(() => const CartScreen()),
                      ),
                      const Divider(height: 1),
                      YSettingsMenuTile(
                        icon: Iconsax.bag_tick,
                        title: 'My Orders',
                        subTitle: 'In-progress and Completed Orders',
                        onTap: () => Get.to(() => const OrderScreen()),
                      ),
                      const Divider(height: 1),
                      YSettingsMenuTile(
                        icon: Iconsax.discount_shape,
                        title: 'My Coupons',
                        subTitle: 'View available coupons',
                        onTap: () => Get.to(() => const CouponListScreen()),
                      ),
                      const Divider(height: 1),
                      const YSettingsMenuTile(
                        icon: Iconsax.notification,
                        title: 'Notifications',
                        subTitle: 'Set any kind of notification message',
                      ),
                      const Divider(height: 1),
                      const YSettingsMenuTile(
                        icon: Iconsax.security_card,
                        title: 'Account Privacy',
                        subTitle: 'Manage data usage and connected accounts',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: YSizes.spaceBtwSections),

                YRoundedContainer(
                  showBorder: true,
                  backgroundColor: dark ? YColors.darkerGrey : YColors.white,
                  padding: const EdgeInsets.all(YSizes.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => AuthenticationRepository.instance.logout(),
                      child: const Text('Log out'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
