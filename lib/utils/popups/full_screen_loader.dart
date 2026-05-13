import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/loaders/animation_loader.dart';
import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

class YFullScreenLoader {
  static final _text = ''.obs; // Reactive text for updates

  static void openLoadingDialog(String text, String animation) {
    _text.value = text; // set initial text

    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => Obx(
        () => PopScope(
          canPop: false,
          child: Container(
            color: YHelperFunctions.isDarkMode(Get.context!)
                ? YColors.dark
                : YColors.white,
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    YAnimationLoaderWidget(
                      text: _text.value, // reactive text
                      animation: animation,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Update loading text dynamically
  static updateMessage(String newText) {
    _text.value = newText;
  }

  static stopLoading() {
    final context = Get.overlayContext;
    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Close the dialog using the Navigator
    }
  }
}
