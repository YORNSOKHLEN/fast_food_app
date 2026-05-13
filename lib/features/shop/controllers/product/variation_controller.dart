import 'package:get/get.dart';

import '../../models/product_variation_model.dart';

class VariationController extends GetxController {
  static VariationController get instance => Get.find();

  /// -- Variables
  RxMap selectedAttributes = {}.obs;
  RxString variationStockStatus = ''.obs;
  Rx<ProductVariationModel> selectedVariation =
      ProductVariationModel.empty().obs;

  /// -- Select Attribute
  void onAttributeSelected(
    dynamic product,
    attributeName,
    attributeValue,
  ) {
    selectedAttributes[attributeName] = attributeValue;
    selectedVariation.value = ProductVariationModel.empty();
    variationStockStatus.value = '';
  }

  /// -- Check Product Variation Stock Status
  void getProductVariationStockStatus() {
    // Stock is no longer tracked; consider a variation available if it has an id
    variationStockStatus.value = selectedVariation.value.id.isNotEmpty
        ? 'Available'
        : '';
  }

  /// -- Reset Selected Attributes when switching products
  void resetSelectedAttributes() {
    selectedAttributes.clear();
    variationStockStatus.value = '';
    selectedVariation.value = ProductVariationModel.empty();
  }
}
