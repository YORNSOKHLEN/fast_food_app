import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/custom_shapes/containers/circular_container.dart';
import '../../../../../common/widgets/images/rounded_image.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/poster_controller.dart';

class YPromoSlider extends StatelessWidget {
  const YPromoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PosterController());
    return Obx(() {
      // Loader
      if (controller.isLoading.value) {
        return const YShimmerEffect(width: double.infinity, height: 190);
      }

      // No data found
      if (controller.posters.isEmpty) {
        return const Center(child: Text('No Posters Available'));
      } else {
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1,
                onPageChanged: (index, _) =>
                    controller.updatePageIndicator(index),
              ),
              items: controller.posters
                  .map(
                    (poster) => YRoundedImage(
                      imageUrl: poster.imageUrl,
                      // Let YRoundedImage auto-detect network vs asset by default.
                      // If you need to force network, pass isNetworkImage: true when necessary.
                      onPressed: () {},
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: YSizes.spaceBtwItems),
            Center(
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < controller.posters.length; i++)
                      YCircularContainer(
                        height: 4,
                        width: 20,
                        margin: EdgeInsets.only(right: 10),
                        backgroundColor:
                            controller.carouselCurrentIndex.value == i
                            ? YColors.primary
                            : YColors.grey,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    });
  }
}
