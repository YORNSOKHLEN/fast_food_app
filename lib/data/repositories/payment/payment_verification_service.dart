import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Payment verification service to poll backend for payment confirmation
class PaymentVerificationService {
  static const String _baseUrl = String.fromEnvironment(
    'PAYWAY_BACKEND_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );
  static const int _pollingIntervalSeconds = 2;
  static const int _maxPollingDurationSeconds = 300; // 5 minutes

  /// Poll backend to verify if payment was received
  ///
  /// Returns: Future<bool> - true if payment confirmed, false if timeout/error
  ///
  /// Expected backend endpoint:
  /// GET /api/payway/payments/{orderId}/status?amount={amount}
  /// Response: {'status': 'pending'|'confirmed'|'failed', 'error'?: 'message'}
  static Future<bool> verifyPaymentWithPolling({
    required String orderId,
    required double amount,
    required Function(String) onStatusUpdate,
  }) async {
    final startTime = DateTime.now();

    while (true) {
      final elapsedSeconds =
          DateTime.now().difference(startTime).inSeconds;

      // Timeout after 5 minutes
      if (elapsedSeconds >= _maxPollingDurationSeconds) {
        onStatusUpdate(
          'Verification timeout. Please check your payment status.',
        );
        return false;
      }

      try {
        final status = await _checkPaymentStatus(
          orderId: orderId,
          amount: amount,
        );

        if (status == 'confirmed') {
          onStatusUpdate('✓ Payment confirmed by PayWay!');
          return true;
        }

        if (status == 'failed' || status == 'expired') {
          onStatusUpdate(
            status == 'expired'
                ? 'Payment session expired. Please refresh the QR code.'
                : 'Payment failed. Please try again.',
          );
          return false;
        }

        // Payment not yet confirmed, update UI with elapsed time
        onStatusUpdate(
          'Checking payment... (${elapsedSeconds}s elapsed)',
        );

        // Wait before next poll
        await Future.delayed(
          Duration(seconds: _pollingIntervalSeconds),
        );
      } catch (e) {
        onStatusUpdate('Verification error: $e');
        // Continue polling on error
        await Future.delayed(
          Duration(seconds: _pollingIntervalSeconds),
        );
      }
    }
  }

  /// Check payment status from backend
  static Future<String> _checkPaymentStatus({
    required String orderId,
    required double amount,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/api/payway/payments/$orderId/status?amount=$amount',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;

        return status ?? 'pending';
      } else if (response.statusCode == 404) {
        return 'pending';
      } else if (response.statusCode == 410) {
        return 'expired';
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        return 'failed';
      } else {
        return 'pending';
      }
    } catch (e) {
      return 'pending';
    }
  }

  /// Verify payment with backend immediately (no polling)
  /// Use this for server-side verification after user confirms
  static Future<bool> verifyPaymentImmediate({
    required String orderId,
    required double amount,
  }) async {
    try {
      final verified = await _checkPaymentStatus(
        orderId: orderId,
        amount: amount,
      );
      return verified == 'confirmed';
    } catch (e) {
      return false;
    }
  }
}

