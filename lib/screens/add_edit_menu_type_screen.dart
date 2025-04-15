// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/input_field.dart';

class AddEditMenuTypeScreen extends StatefulWidget {
  final MenuType? menuType;
  const AddEditMenuTypeScreen({super.key, this.menuType});

  @override
  State<AddEditMenuTypeScreen> createState() => _AddEditMenuTypeScreenState();
}

class _AddEditMenuTypeScreenState extends State<AddEditMenuTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.menuType != null) {
      name.text = widget.menuType!.name;
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
          widget.menuType == null ? "Tambah Tipe Menu" : "Update Tipe Menu",
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
                  Text("Nama Tipe Menu", style: AppTheme.textField),
                  InputField(
                    controller: name,
                    hintText: "Tipe Menu",
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Nama untuk tipe menu tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
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

                        if (widget.menuType != null) {
                          context.read<MenuTypeBloc>().add(
                            UpdateMenuType(
                              widget.menuType!,
                              name.text,
                            ),
                          );
                        } else {
                          context.read<MenuTypeBloc>().add(
                            AddMenuType(name.text),
                          );
                        }
                        // Add new menu
                        // Simpan data ke database
                        Navigator.pop(context);

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
