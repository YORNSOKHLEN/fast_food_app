import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/product/product_repository.dart';
import '../../../data/services/cloud_storage/firebase_storage_service.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../../shop/models/brand_model.dart';
import '../../shop/models/product_model.dart';

class UploadProductController extends GetxController {
  static UploadProductController get instance => Get.find();

  final formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final productId = TextEditingController();
  final price = TextEditingController();
  final salePrice = TextEditingController();
  final description = TextEditingController();
  final categoryId = TextEditingController();
  final brandId = TextEditingController();
  final brandName = TextEditingController();

  final productType = 'single'.obs;
  final isFeatured = false.obs;
  final salePriceDeadline = Rxn<DateTime>();

  Rxn<Uint8List> thumbnailData = Rxn<Uint8List>();
  RxList<Uint8List> imageDataList = <Uint8List>[].obs;

  late ProductRepository _productRepo;
  late YFirebaseStorageService _storageService;

  @override
  void onInit() {
    _productRepo = ProductRepository.instance;
    _storageService = Get.put(YFirebaseStorageService());
    super.onInit();
  }

  @override
  void onClose() {
    title.dispose();
    productId.dispose();
    price.dispose();
    salePrice.dispose();
    description.dispose();
    categoryId.dispose();
    brandId.dispose();
    brandName.dispose();
    super.onClose();
  }

  /// Pick thumbnail image
  Future<void> pickThumbnail() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );
      if (image != null) {
        final data = await image.readAsBytes();
        thumbnailData.value = data;
      }
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Error', message: 'Failed to pick thumbnail: $e');
    }
  }

  /// Pick gallery images
  Future<void> pickGalleryImages() async {
    try {
      final List<XFile> images = await ImagePicker().pickMultiImage(
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );
      if (images.isNotEmpty) {
        for (final image in images) {
          final data = await image.readAsBytes();
          imageDataList.add(data);
        }
      }
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Error', message: 'Failed to pick images: $e');
    }
  }

  /// Remove image from gallery
  void removeGalleryImage(int index) {
    if (index >= 0 && index < imageDataList.length) {
      imageDataList.removeAt(index);
    }
  }

  /// Pick sale price deadline
  Future<void> pickSalePriceDeadline(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      salePriceDeadline.value = picked;
    }
  }

  /// Upload single product
  Future<void> uploadProduct() async {
    if (!formKey.currentState!.validate()) return;

    if (thumbnailData.value == null) {
      YLoaders.errorSnackBar(title: 'Error', message: 'Please pick a thumbnail image');
      return;
    }

    try {
      YLoaders.customToast(message: 'Uploading product...');

      // Upload thumbnail
      final thumbUrl = await _storageService.uploadImageData(
        'Products/Thumbnails',
        thumbnailData.value!,
        '${DateTime.now().millisecondsSinceEpoch}_thumb.jpg',
      );

      // Upload gallery images
      final List<String> imageUrls = [];
      for (int i = 0; i < imageDataList.length; i++) {
        final url = await _storageService.uploadImageData(
          'Products/Images',
          imageDataList[i],
          '${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        imageUrls.add(url);
      }

      // Create brand object
      final brand = BrandModel(
        id: brandId.text.trim().isEmpty ? 'b_${DateTime.now().millisecondsSinceEpoch}' : brandId.text.trim(),
        name: brandName.text.trim(),
        image: '',
      );

      // Create product
       final product = ProductModel(
         id: productId.text.trim().isEmpty
             ? 'p_${DateTime.now().millisecondsSinceEpoch}'
             : productId.text.trim(),
         title: title.text.trim(),
         price: double.tryParse(price.text.trim()) ?? 0.0,
        thumbnail: thumbUrl,
        productType: productType.value,
        salePrice: salePrice.text.trim().isEmpty ? 0.0 : double.tryParse(salePrice.text.trim()) ?? 0.0,
        salePriceDeadline: salePriceDeadline.value,
        description: description.text.trim().isEmpty ? null : description.text.trim(),
        categoryId: categoryId.text.trim().isEmpty ? null : categoryId.text.trim(),
        isFeatured: isFeatured.value,
        brand: brand,
        images: imageUrls.isEmpty ? null : imageUrls,
      );

      // Save to Firestore
      await _productRepo.saveProduct(product);

      YLoaders.hideSnackBar();

      YLoaders.successSnackBar(
        title: 'Success',
        message: 'Product uploaded successfully!',
      );

      // Clear form
      _clearForm();
      Get.back();
    } catch (e) {
      YLoaders.hideSnackBar();
      YLoaders.errorSnackBar(title: 'Error', message: 'Failed to upload product: $e');
    }
  }

  void _clearForm() {
    title.clear();
    productId.clear();
    price.clear();
    salePrice.clear();
    description.clear();
    categoryId.clear();
    brandId.clear();
    brandName.clear();
    isFeatured.value = false;
    salePriceDeadline.value = null;
    thumbnailData.value = null;
    imageDataList.clear();
  }
}

