// ignore_for_file: use_build_context_synchronously
import 'package:the_djenggot/screens/menu/add_edit_menu_type_screen.dart';
import 'dart:io';
import 'dart:typed_data';
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
import 'package:the_djenggot/utils/theme/text_style.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/dropdown_category.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/input_field.dart';

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
  int totalAmount = 0;
  String? selectedMenuTypeId;
  TextEditingController searchController = TextEditingController();
  final TextEditingController moneyReceivedController = TextEditingController();
  bool isExactChange = true;

  // Current step tracker
  int currentStep = 1;
  // Total steps
  int totalSteps = 3;
  // Step titles
  List<String> stepTitles = ["Pilih Menu", "Pilih Tipe Transaksi", "Bukti Pembayaran"];

  // Add state for search bar visibility
  bool isSearchVisible = false;

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
    moneyReceivedController.dispose();
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
    int sum = 0;
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

  int _calculateChange() {
    if (isExactChange || moneyReceivedController.text.isEmpty) return 0;
    final received =
        int.tryParse(moneyReceivedController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return received - totalAmount;
  }

  // Go to next step
  void _nextStep() {
    if (currentStep < totalSteps) {
      // Validate current step
      if (currentStep == 1) {
        if (cartItems.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pilih minimal satu menu!"),
              backgroundColor: AppTheme.danger,
            ),
          );
          return;
        }
      } else if (currentStep == 2) {
        if (selectedType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pilih tipe transaksi!"),
              backgroundColor: AppTheme.danger,
            ),
          );
          return;
        }

        // Skip evidence step if not needed
        if (currentStep == 2 && !(selectedType?.needEvidence ?? true)) {
          _submitTransaction();
          return;
        }
      }

      setState(() {
        currentStep++;
      });
    } else {
      _submitTransaction();
    }
  }

  // Go to previous step
  void _previousStep() {
    if (currentStep > 1) {
      setState(() {
        currentStep--;
      });
    }
  }

  // Submit the transaction
  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      if ((selectedType?.needEvidence ?? true) && evidenceImage == null && currentStep == 3) {
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
      _processAndSaveTransaction(transactionItems);
    }
  }

  // Process and save the transaction
  Future<void> _processAndSaveTransaction(List<TransactionItem> transactionItems) async {
    // Convert image to bytes
    final imageBytes = selectedType?.needEvidence ?? true
        ? await evidenceImage?.readAsBytes() ?? Uint8List(0)
        : Uint8List(0);

    context.read<TransactionBloc>().add(
          AddNewTransaction(
            selectedType!.idTransactionType,
            totalAmount,
            isExactChange
                ? totalAmount
                : int.parse(moneyReceivedController.text.replaceAll(RegExp(r'[^0-9]'), '')),
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

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: Text(
          stepTitles[currentStep - 1],
          style: AppTheme.appBarTitle,
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            if (currentStep > 1) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: _buildStepIndicator(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Step 1: Select Menu
                  if (currentStep == 1) _buildMenuSelectionStep(formatter),

                  // Step 2: Transaction Type
                  if (currentStep == 2) _buildTransactionTypeStep(),

                  // Step 3: Payment Evidence (if needed)
                  if (currentStep == 3 && (selectedType?.needEvidence ?? true))
                    _buildEvidenceStep(),
                ],
              ),
            ),
            _buildBottomNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // Step indicator with circles and lines
  Widget _buildStepIndicator() {
    return SizedBox(
      height: 40,
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          // Circle indicators (step 1, 3, 5)
          if (index % 2 == 0) {
            final stepNumber = (index ~/ 2) + 1;
            final isCompleted = stepNumber < currentStep;
            final isCurrent = stepNumber == currentStep;

            return Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppTheme.success
                    : (isCurrent ? Colors.blue : Colors.grey.shade300),
              ),
              child: Icon(
                isCompleted ? Icons.check : null,
                color: Colors.white,
                size: 16,
              ),
            );
          }
          // Line connectors (step 2, 4)
          else {
            final prevStepNum = (index ~/ 2) + 1;
            final isCompleted = prevStepNum < currentStep;

            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted ? AppTheme.success : Colors.grey.shade300,
              ),
            );
          }
        }),
      ),
    );
  }

  // Menu list view builder
  Widget _buildMenuListView(MenuState state, NumberFormat formatter) {
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
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling within this list
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
                      color: AppTheme.primary.withValues(alpha: 23),
                    ),
                    child: Center(
                        child: Image.memory(
                      item.menuImage,
                      fit: BoxFit.cover,
                    )),
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
                        icon: const Icon(Iconsax.minus_cirlce, color: AppTheme.danger),
                        onPressed: () {
                          setState(() {
                            if (cartItems.any((cartItem) => cartItem.menu.idMenu == item.idMenu)) {
                              final cartItem = cartItems
                                  .firstWhere((cartItem) => cartItem.menu.idMenu == item.idMenu);
                              if (cartItem.quantity > 1) {
                                cartItem.quantity--;
                              } else {
                                cartItems.remove(cartItem);
                              }
                            }
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
                            if (cartItems.any((cartItem) => cartItem.menu.idMenu == item.idMenu)) {
                              final cartItem = cartItems
                                  .firstWhere((cartItem) => cartItem.menu.idMenu == item.idMenu);
                              cartItem.quantity++;
                            } else {
                              cartItems.add(CartItem(menu: item, quantity: 1));
                            }
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
  }

  // Step 1: Menu Selection UI
  Widget _buildMenuSelectionStep(NumberFormat formatter) {
    return Card(
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
            // Header with category/search toggle
            Row(
              children: [
                const Text("Pilih Menu", style: AppTheme.textField),
                const Spacer(),
                // Search toggle button
                IconButton(
                  icon: Icon(
                    isSearchVisible ? Iconsax.category : Iconsax.search_normal,
                    color: AppTheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      isSearchVisible = !isSearchVisible;
                      if (!isSearchVisible) {
                        searchController.clear();
                        filterMenus();
                      }
                    });
                  },
                ),
                // Add new menu category button
                IconButton(
                  icon: const Icon(Iconsax.add, color: AppTheme.primary),
                  onPressed: () {
                    // Navigate to add menu category screen
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => const AddEditMenuTypeScreen(),
                      ),
                    )
                        .then((_) {
                      // Refresh menu types after returning
                      context.read<MenuTypeBloc>().add(LoadMenuTypes());
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar or Category dropdown
            if (isSearchVisible)
              // Search Bar - visible when search is active
              InputField(
                controller: searchController,
                keyboardType: TextInputType.text,
                prefixIcon: const Icon(Iconsax.search_normal),
                hintText: "Cari nama menu...",
                onChanged: (_) => filterMenus(),
              )
            else
              // Menu Type Selection - visible when search is not active
              BlocBuilder<MenuTypeBloc, MenuTypeState>(
                builder: (context, state) {
                  if (state is MenuTypeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MenuTypeLoaded) {
                    final menuTypes = state.menuTypes;

                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: AppTheme.white,
                      decoration: dropdownCategoryDecoration(
                        prefixIcon: Iconsax.category
                      ),
                      hint: Text(
                        "Pilih Kategori Menu",
                        style: createBlackThinTextStyle(14),
                      ),
                      icon: const Icon(Iconsax.arrow_down_1),
                      borderRadius: BorderRadius.circular(12),
                      value: selectedMenuTypeId,
                      items: [
                        DropdownMenuItem<String>(
                          value: 'all',
                          child: Row(
                            children: [
                              const Icon(Iconsax.category, size: 18, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                "Semua Kategori",
                                style: createBlackThinTextStyle(14),
                              )
                            ],
                          ),
                        ),
                        ...menuTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type.idMenuType,
                            child: Row(
                              children: [
                                Icon(getIconFromString(type.menuTypeIcon),
                                    size: 18, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  type.menuTypeName,
                                  style: createBlackThinTextStyle(14),
                                ),
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
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

            const SizedBox(height: 16),

            // Menu list
            BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                return _buildMenuListView(state, formatter);
              },
            ),

            const SizedBox(height: 16),

            // Payment details moved to bottom bar
            Row(
              children: [
                Checkbox(
                  value: isExactChange,
                  onChanged: (value) {
                    setState(() {
                      isExactChange = value ?? true;
                      if (isExactChange) {
                        moneyReceivedController.text = totalAmount.toString();
                      }
                    });
                  },
                ),
                Text("Uang pas", style: AppTheme.textField.copyWith(fontSize: 14)),
              ],
            ),
            if (!isExactChange) ...[
              const SizedBox(height: 8),
              Text("Uang Diterima", style: AppTheme.textField.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              InputField(
                controller: moneyReceivedController,
                keyboardType: const TextInputType.numberWithOptions(),
                prefixIcon: const Icon(Iconsax.money),
                enableCommaSeparator: true,
                hintText: "contoh: Rp. 12.000",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Harga tidak boleh kosong";
                  }
                  final amount = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                  if (amount < totalAmount) {
                    return "Uang yang diterima kurang dari total";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    isExactChange = false;
                    moneyReceivedController.text = value;
                  }); // Trigger rebuild to update change amount
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Kembalian:",
                        style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      formatter.format(_calculateChange()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Step 2: Transaction Type Selection UI
  Widget _buildTransactionTypeStep() {
    return Card(
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
            // TODO : ADD the ADD TRANSACTION TYPE BUTTON 
            const Text("Pilih Tipe Transaksi", style: AppTheme.textField),
            const SizedBox(height: 16),
            BlocBuilder<TransactionTypeBloc, TransactionTypeState>(
              builder: (context, state) {
                if (state is TransactionTypeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransactionTypeLoaded) {
                  final types = state.transactionTypes;

                  return SizedBox(
                    height: 400, // Fixed height
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: types.length,
                      itemBuilder: (context, index) {
                        final type = types[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: AppTheme.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: selectedType?.idTransactionType == type.idTransactionType
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedType = type;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    getIconFromString(type.transactionTypeIcon),
                                    color: AppTheme.primary,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          type.transactionTypeName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          type.needEvidence
                                              ? "Membutuhkan bukti"
                                              : "Tidak perlu bukti",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (selectedType?.idTransactionType == type.idTransactionType)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
    );
  }

  // Step 3: Evidence Upload UI
  Widget _buildEvidenceStep() {
    return Card(
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
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showImageSourceBottomSheet,
              child: Container(
                width: double.infinity,
                height: 400,
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Iconsax.refresh),
                label: const Text("Ganti Gambar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _showImageSourceBottomSheet,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Bottom navigation buttons with total
  Widget _buildBottomNavigationButtons() {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Total amount display
        if (currentStep == 1 && cartItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.primary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "${cartItems.length} Barang",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
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
          ),

        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (currentStep > 1)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _previousStep,
                    child: const Text('Kembali'),
                  ),
                ),
              if (currentStep > 1) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: AppTheme.buttonStyleSecond,
                  onPressed: _nextStep,
                  icon: currentStep == totalSteps
                      ? const Icon(Iconsax.save_2, color: Colors.white)
                      : const Icon(Iconsax.arrow_right_3, color: Colors.white),
                  label: Text(
                    currentStep == 1
                        ? 'Lanjut'
                        : (currentStep == totalSteps ? 'Simpan Transaksi' : 'Lanjutkan'),
                    style: AppTheme.buttonText.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CartItem {
  final Menu menu;
  int quantity;

  CartItem({required this.menu, required this.quantity});
}

// Make sure to import this if not already imported
