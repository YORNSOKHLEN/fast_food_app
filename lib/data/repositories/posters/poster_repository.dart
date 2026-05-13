import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/poster_model.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';

class PosterRepository extends GetxController {
  static PosterRepository get instance => Get.find();

  // Variables
  final _db = FirebaseFirestore.instance;

  // Get all active posters
  Future<List<PosterModel>> fetchPosters() async {
    try {
      final result = await _db
          .collection('Posters')
          .where('Active', isEqualTo: true)
          .get();
      return result.docs
          .map((documentSnapshot) => PosterModel.fromSnapshot(documentSnapshot))
          .toList();
    } on FirebaseException catch (e) {
      throw 'Firebase Exception: ${e.message}';
    } on FormatException catch (_) {
      throw 'Format Exception: Invalid data format';
    } on PlatformException catch (e) {
      throw 'Platform Exception: ${e.message}';
    } catch (e) {
      throw 'Something went wrong while fetching posters: $e';
    }
  }

  // Upload single poster to Firebase
  Future<void> uploadPoster(PosterModel poster) async {
    try {
      await _db
          .collection('Posters')
          .doc(poster.id)
          .set(poster.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again');
    }
  }

  // Upload Posters to Cloud Firebase
  Future<void> uploadDummyData(List<PosterModel> posters) async {
    try {
      // Upload all the Posters along with their Images
      final storage = Get.put(YFirebaseStorageService());

      // Loop through each poster
      for (int i = 0; i < posters.length; i++) {
        var poster = posters[i];
        // Get ImageData link from the local assets
        final file = await storage.getImageDataFromAssets(poster.imageUrl);

        // Upload Image and Get its URL
        final url = await storage.uploadImageData(
          'Posters',
          file,
          'poster_$i',
        );

        // Assign URL to Poster.imageUrl attribute
        poster.imageUrl = url;

        // Store Poster in Firestore
        await _db
            .collection("Posters")
            .doc(poster.id)
            .set(poster.toJson());
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
