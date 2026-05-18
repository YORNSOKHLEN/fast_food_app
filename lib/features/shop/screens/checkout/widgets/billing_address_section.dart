import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fast_food/features/shop/controllers/checkout/billing_address_controller.dart';

import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/validators/validation.dart';

class YBillingAddressSection extends StatelessWidget {
  const YBillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is registered. Some flows navigate to this screen
    // without the global ShopBindings, so register it lazily if missing.
    final controller = Get.isRegistered<BillingAddressController>()
        ? Get.find<BillingAddressController>()
        : Get.put(BillingAddressController());

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => YSectionHeading(
              title: 'Shipping Address',
              buttonTitle: 'Change',
              onPressed: controller.isLoadingLocation.value ? null : controller.showMapPicker,
            ),
          ),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Text(
                    controller.isLoadingLocation.value
                        ? 'Getting your location...'
                        : controller.address.value,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (controller.isLoadingLocation.value)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const SizedBox(height: YSizes.spaceBtwItems),

          /// Phone Number Input
          Obx(
            () => TextFormField(
              controller: controller.phoneController,
              validator: (value) => YValidator.validatePhoneNumber(value),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Iconsax.call),
                errorText: controller.phoneErrorMessage.value.isEmpty 
                  ? null 
                  : controller.phoneErrorMessage.value,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                controller.updatePhoneNumber(value);
                // Validate on change
                controller.formKey.currentState?.validate();
              },
            ),
          ),
        ],
      ),
    );
  }
}
