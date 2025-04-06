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
      stockName.text = widget.stock!.name;
      stockQuantity.text = widget.stock!.quantity.toString();
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
                    controller: stockName,
                    hintText: "Stok",
                    errorText: "Nama Stok tidak boleh kosong",
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 8),
                  Text("Kuantitas Stok", style: AppTheme.textField),
                  const SizedBox(height: 8),
                  InputField(
                    controller: stockQuantity,
                    hintText: "Kuantitas",
                    errorText: "Kuantitas tidak boleh kosong dan harus berupa angka",
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
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
                    child: Text(widget.stock == null ? "Simpan" : "Update",
                        style: AppTheme.buttonText),
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
