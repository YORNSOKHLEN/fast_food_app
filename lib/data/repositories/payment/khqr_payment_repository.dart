import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../features/shop/models/khqr_payment_model.dart';

class KHQRPaymentRepository {
  static const String _baseUrl = String.fromEnvironment(
    'PAYWAY_BACKEND_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );
  static const String merchantName = 'YORN SOKH LEN';
  static const String merchantCity = 'Phnom Penh';
  static const Duration qrValidity = Duration(minutes: 5);

  bool get isConfigured => _baseUrl.isNotEmpty && !_baseUrl.startsWith('YOUR_');

  Future<KHQRPaymentModel> generateMerchantPayment({
    required double amount,
    required String orderId,
    String currencyLabel = 'USD',
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    if (!isConfigured) {
      throw StateError(
        'Configure your KHQR merchant credentials in KHQRPaymentRepository before accepting real payments.',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/payway/payment-sessions'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'orderId': orderId,
              'amount': amount,
              'currency': currencyLabel,
              'merchantName': merchantName,
              'merchantCity': merchantCity,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return KHQRPaymentModel.fromJson(data);
      }

      throw StateError(
        'PayWay backend returned ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      throw StateError(
        'Unable to create PayWay payment session. Start the sample backend first or set PAYWAY_BACKEND_URL. Details: $e',
      );
    }
  }
}

