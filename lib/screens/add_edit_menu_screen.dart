// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/currency_input_formatter.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/input_field.dart';
class AddEditMenuScreen extends StatefulWidget {
  final Menu? menu;
  const AddEditMenuScreen({super.key, this.menu});

  @override
  State<AddEditMenuScreen> createState() => _AddEditMenuScreenState();
}

class _AddEditMenuScreenState extends State<AddEditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();
  File? image;

  void getImage(ImageSource imageSoruce) async {
    final pickedFile = await ImagePicker().pickImage(source: imageSoruce);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> saveMenu() async {}

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      name.text = widget.menu!.name;
      price.text = widget.menu!.price.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: Text(
          widget.menu == null ? "Tambah Menu" : "Update Menu",
          style: AppTheme.appBarTitle,
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gambar Menu", style: AppTheme.textField),
                  image != null
                      ? Image.file(image!, height: 250, width: 250)
                      : Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade300,
                          ),
                        ),
                  const SizedBox(height: 16),
                  Text("Nama Menu", style: AppTheme.textField),
                  InputField(
                    controller: name,
                    hintText: "Menu Name",
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Menu tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Text("Price", style: AppTheme.textField),
                  InputField(
                    controller: price,
                    hintText: "Price",
                    keyboardType: TextInputType.numberWithOptions(),
                    enableCommaSeparator: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Menu tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      getImage(ImageSource.camera);
                    },
                    child: Text("Pick Image from Camera", style: AppTheme.buttonText),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    },
                    child: Text("Pick Image from Gallery", style: AppTheme.buttonText),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final double numericPrice =
                            CurrencyInputFormatter.getNumericalValue(price.text);
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext dialogContext) => AppDialog(
                            type: "loading",
                            title: "Memproses",
                            message: "Mohon tunggu...",
                            onOkPress: () {},
                          ),
                        );

                        if (widget.menu != null) {
                          context.read<MenuBloc>().add(
                                UpdateMenu(widget.menu!.idMenu, name.text, double.parse(price.text),
                                    "id_menu_type"),
                              );
                        } else {
                          Uint8List imageBytes = await image!.readAsBytes();
                          context.read<MenuBloc>().add(
                                AddMenu(
                                  menuName: name.text,
                                  menuPrice: numericPrice,
                                  menuImage: imageBytes,
                                  menuType: "id_menu_type",
                                ),
                              );
                        }
                        // Add new menu
                        // Simpan data ke database
                        Navigator.pop(context);


                        // TODO: ADD OPTION TO CHOOSE WHAT TYPE OF MENU
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext dialogContext) => AppDialog(
                            type: "success",
                            title: "Pengajuan Berhasil",
                            message: "Kembali ke dashboard...",
                            onOkPress: () {},
                          ),
                        );
                        Future.delayed(const Duration(seconds: 1), () {
                          // dismiss loading dialog
                          Navigator.pop(context);
                          Navigator.pop(context);
                          // back to dashboard
                          // Navigator.of(context).pop(true);
                        });
                        // Handle save action
                      }
                    },
                    child: Text("Save", style: AppTheme.buttonText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
