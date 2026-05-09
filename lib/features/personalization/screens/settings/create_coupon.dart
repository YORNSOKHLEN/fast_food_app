import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/utils/constants/sizes.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../features/personalization/controllers/create_coupon_controller.dart';

class CreateCouponScreen extends StatelessWidget {
  const CreateCouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateCouponController());
    return Scaffold(
      appBar: AppBar(title: const Text('Create Coupon')),
      body: Padding(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller.code,
                  decoration: const InputDecoration(labelText: 'Code'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Code required' : null,
                ),
                const SizedBox(height: YSizes.spaceBtwItems),
                Obx(() => DropdownButtonFormField<String>(
                      initialValue: controller.type.value,
                      items: const [
                        DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                        DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                      ],
                      onChanged: (v) => controller.type.value = v ?? 'percentage',
                      decoration: const InputDecoration(labelText: 'Type'),
                    )),
                const SizedBox(height: YSizes.spaceBtwItems),
                TextFormField(
                  controller: controller.amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (10 for 10% or 5 for \$5)'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Amount required' : null,
                ),
                const SizedBox(height: YSizes.spaceBtwItems),
                TextFormField(
                  controller: controller.minOrder,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Min Order Amount (optional)'),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),
                TextFormField(
                  controller: controller.maxDiscount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max Discount (optional)'),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => Text(controller.expiresAt.value == null ? 'No expiry selected' : 'Expires: ${controller.expiresAt.value!.toLocal().toIso8601String().split('T').first}')),
                    ),
                    TextButton(onPressed: () => controller.pickExpiry(context), child: const Text('Pick Expiry')),
                  ],
                ),
                const SizedBox(height: YSizes.spaceBtwItems),
                TextFormField(
                  controller: controller.maxUses,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max Uses (optional)'),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),
                TextFormField(
                  controller: controller.perUser,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Per User Limit (optional)'),
                ),
                const SizedBox(height: YSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: () => controller.createCoupon(), child: const Text('Create Coupon')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

