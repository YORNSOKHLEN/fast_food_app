import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/common/widgets/product/favourite_icon/favourite_icon.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/curved_edges/curved_edges_widgets.dart';
import '../../../../../features/shop/models/product_model.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/product/image_controller.dart';

class YProductImageSlider extends StatelessWidget {
  const YProductImageSlider({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = YHelperFunctions.isDarkMode(context);
    final controller = Get.put(ImagesController());
    final images = controller.getAllProductImages(product);
    return YCurvedEdgesWidgets(
      child: Container(
        color: dark ? YColors.darkerGrey : YColors.light,
        child: Stack(
          children: [
            /// Main Image
            SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.all(YSizes.productImageRadius * 2),
                child: Center(
                  child: Obx(() {
                    final image = controller.selectedProductImage.value;
                    final isNetwork = image.startsWith('http');
                    return GestureDetector(
                      onTap: () => controller.showEnlargedImage(image),
                      child: isNetwork
                          ? CachedNetworkImage(
                              imageUrl: image,
                              progressIndicatorBuilder:
                                  (_, __, downloadProgress) =>
                                      CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                        color: YColors.buttonPrimary,
                                      ),
                            )
                          : Image.asset(image, fit: BoxFit.contain),
                    );
                  }),
                ),
              ),
            ),

            /// Image Slider
            // Positioned(
            //   bottom: 30,
            //   left: YSizes.defaultSpace,
            //   right: 0,
            //   child: SizedBox(
            //     height: 80,
            //     child: ListView.separated(
            //       itemCount: images.length,
            //       shrinkWrap: true,
            //       scrollDirection: Axis.horizontal,
            //       physics: const AlwaysScrollableScrollPhysics(),
            //       separatorBuilder: (_, __) =>
            //           const SizedBox(width: YSizes.spaceBtwItems),
            //       itemBuilder: (_, index) => Obx(() {
            //         final imageSelected =
            //             controller.selectedProductImage.value == images[index];
            //         final image = images[index];
            //         final isNetwork = image.startsWith('http');
            //         return YRoundedImage(
            //           width: 80,
            //           isNetworkImage: isNetwork,
            //           backgroundColor: dark ? YColors.dark : YColors.white,
            //           onPressed: () =>
            //               controller.selectedProductImage.value = images[index],
            //           border: Border.all(
            //             color: imageSelected
            //                 ? YColors.buttonPrimary
            //                 : Colors.transparent,
            //           ),
            //           padding: const EdgeInsets.all(YSizes.xs),
            //           imageUrl: images[index],
            //         );
            //       }),
            //     ),
            //   ),
            // ),

            // Appbar
            YAppBar(
              showBackArrow: true,
              action: [YFavouriteIcon(productId: product.id)],
            ),
          ],
        ),
      ),
    );
  }
}
