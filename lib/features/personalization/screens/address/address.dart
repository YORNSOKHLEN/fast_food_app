import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fast_food/features/personalization/screens/address/widgets/single_address.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import 'add_new_address.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: YColors.buttonPrimary,
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        child: const Icon(Iconsax.add, color: YColors.white),
      ), // FloatingActionButton
      appBar: YAppBar(
        showBackArrow: true,
        title: Text(
          'Addresses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ), // TAppBar
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh addresses
          await Future.delayed(const Duration(seconds: 1));
        },
        child: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(YSizes.defaultSpace),
            child: Column(
              children: [
                YSingleAddress(selectedAddress: true),
                YSingleAddress(selectedAddress: false),
              ],
            ), // Column
          ),
        ),
      ),
    );
  }
}
