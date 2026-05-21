import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/cart_item_model.dart';
import '../../../features/shop/models/order_model.dart';
import '../authentication/authentication_repository.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  /// Variables
  final _db = FirebaseFirestore.instance;

  /* ------------------ FUNCTIONS ------------------ */

  /// Get all orders related to current User
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) {
        throw 'Unable to find user information. Try again in few minutes.';
      }

      final result = await _db
          .collection('Users')
          .doc(userId)
          .collection('Orders')
          .get();
      final orders = result.docs
          .map((documentSnapshot) => OrderModel.fromSnapshot(documentSnapshot))
          .toList();

      // Sort orders from newest to oldest
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      return orders;
    } catch (e) {
      throw 'Something went wrong while fetching Order Information. Try again later';
    }
  }

  /// Store new user order
  Future<void> saveOrder(OrderModel order, String userId) async {
    try {
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Orders')
          .add(order.toJson());
    } catch (e) {
      throw 'Something went wrong while saving Order Information. Try again later';
    }
  }

  /// Increase product order counters for popularity ranking.
  Future<void> incrementProductOrderCounts(List<CartItemModel> items) async {
    try {
      if (items.isEmpty) return;

      final batch = _db.batch();

      for (final item in items) {
        if (item.productId.isEmpty || item.quantity <= 0) continue;

        final productRef = _db.collection('Products').doc(item.productId);
        batch.set(productRef, {
          'OrderCount': FieldValue.increment(item.quantity),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      throw 'Something went wrong while updating product popularity. Try again later';
    }
  }
}
