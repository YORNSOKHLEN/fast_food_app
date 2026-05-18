import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/user_controller.dart';
import '../../../controllers/edit_profile_field_controller.dart';

class EditProfileFieldScreen extends StatelessWidget {
  const EditProfileFieldScreen({
    super.key,
    required this.title,
    required this.label,
    required this.fieldKey,
    required this.initialValue,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.options,
    this.useDatePicker = false,
  });

  final String title;
  final String label;
  final String fieldKey;
  final String initialValue;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<String>? options;
  final bool useDatePicker;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EditProfileFieldController(
        title: title,
        label: label,
        fieldKey: fieldKey,
        initialValue: initialValue,
        validator: validator,
        keyboardType: keyboardType,
        options: options,
        useDatePicker: useDatePicker,
      ),
    );

    return Scaffold(
      appBar: YAppBar(
        showBackArrow: true,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(YSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update your ${label.toLowerCase()} information below.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: YSizes.spaceBtwItems),
            Form(
              key: controller.formKey,
              child: controller.useDropdown
                  ? Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: controller.selectedOption.value,
                        items: controller.dropdownOptions
                            .map(
                              (option) => DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => controller.selectedOption.value = value,
                        validator: validator ??
                            (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return '$label is required.';
                              }
                              return null;
                            },
                        decoration: InputDecoration(labelText: label),
                      ),
                    )
                  : TextFormField(
                      controller: controller.textController,
                      keyboardType: useDatePicker
                          ? TextInputType.none
                          : keyboardType,
                      readOnly: useDatePicker,
                      onTap: useDatePicker ? controller.pickDate : null,
                      validator: validator,
                      decoration: InputDecoration(
                        labelText: label,
                        suffixIcon: useDatePicker
                            ? IconButton(
                                onPressed: controller.pickDate,
                                icon: const Icon(Icons.calendar_today),
                              )
                            : null,
                      ),
                    ),
            ),
            const SizedBox(height: YSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!controller.validateForm()) return;
                  FocusScope.of(context).unfocus();

                  await UserController.instance.updateSingleProfileField(
                    fieldKey: fieldKey,
                    value: controller.getFieldValue(),
                    successMessage: '$title has been updated.',
                  );

                  Get.back();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

