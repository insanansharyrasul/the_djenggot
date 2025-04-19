// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/menu/menu_state.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_state.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_event.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_state.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/transaction/transaction_item.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  TransactionType? selectedType;
  List<Menu> menus = [];
  List<Menu> filteredMenus = [];
  List<CartItem> cartItems = [];
  File? evidenceImage;
  double totalAmount = 0;
  String? selectedMenuTypeId;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionTypeBloc>().add(LoadTransactionTypes());
    context.read<MenuBloc>().add(LoadMenu());
    context.read<MenuTypeBloc>().add(LoadMenuTypes());
    searchController.addListener(() {
      filterMenus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterMenus() {
    if (menus.isEmpty) return;

    setState(() {
      filteredMenus = menus.where((menu) {
        // Filter by type if a type is selected (not "All")
        bool matchesType = selectedMenuTypeId == null ||
            selectedMenuTypeId == 'all' ||
            menu.idMenuType.idMenuType == selectedMenuTypeId;

        // Filter by search text
        bool matchesSearch = searchController.text.isEmpty ||
            menu.menuName.toLowerCase().contains(searchController.text.toLowerCase());

        return matchesType && matchesSearch;
      }).toList();
    });
  }

  void calculateTotal() {
    double sum = 0;
    for (var item in cartItems) {
      sum += item.menu.menuPrice * item.quantity;
    }
    setState(() {
      totalAmount = sum;
    });
  }

  void getImage(ImageSource imageSource) async {
    final pickedFile = await ImagePicker().pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        evidenceImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
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
                    icon: Iconsax.camera,
                    label: "Kamera",
                    onTap: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                  ),
                  _imageSourceOption(
                    icon: Iconsax.gallery,
                    label: "Galeri",
                    onTap: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
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
  }

  Widget _imageSourceOption({
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

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: const Text(
          "Tambah Transaksi",
          style: AppTheme.appBarTitle,
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Add Items Section
            Card(
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
                    const Text("Pilih Menu", style: AppTheme.textField),
                    const SizedBox(height: 16),

                    // Menu Type Selection
                    Text("Filter Kategori Menu", style: AppTheme.textField.copyWith(fontSize: 14)),
                    const SizedBox(height: 8),
                    BlocBuilder<MenuTypeBloc, MenuTypeState>(
                      builder: (context, state) {
                        if (state is MenuTypeLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state is MenuTypeLoaded) {
                          final menuTypes = state.menuTypes;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  border: InputBorder.none,
                                ),
                                value: selectedMenuTypeId,
                                hint: const Text("Semua Kategori"),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'all',
                                    child: Row(
                                      children: [
                                        Icon(Iconsax.category, size: 18, color: AppTheme.primary),
                                        SizedBox(width: 8),
                                        Text("Semua Kategori"),
                                      ],
                                    ),
                                  ),
                                  ...menuTypes.map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type.idMenuType,
                                      child: Row(
                                        children: [
                                          Icon(
                                              type.menuTypeIcon != null
                                                  ? getIconFromString(type.menuTypeIcon!)
                                                  : Iconsax.category,
                                              size: 18,
                                              color: AppTheme.primary),
                                          const SizedBox(width: 8),
                                          Text(type.menuTypeName),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedMenuTypeId = value;
                                  });
                                  filterMenus();
                                },
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 16),

                    // Search Bar
                    Text("Cari Menu", style: AppTheme.textField.copyWith(fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Cari nama menu...",
                        prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Menu Selection Dropdown
                    Text("Pilih Menu", style: AppTheme.textField.copyWith(fontSize: 14)),
                    const SizedBox(height: 8),
                    BlocBuilder<MenuBloc, MenuState>(
                      builder: (context, state) {
                        if (state is MenuLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state is MenuLoaded) {
                          menus = state.menus;

                          // Initial filtering if not yet done
                          if (filteredMenus.isEmpty) {
                            filteredMenus = menus;
                          }

                          if (filteredMenus.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text(
                                  "Tidak ada menu yang tersedia dengan filter ini",
                                  style: TextStyle(color: Colors.grey.shade600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredMenus.length,
                            itemBuilder: (context, index) {
                              final item = filteredMenus[index];
                              return Card(
                                color: AppTheme.white,
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: AppTheme.primary.withOpacity(0.1),
                                        ),
                                        child: Center(
                                          child: item.menuImage != null
                                              ? Image.memory(
                                                  item.menuImage!,
                                                  fit: BoxFit.cover,
                                                )
                                              : const Icon(
                                                  Iconsax.coffee,
                                                  color: AppTheme.primary,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.menuName,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              formatter.format(item.menuPrice),
                                              style: const TextStyle(color: AppTheme.primary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon:
                                                const Icon(Iconsax.minus_cirlce, color: AppTheme.danger),
                                            onPressed: () {
                                              setState(() {
                                                if (cartItems.any((cartItem) =>
                                                    cartItem.menu.idMenu == item.idMenu)) {
                                                  final cartItem = cartItems.firstWhere(
                                                      (cartItem) =>
                                                          cartItem.menu.idMenu == item.idMenu);
                                                  if (cartItem.quantity > 1) {
                                                    cartItem.quantity--;
                                                  } else {
                                                    cartItems.remove(cartItem);
                                                  }
                                                } else {
                                                  cartItems.add(CartItem(menu: item, quantity: 1));
                                                }
                                                // if (item. > 1) {
                                                //   item.quantity--;
                                                // } else {
                                                //   cartItems.removeAt(index);
                                                // }
                                                calculateTotal();
                                              });
                                            },
                                          ),
                                          Text(
                                            "${cartItems.firstWhere((cartItem) => cartItem.menu.idMenu == item.idMenu, orElse: () => CartItem(menu: item, quantity: 0)).quantity}",
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          IconButton(
                                            icon: const Icon(Iconsax.add_circle, color: AppTheme.primary),
                                            onPressed: () {
                                              setState(() {
                                                if (cartItems.any((cartItem) =>
                                                    cartItem.menu.idMenu == item.idMenu)) {
                                                  final cartItem = cartItems.firstWhere(
                                                      (cartItem) =>
                                                          cartItem.menu.idMenu == item.idMenu);
                                                  cartItem.quantity++;
                                                } else {
                                                  cartItems.add(CartItem(menu: item, quantity: 1));
                                                }
                                                // item.quantity++;
                                                calculateTotal();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        if (state is MenuError) {
                          return Text('Error: ${state.message}');
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          formatter.format(totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Transaction Type Selection
            Card(
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
                    const Text("Pilih Tipe Transaksi", style: AppTheme.textField),
                    const SizedBox(height: 8),
                    BlocBuilder<TransactionTypeBloc, TransactionTypeState>(
                      builder: (context, state) {
                        if (state is TransactionTypeLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state is TransactionTypeLoaded) {
                          final types = state.transactionTypes;

                          return DropdownButtonFormField<TransactionType>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            dropdownColor: Colors.white,
                            hint: const Text("Pilih tipe transaksi"),
                            value: selectedType,
                            items: types.map((type) {
                              return DropdownMenuItem<TransactionType>(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(
                                      type.transactionTypeIcon != null
                                          ? getIconFromString(type.transactionTypeIcon!)
                                          : Iconsax.receipt,
                                      color: AppTheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(type.transactionTypeName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedType = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Pilih tipe transaksi";
                              }
                              return null;
                            },
                          );
                        }

                        if (state is TransactionTypeError) {
                          return Text('Error: ${state.message}');
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Payment Evidence
            Card(
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
                    const Text("Bukti Pembayaran", style: AppTheme.textField),
                    const SizedBox(height: 8),
                    GestureDetector(
                      // onTap: pickImage,
                      onTap: _showImageSourceBottomSheet,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: evidenceImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  evidenceImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.image, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text("Ketuk untuk memilih gambar"),
                                ],
                              ),
                      ),
                    ),
                    if (evidenceImage != null) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Iconsax.refresh),
                        label: const Text("Ganti Gambar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                        // onPressed: pickImage,
                        onPressed: _showImageSourceBottomSheet,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.save_2),
                label: Text(
                  "Simpan Transaksi",
                  style: AppTheme.buttonText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: AppTheme.buttonStyleSecond,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (cartItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Pilih minimal satu menu!"),
                          backgroundColor: AppTheme.danger,
                        ),
                      );
                      return;
                    }

                    if (evidenceImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tambahkan bukti pembayaran!"),
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

                    // Convert cartItems to TransactionItems
                    List<TransactionItem> transactionItems = cartItems.map((item) {
                      return TransactionItem(
                        idTransactionItem: '', // Will be generated by repository
                        idTransactionHistory: '', // Will be set by repository
                        menu: item.menu,
                        transactionQuantity: item.quantity,
                      );
                    }).toList();

                    // Convert image to bytes
                    final imageBytes = await evidenceImage!.readAsBytes();

                    context.read<TransactionBloc>().add(
                          AddNewTransaction(
                            selectedType!.idTransactionType,
                            totalAmount,
                            imageBytes,
                            transactionItems,
                          ),
                        );

                    Navigator.pop(context); // Close loading dialog

                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext dialogContext) => AppDialog(
                        type: "success",
                        title: "Berhasil",
                        message: "Transaksi berhasil disimpan",
                        onOkPress: () {},
                      ),
                    );

                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pop(context); // Close success dialog
                      Navigator.pop(context); // Back to transaction list
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final Menu menu;
  int quantity;

  CartItem({required this.menu, required this.quantity});
}
