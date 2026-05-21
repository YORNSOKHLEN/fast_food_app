import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/features/personalization/controllers/user_controller.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/loaders.dart';

/// Controller to manage user-related functionality.
class UpdateNameController extends GetxController {
  static UpdateNameController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();

  /// init user data when Home Screen appears
  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  /// Fetch user record
  Future<void> initializeNames() async {
    firstName.text = userController.user.value.firstName ?? '';
    lastName.text = userController.user.value.lastName ?? '';
  }

  Future<void> updateUserName() async {
    try {
      // Form Validation first
      if (!updateUserNameFormKey.currentState!.validate()) {
        return;
      }

      // Show a brief processing toast instead of full-screen loader
      YLoaders.customToast(message: 'We are updating your information...');

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

      // Update user's first & last name in the Firebase Firestore
      Map<String, dynamic> name = {
        'FirstName': firstName.text.trim(),
        'LastName': lastName.text.trim(),
      };
      await userRepository.updateSingleField(name);

      // Update the Rx User value
      userController.user.value.firstName = firstName.text.trim();
      userController.user.value.lastName = lastName.text.trim();
      userController.user.refresh();

      // Remove Loader
      YLoaders.hideSnackBar();

      // Show Success Message
      YLoaders.successSnackBar(
        title: 'Congratulations',
        message: 'Your Name has been updated.',
      );

      // Return to profile screen; it will rebuild from refreshed user state.
      Get.back();
    } catch (e) {
      YLoaders.hideSnackBar();
      YLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
