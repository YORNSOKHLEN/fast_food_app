import 'package:flutter/material.dart';

import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';

class YBillingAddressSection extends StatefulWidget {
  const YBillingAddressSection({super.key});

  @override
  State<YBillingAddressSection> createState() => _YBillingAddressSectionState();
}

class _YBillingAddressSectionState extends State<YBillingAddressSection> {
  String? address = 'No shipping address selected';
  String? phoneNumber = '+855-96-280-7801';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YSectionHeading(
          title: 'Shipping Address',
          buttonTitle: 'Change',
          onPressed: () {
            // TODO: Navigate to Map Picker if you want editable address
          },
        ),
        Text(address ?? '', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: YSizes.spaceBtwItems / 2),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.grey, size: 16),
            const SizedBox(width: YSizes.spaceBtwItems),
            Text(
              phoneNumber ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
