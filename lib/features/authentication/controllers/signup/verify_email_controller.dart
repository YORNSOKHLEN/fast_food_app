import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:fast_food/common/widgets/success_screen/success_screen.dart';
import 'package:fast_food/utils/constants/text_strings.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fast_food/data/repositories/user/user_repository.dart';
import 'package:fast_food/features/personalization/models/user_model.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  Timer? _redirectTimer;
  bool _hasHandledVerification = false;

  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  @override
  void onClose() {
    _redirectTimer?.cancel();
    super.onClose();
  }

  /// --- Send Email Verification link
  Future<void> sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      YLoaders.successSnackBar(
        title: 'Email Sent!',
        message:
        'Please check your inbox (and spam folder) to verify your email.',
      );
    } catch (e) {
      YLoaders.errorSnackBar(
        title: 'Failed to Send Email',
        message:
        '${e.toString()}\n\nPlease check:\n1. Your internet connection\n2. Firebase email settings\n3. Try again in a few moments',
      );
    }
  }

  /// --- Timer to automatically redirect on Email Verification
  void setTimerForAutoRedirect() {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        await _handleVerifiedEmailSuccess(timer);
      }
    });
  }

  /// --- Manually Check if Email Verified
  Future<void> checkEmailVerificationStatus() async {
    try {
      // Start Loading
      YFullScreenLoader.openLoadingDialog(
        'Checking email verification...',
        YImage.docerAnimation,
      );

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        YFullScreenLoader.stopLoading();
        YLoaders.warningSnackBar(
          title: 'Session Expired',
          message: 'Please login again to continue.',
        );
        return;
      }

      await currentUser.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;

      // Stop loading
      YFullScreenLoader.stopLoading();

      if (refreshedUser?.emailVerified ?? false) {
        await _handleVerifiedEmailSuccess();
      } else {
        YLoaders.warningSnackBar(
          title: 'Not Verified Yet',
          message: 'Please verify your email, then tap Continue.',
        );
      }
    } catch (e) {
      YFullScreenLoader.stopLoading();
      YLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  Future<void> _handleVerifiedEmailSuccess([Timer? timer]) async {
    if (_hasHandledVerification) return;
    _hasHandledVerification = true;
    timer?.cancel();
    _redirectTimer?.cancel();

    // Attempt to save any pending user profile that was stored during signup.
    try {
      final storage = GetStorage();
      final pending = storage.read('pending_user') as Map<String, dynamic>?;
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      if (pending != null && pending['id'] == currentUid) {
        final user = UserModel(
          id: pending['id'] ?? currentUid ?? '',
          firstName: pending['FirstName'] ?? '',
          lastName: pending['LastName'] ?? '',
          username: pending['Username'] ?? '',
          email: pending['Email'] ?? '',
          phoneNumber: pending['PhoneNumber'] ?? '',
          profilePicture: pending['ProfilePicture'] ?? '',
          gender: pending['Gender'] ?? '',
          dateOfBirth: pending['DateOfBirth'] ?? '',
          role: pending['Role'] ?? 'customer',
        );

        final userRepository = Get.put(UserRepository());
        await userRepository.saveUserRecord(user);
        await storage.remove('pending_user');
        YLoaders.successSnackBar(
          title: 'Profile Saved',
          message: 'Your profile has been saved successfully.',
        );
      }
    } catch (e) {
      // If saving fails, show an error but continue with navigation so user can still proceed.
      YLoaders.errorSnackBar(
        title: 'Save Failed',
        message: 'Failed to save profile: ${e.toString()}',
      );
    }

    Get.off(
      () => SuccessScreen(
        image: YImage.staticSuccessIllustration,
        title: YText.yourAccountCreatedTitle,
        subTitle: YText.yourAccountCreatedSubTitle,
        onPressed: () async {
          await AuthenticationRepository.instance.logout();
        },
      ),
    );
  }
}
