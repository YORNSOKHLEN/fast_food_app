import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileFieldController extends GetxController {
  late final GlobalKey<FormState> formKey;
  late final TextEditingController textController;
  final Rxn<String> selectedOption = Rxn<String>();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  final String title;
  final String label;
  final String fieldKey;
  final String initialValue;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<String>? options;
  final bool useDatePicker;

  EditProfileFieldController({
    required this.title,
    required this.label,
    required this.fieldKey,
    required this.initialValue,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.options,
    this.useDatePicker = false,
  });

  bool get useDropdown => options != null && options!.isNotEmpty;

  List<String> get dropdownOptions {
    final opts = List<String>.from(options ?? const []);
    final initial = initialValue.trim();
    if (initial.isNotEmpty && !opts.contains(initial)) {
      opts.insert(0, initial);
    }
    return opts;
  }

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
    textController = TextEditingController(text: initialValue);

    if (useDropdown) {
      final initial = initialValue.trim();
      selectedOption.value = initial.isEmpty ? null : initial;
    }

    if (useDatePicker) {
      selectedDate.value = DateTime.tryParse(initialValue.trim());
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  /// Format date to YYYY-MM-DD
  String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Pick date using date picker
  Future<void> pickDate() async {
    final now = DateTime.now();
    final initialDate =
        selectedDate.value ?? DateTime(now.year - 18, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;
      textController.text = formatDate(pickedDate);
    }
  }

  /// Get current field value
  String getFieldValue() {
    if (useDropdown) {
      return (selectedOption.value ?? '').trim();
    }
    return textController.text.trim();
  }

  /// Validate form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }
}

