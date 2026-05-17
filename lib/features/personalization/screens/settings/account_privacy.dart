import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/account_privacy_controller.dart';

class AccountPrivacyScreen extends StatelessWidget {
  const AccountPrivacyScreen({super.key});

  Widget _buildPrivacyOption({
    required BuildContext context,
    required AccountPrivacyController controller,
    required IconData icon,
    required String title,
    required String subtitle,
    required Rx<bool> observableValue,
    required Function(bool) onChanged,
  }) {
    final dark = YHelperFunctions.isDarkMode(context);
    return Obx(() => YRoundedContainer(
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
                      icon,
                      color: YColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: YSizes.spaceBtwItems),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: observableValue.value,
            onChanged: onChanged,
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountPrivacyController>();
    final dark = YHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: YAppBar(
        showBackArrow: true,
        title: Text(
          'Account Privacy',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: ListView(
          children: [
            // Privacy Settings Heading
            const YSectionHeading(
              title: 'Privacy Settings',
              showActionButton: false,
            ),
            const SizedBox(height: YSizes.spaceBtwItems),

            // Profile Visibility
            _buildPrivacyOption(
              context: context,
              controller: controller,
              icon: Iconsax.eye,
              title: 'Profile Visibility',
              subtitle: 'Make your profile visible to other users',
              observableValue: controller.profileVisibility,
              onChanged: controller.toggleProfileVisibility,
            ),

            const SizedBox(height: YSizes.spaceBtwItems),

            // Share Activity Status
            _buildPrivacyOption(
              context: context,
              controller: controller,
              icon: Iconsax.activity,
              title: 'Activity Status',
              subtitle: 'Let others see when you\'re active',
              observableValue: controller.shareActivityStatus,
              onChanged: controller.toggleActivityStatus,
            ),

            const SizedBox(height: YSizes.spaceBtwSections),

            // Data Usage Heading
            const YSectionHeading(
              title: 'Data Usage',
              showActionButton: false,
            ),
            const SizedBox(height: YSizes.spaceBtwItems),

            // Data Collection
            _buildPrivacyOption(
              context: context,
              controller: controller,
              icon: Iconsax.chart,
              title: 'Data Collection',
              subtitle: 'Allow collection of usage data to improve service',
              observableValue: controller.dataCollection,
              onChanged: controller.toggleDataCollection,
            ),

            const SizedBox(height: YSizes.spaceBtwItems),

            // Marketing Communications
            _buildPrivacyOption(
              context: context,
              controller: controller,
              icon: Iconsax.message,
              title: 'Marketing Communications',
              subtitle: 'Receive marketing emails and offers',
              observableValue: controller.marketingCommunications,
              onChanged: controller.toggleMarketingCommunications,
            ),

            const SizedBox(height: YSizes.spaceBtwSections),

            // Connected Accounts Heading
            const YSectionHeading(
              title: 'Connected Accounts',
              showActionButton: false,
            ),
            const SizedBox(height: YSizes.spaceBtwItems),

            // Third Party Sharing
            _buildPrivacyOption(
              context: context,
              controller: controller,
              icon: Iconsax.share,
              title: 'Third Party Sharing',
              subtitle: 'Share data with trusted partners',
              observableValue: controller.thirdPartySharing,
              onChanged: controller.toggleThirdPartySaring,
            ),

            const SizedBox(height: YSizes.spaceBtwItems),

            // Connected Services
            YRoundedContainer(
              showBorder: true,
              backgroundColor: dark ? YColors.darkerGrey : YColors.white,
              padding: const EdgeInsets.all(YSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.link_circle,
                        color: YColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: YSizes.spaceBtwItems),
                      Expanded(
                        child: Text(
                          'Connected Apps',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Icon(Iconsax.arrow_right, size: 20, color: YColors.darkGrey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage apps with access to your account',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: YSizes.spaceBtwSections),

            // Privacy Policy and Terms
            YRoundedContainer(
              showBorder: false,
              backgroundColor: YColors.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(YSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.shield_tick,
                        color: YColors.primary,
                      ),
                      const SizedBox(width: YSizes.spaceBtwItems),
                      Expanded(
                        child: Text(
                          'Your Privacy Matters',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: YColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We are committed to protecting your privacy. For more information, please review our Privacy Policy and Terms of Service.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Open Privacy Policy
                          },
                          child: Text(
                            'Privacy Policy',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: YColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: YSizes.spaceBtwItems),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Open Terms of Service
                          },
                          child: Text(
                            'Terms of Service',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: YColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: YSizes.spaceBtwSections),

            // Delete Account
            YRoundedContainer(
              showBorder: false,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(YSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.trash,
                        color: Colors.red,
                      ),
                      const SizedBox(width: YSizes.spaceBtwItems),
                      Text(
                        'Delete Account',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Permanently delete your account and all associated data.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.deleteAccount,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.red,
                        ),
                      ),
                      child: Text(
                        'Delete Account',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: YSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }
}

