import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/common/widgets/product/product_cards/product_card_vertical.dart';
import 'package:fast_food/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:fast_food/features/shop/screens/home/widgets/home_categories.dart';
import 'package:fast_food/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:fast_food/utils/constants/sizes.dart';

import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../controllers/product/product_controller.dart';
import '../all_products/all_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchAllFeaturedProducts();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Header
            YPrimaryHeaderContainer(
              child: Column(
                children: [
                  // App Bar
                  YHomeAppBar(),
                  SizedBox(height: YSizes.spaceBtwSections),

                  //Searchbar
                  YSearchContainer(text: 'Search in Store'),
                  SizedBox(height: YSizes.spaceBtwSections),

                  // Categories and Heading
                  Padding(
                    padding: EdgeInsets.only(left: YSizes.defaultSpace),
                    child: Column(
                      children: [
                        // Heading
                        YSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: YSizes.spaceBtwItems),

                        // Categories
                        YHomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: YSizes.spaceBtwSections),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(YSizes.defaultSpace),
              child: Column(
                children: [
                  // Promo Slider
                  YPromoSlider(),
                  SizedBox(height: YSizes.spaceBtwSections),

                  // All Products
                  YSectionHeading(
                    title: 'All Products',
                    onPressed: () => Get.to(
                      () => AllProductsScreen(
                        title: 'All Products',
                        futureMethod: controller.fetchRandomProducts(limit: -1),
                      ),
                    ),
                  ),
                  SizedBox(height: YSizes.spaceBtwItems),
                  Obx(() {
                    return YGridLayout(
                      itemCount: controller.featuredProducts.length,
                      itemBuilder: (_, index) => ProductCardVertical(
                        product: controller.featuredProducts[index],
                      ),
                    );
                  }),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
