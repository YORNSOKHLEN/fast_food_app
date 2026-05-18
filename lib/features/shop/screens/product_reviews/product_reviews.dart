import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fast_food/common/widgets/appbar/appbar.dart';
import 'package:fast_food/common/widgets/product/ratings/rating_indicator.dart';
import 'package:fast_food/data/repositories/authentication/authentication_repository.dart';
import 'package:fast_food/data/repositories/review/review_repository.dart';
import 'package:fast_food/features/shop/models/product_model.dart';
import 'package:fast_food/features/shop/models/review_model.dart';
import 'package:fast_food/features/shop/screens/product_reviews/widgets/rating_progress_indicator.dart';
import 'package:fast_food/features/shop/screens/product_reviews/widgets/user_review_card.dart';
import 'package:fast_food/utils/constants/colors.dart';
import 'package:fast_food/utils/constants/sizes.dart';
import 'package:fast_food/features/shop/controllers/product_reviews_controller.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key, this.product});

  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ProductReviewsController(product: product),
    );
    final currentUserId = AuthenticationRepository.instance.authUser?.uid;
    final reviewRepository = Get.isRegistered<ReviewRepository>()
        ? Get.find<ReviewRepository>()
        : Get.put(ReviewRepository());

    return Scaffold(
      appBar: YAppBar(
        title: const Text('Reviews & Ratings'),
        showBackArrow: true,
      ),
      body: product == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(YSizes.defaultSpace),
                child: Text('Select a product to view and write reviews.'),
              ),
            )
          : StreamBuilder<List<ReviewModel>>(
              stream: reviewRepository.watchProductReviews(product!.id),
              builder: (context, snapshot) {
                final reviews = snapshot.data ?? const <ReviewModel>[];
                final summary = controller.buildSummary(reviews);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(YSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share your real experience with ${product!.title}.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: YSizes.spaceBtwSections),

                        Text(
                          'Write a Review',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: YSizes.spaceBtwItems),
                        Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your rating',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: YSizes.spaceBtwItems / 2),
                              Obx(
                                () => RatingBar.builder(
                                  initialRating: controller.selectedRating.value,
                                  minRating: 1,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  itemSize: 30,
                                  itemBuilder: (context, index) => const Icon(
                                    Iconsax.star1,
                                    color: YColors.buttonPrimary,
                                  ),
                                  onRatingUpdate: (rating) {
                                    controller.selectedRating.value = rating;
                                  },
                                ),
                              ),
                              const SizedBox(height: YSizes.spaceBtwItems),
                              TextFormField(
                                controller: controller.reviewController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: 'Write your review',
                                  hintText: 'Tell others what you think...',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a review';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: YSizes.spaceBtwItems),
                              SizedBox(
                                width: double.infinity,
                                child: Obx(
                                  () => ElevatedButton(
                                    onPressed: controller.isSubmitting.value
                                        ? null
                                        : controller.submitReview,
                                    child: Text(
                                      controller.isSubmitting.value
                                          ? 'Posting...'
                                          : 'Submit Review',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: YSizes.spaceBtwSections),

                        Text(
                          'Timeline',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: YSizes.spaceBtwItems),
                        YOverallProductRatings(
                          averageRating: summary.averageRating,
                          totalReviews: summary.totalReviews,
                          ratingCounts: summary.ratingCounts,
                        ),
                        const SizedBox(height: YSizes.spaceBtwItems),
                        YRatingBarIndicator(rating: summary.averageRating),
                        const SizedBox(height: YSizes.spaceBtwItems / 2),
                        Text(
                          '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: YSizes.spaceBtwSections),

                        if (snapshot.connectionState == ConnectionState.waiting &&
                            reviews.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: YSizes.lg),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (reviews.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: YSizes.lg,
                            ),
                            child: Text(
                              'No reviews yet. Be the first to review this product.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        else
                          ListView.separated(
                            itemCount: reviews.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: YSizes.spaceBtwItems),
                            itemBuilder: (context, index) {
                              final review = reviews[index];
                              final canDelete =
                                  currentUserId != null &&
                                  review.userId == currentUserId;

                              return YUserReviewCard(
                                review: review,
                                canDelete: canDelete,
                                onDelete: canDelete
                                    ? () => controller.deleteReview(review.id)
                                    : null,
                              );
                            },
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


