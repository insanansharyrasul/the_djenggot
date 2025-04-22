import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/menu/menu_state.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_state.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  typeAsc,
  typeDesc,
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _currentSort = SortOption.nameAsc;
  MenuType? _selectedType;
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<MenuTypeBloc>().add(LoadMenuTypes());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Menu> _getFilteredMenus(List<Menu> menus) {
    // Apply search filter
    var filtered = _searchQuery.isEmpty
        ? menus
        : menus
            .where((menu) => menu.menuName.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    // Apply menu type filter
    if (_selectedType != null) {
      filtered = filtered
          .where((menu) => menu.idMenuType.idMenuType == _selectedType!.idMenuType)
          .toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.nameAsc:
        filtered.sort((a, b) => a.menuName.compareTo(b.menuName));
        break;
      case SortOption.nameDesc:
        filtered.sort((a, b) => b.menuName.compareTo(a.menuName));
        break;
      case SortOption.priceAsc:
        filtered.sort((a, b) => a.menuPrice.compareTo(b.menuPrice));
        break;
      case SortOption.priceDesc:
        filtered.sort((a, b) => b.menuPrice.compareTo(a.menuPrice));
        break;
      case SortOption.typeAsc:
        filtered.sort((a, b) => a.idMenuType.menuTypeName.compareTo(b.idMenuType.menuTypeName));
        break;
      case SortOption.typeDesc:
        filtered.sort((a, b) => b.idMenuType.menuTypeName.compareTo(a.idMenuType.menuTypeName));
        break;
    }

    return filtered;
  }

  String _getOptionText(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return "Nama (A-Z)";
      case SortOption.nameDesc:
        return "Nama (Z-A)";
      case SortOption.priceAsc:
        return "Harga (Rendah-Tinggi)";
      case SortOption.priceDesc:
        return "Harga (Tinggi-Rendah)";
      case SortOption.typeAsc:
        return "Kategori (A-Z)";
      case SortOption.typeDesc:
        return "Kategori (Z-A)";
    }
  }

  IconData _getOptionIcon(SortOption option) {
    if (option == SortOption.nameAsc || option == SortOption.nameDesc) {
      return Iconsax.text;
    } else if (option == SortOption.priceAsc || option == SortOption.priceDesc) {
      return Iconsax.money;
    } else {
      return Iconsax.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          "Daftar Menu",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(26),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari menu...',
                        prefixIcon: const Icon(Iconsax.search_normal),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Iconsax.close_circle),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFilterVisible ? Iconsax.filter_square : Iconsax.filter_search,
                    color: _isFilterVisible ? AppTheme.primary : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFilterVisible = !_isFilterVisible;
                    });
                  },
                ),
              ],
            ),

            // Filter and Sort Controls
            if (_isFilterVisible) ...[
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.setting_4, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Filter dan Pengurutan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Menu Type Filter
                      Text(
                        'Filter berdasarkan kategori',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<MenuTypeBloc, MenuTypeState>(
                        builder: (context, state) {
                          if (state is MenuTypeLoaded) {
                            return SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: FilterChip(
                                      selected: _selectedType == null,
                                      label: const Text('Semua'),
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedType = null;
                                        });
                                      },
                                      backgroundColor: Colors.grey.shade100,
                                      selectedColor: AppTheme.primary
                                          .withAlpha(26),
                                      labelStyle: TextStyle(
                                        color: _selectedType == null
                                            ? AppTheme.primary
                                            : Colors.grey.shade700,
                                        fontWeight: _selectedType == null
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  ...state.menuTypes.map((type) {
                                    bool isSelected = _selectedType?.idMenuType == type.idMenuType;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: FilterChip(
                                        selected: isSelected,
                                        avatar: Icon(
                                          type.menuTypeIcon != null
                                              ? getIconFromString(type.menuTypeIcon!)
                                              : Iconsax.category,
                                          size: 16,
                                          color:
                                              isSelected ? AppTheme.primary : Colors.grey.shade700,
                                        ),
                                        label: Text(type.menuTypeName),
                                        onSelected: (_) {
                                          setState(() {
                                            _selectedType = isSelected ? null : type;
                                          });
                                        },
                                        backgroundColor: Colors.grey.shade100,
                                        selectedColor: AppTheme.primary
                                            .withAlpha(26),
                                        labelStyle: TextStyle(
                                          color:
                                              isSelected ? AppTheme.primary : Colors.grey.shade700,
                                          fontWeight:
                                              isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),

                      const SizedBox(height: 16),

                      // Sort Options
                      Text(
                        'Urutkan berdasarkan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SortOption>(
                            value: _currentSort,
                            isExpanded: true,
                            icon: const Icon(Iconsax.arrow_down_1),
                            items: SortOption.values.map((SortOption option) {
                              return DropdownMenuItem<SortOption>(
                                value: option,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getOptionIcon(option),
                                      size: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_getOptionText(option)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (SortOption? newValue) {
                              setState(() {
                                _currentSort = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Menu Grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<MenuBloc>(context).add(LoadMenu());
                },
                child: BlocBuilder<MenuBloc, MenuState>(builder: (context, state) {
                  if (state is MenuLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MenuLoaded) {
                    final filteredMenus = _getFilteredMenus(state.menus);

                    if (filteredMenus.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.search_status,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada menu yang ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba ubah filter atau kata kunci pencarian',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredMenus.length,
                      itemBuilder: (context, index) {
                        final menu = filteredMenus[index];
                        return GestureDetector(
                          onTap: () {
                            context.push('/menu-detail/${menu.idMenu}');
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Menu Image
                                if (menu.menuImage != null)
                                  Expanded(
                                    child: Hero(
                                      tag: "menu-image-${menu.idMenu}",
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: MemoryImage(menu.menuImage!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Iconsax.coffee,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),

                                // Menu Details
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Menu Name
                                      Text(
                                        menu.menuName,
                                        style: const TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.nearlyBlue,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 4),

                                      // Menu Type
                                      Row(
                                        children: [
                                          Icon(
                                            getIconFromString(menu.idMenuType.menuTypeIcon ?? ''),
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              menu.idMenuType.menuTypeName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Price
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'id_ID',
                                          decimalDigits: 0,
                                          symbol: 'Rp ',
                                        ).format(menu.menuPrice),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.document_1,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada menu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
