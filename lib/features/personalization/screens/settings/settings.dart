import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fast_food/common/widgets/appbar/appbar.dart';
import 'package:fast_food/features/personalization/screens/profile/profile.dart';
import 'package:fast_food/features/personalization/controllers/user_controller.dart';
import 'package:fast_food/features/shop/screens/order/order.dart';
import 'package:fast_food/utils/constants/colors.dart';
import 'package:fast_food/utils/constants/sizes.dart';

import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/list_tile/settings_menu_tile.dart';
import '../../../../common/widgets/list_tile/user_profile_tile.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import 'create_coupon.dart';
import 'coupon_list.dart';
import 'upload_product.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/services/data_upload_service.dart';
import '../../../shop/screens/cart/cart.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'notifications.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _uploadDummyData(BuildContext context) async {
    try {
      final dataUploadService = Get.find<DataUploadService>();
      await dataUploadService.uploadAllData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = YHelperFunctions.isDarkMode(context);
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());

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
                      YSettingsMenuTile(
                        icon: Iconsax.notification,
                        title: 'Notifications',
                        subTitle: 'Set any kind of notification message',
                        onTap: () => Get.to(() => const NotificationScreen()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: YSizes.spaceBtwSections),

                Obx(() {
                  final isAdmin = userController.user.value.role == 'admin';
                  if (!isAdmin) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const YSectionHeading(
                        title: 'Admin Tools',
                        showActionButton: false,
                      ),
                      const SizedBox(height: YSizes.spaceBtwItems),
                      YRoundedContainer(
                        showBorder: true,
                        backgroundColor: dark
                            ? YColors.darkerGrey
                            : YColors.white,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            YSettingsMenuTile(
                              icon: Iconsax.discount_shape,
                              title: 'Create Coupon',
                              subTitle:
                                  'Create coupons for all users or one user',
                              onTap: () =>
                                  Get.to(() => const CreateCouponScreen()),
                            ),
                            const Divider(height: 1),
                            YSettingsMenuTile(
                              icon: Iconsax.discount_shape,
                              title: 'Coupons',
                              subTitle: 'View coupon list and usage details',
                              onTap: () =>
                                  Get.to(() => const CouponListScreen()),
                            ),
                            const Divider(height: 1),
                            YSettingsMenuTile(
                              icon: Iconsax.add_square,
                              title: 'Upload Product',
                              subTitle: 'Add new products to the store',
                              onTap: () =>
                                  Get.to(() => const UploadProductScreen()),
                            ),
                            const Divider(height: 1),
                            YSettingsMenuTile(
                              icon: Iconsax.cloud_add,
                              title: 'Upload Dummy Data',
                              subTitle: 'Load sample products and data',
                              onTap: () => _uploadDummyData(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: YSizes.spaceBtwSections),
                    ],
                  );
                }),

                YRoundedContainer(
                  showBorder: true,
                  backgroundColor: dark ? YColors.darkerGrey : YColors.white,
                  padding: const EdgeInsets.all(YSizes.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () =>
                          AuthenticationRepository.instance.logout(),
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
