import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/features/authentication/screens/login/widgets/login_form.dart';
import 'package:fast_food/features/authentication/screens/login/widgets/login_header.dart';

import '../../../../common/styles/spacing_styles.dart';
import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/social_buttons.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: YSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              // Login Header with Logo
              const SizedBox(height: YSizes.spaceBtwSections),
              LoginHeader(),
              const SizedBox(height: YSizes.spaceBtwSections),

              // Form
              LoginForm(),
              const SizedBox(height: YSizes.spaceBtwSections),

              // Divider
              FormDivider(dividerText: YText.orSignInWith.capitalize!),
              const SizedBox(height: YSizes.spaceBtwSections),

              // Social Buttons
              const SocialButton(),
              const SizedBox(height: YSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}
