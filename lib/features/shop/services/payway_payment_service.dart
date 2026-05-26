import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:http/http.dart' as http;
import 'package:khqr_sdk/khqr_sdk.dart';
import 'package:pointycastle/export.dart';

class PaywayPaymentService {
  PaywayPaymentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String merchantId = 'ec475573';
  static const String publicKey = '14a7e4d7d554119509ac775583fc10d7418c96fe';
  static const String rsaPublicKeyPem = '''-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCCuHPd2mvS/eM6HIR5CYGfD1jg
gDO3WQ6ijuyBU7U5ZqbjeZ6ga1K/BzDYuNlujPXtPDdf2F0TYFrKAhaiRn69KsnN
0hZEDFFPq4kcLgE02Z5qvPWGpu6KPJ1y9PO06gT5ZoexF9f1GJ1XUtsupcTMFNmr
OMb/Hha8UVSfwNnanwIDAQAB
-----END PUBLIC KEY-----''';
  static const String rsaPrivateKeyPem = '''-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQDDxizQbwCL3DcFYyKaM4K2tOpdybm03JQC5NIzVP6qOGI8FNBI
YFAQPuGATGSjVVyACgVwZupi+4AYH08FagOxDTwvY002faOacitLjhLOAszPjLRm
QyXVdESwmWl8t45GBd3BwkmdsLT3g2scjHxmpLea1oUKclJkgBNU+shcowIDAQAB
AoGAFBNf6BXh7/WqnL5QP5DVsCe4OtrjVMUj1nIhjgsCvHDgvfmCbFGYFDpmhHIR
BeDMhgLBEQg0s+bHeXHIeC0paJIG1j6xo55aTHL4FbMIndpv+Cc+8tM76AwKALAD
7e7YDvxrwPCsLk6oxqqgSkyX5bK8INorjYU78nxlgO/s+rECQQDRWWf+2E2EXebp
a7IaAnLyWYfIilUeldfEHllTAgsv4LuW7/i38w7KnjuTDzofNY4dUV18rl4NDICd
FDhD6EkxAkEA72Zb1lt9ko8riLpktb4BFoOF9oTDJESYa+fD+JOrtKpUE4RZ0Dk6
Uhi9mYKINZ3C9qyETkMYn82fw69aXp5OEwJACreT/lTeawdPmeV8gZ5cehGhRN/o
CZ/MIusW0YwKPJI5qDlytyAHQtIk5Jtj81MPimqu6YIXqH1aXDA7zSYoEQJBANS9
snjv/sxB3F75vMtg2Nin8mEao8tUBdtGL3lzyQ+YmXRqleGbKX+RKtQDEoYK9xl8
P2rI51YDRamA557TsO8CQDZiVU5oNuZtL6+pQa5EMiGruhcLtpT49kbOfoLEWrv2
g8MiDYFseKh4WM2dERq4YrvQYrUGC1Y99Rup0zUw3L0=
-----END RSA PRIVATE KEY-----''';
  static const String endpoint =
      'https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/purchase';
  static const String fallbackMerchantName = 'Fast Food';
  static const String fallbackAcquiringBank = 'PayWay Sandbox';

  Future<PaywayPaymentResult> createPaymentQr({
    required double amount,
    required String orderId,
    required String paymentMethod,
  }) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final requestPayload = <String, dynamic>{
      'merchantId': merchantId,
      'publicKey': publicKey,
      'rsaPublicKey': rsaPublicKeyPem,
      'amount': amount.toStringAsFixed(2),
      'currency': 'USD',
      'orderId': orderId,
      'transactionId': orderId,
      'paymentMethod': paymentMethod,
      'description': 'Fast Food order #$orderId',
      'timestamp': timestamp,
      'callbackUrl': '',
      'returnUrl': '',
    };

    final requestJson = jsonEncode(requestPayload);
    final signature = _signPayload(requestJson);
    final fallbackQr = _buildFallbackKhqr(amount, orderId);

    final body = jsonEncode({
      ...requestPayload,
      'signature': signature,
    });

