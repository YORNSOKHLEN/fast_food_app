import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/controllers/user_controller.dart';

class LoginController extends GetxController {
  // Variables
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());

  @override
  void onInit() {
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  /// Email & Password Login
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Show processing toast instead of full-screen loader
      YLoaders.customToast(message: 'Logging you in...');

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

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        YLoaders.hideSnackBar();
        return;
      }

      // Save Data if Remember Me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }

      // Login user using Email & Password Authentication
      await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Remove Loader
      YLoaders.hideSnackBar();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      YLoaders.hideSnackBar();
      YLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Google SignIn Authentication
  Future<void> googleSignIn() async {
    try {
      YLoaders.customToast(message: 'Logging you in...');

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

      // Google Authentication
      final userCredentials = await AuthenticationRepository.instance
          .signInWithGoogle();

      // Save user record to Firestore
      await userController.saveUserRecord(userCredentials);

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      final message = e.toString();
      if (!message.contains('Google sign-in cancelled')) {
        YLoaders.errorSnackBar(title: 'Oh Snap', message: message);
      }
    } finally {
      YLoaders.hideSnackBar();
    }
  }

}
