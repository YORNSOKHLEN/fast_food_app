class CouponModel {
  final String id;
  final String code;
  final String type; // 'percentage' | 'fixed'
  final double amount;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final int? maxUses;
  final int? perUserLimit;
  final String? targetUserId; // null/empty = all users, otherwise specific user
  final String? targetProductId; // null/empty = all products, otherwise specific product
  final bool active;
  final int usageCount;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.amount,
    this.minOrderAmount,
    this.maxDiscountAmount,
    this.startsAt,
    this.expiresAt,
    this.maxUses,
    this.perUserLimit,
    this.targetUserId,
    this.targetProductId,
    this.active = true,
    this.usageCount = 0,
  });

  factory CouponModel.fromMap(String id, Map<String, dynamic> data) {
    final rawTargetUserId = (data['targetUserId'] ?? '').toString().trim();
    return CouponModel(
      id: id,
      code: (data['code'] ?? '').toString(),
      type: (data['type'] ?? 'fixed').toString(),
      amount: (data['amount'] ?? 0).toDouble(),
      minOrderAmount: data['minOrderAmount'] != null ? (data['minOrderAmount'] as num).toDouble() : null,
      maxDiscountAmount: data['maxDiscountAmount'] != null ? (data['maxDiscountAmount'] as num).toDouble() : null,
      startsAt: data['startsAt'] != null
          ? (data['startsAt'] is DateTime
              ? data['startsAt'] as DateTime
              : (data['startsAt'] as dynamic).toDate())
          : null,
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] is DateTime
              ? data['expiresAt'] as DateTime
              : (data['expiresAt'] as dynamic).toDate())
          : null,
      maxUses: data['maxUses'] as int?,
      perUserLimit: data['perUserLimit'] as int?,
      targetUserId: rawTargetUserId.isEmpty ? null : rawTargetUserId,
      targetProductId: (data['targetProductId'] ?? '').toString().trim().isEmpty
          ? null
          : (data['targetProductId'] ?? '').toString().trim(),
      active: data['active'] ?? true,
      usageCount: (data['usageCount'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'type': type,
        'amount': amount,
        'minOrderAmount': minOrderAmount,
        'maxDiscountAmount': maxDiscountAmount,
        'startsAt': startsAt,
        'expiresAt': expiresAt,
        'maxUses': maxUses,
        'perUserLimit': perUserLimit,
        'targetUserId': targetUserId,
        'targetProductId': targetProductId,
        'active': active,
        'usageCount': usageCount,
      };
}

