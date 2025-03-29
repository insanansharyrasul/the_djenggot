import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/text_style.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.errorText,
    required this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final String errorText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
            controller: controller,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return errorText;
              }
              return null;
            },
          ),
    );
  }
}