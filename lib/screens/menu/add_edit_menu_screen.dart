// ignore_for_file: use_build_context_synchronously
// TODO : Compress image before upload

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_state.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/currency_input_formatter.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/input_field.dart';
import 'package:go_router/go_router.dart';

class AddEditMenuScreen extends StatefulWidget {
  final Menu? menu;
  const AddEditMenuScreen({super.key, this.menu});

  @override
  State<AddEditMenuScreen> createState() => _AddEditMenuScreenState();
}

class _AddEditMenuScreenState extends State<AddEditMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();
  File? image;
  MenuType? selectedMenuType;

  void getImage(ImageSource imageSource) async {
    final pickedFile = await ImagePicker().pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
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

  Future<void> saveMenu() async {}

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      name.text = widget.menu!.menuName;
      price.text = widget.menu!.menuPrice.toString();
      // Load menu types to find the current one
      context.read<MenuTypeBloc>().add(LoadMenuTypes());
    } else {
      // Load menu types for dropdown
      context.read<MenuTypeBloc>().add(LoadMenuTypes());
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
          widget.menu == null ? "Tambah Menu" : "Update Menu",
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
                    // Image Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Gambar Menu",
                            style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _showImageSourceBottomSheet,
                            child: Center(
                              child: widget.menu?.menuImage != null || image != null
                                  ? Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: image != null
                                              ? FileImage(image!)
                                              : MemoryImage(widget.menu!.menuImage!),
                                          fit: BoxFit.cover,
                                        ),
                                        // ),
                                      ),
                                    )
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.shade100,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                          // style: BorderStyle.dashed,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Iconsax.camera,
                                            size: 48,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Tap untuk pilih gambar",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Form Fields
                    Text(
                      "Nama Menu",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InputField(
                      controller: name,
                      hintText: "Nama Menu",
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Iconsax.coffee),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Menu tidak boleh kosong";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Harga",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InputField(
                      controller: price,
                      hintText: "Harga Menu",
                      keyboardType: const TextInputType.numberWithOptions(),
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
                      "Kategori Menu",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Menu Type Dropdown
                    BlocBuilder<MenuTypeBloc, MenuTypeState>(
                      builder: (context, state) {
                        if (state is MenuTypeLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is MenuTypeLoaded) {
                          final menuTypes = state.menuTypes;

                          // If menu is being edited, try to find its menu type in the list
                          if (widget.menu != null && selectedMenuType == null) {
                            for (var type in menuTypes) {
                              if (type.idMenuType == widget.menu!.idMenuType.idMenuType) {
                                selectedMenuType = type;
                                break;
                              }
                            }
                          }
                          // Check if menu types list is empty
                          if (menuTypes.isEmpty) {
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
                                        "Belum ada kategori menu",
                                        style: AppTheme.textField.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Silahkan buat kategori menu terlebih dahulu",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.amber.shade800),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        icon: const Icon(Iconsax.add_circle),
                                        label: const Text("Buat Kategori Menu"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          context.push('/add-edit-menu-type').then((_) {
                                            // Reload menu types when returning from add screen
                                            context.read<MenuTypeBloc>().add(LoadMenuTypes());
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
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonFormField<MenuType>(
                                  value: selectedMenuType,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Iconsax.category),
                                    border: InputBorder.none,
                                    // contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                    hintText: "Pilih Kategori Menu",
                                    hintStyle: TextStyle(color: Colors.grey.shade500),
                                  ),
                                  validator: (value) {
                                    if (value == null) {
                                      return "Kategori menu harus dipilih";
                                    }
                                    return null;
                                  },
                                  items: menuTypes.map((type) {
                                    return DropdownMenuItem<MenuType>(
                                      value: type,
                                      child: Row(
                                        children: [
                                          if (type.menuTypeIcon != null &&
                                              type.menuTypeIcon!.isNotEmpty)
                                            Icon(
                                              getIconFromString(type.menuTypeIcon!),
                                              color: AppTheme.primary,
                                              size: 18,
                                            ),
                                          if (type.menuTypeIcon != null &&
                                              type.menuTypeIcon!.isNotEmpty)
                                            const SizedBox(width: 12),
                                          Text(type.menuTypeName),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedMenuType = newValue;
                                    });
                                  },
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  icon: const Icon(Iconsax.arrow_down_1),
                                ),
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
                                    context.push('/add-edit-menu-type').then((_) {
                                      // Reload menu types when returning from add screen
                                      context.read<MenuTypeBloc>().add(LoadMenuTypes());
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        } else if (state is MenuTypeError) {
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  "Error loading menu types: ${state.message}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<MenuTypeBloc>().add(LoadMenuTypes());
                                  },
                                  child: const Text("Retry"),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container(); // Fallback
                      },
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Submit Button
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
                          "Simpan Menu",
                          style: AppTheme.buttonText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (image == null && widget.menu == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Harap pilih gambar menu"),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }

                            if (selectedMenuType == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Harap pilih kategori menu"),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }

                            final double numericPrice =
                                CurrencyInputFormatter.getNumericalValue(price.text);
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

                            if (widget.menu != null) {
                              context.read<MenuBloc>().add(
                                    UpdateMenu(
                                      widget.menu!,
                                      name.text,
                                      numericPrice,
                                      selectedMenuType!.idMenuType,
                                      widget.menu!.menuImage,
                                    ),
                                  );
                            } else {
                              Uint8List imageBytes = await image!.readAsBytes();
                              context.read<MenuBloc>().add(
                                    AddMenu(
                                      menuName: name.text,
                                      menuPrice: numericPrice,
                                      menuImage: imageBytes,
                                      menuType: selectedMenuType!.idMenuType,
                                    ),
                                  );
                            }
                            Navigator.pop(context);

                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext dialogContext) => AppDialog(
                                type: "success",
                                title: "Berhasil",
                                message: widget.menu == null
                                    ? "Menu berhasil ditambahkan"
                                    : "Menu berhasil diperbarui",
                                onOkPress: () {},
                              ),
                            );

                            Future.delayed(const Duration(milliseconds: 500), () {
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
