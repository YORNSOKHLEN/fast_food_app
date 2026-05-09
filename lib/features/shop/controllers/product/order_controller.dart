import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/order/order_repository.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import 'cart_controller.dart';
import 'checkout_controller.dart';
import '../product/coupon_controller.dart';

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
  void processOrder(
    double totalAmount, {
    List<CartItemModel>? items,
    bool clearCartAfterOrder = true,
  }) async {
    try {
      // Start Loader
      YFullScreenLoader.openLoadingDialog(
        'Processing your order',
        YImage.docerAnimation,
      );

      // Get user authentication Id
      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) return;

      final orderItems = items ?? cartController.cartItems.toList();

      // Add Details
      final order = OrderModel(
        id: UniqueKey().toString(),
        // Generate a unique ID
        userId: userId,
        status: OrderStatus.pending,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        paymentMethod: checkoutController.selectedPaymentMethod.value.name,
        // address: addressController.selectedAddress.value,
        // deliveryDate: DateTime.now(), // Set Date as needed
        items: orderItems,
      );

      // Save the order to Firestore
      await orderRepository.saveOrder(order, userId);

      // If a coupon was applied, claim its usage for this order
      try {
        final couponController = Get.find<CouponController>();
        if (couponController.appliedCoupon.value != null) {
          await couponController.claimCouponForOrder(order.id);
        }
      } catch (_) {
        // ignore if coupon controller not found or claim failed (non-blocking)
      }

      // Update product popularity counters based on purchased quantities.
      await orderRepository.incrementProductOrderCounts(orderItems);

      // CLEAR CART AFTER SUCCESSFUL CHECKOUT
      if (clearCartAfterOrder) {
        cartController.clearCart();
      }

      // Show Success screen
      Get.off(
        () => SuccessScreen(
          image: YImage.paymentSuccess,
          title: 'Payment Success!',
          subTitle: 'Your item will be shipped soon!',
          onPressed: () => Get.offAll(() => const NavigationMenu()),
        ),
      );

      // Additional logic like clearing cart or navigating to success screen would follow here.
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
