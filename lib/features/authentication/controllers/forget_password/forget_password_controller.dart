import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:fast_food/utils/popups/loaders.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
// ...existing code...

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

      // Show brief processing toast instead of full-screen loader
      YLoaders.customToast(message: 'Processing your request...');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        YLoaders.hideSnackBar();
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
      YLoaders.hideSnackBar();

      // Show Success Screen
      YLoaders.successSnackBar(
        title: 'Email sent',
        message: 'Email Link Sent to Reset your Password'.tr,
      );

      // Redirect
      Get.to(() => ResetPasswordScreen(email: email.text.trim()));
    } catch (e) {
      YLoaders.hideSnackBar();
      YLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> resendPasswordResetEmail(String emailAddress) async {
    try {
      YLoaders.customToast(message: 'Processing your request...');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        YLoaders.hideSnackBar();
        YLoaders.errorSnackBar(
          title: 'No Internet',
          message: 'Please check your internet connection.',
        );
        return;
      }

      // Send Email to Reset Password
      await AuthenticationRepository.instance.sendPasswordResetEmail(emailAddress);

      // Remove Loader
      YLoaders.hideSnackBar();

      // Show Success Screen
      YLoaders.successSnackBar(
        title: 'Email sent',
        message: 'Email Link Sent to Reset your Password'.tr,
      );
    } catch (e) {
      // Remove Loader
      YLoaders.hideSnackBar();
      YLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
