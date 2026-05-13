import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/product_model.dart';
import '../../services/cloud_storage/firebase_storage_service.dart';

/// Repository for managing product-related data and operations.
class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  /// Firestore instance for database interactions.
  final _db = FirebaseFirestore.instance;

  /// Get limited featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      // Fetches documents where 'IsFeatured' is true, limited to 4 items
      final snapshot = await _db
          .collection('Products')
          .where('IsFeatured', isEqualTo: true)
          .limit(4)
          .get();

      // Maps the Firestore documents into a List of ProductModel
      return snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Get products ordered by how many times they were ordered.
  Future<List<ProductModel>> getPopularProducts({int limit = 4}) async {
    try {
      final snapshot = await _db
          .collection('Products')
          .orderBy('OrderCount', descending: true)
          .limit(limit)
          .get();

      final popularProducts = snapshot.docs
          .map((e) => ProductModel.fromSnapshot(e))
          .where((product) => product.orderCount > 0)
          .toList();

      return popularProducts;
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Get Products based on the Brand
  Future<List<ProductModel>> fetchProductsByQuery(Query query) async {
    try {
      final querySnapshot = await query.get();

      final List<ProductModel> productList = querySnapshot.docs
          .map(
            (doc) => ProductModel.fromQuerySnapshot(
              doc as QueryDocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();

      return productList;
    } on FirebaseException catch (e) {
      throw e.message ?? 'Firebase error occurred';
    } on PlatformException catch (e) {
      throw e.message ?? 'Platform error occurred';
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<List<ProductModel>> getProductsForBrand({
    required String brandId,
    int limit = -1,
  }) async {
    try {
      final querySnapshot = limit == -1
          ? await _db
                .collection('Products')
                .where('Brand.Id', isEqualTo: brandId)
                .get()
          : await _db
                .collection('Products')
                .where('Brand.Id', isEqualTo: brandId)
                .limit(limit)
                .get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint('getProductsForBrand error: $e');
      return [];
    }
  }

  Future<List<ProductModel>> getProductsForCategory({
    required String categoryId,
    int limit = 4,
  }) async {
    try {
      final productsQuery = limit == -1
          ? await _db
                .collection('Products')
                .where('CategoryId', isEqualTo: categoryId)
                .get()
          : await _db
                .collection('Products')
                .where('CategoryId', isEqualTo: categoryId)
                .limit(limit)
                .get();

      final products = productsQuery.docs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();

      products.sort((a, b) => b.orderCount.compareTo(a.orderCount));
      return products;
    } catch (e) {
      debugPrint('getProductsForCategory error: $e');
      return [];
    }
  }

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _db.collection('Products').get();
      return snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Get random products with optional limit.
  Future<List<ProductModel>> getRandomProducts({int limit = 6}) async {
    try {
      final products = await getAllProducts();
      if (products.isEmpty) return [];

      products.shuffle(Random());
      if (limit <= 0 || limit >= products.length) return products;

      return products.take(limit).toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Fetch a single product by its document id.
  Future<ProductModel> getProductById(String productId) async {
    try {
      final doc = await _db.collection('Products').doc(productId).get();
      if (!doc.exists) {
        throw Exception('Product not found');
      }
      return ProductModel.fromSnapshot(doc);
    } catch (e) {
      debugPrint('getProductById error: $e');
      rethrow;
    }
  }

  /// Get Products based on the Query
  Future<List<ProductModel>> getFavouriteProducts(
    List<String> productIds,
  ) async {
    try {
      final snapshot = await _db
          .collection('Products')
          .where(FieldPath.documentId, whereIn: productIds)
          .get();
      return snapshot.docs
          .map((querySnapshot) => ProductModel.fromSnapshot(querySnapshot))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Search products by title
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _db.collection('Products').get();
      final allProducts = snapshot.docs
          .map((e) => ProductModel.fromSnapshot(e))
          .toList();

      // Filter products by title (case-insensitive)
      return allProducts
          .where(
            (product) =>
                product.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error occurred');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again.');
    }
  }

  Future<String?> safeUploadImage(
    YFirebaseStorageService storage,
    String path,
    Uint8List data,
    String name,
  ) async {
    try {
      return await storage.uploadImageData(path, data, name);
    } catch (e) {
      debugPrint('Upload failed for $name: $e');
      return null; // return null if failed
    }
  }

  /// Upload dummy data to the Cloud Firebase
  Future<void> uploadDummyData(List<ProductModel> products) async {
    try {
      final storage = Get.put(YFirebaseStorageService());
      final firestore = FirebaseFirestore.instance;

      for (final product in products) {
        /// ---------------- THUMBNAIL ----------------
        final thumbData = await storage.getImageDataFromAssets(
          product.thumbnail,
        );
        final thumbUrl = await storage.uploadImageData(
          'Products/Thumbnails',
          thumbData,
          product.thumbnail,
        );
        product.thumbnail = thumbUrl;

        /// ---------------- PRODUCT IMAGES ----------------
        if (product.images != null && product.images!.isNotEmpty) {
          final List<String> uploadedImages = [];

          for (final image in product.images!) {
            final imageData = await storage.getImageDataFromAssets(image);
            final imageUrl = await storage.uploadImageData(
              'Products/Images',
              imageData,
              image,
            );
            uploadedImages.add(imageUrl);
          }

          product.images = uploadedImages;
        }


        /// ---------------- SAVE TO FIRESTORE ----------------
        await firestore
            .collection('Products')
            .doc(product.id)
            .set(product.toJson());
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Save a single product to Firestore (used for admin uploads)
  Future<void> saveProduct(ProductModel product) async {
    try {
      await _db.collection('Products').doc(product.id).set(product.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firebase error when saving product');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform error when saving product');
    } catch (e) {
      throw Exception('Something went wrong. Please try again');
    }
  }
}
