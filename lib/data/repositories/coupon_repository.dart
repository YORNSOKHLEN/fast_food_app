import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../features/shop/models/coupon_model.dart';

class CouponRepository extends GetxController {
  static CouponRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch active coupons for display.
  Future<List<CouponModel>> fetchActiveCoupons() async {
    try {
      final snapshot = await _db
          .collection('Coupons')
          .where('active', isEqualTo: true)
          .get();

      final coupons = snapshot.docs
          .map((doc) => CouponModel.fromMap(doc.id, doc.data()))
          .where((coupon) {
            final now = DateTime.now();
            final startsOk = coupon.startsAt == null || !now.isBefore(coupon.startsAt!);
            final expiresOk = coupon.expiresAt == null || !now.isAfter(coupon.expiresAt!);
            return startsOk && expiresOk;
          })
          .toList();

      return coupons;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch active coupons that the given user has not used yet.
  Future<List<CouponModel>> fetchActiveCouponsForUser(String userId) async {
    try {
      final activeCouponsFuture = fetchActiveCoupons();
      final usedCouponsFuture = _db
          .collection('CouponUsages')
          .where('userId', isEqualTo: userId)
          .get();

      final results = await Future.wait([activeCouponsFuture, usedCouponsFuture]);
      final activeCoupons = results[0] as List<CouponModel>;
      final usedSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;

      final usedCouponIds = usedSnapshot.docs
          .map((doc) => doc.data()['couponId']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      return activeCoupons
          .where((coupon) => !usedCouponIds.contains(coupon.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch coupon document by code (case-insensitive match)
  Future<CouponModel?> fetchCouponByCode(String code) async {
    try {
      final normalized = code.trim().toUpperCase();
      final query = await _db
          .collection('Coupons')
          .where('code', isEqualTo: normalized)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      final doc = query.docs.first;
      return CouponModel.fromMap(doc.id, doc.data());
    } catch (e) {
      rethrow;
    }
  }

  /// Claim a coupon usage in a transaction: increment usageCount and create usage record.
  Future<void> claimCouponUsage({
    required String couponId,
    required String userId,
    required String orderId,
  }) async {
    final couponRef = _db.collection('Coupons').doc(couponId);
    final usagesRef = _db.collection('CouponUsages').doc();

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(couponRef);
      if (!snapshot.exists) throw Exception('Coupon not found');

      final data = snapshot.data()!;
      final maxUses = data['maxUses'] as int?;
      final usageCount = (data['usageCount'] ?? 0) as int;

      if (maxUses != null && usageCount >= maxUses) {
        throw Exception('Coupon usage limit reached');
      }

      // increment
      tx.update(couponRef, {'usageCount': usageCount + 1});

      // write usage
      tx.set(usagesRef, {
        'couponId': couponId,
        'userId': userId,
        'orderId': orderId,
        'usedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Count how many times a user used a coupon
  Future<int> userUsageCount(String couponId, String userId) async {
    final q = await _db
        .collection('CouponUsages')
        .where('couponId', isEqualTo: couponId)
        .where('userId', isEqualTo: userId)
        .get();
    return q.docs.length;
  }

  /// Create a new coupon document. Returns the created doc id.
  Future<String> createCoupon(Map<String, dynamic> data) async {
    try {
      // Normalize code to uppercase (if provided)
      if (data.containsKey('code')) {
        data['code'] = (data['code'] as String).trim().toUpperCase();
      }
      data['createdAt'] = FieldValue.serverTimestamp();
      data['usageCount'] = 0;
      // Ensure active flag
      data['active'] = data['active'] ?? true;

      final docRef = await _db.collection('Coupons').add(data);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }
}

