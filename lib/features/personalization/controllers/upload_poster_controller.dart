import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/posters/poster_repository.dart';
import '../../../data/services/cloud_storage/firebase_storage_service.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../shop/models/poster_model.dart';

class UploadPosterController extends GetxController {
  static UploadPosterController get instance => Get.find();

  final formKey = GlobalKey<FormState>();
  final posterIdController = TextEditingController();

  Rxn<Uint8List> imageData = Rxn<Uint8List>();
  final isActive = true.obs;

  late PosterRepository _posterRepo;
  late YFirebaseStorageService _storageService;

  @override
  void onInit() {
    _posterRepo = PosterRepository.instance;
    _storageService = Get.put(YFirebaseStorageService());
    super.onInit();
  }

  @override
  void onClose() {
    posterIdController.dispose();
    super.onClose();
  }

  /// Pick poster image
  Future<void> pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 1024,
        maxWidth: 1024,
      );
      if (image != null) {
        final data = await image.readAsBytes();
        imageData.value = data;
      }
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Error', message: 'Failed to pick image: $e');
    }
  }

  /// Upload single poster
  Future<void> uploadPoster() async {
    if (!formKey.currentState!.validate()) return;

    if (imageData.value == null) {
      YLoaders.errorSnackBar(title: 'Error', message: 'Please pick a poster image');
      return;
    }

    try {
      YFullScreenLoader.openLoadingDialog('Uploading poster...', YImage.docerAnimation);

      // Upload image
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_poster.jpg';
      final imageUrl = await _storageService.uploadImageData(
        'Posters',
        imageData.value!,
        fileName,
      );

      // Create poster
      final posterId = posterIdController.text.trim().isEmpty
          ? 'poster_${DateTime.now().millisecondsSinceEpoch}'
          : posterIdController.text.trim();

      final poster = PosterModel(
        id: posterId,
        imageUrl: imageUrl,
        active: isActive.value,
      );

      // Save to Firestore
      await _posterRepo.uploadPoster(poster);

      YFullScreenLoader.stopLoading();

      YLoaders.successSnackBar(
        title: 'Success',
        message: 'Poster uploaded successfully!',
      );

      // Clear form
      _clearForm();
      Get.back();
    } catch (e) {
      YFullScreenLoader.stopLoading();
      YLoaders.errorSnackBar(title: 'Error', message: 'Failed to upload poster: $e');
    }
  }

  void _clearForm() {
    posterIdController.clear();
    imageData.value = null;
    isActive.value = true;
  }
}

