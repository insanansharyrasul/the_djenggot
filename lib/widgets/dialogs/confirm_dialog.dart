import 'package:the_djenggot/utils/theme/text_style.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onOkPress,
    required this.onCancelPress,
    this.okTitle,
    this.cancelTitle,
  });

  final String title;
  final String message;
  final VoidCallback onOkPress;
  final String? okTitle;
  final VoidCallback onCancelPress;
  final String? cancelTitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(
                Iconsax.information,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                title,
                style: createBlackTextStyle(24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                message,
                style: createGreyThinTextStyle(14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onTap: onCancelPress,
                      child: Text(
                        cancelTitle ?? "Kembali",
                        textAlign: TextAlign.end,
                        style: createPrimaryTextStyle(14),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onTap: onOkPress,
                      child: Text(
                        okTitle ?? "Ok",
                        textAlign: TextAlign.end,
                        style: createPrimaryTextStyle(14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
