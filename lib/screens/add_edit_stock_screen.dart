// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/input_field.dart';

class AddEditStockScreen extends StatefulWidget {
  final Stock? stock;
  const AddEditStockScreen({super.key, this.stock});

  @override
  State<AddEditStockScreen> createState() => _AddEditStockScreenState();
}

class _AddEditStockScreenState extends State<AddEditStockScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController stockName = TextEditingController();
  TextEditingController stockQuantity = TextEditingController();
  TextEditingController category = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.stock != null) {
      stockName.text = widget.stock!.stockName;
      stockQuantity.text = widget.stock!.stockQuantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title:
            Text(widget.stock == null ? "Tambah Stok" : "Update Stok", style: AppTheme.appBarTitle),
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
                  Text("Nama Stok", style: AppTheme.textField),
                  const SizedBox(height: 8),
                  InputField(
                    prefixIcon: const Icon(Iconsax.box),
                    controller: stockName,
                    hintText: "Stok",
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Nama Stok tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Text("Kuantitas Stok", style: AppTheme.textField),
                  const SizedBox(height: 8),
                  InputField(
                    prefixIcon: const Icon(Iconsax.box),
                    controller: stockQuantity,
                    hintText: "Kuantitas",
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Kuantitas tidak boleh kosong";
                      }
                      if (int.tryParse(value) == null) {
                        return "Kuantitas harus berupa angka";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Text("Kategori Stok (Optional)", style: AppTheme.textField),
                  const SizedBox(height: 8),
                  // DropdownButton(items: , onChanged: onChanged)
                  ElevatedButton(
                    style: AppTheme.buttonStyle,
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

                        if (stockQuantity.text.isEmpty) {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext dialogContext) => AppDialog(
                              type: "error",
                              title: "Error",
                              message: "Kuantitas tidak boleh kosong",
                              onOkPress: () {},
                            ),
                          );
                          return;
                        }

                        if (stockName.text.isEmpty) {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext dialogContext) => AppDialog(
                              type: "error",
                              title: "Error",
                              message: "Nama Stok tidak boleh kosong",
                              onOkPress: () {},
                            ),
                          );
                          return;
                        }

                        if (int.tryParse(stockQuantity.text) == null) {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext dialogContext) => AppDialog(
                              type: "error",
                              title: "Error",
                              message: "Kuantitas harus berupa angka",
                              onOkPress: () {},
                            ),
                          );
                          return;
                        }

                        if (widget.stock != null) {
                          context.read<StockBloc>().add(
                                UpdateStock(
                                  widget.stock!,
                                  stockName.text,
                                  stockQuantity.text,
                                ),
                              );
                        } else {
                          context.read<StockBloc>().add(
                                AddStock(
                                  stockName: stockName.text,
                                  stockQuantity: int.parse(stockQuantity.text),
                                ),
                              );
                        }
                        // Add new stock
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

                        // TODO: ADD OPTION TO CHOOSE WHAT TYPE OF STOCK
                        Future.delayed(const Duration(milliseconds: 500), () {
                          // dismiss loading dialog
                          Navigator.pop(context);
                          Navigator.pop(context);
                          // back to dashboard
                          // Navigator.of(context).pop(true);
                        });
                        // Handle save action
                      }
                    },
                    child: Text(
                      widget.stock == null ? "Simpan" : "Update",
                      style: AppTheme.buttonText,
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
