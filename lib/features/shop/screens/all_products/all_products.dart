import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:fast_food/utils/helpers/cloud_helper_functions.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/product/sortable/sortable_products.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/all_product_controller.dart';
import '../../models/product_model.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({
    super.key,
    required this.title,
    this.query,
    this.futureMethod,
  });

  final String title;
  final Query? query;
  final Future<List<ProductModel>>? futureMethod;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllProductsController());

    return Scaffold(
      appBar: const YAppBar(title: Text('All Products'), showBackArrow: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await (futureMethod ?? controller.fetchProductsByQuery(query as Query<Map<String, dynamic>>?));
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(YSizes.defaultSpace),
            child: FutureBuilder(
              future:
                  futureMethod ??
                  controller.fetchProductsByQuery(
                    query as Query<Map<String, dynamic>>?,
                  ),
              builder: (context, snapshot) {
                const loader = YVerticalProductShimmer();
                final widget = YCloudHelperFunctions.checkMultiRecordState(
                  snapshot: snapshot,
                  loader: loader,
                );

                // Return
                if (widget != null) return widget;

                // Products found!
                final products = snapshot.data!;

                return YSortableProducts(products: products);
              },
            ),
          ),
        ),
      ),
    );
  }
}
