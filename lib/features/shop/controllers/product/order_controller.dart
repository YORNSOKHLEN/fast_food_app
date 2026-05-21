import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/order/order_repository.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../../utils/services/notification_service.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../product/coupon_controller.dart';
import '../../screens/checkout/payway_qr_payment_screen.dart';
import 'cart_controller.dart';
import 'checkout_controller.dart';

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

        // Check if PayWay/KHQR payment method is selected
       final paymentMethod = checkoutController.selectedPaymentMethod.value.name;
        final normalizedPaymentMethod = paymentMethod.toLowerCase();

        if (normalizedPaymentMethod.contains('payway') ||
            normalizedPaymentMethod.contains('khqr') ||
            normalizedPaymentMethod.contains('aba')) {
          await _processPayWayQrPayment(
            totalAmount,
            userId,
            items,
            clearCartAfterOrder,
          );
          return;
        }

        // For non-QR payments, save order directly
        _saveOrderAndComplete(
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

  /// Handle live PayWay/KHQR payment flow
  Future<void> _processPayWayQrPayment(
        double totalAmount,
        String userId,
        List<CartItemModel>? items,
        bool clearCartAfterOrder,
      ) async {
        try {
          final orderId = UniqueKey().toString();

        // Show payment screen and wait for real verification
        final paymentSuccessful = await Get.to<bool>(
          () => PayWayQRPaymentScreen(
            amount: totalAmount,
            orderId: orderId,
          ),
        );

        // Only proceed if payment was verified by backend
        if (paymentSuccessful == true) {
          YLoaders.customToast(
            message: '✓ Payment verified! Saving your order...',
          );

          await _saveOrderAndComplete(
            totalAmount,
            userId,
            items,
            clearCartAfterOrder,
            'PayWay QR',
            orderId: orderId,
          );
        } else {
          YLoaders.warningSnackBar(
            title: 'Payment Not Confirmed',
            message:
                'Payment could not be verified. Your order was not saved.',
          );
        }
      } catch (e) {
        YLoaders.hideSnackBar();
        YLoaders.errorSnackBar(
          title: 'Payment Error',
          message: e.toString(),
        );
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
      await YNotificationService.instance.showOrderSuccessNotification(
        orderId: order.id,
        totalAmount: totalAmount,
        itemCount: totalItemCount,
      );

      // CLEAR CART AFTER SUCCESSFUL CHECKOUT
      if (clearCartAfterOrder) {
        cartController.clearCart();
      }

      // Remove loader before showing success screen
      YLoaders.hideSnackBar();

      // Show Success screen
      Get.off(
        () => SuccessScreen(
          image: YImage.paymentSuccess,
          title: 'Payment Success!',
          subTitle: 'Your item will be shipped soon!',
          onPressed: () => Get.offAll(() => const NavigationMenu()),
        ),
      );
    } catch (e) {
      YLoaders.hideSnackBar();
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
