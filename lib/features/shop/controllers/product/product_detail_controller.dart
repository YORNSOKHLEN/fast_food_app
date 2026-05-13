import 'package:get/get.dart';

import 'cart_controller.dart';
import '../../models/product_model.dart';

class ProductDetailController extends GetxController {
  ProductDetailController(this.product);

  final ProductModel product;
  final isLoading = true.obs;
  late final CartController cartController;

  @override
  void onInit() {
    super.onInit();
    cartController = CartController.instance;
    cartController.updateAlreadyAddedProductCount(product);
    _hideLoader();
  }

  Future<void> _hideLoader() async {
    await Future.delayed(const Duration(milliseconds: 250));
    isLoading.value = false;
  }
}

