import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khqr_sdk/khqr_sdk.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../data/repositories/payment/khqr_payment_repository.dart';
import '../../../../data/repositories/payment/payment_verification_service.dart';
import '../../models/khqr_payment_model.dart';

class PayWayQRPaymentScreen extends StatefulWidget {
  const PayWayQRPaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
  });

  final double amount;
  final String orderId;

  @override
  State<PayWayQRPaymentScreen> createState() => _PayWayQRPaymentScreenState();
}

class _PayWayQRPaymentScreenState extends State<PayWayQRPaymentScreen> {
  final KHQRPaymentRepository _repository = Get.put(KHQRPaymentRepository());
  late Future<KHQRPaymentModel> _paymentFuture;

  // Payment verification state
  String _verificationStatus = 'Waiting for PayWay QR scan...';
  bool _isPaymentVerified = false;
  bool _isVerifying = true;

  @override
  void initState() {
    super.initState();
    _paymentFuture = _createPayment();
    // Start polling for payment verification
    _startPaymentVerification();
  }

  Future<KHQRPaymentModel> _createPayment() {
    return _repository.generateMerchantPayment(
      amount: widget.amount,
      orderId: widget.orderId,
    );
  }

  /// Start polling the backend to verify payment
  void _startPaymentVerification() {
    // Run verification in background without blocking UI
    PaymentVerificationService.verifyPaymentWithPolling(
      orderId: widget.orderId,
      amount: widget.amount,
      onStatusUpdate: (status) {
        if (mounted) {
          setState(() {
            _verificationStatus = status;
          });
        }
      },
    ).then((verified) {
      if (mounted) {
        setState(() {
          _isPaymentVerified = verified;
          _isVerifying = false;

          if (verified) {
            _verificationStatus = '✓ Payment confirmed by PayWay!';
          } else {
            _verificationStatus =
                'Payment not verified. Please try again.';
          }
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verificationStatus = 'Verification error: $e';
        });
      }
    });
  }

  Future<void> _regeneratePayment() async {
    setState(() {
      _paymentFuture = _createPayment();
      _isPaymentVerified = false;
      _isVerifying = true;
      _verificationStatus = 'Waiting for PayWay QR scan...';
    });
    await _paymentFuture;
    _startPaymentVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const YAppBar(
        showBackArrow: true,
        title: Text('PayWay QR Payment'),
      ),
      body: FutureBuilder<KHQRPaymentModel>(
        future: _paymentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(YSizes.defaultSpace),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56),
                    const SizedBox(height: YSizes.spaceBtwItems),
                    Text(
                      'Unable to create the payment QR.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: YSizes.spaceBtwItems / 2),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: YSizes.spaceBtwSections),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _regeneratePayment,
                        child: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(height: YSizes.spaceBtwItems),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final payment = snapshot.data!;
          final qrValidity = KHQRPaymentRepository.qrValidity;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(YSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Scan to pay with any KHQR-enabled banking app.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: YSizes.spaceBtwSections),
                  Center(
                    child: KhqrCardWidget(
                      qr: payment.qrCode,
                      receiverName: KHQRPaymentRepository.merchantName,
                      amount: payment.amount,
                      currency: KhqrCurrency.usd,
                      duration: qrValidity,
                      regenerateButtonText: 'Refresh QR',
                      onRegenerate: _regeneratePayment,
                      showShadow: true,
                    ),
                  ),
                   const SizedBox(height: YSizes.spaceBtwSections),
                   Container(
                     padding: const EdgeInsets.all(YSizes.md),
                     decoration: BoxDecoration(
                       color: Theme.of(context).cardColor,
                       borderRadius: BorderRadius.circular(YSizes.md),
                       border: Border.all(color: Theme.of(context).dividerColor),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Payment details',
                           style: Theme.of(context).textTheme.titleMedium,
                         ),
                         const SizedBox(height: YSizes.spaceBtwItems / 2),
                         _DetailRow(label: 'Order ID', value: payment.transactionId),
                         _DetailRow(label: 'Amount', value: '\$${payment.amount.toStringAsFixed(2)}'),
                         _DetailRow(label: 'Status', value: payment.status),
                         _DetailRow(label: 'Expires in', value: '${qrValidity.inMinutes} minutes'),
                       ],
                     ),
                   ),
                   const SizedBox(height: YSizes.spaceBtwSections),
                   // Real-time verification status
                   Container(
                     padding: const EdgeInsets.all(YSizes.md),
                     decoration: BoxDecoration(
                        color: _isPaymentVerified
                            ? Colors.green.withValues(alpha: 0.1)
                            : _isVerifying
                                ? Colors.blue.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(YSizes.md),
                       border: Border.all(
                         color: _isPaymentVerified
                             ? Colors.green
                             : _isVerifying
                                 ? Colors.blue
                                 : Colors.red,
                       ),
                     ),
                     child: Row(
                       children: [
                         if (_isPaymentVerified)
                           const Icon(Icons.check_circle, color: Colors.green)
                         else if (_isVerifying)
                           const SizedBox(
                             width: 20,
                             height: 20,
                             child: CircularProgressIndicator(strokeWidth: 2),
                           )
                         else
                           const Icon(Icons.info, color: Colors.red),
                         const SizedBox(width: YSizes.spaceBtwItems),
                         Expanded(
                           child: Text(
                             _verificationStatus,
                             style: Theme.of(context).textTheme.bodySmall,
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: YSizes.spaceBtwSections),
                   const _InstructionRow(
                     number: '1',
                      text: 'Open ABA PayWay or another KHQR-supported app.',
                   ),
                  const _InstructionRow(
                    number: '2',
                    text: 'Open any KHQR-supported banking app.',
                  ),
                  const _InstructionRow(
                    number: '3',
                    text: 'After the transfer is completed, continue to place the order.',
                  ),
                  const SizedBox(height: YSizes.spaceBtwSections),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: _isPaymentVerified
                           ? () => Get.back(result: true)
                           : null,
                       child: Text(
                         _isPaymentVerified
                                ? 'Payment Confirmed - Continue'
                             : _isVerifying
                                        ? 'Verifying Payment...'
                                 : 'Verification Failed - Try Again',
                       ),
                     ),
                   ),
                   const SizedBox(height: YSizes.spaceBtwItems),
                   SizedBox(
                     width: double.infinity,
                     child: OutlinedButton(
                       onPressed: () => Get.back(result: false),
                       child: const Text('Cancel Payment'),
                     ),
                   ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: YSizes.spaceBtwItems / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            child: Text(number, style: Theme.of(context).textTheme.labelSmall),
          ),
          const SizedBox(width: YSizes.spaceBtwItems / 2),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}




