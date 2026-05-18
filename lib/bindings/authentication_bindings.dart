import 'package:get/get.dart';
import 'package:fast_food/features/authentication/controllers/login/login_controller.dart';
import 'package:fast_food/features/authentication/controllers/signup/signup_controller.dart';
import 'package:fast_food/features/authentication/controllers/signup/verify_email_controller.dart';
import 'package:fast_food/features/authentication/controllers/forget_password/forget_password_controller.dart';
import 'package:fast_food/features/authentication/controllers/onboarding/onboarding_controller.dart';

class AuthenticationBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnBoardingController>(() => OnBoardingController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<SignupController>(() => SignupController(), fenix: true);
    Get.lazyPut<VerifyEmailController>(() => VerifyEmailController(), fenix: true);
    Get.lazyPut<ForgetPasswordController>(() => ForgetPasswordController(), fenix: true);
  }
}