    try {
      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      final decoded = _tryDecodeJson(response.body);
      final qrContent = _extractQrContent(decoded) ??
          _extractQrContentFromString(response.body) ??
          fallbackQr;

      return PaywayPaymentResult(
        qrContent: qrContent,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        message: _extractMessage(decoded) ??
            'Payway QR generated${response.statusCode >= 200 && response.statusCode < 300 ? '' : ' with fallback'}',
        requestPayload: requestPayload,
        signature: signature,
        usedFallback: qrContent == fallbackQr,
      );
    } catch (_) {
      final fallback = _buildFallbackKhqr(amount, orderId);
      return PaywayPaymentResult(
        qrContent: fallback,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        message: 'Fallback QR generated locally',
        requestPayload: requestPayload,
        signature: signature,
        usedFallback: true,
      );
    }
  }

  String _buildFallbackKhqr(double amount, String orderId) {
    final res = KhqrSdk.generateMerchant(
      MerchantInfo(
        merchantId: merchantId,
        bakongAccountId: merchantId,
        merchantName: fallbackMerchantName,
        acquiringBank: fallbackAcquiringBank,
        merchantCity: 'Phnom Penh',
        currency: KhqrCurrency.usd,
        amount: amount,
        billNumber: orderId,
        storeLabel: 'Fast Food Order',
        terminalLabel: 'Terminal 1',
        purposeOfTransaction: 'Food payment',
        expirationTimestamp:
            DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
      ),
    );

    return res.data?.qr ??
        'PAYWAY|$merchantId|$orderId|${amount.toStringAsFixed(2)}|${DateTime.now().millisecondsSinceEpoch}';
  }

  String _signPayload(String payload) {
    final privateKey = _parseRSAPrivateKey(rsaPrivateKeyPem);
    final signer = Signer('SHA-256/RSA');
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final signature = signer.generateSignature(
      Uint8List.fromList(utf8.encode(payload)),
    ) as RSASignature;
    return base64Encode(signature.bytes);
  }

  RSAPrivateKey _parseRSAPrivateKey(String pem) {
    final cleanPem = pem
        .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
        .replaceAll('-----END RSA PRIVATE KEY-----', '')
        .replaceAll(RegExp(r'\s'), '');
    final bytes = base64Decode(cleanPem);
    final parser = ASN1Parser(bytes);
    final topLevel = parser.nextObject() as ASN1Sequence;
    final elements = topLevel.elements;
    if (elements.length < 9) {
      throw FormatException('Invalid RSA private key.');
    }

    return RSAPrivateKey(
      (elements[1] as ASN1Integer).valueAsBigInteger,
      (elements[3] as ASN1Integer).valueAsBigInteger,
      (elements[4] as ASN1Integer).valueAsBigInteger,
      (elements[5] as ASN1Integer).valueAsBigInteger,
    );
  }

  dynamic _tryDecodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _extractQrContent(dynamic decoded) {
    if (decoded == null) return null;

    if (decoded is String) {
      return decoded.trim().isEmpty ? null : decoded.trim();
    }

    if (decoded is Map<String, dynamic>) {
      const directKeys = [
        'qr',
        'qrCode',
        'qr_code',
        'qrString',
        'qr_string',
        'paymentQr',
        'payment_url',
        'paymentUrl',
        'url',
        'link',
      ];

      for (final key in directKeys) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }

      final nestedKeys = ['data', 'result', 'response', 'payload'];
      for (final key in nestedKeys) {
        final nested = _extractQrContent(decoded[key]);
        if (nested != null) return nested;
      }
    }

    return null;
  }

  String? _extractQrContentFromString(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    return null;
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] ?? decoded['msg'] ?? decoded['description'];
      if (message is String && message.trim().isNotEmpty) return message.trim();
    }
    return null;
  }
}

class PaywayPaymentResult {
  const PaywayPaymentResult({
    required this.qrContent,
    required this.expiresAt,
    required this.message,
    required this.requestPayload,
    required this.signature,
    required this.usedFallback,
  });

  final String qrContent;
  final DateTime expiresAt;
  final String? message;
  final Map<String, dynamic> requestPayload;
  final String signature;
  final bool usedFallback;
}


