import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/coupon_list_controller.dart';

class CouponListScreen extends StatelessWidget {
  const CouponListScreen({super.key});

  String _discountLabel(String type, double amount) {
    if (type == 'percentage') return '${amount.toStringAsFixed(0)}% OFF';
    return '\$${amount.toStringAsFixed(2)} OFF';
  }

  String _formatExpiry(DateTime? date) {
    if (date == null) return 'No expiry';
    return YHelperFunctions.getFormatDate(date);
  }

  Widget _infoChip({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: YColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(YSizes.sm),
        border: Border.all(color: YColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: YColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponListController());
    final dark = YHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: YAppBar(
        showBackArrow: true,
        title: Text(
          'Coupons',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.discount_outlined, size: 56, color: YColors.darkGrey),
                  const SizedBox(height: YSizes.spaceBtwItems),
                  Text(
                    'Failed to load coupons',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: YSizes.spaceBtwItems / 2),
                  Text(
                    'Please try again in a moment.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: YSizes.spaceBtwItems),
                  ElevatedButton(
                    onPressed: () => controller.fetchCoupons(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_outlined, size: 56, color: YColors.darkGrey),
                  const SizedBox(height: YSizes.spaceBtwItems),
                  Text(
                    'No active coupons available right now.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: YSizes.spaceBtwItems / 2),
                  Text(
                    'New deals will appear here when available.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchCoupons(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.coupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: YSizes.spaceBtwItems),
              itemBuilder: (_, index) {
                final coupon = controller.coupons[index];
                final subtitleStyle = Theme.of(context).textTheme.bodySmall;

                return YRoundedContainer(
                  showBorder: true,
                  backgroundColor: dark ? YColors.dark : YColors.white,
                  padding: const EdgeInsets.all(YSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coupon.code,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _discountLabel(coupon.type, coupon.amount),
                                  style: Theme.of(context).textTheme.titleMedium!.apply(
                                        color: YColors.buttonPrimary,
                                        fontWeightDelta: 1,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: YColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(YSizes.sm),
                            child: IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: coupon.code));
                                YLoaders.successSnackBar(
                                  title: 'Copied',
                                  message: 'Coupon code copied',
                                );
                              },
                              icon: const Icon(Icons.copy, size: 18),
                              color: YColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: YSizes.spaceBtwItems),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(context: context, icon: Icons.shopping_bag_outlined, label: 'Min: ${coupon.minOrderAmount ?? 0}'),
                          _infoChip(context: context, icon: Icons.schedule_outlined, label: _formatExpiry(coupon.expiresAt)),
                          _infoChip(
                            context: context,
                            icon: Icons.people_outline,
                            label: coupon.targetUserId == null ? 'All users' : 'User: ${coupon.targetUserId}',
                          ),
                          _infoChip(
                            context: context,
                            icon: Icons.category_outlined,
                            label: coupon.targetProductId == null ? 'All products' : 'Product: ${coupon.targetProductId}',
                          ),
                          _infoChip(
                            context: context,
                            icon: Icons.percent_outlined,
                            label: 'Usage: ${coupon.usageCount}${coupon.maxUses != null ? ' / ${coupon.maxUses}' : ''}',
                          ),
                          if (coupon.perUserLimit != null)
                            _infoChip(
                              context: context,
                              icon: Icons.person_outline,
                              label: 'Per user: ${coupon.perUserLimit}',
                            ),
                        ],
                      ),
                      const SizedBox(height: YSizes.spaceBtwItems),
                      Text(
                        'Swipe down to refresh',
                        style: subtitleStyle,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

