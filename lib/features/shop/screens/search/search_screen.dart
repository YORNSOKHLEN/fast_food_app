import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product/product_cards/product_card_vertical.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/search_controller.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = Get.put(ProductSearchController());
    final productCtrl = searchCtrl.productController;

    return Scaffold(
      appBar: YAppBar(
        showBackArrow: true,
        title: TextField(
          controller: searchCtrl.searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Iconsax.search_normal),
              onPressed: () {
                searchCtrl.performSearch(searchCtrl.searchController.text);
              },
            ),
          ),
          onChanged: (value) {
            searchCtrl.performSearch(value);
          },
          onSubmitted: (value) {
            searchCtrl.performSearch(value);
          },
        ),
      ),
      body: Obx(() {
        if (productCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (productCtrl.searchResults.isEmpty &&
            searchCtrl.searchController.text.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              searchCtrl.clearSearch();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.search_normal, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Search for products',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter a product name to search',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (productCtrl.searchResults.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              searchCtrl.performSearch(searchCtrl.searchController.text);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.search_normal_1, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with different keywords',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            searchCtrl.performSearch(searchCtrl.searchController.text);
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(YSizes.defaultSpace),
              child: Column(
                children: [
                  Text(
                    'Found ${productCtrl.searchResults.length} results',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: YSizes.spaceBtwSections),
                  YGridLayout(
                    itemCount: productCtrl.searchResults.length,
                    itemBuilder: (_, index) => ProductCardVertical(
                      product: productCtrl.searchResults[index],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
