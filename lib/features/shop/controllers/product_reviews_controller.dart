import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/data/repositories/authentication/authentication_repository.dart';
import 'package:fast_food/data/repositories/review/review_repository.dart';
import 'package:fast_food/features/shop/models/product_model.dart';
import 'package:fast_food/features/shop/models/review_model.dart';
import 'package:fast_food/utils/popups/loaders.dart';

class ProductReviewsController extends GetxController {
  static ProductReviewsController get instance => Get.find();

  late final ReviewRepository reviewRepository;
  late final GlobalKey<FormState> formKey;
  late final TextEditingController reviewController;

  final RxDouble selectedRating = 0.0.obs;
  final RxBool isSubmitting = false.obs;
  final ProductModel? product;

  ProductReviewsController({this.product});

  @override
  void onInit() {
    super.onInit();
    reviewRepository = Get.isRegistered<ReviewRepository>()
        ? Get.find<ReviewRepository>()
        : Get.put(ReviewRepository());
    formKey = GlobalKey<FormState>();
    reviewController = TextEditingController();
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  /// Submit a review
  Future<void> submitReview() async {
    try {
      if (product == null) {
        YLoaders.errorSnackBar(
          title: 'Error',
          message: 'Product not found. Please go back and try again.',
        );
        return;
      }

      if (!formKey.currentState!.validate()) {
        YLoaders.warningSnackBar(
          title: 'Validation Error',
          message: 'Please fill in all required fields.',
        );
        return;
      }

      if (selectedRating.value <= 0) {
        YLoaders.warningSnackBar(
          title: 'Rating required',
          message: 'Please select a rating before submitting your review.',
        );
        return;
      }

      final authUser = AuthenticationRepository.instance.authUser;
      if (authUser == null) {
        YLoaders.warningSnackBar(
          title: 'Sign in required',
          message: 'Please sign in before writing a review.',
        );
        return;
      }

      final displayName = authUser.displayName?.trim();
      final userName = displayName != null && displayName.isNotEmpty
          ? displayName
          : (authUser.email?.split('@').first ?? 'Anonymous');

      isSubmitting.value = true;

      await reviewRepository.addReview(
        ReviewModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          productId: product!.id,
          userId: authUser.uid,
          userName: userName,
          userImage: authUser.photoURL ?? '',
          rating: selectedRating.value,
          comment: reviewController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      reviewController.clear();
      selectedRating.value = 0;

      YLoaders.successSnackBar(
        title: 'Review posted',
        message: 'Your review has been added to the timeline.',
      );
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      await reviewRepository.deleteReview(reviewId);
      YLoaders.successSnackBar(
        title: 'Review deleted',
        message: 'Your review has been removed from the timeline.',
      );
    } catch (e) {
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Build review summary
  ReviewSummary buildSummary(List<ReviewModel> reviews) {
    if (reviews.isEmpty) {
      return const ReviewSummary(
        averageRating: 0,
        totalReviews: 0,
        ratingCounts: <int, int>{},
      );
    }

    final totalReviews = reviews.length;
    final totalRating = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    final ratingCounts = <int, int>{for (final rating in [1, 2, 3, 4, 5]) rating: 0};

    for (final review in reviews) {
      final normalizedRating = review.rating.round().clamp(1, 5);
      ratingCounts[normalizedRating] = (ratingCounts[normalizedRating] ?? 0) + 1;
    }

    return ReviewSummary(
      averageRating: totalRating / totalReviews,
      totalReviews: totalReviews,
      ratingCounts: ratingCounts,
    );
  }
}

class ReviewSummary {
  const ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });

  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts;
}

