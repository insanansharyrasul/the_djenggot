import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_state.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/utils/theme/text_style.dart';
import 'package:the_djenggot/widgets/currency_input_formatter.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/dropdown_category.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/image_source_picker.dart';
import 'package:the_djenggot/widgets/input_field.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      name.text = widget.menu!.menuName;
      price.text = widget.menu!.menuPrice.toString();
      context.read<MenuTypeBloc>().add(LoadMenuTypes());
    } else {
      context.read<MenuTypeBloc>().add(LoadMenuTypes());
    }
  }

  @override
  void dispose() {
    name.dispose();
    price.dispose();
    super.dispose();
  }

  Future<Uint8List> compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) return bytes;

    img.Image resized;
    if (image.width > 1024 || image.height > 1024) {
      int targetWidth, targetHeight;
      if (image.width > image.height) {
        targetWidth = 1024;
        targetHeight = (1024 * image.height / image.width).round();
      } else {
        targetHeight = 1024;
        targetWidth = (1024 * image.width / image.height).round();
      }
      resized = img.copyResize(image, width: targetWidth, height: targetHeight);
    } else {
      resized = image;
    }

    return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
  }

  String? validateMenuName(String? value) {
    if (value == null || value.isEmpty) {
      return "Menu tidak boleh kosong";
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return "Harga tidak boleh kosong";
    }
    return null;
  }

  Widget _buildImageWidget() {
    if (widget.menu?.menuImage != null && image == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: MemoryImage(widget.menu!.menuImage),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (image != null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: FileImage(image!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
          border: Border.all(
            color: Colors.grey.shade400,
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            onTap: _isProcessing ? null : _showImageSourceBottomSheet,
                            child: _buildImageWidget(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    Text(
                      "Nama Menu",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InputField(
                      controller: name,
                      hintText: "contoh: Nasi Goreng",
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Iconsax.coffee),
                      validator: validateMenuName,
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Harga",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InputField(
                      controller: price,
                      hintText: "contoh: 15.000",
                      keyboardType: const TextInputType.numberWithOptions(),
                      prefixIcon: const Icon(Iconsax.money),
                      enableCommaSeparator: true,
                      validator: validatePrice,
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Kategori Menu",
                      style: AppTheme.textField.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    _buildMenuTypeDropdown(),

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
                          _isProcessing ? "Memproses..." : "Simpan Menu",
                          style: AppTheme.buttonText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _isProcessing ? null : _saveMenu,
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

  Widget _buildMenuTypeDropdown() {
    return BlocBuilder<MenuTypeBloc, MenuTypeState>(
      builder: (context, state) {
        if (state is MenuTypeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is MenuTypeLoaded) {
          final menuTypes = state.menuTypes;

          if (widget.menu != null && selectedMenuType == null) {
            for (var type in menuTypes) {
              if (type.idMenuType == widget.menu!.idMenuType.idMenuType) {
                selectedMenuType = type;
                break;
              }
            }
          }
          if (menuTypes.isEmpty) {
            return _buildEmptyMenuTypesWidget();
          }

          return _buildMenuTypeSelector(menuTypes);
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
        return Container(); 
      },
    );
  }

  Widget _buildEmptyMenuTypesWidget() {
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

  Widget _buildMenuTypeSelector(List<MenuType> menuTypes) {
    return Column(
      children: [
        DropdownButtonFormField<MenuType>(
          value: selectedMenuType,
          decoration: dropdownCategoryDecoration(
            prefixIcon: Iconsax.category,
          ),
          hint: Text(
            "Pilih Kategori Menu",
            style: createBlackThinTextStyle(14),
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
                  if (type.menuTypeIcon.isNotEmpty)
                    Icon(
                      getIconFromString(type.menuTypeIcon),
                      color: AppTheme.primary,
                      size: 18,
                    ),
                  if (type.menuTypeIcon.isNotEmpty) const SizedBox(width: 12),
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
                context.read<MenuTypeBloc>().add(LoadMenuTypes());
              });
            },
          ),
        ),
      ],
    );
  }

  void _showImageSourceBottomSheet() async {
    final File? pickedFile = await showImageSourcePicker(context);
    if (pickedFile != null) {
      setState(() {
        image = pickedFile;
      });
    }
  }

  Future<void> _saveMenu() async {
    if (_isProcessing) return;

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

      setState(() {
        _isProcessing = true;
      });

      final int numericPrice = CurrencyInputFormatter.getNumericalValue(price.text);

      final navigator = Navigator.of(context);
      try {
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
          Uint8List imageBytes;
          if (image != null) {
            imageBytes = await compressImage(image!);
          } else {
            imageBytes = widget.menu!.menuImage;
          }

          context.read<MenuBloc>().add(
                UpdateMenu(
                  widget.menu!,
                  name.text,
                  numericPrice,
                  selectedMenuType!.idMenuType,
                  imageBytes,
                ),
              );
        } else {
          Uint8List imageBytes = await compressImage(image!);
          context.read<MenuBloc>().add(
                AddMenu(
                  menuName: name.text,
                  menuPrice: numericPrice,
                  menuImage: imageBytes,
                  menuType: selectedMenuType!.idMenuType,
                ),
              );
        }
        navigator.pop(); 

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext dialogContext) => AppDialog(
            type: "success",
            title: "Berhasil",
            message: widget.menu == null ? "Menu berhasil ditambahkan" : "Menu berhasil diperbarui",
            onOkPress: () {},
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          navigator.pop();
          navigator.pop();
        });
      } catch (e) {
        navigator.pop(); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
