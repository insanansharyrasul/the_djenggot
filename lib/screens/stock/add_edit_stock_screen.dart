import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_state.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/utils/theme/text_style.dart';
import 'package:the_djenggot/widgets/currency_input_formatter.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/dropdown_category.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/input_field.dart';
import 'package:go_router/go_router.dart';

class AddEditStockScreen extends StatefulWidget {
  final Stock? stock;
  const AddEditStockScreen({super.key, this.stock});

  @override
  State<AddEditStockScreen> createState() => _AddEditStockScreenState();
}

class _AddEditStockScreenState extends State<AddEditStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController stockName = TextEditingController();
  final TextEditingController stockQuantity = TextEditingController();
  final TextEditingController stockThreshold = TextEditingController();
  final TextEditingController stockPrice = TextEditingController();
  StockType? selectedStockType;

  @override
  void initState() {
    super.initState();
    if (widget.stock != null) {
      stockName.text = widget.stock!.stockName;
      stockQuantity.text = widget.stock!.stockQuantity.toString();
      stockThreshold.text = widget.stock!.stockThreshold?.toString() ?? '0';
      stockPrice.text = widget.stock!.price.toString();
      context.read<StockTypeBloc>().add(LoadStockTypes());
    } else {
      context.read<StockTypeBloc>().add(LoadStockTypes());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama Stok",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InputField(
                      controller: stockName,
                      hintText: "contoh: Minyak Goreng",
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Iconsax.box),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Nama Stok tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Kuantitas",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InputField(
                            controller: stockQuantity,
                            hintText: "contoh: 100",
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Iconsax.calculator),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Kuantitas tidak boleh kosong";
                              }
                              if (int.tryParse(value) == null) {
                                return "Kuantitas harus berupa angka";
                              }
                              if (int.tryParse(value)! < 0) {
                                return "Kuantitas tidak boleh negatif";
                              }
                              return null;
                            },
                          ),
                        ),
                        if (selectedStockType?.stockUnit != null &&
                            selectedStockType!.stockUnit.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              selectedStockType!.stockUnit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Batas Minimum",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InputField(
                            controller: stockThreshold,
                            hintText: "contoh: 15",
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Iconsax.warning_2),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Batas minimum tidak boleh kosong";
                              }
                              if (int.tryParse(value) == null) {
                                return "Batas minimum harus berupa angka";
                              }
                              if (int.tryParse(value)! < 0) {
                                return "Batas minimum tidak boleh negatif";
                              }
                              return null;
                            },
                          ),
                        ),
                        if (selectedStockType?.stockUnit != null &&
                            selectedStockType!.stockUnit.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              selectedStockType!.stockUnit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Harga Satuan (Rp)",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InputField(
                      controller: stockPrice,
                      hintText: "contoh: Rp.15.000",
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Iconsax.money),
                      enableCommaSeparator: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Harga tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Kategori Stok",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<StockTypeBloc, StockTypeState>(
                      builder: (context, state) {
                        if (state is StockTypeLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is StockTypeLoaded) {
                          final stockTypes = state.stockTypes;

                          if (widget.stock != null && selectedStockType == null) {
                            for (var type in stockTypes) {
                              if (type.idStockType == widget.stock!.idStockType.idStockType) {
                                selectedStockType = type;
                                break;
                              }
                            }
                          }

                          if (stockTypes.isEmpty) {
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Iconsax.info_circle,
                                        color: Colors.amber,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Belum ada kategori stok",
                                        style: AppTheme.textField.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Silahkan buat kategori stok terlebih dahulu",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.amber.shade800),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        icon: const Icon(Iconsax.add_circle),
                                        label: const Text("Buat Kategori Stok"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          context.push('/add-edit-stock-type').then((_) {
                                            context.read<StockTypeBloc>().add(LoadStockTypes());
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              DropdownButtonFormField<StockType>(
                                value: selectedStockType,
                                decoration: dropdownCategoryDecoration(
                                  prefixIcon: Iconsax.category,
                                ),
                                hint: Text(
                                  "Pilih Kategori Stok",
                                  style: createBlackThinTextStyle(14),
                                ),
                                items: stockTypes.map((type) {
                                  return DropdownMenuItem<StockType>(
                                    value: type,
                                    child: Row(
                                      children: [
                                        if (type.stockTypeIcon.isNotEmpty)
                                          Icon(
                                            getIconFromString(type.stockTypeIcon),
                                            color: AppTheme.primary,
                                            size: 18,
                                          ),
                                        if (type.stockTypeIcon.isNotEmpty)
                                          const SizedBox(width: 12),
                                        Text(type.stockTypeName),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedStockType = newValue;
                                  });
                                },
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                icon: const Icon(Iconsax.arrow_down_1),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Iconsax.add, size: 16),
                                  label: const Text("Tambah Kategori Baru"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primary,
                                  ),
                                  onPressed: () {
                                    context
                                        .push(
                                      '/add-edit-stock-type',
                                    )
                                        .then((_) {
                                      context.read<StockTypeBloc>().add(LoadStockTypes());
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        } else if (state is StockTypeError) {
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  "Error loading stock types: ${state.message}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<StockTypeBloc>().add(LoadStockTypes());
                                  },
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Iconsax.tick_square, color: Colors.white),
                        label: Text(
                          "Simpan Stok",
                          style: AppTheme.buttonText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

                            final int numericPrice =
                                CurrencyInputFormatter.getNumericalValue(stockPrice.text);
                            final int threshold = int.tryParse(stockThreshold.text) ?? 0;
                            // final int price = int.tryParse(stockPrice.text) ?? 0;

                            if (widget.stock != null) {
                              context.read<StockBloc>().add(
                                    UpdateStock(
                                      widget.stock!,
                                      stockName.text,
                                      stockQuantity.text,
                                      selectedStockType!.idStockType,
                                      threshold,
                                      numericPrice,
                                    ),
                                  );
                            } else {
                              context.read<StockBloc>().add(
                                    AddStock(
                                      stockName: stockName.text,
                                      stockQuantity: int.parse(stockQuantity.text),
                                      stockType: selectedStockType,
                                      threshold: threshold,
                                      price: numericPrice,
                                    ),
                                  );
                            }

                            final navigator = Navigator.of(context);
                            navigator.pop();

                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext dialogContext) => AppDialog(
                                type: "success",
                                title: "Berhasil",
                                message: widget.stock == null
                                    ? "Stok berhasil ditambahkan"
                                    : "Stok berhasil diperbarui",
                                onOkPress: () {},
                              ),
                            );

                            Future.delayed(const Duration(milliseconds: 500), () {
                              navigator.pop();
                              navigator.pop();
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
