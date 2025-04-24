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
      iconController.text = widget.stockType!.stockTypeIcon;
      unitController.text = widget.stockType!.stockUnit;
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
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppTheme.background,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nama Tipe Stok", style: AppTheme.textField),
                    InputField(
                      controller: name,
                      hintText: "contoh: Daging-dagingan", // Change from "Tipe Stok"
                      prefixIcon: const Icon(Iconsax.box),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nama untuk tipe stok tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Satuan (contoh: kg, liter, pcs)", style: AppTheme.textField),
                    InputField(
                      controller: unitController,
                      hintText: "contoh: kg, liter, pcs", // Changed from "Satuan Stok"
                      prefixIcon: const Icon(Iconsax.ruler),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Satuan untuk tipe stok tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Icon", style: AppTheme.textField),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              label: const Text(
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
                        ),
                        Flexible(
                          child: Icon(
                            iconController.text.isEmpty
                                ? Icons.abc
                                : getIconFromString(iconController.text),
                            color: AppTheme.primary,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
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
                          if (iconController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Icon tidak boleh kosong"),
                              backgroundColor: AppTheme.danger,
                            ));
                            return;
                          }

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
                                      iconController.text,
                                      unitController.text,
                                    ),
                                  );
                            } else {
                              context.read<StockTypeBloc>().add(
                                    AddStockType(
                                      name.text,
                                      iconController.text,
                                      unitController.text,
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
          ),
        ],
      ),
    );
  }
}
