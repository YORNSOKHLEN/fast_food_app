class KHQRPaymentModel {
  final String transactionId;
  final String qrCode;
  final double amount;
  final String currency;
  final String description;
  final DateTime timestamp;
  String status; // 'pending', 'completed', 'failed' - mutable for updates

  KHQRPaymentModel({
    required this.transactionId,
    required this.qrCode,
    required this.amount,
    this.currency = 'USD',
    required this.description,
    required this.timestamp,
    this.status = 'pending',
  });

  factory KHQRPaymentModel.fromJson(Map<String, dynamic> json) {
    return KHQRPaymentModel(
      transactionId: json['transactionId'] ?? '',
      qrCode: json['qrCode'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'qrCode': qrCode,
      'amount': amount,
      'currency': currency,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }
}


