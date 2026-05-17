import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/user_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());
    final dark = YHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: YAppBar(
        showBackArrow: true,
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: ListView(
          children: [
            // Order Notifications
            Obx(() => YRoundedContainer(
              showBorder: true,
              backgroundColor: dark ? YColors.darkerGrey : YColors.white,
              padding: const EdgeInsets.all(YSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.shopping_cart,
                              color: YColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: YSizes.spaceBtwItems),
                            Text(
                              'Order Updates',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Order status and delivery updates',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.orderNotifications.value,
                    onChanged: controller.toggleOrderNotifications,
                  ),
                ],
              ),
            )),

            const SizedBox(height: YSizes.spaceBtwItems),

            // Promotional Notifications
            Obx(() => YRoundedContainer(
              showBorder: true,
              backgroundColor: dark ? YColors.darkerGrey : YColors.white,
              padding: const EdgeInsets.all(YSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.discount_circle,
                              color: YColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: YSizes.spaceBtwItems),
                            Text(
                              'Promotions & Offers',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Special deals and discounts',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.promotionalNotifications.value,
                    onChanged: controller.togglePromotionalNotifications,
                  ),
                ],
              ),
            )),

            const SizedBox(height: YSizes.spaceBtwItems),

            // Email Notifications
            Obx(() => YRoundedContainer(
              showBorder: true,
              backgroundColor: dark ? YColors.darkerGrey : YColors.white,
              padding: const EdgeInsets.all(YSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.direct,
                              color: YColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: YSizes.spaceBtwItems),
                            Text(
                              'Email Notifications',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Receive notifications via email',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.emailNotifications.value,
                    onChanged: controller.toggleEmailNotifications,
                  ),
                ],
              ),
            )),

            const SizedBox(height: YSizes.spaceBtwItems),

            // SMS Notifications
            Obx(() => YRoundedContainer(
              showBorder: true,
              backgroundColor: dark ? YColors.darkerGrey : YColors.white,
              padding: const EdgeInsets.all(YSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.sms,
                              color: YColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: YSizes.spaceBtwItems),
                            Text(
                              'SMS Notifications',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Receive text messages',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.smsNotifications.value,
                    onChanged: controller.toggleSMSNotifications,
                  ),
                ],
              ),
            )),

            const SizedBox(height: YSizes.spaceBtwItems),

            // Push Notifications
            Obx(() => YRoundedContainer(
              showBorder: true,
              backgroundColor: dark ? YColors.darkerGrey : YColors.white,
              padding: const EdgeInsets.all(YSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Iconsax.notification,
                              color: YColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: YSizes.spaceBtwItems),
                            Text(
                              'Push Notifications',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'App notifications',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.pushNotifications.value,
                    onChanged: controller.togglePushNotifications,
                  ),
                ],
              ),
            )),

            const SizedBox(height: YSizes.spaceBtwSections),

            // Info Section
            YRoundedContainer(
              showBorder: false,
              backgroundColor: YColors.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(YSizes.md),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: YColors.primary,
                  ),
                  const SizedBox(width: YSizes.spaceBtwItems),
                  Expanded(
                    child: Text(
                      'You can manage your notification preferences here. Some notifications may be essential for order updates.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: YSizes.spaceBtwItems),

            Obx(() {
              final isAdmin = userController.user.value.role == 'admin';
              if (!isAdmin) return const SizedBox.shrink();

              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.showTestNotification,
                  icon: const Icon(Iconsax.notification),
                  label: const Text('Send Test Notification'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}


