import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/utils/constants/sizes.dart';

import '../../../../features/personalization/controllers/upload_product_controller.dart';

class UploadProductScreen extends StatelessWidget {
  const UploadProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadProductController());
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Product')),
      body: Padding(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Product ID
                TextFormField(
                  controller: controller.productId,
                  decoration: const InputDecoration(
                    labelText: 'Product ID (optional)',
                    hintText: 'Leave empty for auto-generated ID',
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Title
                TextFormField(
                  controller: controller.title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Price
                TextFormField(
                  controller: controller.price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Price required' : null,
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Sale Price
                TextFormField(
                  controller: controller.salePrice,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Sale Price (optional)',
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Sale Price Deadline
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.salePriceDeadline.value == null
                              ? 'No deadline selected'
                              : 'Deadline Discount: ${controller.salePriceDeadline.value!.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          controller.pickSalePriceDeadline(context),
                      child: const Text('Pick Deadline'),
                    ),
                  ],
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Description
                TextFormField(
                  controller: controller.description,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Category ID
                TextFormField(
                  controller: controller.categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category ID (optional)',
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Brand ID
                TextFormField(
                  controller: controller.brandId,
                  decoration: const InputDecoration(
                    labelText: 'Brand ID (optional)',
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Brand Name
                TextFormField(
                  controller: controller.brandName,
                  decoration: const InputDecoration(labelText: 'Brand Name'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Brand name required'
                      : null,
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Is Featured
                Obx(
                  () => CheckboxListTile(
                    value: controller.isFeatured.value,
                    onChanged: (v) => controller.isFeatured.value = v ?? false,
                    title: const Text('Is Featured'),
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Thumbnail Image
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.pickThumbnail(),
                    child: const Text('Pick Thumbnail Image'),
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),
                Obx(() {
                  if (controller.thumbnailData.value == null) {
                    return const Text('No thumbnail selected');
                  }
                  return Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(
                      controller.thumbnailData.value!,
                      fit: BoxFit.cover,
                    ),
                  );
                }),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Gallery Images
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.pickGalleryImages(),
                    child: const Text('Pick Gallery Images'),
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// Display Gallery Images
                Obx(() {
                  if (controller.imageDataList.isEmpty) {
                    return const Text('No gallery images selected');
                  }
                  return SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.imageDataList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.memory(
                                  controller.imageDataList[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      controller.removeGalleryImage(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: YSizes.spaceBtwSections),

                /// Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.uploadProduct(),
                    child: const Text('Upload Product'),
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
