import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/utils/constants/sizes.dart';

import '../../../../features/personalization/controllers/upload_poster_controller.dart';

class UploadPosterScreen extends StatelessWidget {
  const UploadPosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadPosterController());
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Poster')),
      body: Padding(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Poster ID (Optional)
                TextFormField(
                  controller: controller.posterIdController,
                  decoration: const InputDecoration(
                    labelText: 'Poster ID (optional)',
                    hintText: 'Leave empty for auto-generated ID',
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Active Status
                Obx(() => CheckboxListTile(
                  value: controller.isActive.value,
                  onChanged: (v) => controller.isActive.value = v ?? true,
                  title: const Text('Active'),
                )),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Poster Image
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.pickImage(),
                    child: const Text('Pick Poster Image'),
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Display Selected Image
                Obx(() {
                  if (controller.imageData.value == null) {
                    return const Text('No poster image selected');
                  }
                  return Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(
                      controller.imageData.value!,
                      fit: BoxFit.cover,
                    ),
                  );
                }),
                const SizedBox(height: YSizes.spaceBtwSections),

                /// Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.uploadPoster(),
                    child: const Text('Upload Poster'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

