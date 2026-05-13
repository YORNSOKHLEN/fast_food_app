import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fast_food/common/widgets/login_signup/form_divider.dart';
import 'package:fast_food/common/widgets/login_signup/social_buttons.dart';
import 'package:fast_food/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:fast_food/utils/constants/sizes.dart';
import 'package:fast_food/utils/constants/text_strings.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(YSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title section
              Text(
                YText.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: YSizes.sm),
              Text(
                'Create your account to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: YSizes.spaceBtwSections),

              // Form
              SignupForm(),
              const SizedBox(height: YSizes.spaceBtwSections),

              // Divider
              FormDivider(dividerText: YText.orSignUpWith.capitalize!),
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
