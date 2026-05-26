import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/order/order_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../product/coupon_controller.dart';
import 'cart_controller.dart';
import 'checkout_controller.dart';
import '../../screens/checkout/payway_payment_screen.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  /// Variables
  final cartController = CartController.instance;

  // final addressController = AddressController.instance;
  final checkoutController = CheckoutController.instance;
  final orderRepository = Get.put(OrderRepository());

  /// Fetch user's order history
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userOrders = await orderRepository.fetchUserOrders();
      return userOrders;
    } catch (e) {
      YLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

    /// Add methods for order processing
    Future<void> processOrder(
      double totalAmount, {
      List<CartItemModel>? items,
      bool clearCartAfterOrder = true,
    }) async {
      try {
        // Get user authentication Id
        final userId = AuthenticationRepository.instance.authUser!.uid;
        if (userId.isEmpty) {
          YLoaders.hideSnackBar();
          YLoaders.errorSnackBar(
            title: 'Error',
            message: 'User not authenticated. Please login again.',
          );
          return;
        }

        final paymentMethod = checkoutController.selectedPaymentMethod.value.name;

        // Save order directly for the selected payment method.
        await _saveOrderAndComplete(
          totalAmount,
          userId,
          items,
          clearCartAfterOrder,
          paymentMethod,
        );
      } catch (e) {
        YLoaders.hideSnackBar();
        YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      }
    }


  /// Save order and show completion screen
  Future<void> _saveOrderAndComplete(
    double totalAmount,
    String userId,
    List<CartItemModel>? items,
    bool clearCartAfterOrder,
    String paymentMethod, {
    String? orderId,
  }) async {
    try {
      // Show brief processing toast
      YLoaders.customToast(message: 'Processing your order');

      final orderItems = items ?? cartController.cartItems.toList();
      final totalItemCount = orderItems.fold<int>(0, (sum, item) => sum + item.quantity);

      // Generate order if not already generated (for QR)
      final finalOrderId = orderId ?? UniqueKey().toString();

      // Create order model
      final order = OrderModel(
        id: finalOrderId,
        userId: userId,
        status: OrderStatus.pending,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        paymentMethod: paymentMethod,
        items: orderItems,
      );

      // Save the order to Firestore
      await orderRepository.saveOrder(order, userId);

      // If a coupon was applied, claim its usage for this order.
      try {
        if (Get.isRegistered<CouponController>()) {
          final couponController = Get.find<CouponController>();
          if (couponController.appliedCoupon.value != null) {
            await couponController.claimCouponForOrder(order.id);
          }
        }
      } catch (e) {
        YLoaders.hideSnackBar();
        YLoaders.errorSnackBar(
          title: 'Coupon Error',
          message: e.toString(),
        );
        return;
      }

      // Update product popularity counters based on purchased quantities.
      await orderRepository.incrementProductOrderCounts(orderItems);

      // Show a real device notification for the successful order.
      // await YNotificationService.instance.showOrderSuccessNotification(
      //   orderId: order.id,
      //   totalAmount: totalAmount,
      //   itemCount: totalItemCount,
      // );

      // CLEAR CART AFTER SUCCESSFUL CHECKOUT
      if (clearCartAfterOrder) {
        cartController.clearCart();
      }

      // Remove loader before showing the QR payment screen
      YLoaders.hideSnackBar();

      // Show Payway QR payment screen
      Get.off(
        () => PaywayPaymentScreen(
          orderId: finalOrderId,
          totalAmount: totalAmount,
          itemCount: totalItemCount,
          paymentMethod: paymentMethod,
        ),
      );
    } catch (e) {
      YLoaders.hideSnackBar();
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
