// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/input_field.dart';

class AddEditStockTypeScreen extends StatefulWidget {
  final StockType? stockType;
  const AddEditStockTypeScreen({super.key, this.stockType});

  @override
  State<AddEditStockTypeScreen> createState() => _AddEditStockTypeScreenState();
}

class _AddEditStockTypeScreenState extends State<AddEditStockTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.stockType != null) {
      name.text = widget.stockType!.stockTypeName;
      iconController.text = widget.stockType!.stockTypeIcon ?? '';
      unitController.text = widget.stockType!.stockUnit ?? '';
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
          widget.stockType == null ? "Tambah Tipe Stok" : "Update Tipe Stok",
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
                  Text("Nama Tipe Stok", style: AppTheme.textField),
                  InputField(
                    controller: name,
                    hintText: "Tipe Stok",
                    prefixIcon: const Icon(Iconsax.box),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Nama untuk tipe stok tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Text("Satuan (contoh: kg, liter, pcs)", style: AppTheme.textField),
                  InputField(
                    controller: unitController,
                    hintText: "Satuan Stok",
                    prefixIcon: const Icon(Iconsax.ruler),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 16),
                  Text("Icon (Optional)", style: AppTheme.textField),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      label: Text(
                        "Pilih Icon",
                        style: AppTheme.buttonTextBold,
                      ),
                      style: AppTheme.buttonStyleSecond,
                      onPressed: () {
                        showIconPickerBottomSheet(
                          context,
                          currentIconName: iconController.text,
                          onIconSelected: (iconName, icon) {
                            setState(() {
                              iconController.text = iconName;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      label: Text(
                        "Simpan Tipe Stok",
                        style: AppTheme.buttonText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: AppTheme.buttonStyleSecond,
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

                          if (widget.stockType != null) {
                            context.read<StockTypeBloc>().add(
                                  UpdateStockType(
                                    widget.stockType!,
                                    name.text,
                                    icon: iconController.text.isEmpty ? null : iconController.text,
                                    unit: unitController.text.isEmpty ? null : unitController.text,
                                  ),
                                );
                          } else {
                            context.read<StockTypeBloc>().add(
                                  AddStockType(
                                    name.text,
                                    icon: iconController.text.isEmpty ? null : iconController.text,
                                    unit: unitController.text.isEmpty ? null : unitController.text,
                                  ),
                                );
                          }

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
                            Navigator.pop(context);
                          });
                        }
                      },
                    ),
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
