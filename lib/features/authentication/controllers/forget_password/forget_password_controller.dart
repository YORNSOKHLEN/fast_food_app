import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:fast_food/utils/popups/loaders.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  /// Variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  /// Send Reset Password EMail
  Future<void> sendPasswordResetEmail() async {
    try {
      // Form Validation first
      if (!forgetPasswordFormKey.currentState!.validate()) {
        return;
      }

      // Start Loading
      YFullScreenLoader.openLoadingDialog(
        'Processing your request...',
        YImage.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        YFullScreenLoader.stopLoading();
        YLoaders.errorSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection.',
        );
        return;
      }

      // Send Email to Reset Password
      await AuthenticationRepository.instance.sendPasswordResetEmail(
        email.text.trim(),
      );

      // Remove Loader
      YFullScreenLoader.stopLoading();

      // Show Success Screen
      YLoaders.successSnackBar(
        title: 'Email sent',
        message: 'Email Link Sent to Reset your Password'.tr,
      );

      // Redirect
      Get.to(() => ResetPasswordScreen(email: email.text.trim()));
    } catch (e) {
      YFullScreenLoader.stopLoading();
      YLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> resendPasswordResetEmail(String emailAddress) async {
    try {
      // Start Loading
      YFullScreenLoader.openLoadingDialog(
        'Processing your request...',
        YImage.docerAnimation,
      );

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        YFullScreenLoader.stopLoading();
        YLoaders.errorSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection.',
        );
        return;
      }

      // Send Email to Reset Password
      await AuthenticationRepository.instance.sendPasswordResetEmail(emailAddress);

      // Remove Loader
      YFullScreenLoader.stopLoading();

      // Show Success Screen
      YLoaders.successSnackBar(
        title: 'Email sent',
        message: 'Email Link Sent to Reset your Password'.tr,
      );
    } catch (e) {
      // Remove Loader
      YFullScreenLoader.stopLoading();
      YLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
