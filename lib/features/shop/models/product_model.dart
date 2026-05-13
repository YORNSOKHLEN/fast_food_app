import 'package:cloud_firestore/cloud_firestore.dart';

import 'brand_model.dart';

class ProductModel {
  String id;
  int orderCount;
  String? sku;
  double price;
  String title;
  DateTime? date;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? brandId;
  String? description;
  String? categoryId;
  List<String>? images;
  String productType;
  DateTime? salePriceDeadline;

  ProductModel({
    required this.id,
    required this.title,
    this.orderCount = 0,
    required this.price,
    required this.thumbnail,
    this.productType = 'single',
    this.sku,
    this.brand,
    this.brandId,
    this.date,
    this.images,
    this.salePrice = 0.0,
    this.isFeatured,
    this.categoryId,
    this.description,
    this.salePriceDeadline,
  });

  /// Create Empty func for clean code
  static ProductModel empty() => ProductModel(
    id: '',
    title: '',
    orderCount: 0,
    price: 0,
    thumbnail: '',
    productType: '',
  );

  /// Json Format
  Map<String, Object?> toJson() {
    return {
      'SKU': sku,
      'Title': title,
      'OrderCount': orderCount,
      'Price': price,
      'Images': images ?? [],
      'Thumbnail': thumbnail,
      'SalePrice': salePrice,
      'SalePriceDeadline': salePriceDeadline,
      'IsFeatured': isFeatured,
      'CategoryId': categoryId,
      'BrandId': brandId,
      'Brand': brand?.toJson(),
      'Description': description,
      'ProductType': productType,
    };
  }

  /// Map Json oriented document snapshot from Firebase to Model
  factory ProductModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() == null) return ProductModel.empty();
    final data = document.data()!;
    return ProductModel(
      id: document.id,
      sku: data['SKU'],
      title: data['Title'],
      orderCount: (data['OrderCount'] as num?)?.toInt() ?? 0,
      isFeatured: data['IsFeatured'] ?? false,
      price: double.parse((data['Price'] ?? 0.0).toString()),
      salePrice: double.parse((data['SalePrice'] ?? 0.0).toString()),
      thumbnail: data['Thumbnail'] ?? '',
      categoryId: data['CategoryId'] ?? '',
      brandId: data['BrandId'],
      description: data['Description'] ?? '',
      productType: data['ProductType'] ?? '',
      brand: BrandModel.fromJson(data['Brand']),
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      salePriceDeadline: data['SalePriceDeadline'] != null
          ? (data['SalePriceDeadline'] is DateTime
              ? data['SalePriceDeadline'] as DateTime
              : (data['SalePriceDeadline'] as dynamic).toDate())
          : null,
    );
  }

  /// Map Firestore QueryDocumentSnapshot to ProductModel
  factory ProductModel.fromQuerySnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return ProductModel(
      id: document.id,
      sku: data['SKU']?.toString() ?? '',
      title: data['Title']?.toString() ?? '',
      orderCount: (data['OrderCount'] as num?)?.toInt() ?? 0,
      isFeatured: data['IsFeatured'] ?? false,
      price: (data['Price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (data['SalePrice'] as num?)?.toDouble() ?? 0.0,
      thumbnail: data['Thumbnail']?.toString() ?? '',
      categoryId: data['CategoryId']?.toString() ?? '',
      brandId: data['BrandId'],
      description: data['Description']?.toString() ?? '',
      productType: data['ProductType']?.toString() ?? '',
      brand: BrandModel.fromJson(data['Brand']),
      images: data['Images'] != null ? List<String>.from(data['Images']) : [],
      salePriceDeadline: data['SalePriceDeadline'] != null
          ? (data['SalePriceDeadline'] is DateTime
              ? data['SalePriceDeadline'] as DateTime
              : (data['SalePriceDeadline'] as dynamic).toDate())
          : null,
    );
  }
}
