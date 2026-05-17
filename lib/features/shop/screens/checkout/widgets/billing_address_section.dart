import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fast_food/features/shop/controllers/checkout/billing_address_controller.dart';

import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/validators/validation.dart';

class YBillingAddressSection extends StatelessWidget {
  YBillingAddressSection({super.key});

  final controller = Get.put(BillingAddressController());

  void _showMapPicker() async {
    controller.setLoading(true);

    // Get current location
    final currentLocation = await controller.getCurrentLocation();
    if (currentLocation != null) {
      controller.updateLocation(currentLocation);
    }

    controller.setLoading(false);

    Get.dialog(
      AlertDialog(
        title: const Text('Select Delivery Location'),
        content: SizedBox(
          height: 400,
          width: 300,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.getSelectedLocation(),
              zoom: 15,
            ),
            onMapCreated: (mapCtrl) {
              // Map controller reference if needed
            },
            onTap: (LatLng latLng) {
              controller.updateLocation(latLng);
              Get.back();
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: controller.getSelectedLocation(),
                infoWindow: const InfoWindow(title: 'Selected Location'),
              ),
            },
            myLocationEnabled: controller.hasLocationPermission.value,
            myLocationButtonEnabled: controller.hasLocationPermission.value,
            zoomControlsEnabled: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => YSectionHeading(
            title: 'Shipping Address',
            buttonTitle: 'Change',
            onPressed: controller.isLoadingLocation.value ? null : _showMapPicker,
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
        TextFormField(
          controller: controller.phoneController,
          validator: (value) => YValidator.validatePhoneNumber(value),
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: const Icon(Iconsax.call),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            controller.updatePhoneNumber(value);
          },
        ),
      ],
    );
  }
}
