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
import 'package:the_djenggot/widgets/empty_state.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/menu/menu_filter_fab.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _currentSort = 'nameAsc'; 
  MenuType? _selectedType;

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
      case 'nameAsc':
        filtered.sort((a, b) => a.menuName.compareTo(b.menuName));
        break;
      case 'nameDesc':
        filtered.sort((a, b) => b.menuName.compareTo(a.menuName));
        break;
      case 'priceAsc':
        filtered.sort((a, b) => a.menuPrice.compareTo(b.menuPrice));
        break;
      case 'priceDesc':
        filtered.sort((a, b) => b.menuPrice.compareTo(a.menuPrice));
        break;
      case 'typeAsc':
        filtered.sort((a, b) => a.idMenuType.menuTypeName.compareTo(b.idMenuType.menuTypeName));
        break;
      case 'typeDesc':
        filtered.sort((a, b) => b.idMenuType.menuTypeName.compareTo(a.idMenuType.menuTypeName));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Daftar Menu",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            // Search Bar
            Container(
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
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                          const EmptyState(
                            icon: Icons.egg_alt,
                            title: "Tidak ada menu yang ditemukan.",
                            subtitle: "Coba ubah filter atau kata kunci pencarian",
                          )
                        ],
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
                            color: AppTheme.white,
                            clipBehavior: Clip.antiAlias,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Menu Image
                                Expanded(
                                  child: Hero(
                                    tag: "menu-image-${menu.idMenu}",
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: MemoryImage(menu.menuImage),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
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
                                            getIconFromString(menu.idMenuType.menuTypeIcon),
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
      floatingActionButton: BlocBuilder<MenuTypeBloc, MenuTypeState>(
        builder: (context, state) {
          if (state is MenuTypeLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MenuFilterFab(
                  selectedType: _selectedType,
                  sortBy: _currentSort,
                  menuTypes: state.menuTypes,
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  onSortChanged: (sort) {
                    setState(() {
                      _currentSort = sort;
                    });
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () => context.push('/add-edit-menu'),
                  backgroundColor: AppTheme.primary,
                  child: const Icon(Iconsax.add),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
