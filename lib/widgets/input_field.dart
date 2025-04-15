import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_djenggot/utils/theme/text_style.dart';
import 'package:the_djenggot/widgets/currency_input_formatter.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.enableCommaSeparator = false,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool? enableCommaSeparator;
  final FormFieldValidator<String?>? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        inputFormatters: [
          if (enableCommaSeparator!) ...[
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ]
        ],
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          errorStyle: createRedThinTextStyle(12),
          contentPadding: const EdgeInsets.all(16.0),
          hintText: hintText,
          hintStyle: createGreyThinTextStyle(14),
        ),
        style: createBlackTextStyle(14),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
