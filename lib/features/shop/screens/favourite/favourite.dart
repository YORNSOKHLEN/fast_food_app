import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/icons/circular_icon.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/loaders/animation_loader.dart';
import '../../../../common/widgets/product/product_cards/product_card_vertical.dart';
import '../../../../common/widgets/shimmers/vertical_product_shimmer.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/product/favourite_controller.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FavouriteController.instance;
    return Scaffold(
      appBar: YAppBar(
        title: Text(
          'Favorites',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        action: [
          YCircularIcon(
            icon: Iconsax.add,
            onPressed: () {
              final navController = Get.find<NavigationController>();
              navController.selectedIndex.value = 0;
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.favoriteProducts();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(YSizes.defaultSpace),
            child: Obx(
              () {
                return FutureBuilder(
                  future: controller.favoriteProducts(),
                  builder: (context, snapshot) {
                    /// Nothing Found Widget
                    final emptyWidget = YAnimationLoaderWidget(
                      text: 'Whoops! Favorites is Empty...',
                      animation: YImage.docerAnimation,
                      showAction: true,
                      actionText: 'Let\'s add some',
                      onActionPressed: () {
                        final navController =
                            Get.find<NavigationController>();
                        navController.selectedIndex.value =
                            0; // Switch to Store tab
                      },
                    );

                    const loader = YVerticalProductShimmer(itemCount: 6);
                    final widget = YCloudHelperFunctions
                        .checkMultiRecordState(
                      snapshot: snapshot,
                      loader: loader,
                      nothingFound: emptyWidget,
                    );
                    if (widget != null) return widget;

                    final products = snapshot.data!;
                    return YGridLayout(
                      itemCount: products.length,
                      itemBuilder: (_, index) => ProductCardVertical(
                        product: products[index],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

