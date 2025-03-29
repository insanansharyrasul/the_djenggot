import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/input_field.dart';

class AddEditStockScreen extends StatefulWidget {
  const AddEditStockScreen({super.key});

  @override
  State<AddEditStockScreen> createState() => _AddEditStockScreenState();
}

class _AddEditStockScreenState extends State<AddEditStockScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController stockName = TextEditingController();
  TextEditingController stockQuantity = TextEditingController();
  TextEditingController category = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DjenggotAppTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DjenggotAppTheme.background,
        centerTitle: true,
        title: const Text("Add/Edit Stock", style: DjenggotAppTheme.appBarTitle),
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
                  Text("Nama Stok", style: DjenggotAppTheme.textField),
                  const SizedBox(height: 8),
                  InputField(
                    controller: stockName,
                    hintText: "Stok",
                    errorText: "Nama Stok tidak boleh kosong",
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 8),
                  Text("Kuantitas Stok", style: DjenggotAppTheme.textField),
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
                        context.read<StockBloc>().add(
                          AddStock(
                            stockName: stockName.text,
                            stockQuantity: int.parse(stockQuantity.text),
                          ),
                        );
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
                        Future.delayed(const Duration(seconds: 2), () {
                          // dismiss loading dialog
                          Navigator.pop(context);
                          Navigator.pop(context);
                          // back to dashboard
                          // Navigator.of(context).pop(true);
                        });
                        // Handle save action
                      }
                    },
                    child: Text("Simpan", style: DjenggotAppTheme.buttonText),
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
