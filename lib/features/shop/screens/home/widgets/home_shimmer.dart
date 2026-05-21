import 'package:flutter/material.dart';

import '../../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../common/widgets/shimmers/vertical_product_shimmer.dart';
import '../../../../../utils/constants/sizes.dart';

class YHomeShimmer extends StatelessWidget {
  const YHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          YPrimaryHeaderContainer(
            child: Column(
              children: [
                const SizedBox(height: YSizes.spaceBtwSections),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: YSizes.defaultSpace,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const YShimmerEffect(width: 120, height: 16),
                      const YShimmerEffect(width: 40, height: 40, radius: 20),
                    ],
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwSections),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: YSizes.defaultSpace,
                  ),
                  child: YShimmerEffect(width: double.infinity, height: 52),
                ),
                const SizedBox(height: YSizes.spaceBtwSections),
                Padding(
                  padding: const EdgeInsets.only(left: YSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const YShimmerEffect(width: 160, height: 18),
                      const SizedBox(height: YSizes.spaceBtwItems),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: 6,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: YSizes.spaceBtwItems),
                          itemBuilder: (_, __) => const Column(
                            children: [
                              YShimmerEffect(
                                width: 55,
                                height: 55,
                                radius: 55,
                              ),
                              SizedBox(height: YSizes.spaceBtwItems / 2),
                              YShimmerEffect(width: 55, height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: YSizes.spaceBtwSections),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(YSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const YShimmerEffect(width: double.infinity, height: 190),
                const SizedBox(height: YSizes.spaceBtwSections),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    YShimmerEffect(width: 120, height: 18),
                    YShimmerEffect(width: 70, height: 14),
                  ],
                ),
                const SizedBox(height: YSizes.spaceBtwItems),
                const YVerticalProductShimmer(itemCount: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

