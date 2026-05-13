import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/signup/signup_controller.dart';

class YTermsAndConditionsCheckbox extends StatelessWidget {
  const YTermsAndConditionsCheckbox({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = YHelperFunctions.isDarkMode(context);
    final controller = SignupController.instance;
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(() {
            return Checkbox(
              value: controller.privacyPolicy.value,
              onChanged: (value) => controller.privacyPolicy.value =
                  !controller.privacyPolicy.value,
            );
          }),
        ),
        const SizedBox(width: YSizes.spaceBtwItems),

        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${YText.iAgreeTo} ',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                TextSpan(
                  text: '${YText.privacyPolicy} ',
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: dark ? YColors.light : YColors.buttonPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: dark ? YColors.light : YColors.buttonPrimary,
                  ),
                ),
                TextSpan(
                  text: '${YText.and} ',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                TextSpan(
                  text: '${YText.termsOfUse} ',
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: dark ? YColors.light : YColors.buttonPrimary,
                    decoration: TextDecoration.underline,
                    decorationColor: dark ? YColors.light : YColors.buttonPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
