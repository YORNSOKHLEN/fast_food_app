import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fast_food/common/widgets/appbar/appbar.dart';
import 'package:fast_food/features/personalization/screens/profile/widgets/change_name.dart';
import 'package:fast_food/features/personalization/screens/profile/widgets/edit_profile_field.dart';
import 'package:fast_food/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:fast_food/common/widgets/shimmers/shimmer.dart';

import '../../../../common/widgets/images/circular_image.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _displayValue(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? 'Not set' : text;
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      appBar: YAppBar(showBackArrow: true, title: const Text('Profile')),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () async {
            await controller.fetchUserRecord();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(YSizes.defaultSpace),
              child: Column(
                children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage =
                          controller.user.value.profilePicture ?? '';
                      final image = networkImage.isNotEmpty
                          ? networkImage
                          : YImage.user;
                      return controller.imageUpLoading.value
                          ? YShimmerEffect(width: 80, height: 80, radius: 80)
                          : YCircularImage(
                              image: image,
                              width: 80,
                              height: 80,
                              padding: 0,
                              backgroundColor: Colors.transparent,
                              isNetworkImage: networkImage.isNotEmpty,
                            );
                    }),
                    TextButton(
                      onPressed: () => controller.uploadUserProfilePicture(),
                      child: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: YSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: YSizes.spaceBtwItems),

              // Heading Profile Info
              const YSectionHeading(
                title: 'Profile Information',
                showActionButton: false,
              ),
              const SizedBox(height: YSizes.spaceBtwItems),

              // Profile Info
              YProfileMenu(
                onPressed: () => Get.to(() => const ChangeName()),
                title: 'Name',
                value: _displayValue(controller.user.value.fullName),
              ),
              YProfileMenu(
                onPressed: () => Get.to(
                  () => EditProfileFieldScreen(
                    title: 'Edit Username',
                    label: 'Username',
                    fieldKey: 'Username',
                    initialValue: controller.user.value.username ?? '',
                    validator: (value) =>
                        YValidator.validateEmptyText('Username', value),
                  ),
                ),
                title: 'Username',
                value: _displayValue(controller.user.value.username),
              ),

              const SizedBox(height: YSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: YSizes.spaceBtwItems),

              // Heading Personal Info
              const YSectionHeading(
                title: 'Personal Information',
                showActionButton: false,
              ),
              const SizedBox(height: YSizes.spaceBtwItems),

              YProfileMenu(
                title: 'User ID',
                value: controller.user.value.id,
                icon: Iconsax.copy,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: controller.user.value.id),
                  );
                  YLoaders.successSnackBar(
                    title: 'Copied',
                    message: 'User ID copied to clipboard.',
                  );
                },
              ),
              YProfileMenu(
                title: 'Email',
                value: _displayValue(controller.user.value.email),
                onPressed: () => Get.to(
                  () => EditProfileFieldScreen(
                    title: 'Edit Email',
                    label: 'Email',
                    fieldKey: 'Email',
                    initialValue: controller.user.value.email ?? '',
                    keyboardType: TextInputType.emailAddress,
                    validator: YValidator.validateEmail,
                  ),
                ),
              ),
              YProfileMenu(
                title: 'Phone Number',
                value: _displayValue(controller.user.value.phoneNumber),
                onPressed: () => Get.to(
                  () => EditProfileFieldScreen(
                    title: 'Edit Phone Number',
                    label: 'Phone Number',
                    fieldKey: 'PhoneNumber',
                    initialValue: controller.user.value.phoneNumber ?? '',
                    keyboardType: TextInputType.phone,
                    validator: YValidator.validatePhoneNumber,
                  ),
                ),
              ),
              YProfileMenu(
                title: 'Gender',
                value: _displayValue(controller.user.value.gender),
                onPressed: () => Get.to(
                  () => EditProfileFieldScreen(
                    title: 'Edit Gender',
                    label: 'Gender',
                    fieldKey: 'Gender',
                    initialValue: controller.user.value.gender ?? '',
                    options: const [
                      'Male',
                      'Female',
                      'Other',
                      'Prefer not to say',
                    ],
                  ),
                ),
              ),
              YProfileMenu(
                title: 'Date of Birth',
                value: _displayValue(controller.user.value.dateOfBirth),
                onPressed: () => Get.to(
                  () => EditProfileFieldScreen(
                    title: 'Edit Date of Birth',
                    label: 'Date of Birth',
                    fieldKey: 'DateOfBirth',
                    initialValue: controller.user.value.dateOfBirth ?? '',
                    useDatePicker: true,
                    validator: (value) =>
                        YValidator.validateEmptyText('Date of Birth', value),
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: YSizes.spaceBtwItems),

              // Close account
              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: const Text(
                    'Close Account',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
