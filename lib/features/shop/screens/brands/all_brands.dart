import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/features/shop/controllers/brand_controller.dart';
import 'package:fast_food/features/shop/screens/brands/brand_products.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/brands/brand_card.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/shimmers/brand_shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/sizes.dart';

class AllBrandScreen extends StatelessWidget {
  const AllBrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brandController = Get.put(BrandController());
    return Scaffold(
      appBar: const YAppBar(title: Text('Brand'), showBackArrow: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await brandController.getFeaturedBrands();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(YSizes.defaultSpace),
            child: Column(
              children: [
                /// -- Heading
                const YSectionHeading(title: 'Brands', showActionButton: false),
                const SizedBox(height: YSizes.spaceBtwItems),

                /// -- Brands Grid
                Obx(() {
                  if (brandController.isLoading.value) {
                    return const YBrandsShimmer();
                  }
                  if (brandController.featuredBrands.isEmpty) {
                    return Center(
                      child: Text(
                        'No Data Found!',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.apply(color: Colors.white),
                      ),
                    );
                  }

                  return YGridLayout(
                    itemCount: brandController.allBrands.length,
                    mainAxisExtent: 80,
                    itemBuilder: (_, index) {
                      final brand = brandController.allBrands[index];
                      return YBrandCard(
                        showBorder: false,
                        onTab: () => Get.to(() => BrandProducts(brand: brand)),
                        brand: brand,
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
