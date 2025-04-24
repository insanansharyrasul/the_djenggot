// TODO: Compress image before upload
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_event.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/input_field.dart';

class AddEditTransactionTypeScreen extends StatefulWidget {
  final TransactionType? transactionType;
  const AddEditTransactionTypeScreen({super.key, this.transactionType});

  @override
  State<AddEditTransactionTypeScreen> createState() => _AddEditTransactionTypeScreenState();
}

class _AddEditTransactionTypeScreenState extends State<AddEditTransactionTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController iconController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.transactionType != null) {
      name.text = widget.transactionType!.transactionTypeName;
      iconController.text = widget.transactionType!.transactionTypeIcon;
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
          widget.transactionType == null ? "Tambah Tipe Transaksi" : "Update Tipe Transaksi",
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
                    const Text("Nama Tipe Transaksi", style: AppTheme.textField),
                    InputField(
                      controller: name,
                      hintText: "Tipe Transaksi",
                      prefixIcon: const Icon(Iconsax.receipt),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nama untuk tipe transaksi tidak boleh kosong";
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
                          "Simpan Tipe Transaksi",
                          style: AppTheme.buttonText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: AppTheme.buttonStyleSecond,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (iconController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Pilih icon untuk tipe transaksi"),
                                  backgroundColor: AppTheme.danger,
                                ),
                              );
                              
                              return;
                            }

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

                            if (widget.transactionType != null) {
                              context.read<TransactionTypeBloc>().add(
                                    UpdateTransactionType(
                                      widget.transactionType!,
                                      name.text,
                                      icon:
                                          iconController.text.isEmpty ? null : iconController.text,
                                    ),
                                  );
                            } else {
                              context.read<TransactionTypeBloc>().add(
                                    AddTransactionType(
                                      name.text,
                                      icon:
                                          iconController.text.isEmpty ? null : iconController.text,
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
