import 'package:flutter/material.dart';
import 'package:fast_food/common/widgets/shimmers/shimmer.dart';

import '../../../utils/constants/sizes.dart';
import '../layouts/grid_layout.dart';

class YVerticalProductShimmer extends StatelessWidget {
  const YVerticalProductShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return YGridLayout(
      itemCount: itemCount,
      itemBuilder: (_, __) => SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            const YShimmerEffect(width: 180, height: 180),
            SizedBox(height: YSizes.spaceBtwItems),

            /// Text
            const YShimmerEffect(width: 160, height: 15),
            const SizedBox(height: YSizes.spaceBtwItems / 2),
            const YShimmerEffect(width: 110, height: 15),
          ],
        ),
      ),
    );
  }
}
