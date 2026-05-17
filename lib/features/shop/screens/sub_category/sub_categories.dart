import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/image_text_widgets/vertical_image_text.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product/product_cards/product_card_vertical.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../routes/routes.dart';
import '../../controllers/category_controller.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    return Obx(() {
      final matchedCategories = controller.allCategories
          .where((category) => category.id == categoryId)
          .toList();
      final category = matchedCategories.isNotEmpty
          ? matchedCategories.first
          : null;

      return Scaffold(
        appBar: YAppBar(
          title: Text(category?.name ?? 'Categories'),
          showBackArrow: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(YSizes.defaultSpace),
            child: Column(
              children: [
                // Banner
                // YRoundedImage(
                //   width: double.infinity,
                //   height: MediaQuery.of(context).size.height * 0.25,
                //   imageUrl: category?.image.isNotEmpty == true
                //       ? category!.image
                //       : YImage.banner1,
                //   applyImageRadius: true,
                //   fit: BoxFit.cover,
                // ),
                // const SizedBox(height: YSizes.spaceBtwSections),

                FutureBuilder<List<CategoryModel>>(
                  future: controller.getSubCategories(categoryId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Check if there are subcategories
                    final subCategories =
                        snapshot.data ?? const <CategoryModel>[];
                    if (subCategories.isNotEmpty) {
                      return SizedBox(
                        height: 110,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: subCategories.length,
                          itemBuilder: (_, index) {
                            final subCategory = subCategories[index];
                            return YVerticalImageText(
                              image: subCategory.image.isNotEmpty
                                  ? subCategory.image
                                  : YImage.iconStore,
                              title: subCategory.name,
                              onTap: () => Get.toNamed(
                                YRoutes.subCategories,
                                arguments: subCategory.id,
                              ),
                            );
                          },
                        ),
                      );
                    }

                    // If no subcategories, show products for this category instead
                    return FutureBuilder<List<ProductModel>>(
                      future: controller.getCategoryProducts(
                        categoryId: categoryId,
                        limit: -1,
                      ),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (productSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load products',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    final products = productSnapshot.data ?? const [];
                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          'No products found.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    return YGridLayout(
                      itemCount: products.length,
                      itemBuilder: (_, index) =>
                          ProductCardVertical(product: products[index]),
                    );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
