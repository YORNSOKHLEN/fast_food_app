import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/banner_model.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';

class BannerRepository extends GetxController {
  static BannerRepository get instance => Get.find();

  // Variables
  final _db = FirebaseFirestore.instance;

  // Get all poster
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final result = await _db
          .collection('Banners')
          .where('Active', isEqualTo: true)
          .get();
      return result.docs
          .map((documentSnapshot) => BannerModel.fromSnapshot(documentSnapshot))
          .toList();
    } on FirebaseException catch (e) {
      throw 'Firebase Exception: ${e.message}';
    } on FormatException catch (_) {
      throw 'Format Exception: Invalid data format';
    } on PlatformException catch (e) {
      throw 'Platform Exception: ${e.message}';
    } catch (e) {
      throw 'Something went wrong while fetching poster: $e';
    }
  }

  // Upload Banners to Cloud Firebase
  Future<void> uploadDummyData(List<BannerModel> banners) async {
    try {
      // Upload all the Banners along with their Images
      final storage = Get.put(YFirebaseStorageService());

      // Loop through each banner
      for (var banner in banners) {
        // Get ImageData link from the local assets
        final file = await storage.getImageDataFromAssets(banner.imageUrl);

        // Upload Image and Get its URL
        final url = await storage.uploadImageData(
          'Banners',
          file,
          'banner_${banners.indexOf(banner)}',
        );

        // Assign URL to Banner.imageUrl attribute
        banner.imageUrl = url;

        // Store Banner in Firestore
        await _db
            .collection("Banners")
            .doc('banner_${banners.indexOf(banner)}')
            .set(banner.toJson());
      }
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again');
    }
  }
}
