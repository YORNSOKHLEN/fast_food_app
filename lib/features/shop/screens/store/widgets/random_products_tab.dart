import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../../common/widgets/product/product_cards/product_card_vertical.dart';
import '../../../../../common/widgets/shimmers/vertical_product_shimmer.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/product_controller.dart';

class RandomProductsTab extends StatelessWidget {
  const RandomProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return RefreshIndicator(
      onRefresh: () => controller.loadRandomProducts(limit: 8),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(YSizes.defaultSpace),
            child: Column(
              children: [
                // YSectionHeading(
                //   title: 'Random Products',
                //   onPressed: () => Get.to(
                //     () => AllProductsScreen(
                //       title: 'Random Products',
                //       futureMethod: controller.fetchRandomProducts(limit: -1),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: YSizes.spaceBtwItems),
                Obx(() {
                  if (controller.isLoading.value && controller.randomProducts.isEmpty) {
                    return const YVerticalProductShimmer();
                  }

                  if (controller.randomProducts.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return YGridLayout(
                    itemCount: controller.randomProducts.length,
                    itemBuilder: (_, index) => ProductCardVertical(
                      product: controller.randomProducts[index],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

