import 'dart:async';

import 'package:flutter/material.dart';
import 'package:khqr_sdk/khqr_sdk.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import 'package:get/get.dart';
import '../../services/payway_payment_service.dart';
import '../../../../utils/services/notification_service.dart';

class PaywayPaymentScreen extends StatefulWidget {
  const PaywayPaymentScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.itemCount,
    required this.paymentMethod,
  });

  final String orderId;
  final double totalAmount;
  final int itemCount;
  final String paymentMethod;

  @override
  State<PaywayPaymentScreen> createState() => _PaywayPaymentScreenState();
}

class _PaywayPaymentScreenState extends State<PaywayPaymentScreen> {
  static const int _qrRefreshSeconds = 5 * 60;
  static const int _successSeconds = 10;

  final PaywayPaymentService _service = PaywayPaymentService();

  PaywayPaymentResult? _paymentResult;
  Timer? _refreshTimer;
  Timer? _successTimer;
  bool _isLoading = true;
  String? _errorMessage;
  int _refreshCountdown = _qrRefreshSeconds;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _createQr();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _successTimer?.cancel();
    super.dispose();
  }

  Future<void> _createQr() async {
    _cancelTimers();
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _paymentResult = null;
      _refreshCountdown = _qrRefreshSeconds;
    });

    try {
      final result = await _service.createPaymentQr(
        amount: widget.totalAmount,
        orderId: widget.orderId,
        paymentMethod: widget.paymentMethod,
      );

      if (!mounted) return;
      setState(() {
        _paymentResult = result;
        _isLoading = false;
      });

      _startTimers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startTimers() {
    _cancelTimers();

    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _refreshCountdown -= 1;
      });

      if (_refreshCountdown <= 0) {
        timer.cancel();
        _createQr();
      }
    });

    _successTimer = Timer(const Duration(seconds: _successSeconds), () {
      _goToSuccess();
    });
  }

  void _cancelTimers() {
    _refreshTimer?.cancel();
    _successTimer?.cancel();
  }

  void _goToSuccess() {
    if (_didNavigate || !mounted) return;
    _didNavigate = true;
    _cancelTimers();
    YLoaders.hideSnackBar();

    // Show shared order success notification
    YNotificationService.instance.showOrderSuccessNotification(
      orderId: widget.orderId,
      totalAmount: widget.totalAmount,
      itemCount: widget.itemCount,
    );

    Get.off(
      () => SuccessScreen(
        image: YImage.paymentSuccess,
        title: 'Payment Success!',
        subTitle: 'Your item will be prepared shortly.',
        onPressed: () => Get.offAll(() => const NavigationMenu()),
      ),
    );
  }

  String _formatCountdown(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final dark = YHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: YAppBar(
        showBackArrow: true,
        title: Text(
          'QR Payment',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YRoundedContainer(
              showBorder: true,
              backgroundColor: dark ? YColors.black : YColors.white,
              padding: const EdgeInsets.all(YSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan to pay',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: YSizes.spaceBtwItems),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order ID',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                widget.orderId.substring(0, 8),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Amount',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                '\$${widget.totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: YSizes.spaceBtwSections),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              YRoundedContainer(
                showBorder: true,
                backgroundColor: dark ? YColors.black : YColors.white,
                padding: const EdgeInsets.all(YSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unable to create QR',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: YSizes.spaceBtwItems),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: YSizes.spaceBtwItems),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createQr,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              )
            else if (_paymentResult != null)
              Column(
                children: [
                  YRoundedContainer(
                    showBorder: true,
                    backgroundColor: dark ? YColors.black : YColors.white,
                    padding: const EdgeInsets.all(YSizes.defaultSpace),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                          KhqrCardWidget(
                            width: 300.0,
                            receiverName: PaywayPaymentService.fallbackMerchantName,
                            amount: widget.totalAmount,
                            keepIntegerDecimal: true,
                            currency: KhqrCurrency.usd,
                            qr: _paymentResult!.qrContent,
                        ),
                        const SizedBox(height: YSizes.spaceBtwItems),
                        // Text(
                        //   _paymentResult!.usedFallback
                        //       ? 'Sandbox QR generated locally'
                        //       : (_paymentResult!.message ?? 'QR ready'),
                        //   style: Theme.of(context).textTheme.bodyMedium,
                        //   textAlign: TextAlign.center,
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: YSizes.spaceBtwItems),
                  Row(
                    children: [
                      Expanded(
                        child: YRoundedContainer(
                          showBorder: true,
                          backgroundColor:
                              dark ? YColors.black : YColors.white,
                          padding: const EdgeInsets.all(YSizes.md),
                          child: Column(
                            children: [
                              Text(
                                'QR resets in',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatCountdown(_refreshCountdown),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: YSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _createQr,
                      child: const Text('Refresh QR'),
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}


