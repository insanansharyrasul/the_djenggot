import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class MenuFilterFab extends StatelessWidget {
  final MenuType? selectedType;
  final String sortBy;
  final List<MenuType> menuTypes;
  final Function(MenuType?) onTypeChanged;
  final Function(String) onSortChanged;

  const MenuFilterFab({
    super.key,
    this.selectedType,
    required this.sortBy,
    required this.menuTypes,
    required this.onTypeChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Iconsax.filter,
      activeIcon: Iconsax.close_circle,
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.white,
      activeBackgroundColor: AppTheme.danger,
      activeForegroundColor: AppTheme.white,
      spacing: 8,
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      children: [
        SpeedDialChild(
          child: const Icon(Iconsax.category, color: AppTheme.primary),
          backgroundColor: AppTheme.white,
          labelStyle: AppTheme.subtitle.copyWith(color: AppTheme.darkText),
          label: 'Filter Kategori',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Pilih Kategori', style: AppTheme.headline.copyWith(fontSize: 18)),
                backgroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Semua Kategori', style: AppTheme.body1),
                        selected: selectedType == null,
                        selectedColor: AppTheme.primary,
                        onTap: () {
                          onTypeChanged(null);
                          Navigator.pop(context);
                        },
                      ),
                      ...menuTypes.map((type) => ListTile(
                            leading:
                                Icon(getIconFromString(type.menuTypeIcon), color: AppTheme.primary),
                            title: Text(type.menuTypeName, style: AppTheme.body1),
                            selected: selectedType?.idMenuType == type.idMenuType,
                            selectedColor: AppTheme.primary,
                            onTap: () {
                              onTypeChanged(type);
                              Navigator.pop(context);
                            },
                          )),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Iconsax.sort, color: AppTheme.primary),
          backgroundColor: AppTheme.white,
          labelStyle: AppTheme.subtitle.copyWith(color: AppTheme.darkText),
          label: 'Urutkan',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Urutkan Berdasarkan', style: AppTheme.headline.copyWith(fontSize: 18)),
                backgroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Nama (A-Z)', style: AppTheme.body1),
                      selected: sortBy == 'nameAsc',
                      selectedColor: AppTheme.primary,
                      onTap: () {
                        onSortChanged('nameAsc');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Nama (Z-A)', style: AppTheme.body1),
                      selected: sortBy == 'nameDesc',
                      selectedColor: AppTheme.primary,
                      onTap: () {
                        onSortChanged('nameDesc');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Harga (Rendah-Tinggi)', style: AppTheme.body1),
                      selected: sortBy == 'priceAsc',
                      selectedColor: AppTheme.primary,
                      onTap: () {
                        onSortChanged('priceAsc');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Harga (Tinggi-Rendah)', style: AppTheme.body1),
                      selected: sortBy == 'priceDesc',
                      selectedColor: AppTheme.primary,
                      onTap: () {
                        onSortChanged('priceDesc');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
