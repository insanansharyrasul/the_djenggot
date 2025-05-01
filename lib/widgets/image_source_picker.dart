import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

Future<File?> showImageSourcePicker(BuildContext context) async {
  File? pickedFile;

  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Pilih Sumber Gambar",
              style: AppTheme.appBarTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imageSourceOption(
                  context: ctx,
                  icon: Iconsax.camera,
                  label: "Kamera",
                  onTap: () {
                    Navigator.pop(ctx, ImageSource.camera);
                  },
                ),
                _imageSourceOption(
                  context: ctx,
                  icon: Iconsax.gallery,
                  label: "Galeri",
                  onTap: () {
                    Navigator.pop(ctx, ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );

  if (source != null) {
    pickedFile = await _getImage(source);
  }

  return pickedFile;
}

Future<File?> _getImage(ImageSource imageSource) async {
  final pickedFile = await ImagePicker().pickImage(source: imageSource);
  if (pickedFile != null) {
    return File(pickedFile.path);
  }
  return null;
}

Widget _imageSourceOption({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTheme.textField),
      ],
    ),
  );
}
