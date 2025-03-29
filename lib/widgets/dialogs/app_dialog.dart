import 'package:the_djenggot/widgets/dialogs/confirm_dialog.dart';
import 'package:the_djenggot/widgets/dialogs/error_dialog.dart';
import 'package:the_djenggot/widgets/dialogs/loading_dialog.dart';
import 'package:the_djenggot/widgets/dialogs/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.onOkPress,
    this.okTitle,
    this.cancelTitle,
  });

  final String type;
  final String title;
  final String message;
  final VoidCallback onOkPress;
  final String? okTitle;
  final String? cancelTitle;

  @override
  Widget build(BuildContext context) {
    if (type == "success") {
      return SuccessDialog(title: title, message: message);
    } else if (type == "error") {
      return ErrorDialog(
        title: title,
        message: message,
        onOkPress: onOkPress,
      );
    } else if (type == "confirm") {
      return ConfirmDialog(
        title: title,
        message: message,
        onOkPress: onOkPress,
        onCancelPress: () {
          context.pop(false);
          return;
        },
        okTitle: okTitle,
        cancelTitle: cancelTitle,
      );
    }

    return LoadingDialog(title: title, message: message);
  }
}
