import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_state.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  quantityAsc,
  quantityDesc,
  typeAsc,
  typeDesc,
}

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _currentSort = SortOption.nameAsc;
  StockType? _selectedType;
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StockBloc>(context).add(LoadStock());
    context.read<StockTypeBloc>().add(LoadStockTypes());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      BlocProvider.of<StockBloc>(context).add(
        SearchStock(_searchController.text),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Stock> _getFilteredStocks(List<Stock> stocks) {
    // Apply search filter is handled by SearchStock event
    var filtered = stocks;

    // Apply stock type filter
    if (_selectedType != null) {
      filtered = filtered
          .where((stock) => stock.idStockType.idStockType == _selectedType!.idStockType)
          .toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.nameAsc:
        filtered.sort((a, b) => a.stockName.compareTo(b.stockName));
        break;
      case SortOption.nameDesc:
        filtered.sort((a, b) => b.stockName.compareTo(a.stockName));
        break;
      case SortOption.quantityAsc:
        filtered.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case SortOption.quantityDesc:
        filtered.sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
        break;
      case SortOption.typeAsc:
        filtered.sort((a, b) => a.idStockType.stockTypeName.compareTo(b.idStockType.stockTypeName));
        break;
      case SortOption.typeDesc:
        filtered.sort((a, b) => b.idStockType.stockTypeName.compareTo(a.idStockType.stockTypeName));
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
      case SortOption.quantityAsc:
        return "Kuantitas (Rendah-Tinggi)";
      case SortOption.quantityDesc:
        return "Kuantitas (Tinggi-Rendah)";
      case SortOption.typeAsc:
        return "Kategori (A-Z)";
      case SortOption.typeDesc:
        return "Kategori (Z-A)";
    }
  }

  IconData _getOptionIcon(SortOption option) {
    if (option == SortOption.nameAsc || option == SortOption.nameDesc) {
      return Iconsax.text;
    } else if (option == SortOption.quantityAsc || option == SortOption.quantityDesc) {
      return Iconsax.chart_1;
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
          "Daftar Stok",
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
                        hintText: 'Cari stok...',
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

                      // Stock Type Filter
                      Text(
                        'Filter berdasarkan kategori',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<StockTypeBloc, StockTypeState>(
                        builder: (context, state) {
                          if (state is StockTypeLoaded) {
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
                                      selectedColor: AppTheme.primary.withAlpha(26),
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
                                  ...state.stockTypes.map((type) {
                                    bool isSelected =
                                        _selectedType?.idStockType == type.idStockType;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: FilterChip(
                                        selected: isSelected,
                                        avatar: Icon(
                                          getIconFromString(type.stockTypeIcon),
                                          size: 16,
                                          color:
                                              isSelected ? AppTheme.primary : Colors.grey.shade700,
                                        ),
                                        label: Text(type.stockTypeName),
                                        onSelected: (_) {
                                          setState(() {
                                            _selectedType = isSelected ? null : type;
                                          });
                                        },
                                        backgroundColor: Colors.grey.shade100,
                                        selectedColor: AppTheme.primary.withAlpha(26),
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

            // Stock List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  BlocProvider.of<StockBloc>(context).add(LoadStock());
                },
                child: BlocBuilder<StockBloc, StockState>(builder: (context, state) {
                  if (state is StockLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StockLoaded) {
                    final filteredStocks = _getFilteredStocks(state.stocks);

                    if (filteredStocks.isEmpty) {
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
                              'Tidak ada stok yang ditemukan',
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

                    return ListView.separated(
                      itemCount: filteredStocks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final stock = filteredStocks[index];
                        final stockUnit = stock.idStockType.stockUnit;
                        final isLowStock = stock.stockThreshold != null &&
                            stock.stockQuantity <= stock.stockThreshold!;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side:
                                isLowStock ? const BorderSide(color: Colors.red) : BorderSide.none,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withAlpha(23),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  getIconFromString(stock.idStockType.stockTypeIcon),
                                  color: AppTheme.primary,
                                ),
                              ),
                              title: Text(
                                stock.stockName,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Iconsax.category,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        stock.idStockType.stockTypeName,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.chart_1,
                                        size: 14,
                                        color: isLowStock ? Colors.red : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Kuantitas: ${stock.stockQuantity}${stockUnit.isNotEmpty ? ' $stockUnit' : ''}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isLowStock ? Colors.red : Colors.grey,
                                          fontWeight:
                                              isLowStock ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (stock.stockThreshold != null && stock.stockThreshold! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Iconsax.warning_2,
                                            size: 14,
                                            color: isLowStock ? Colors.red : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Minimum: ${stock.stockThreshold}${stockUnit.isNotEmpty ? ' $stockUnit' : ''}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isLowStock ? Colors.red : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Iconsax.edit,
                                        color: AppTheme.nearlyBlue,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        context.push('/add-edit-stock', extra: stock);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Iconsax.trash,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AppDialog(
                                              type: "confirm",
                                              title: "Anda akan menghapus stok ini!",
                                              message: "Apakah anda yakin?",
                                              okTitle: "Hapus",
                                              cancelTitle: "Batal",
                                              onOkPress: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<StockBloc>(context).add(
                                                  DeleteStock(stock.idStock),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
                          'Belum ada stok',
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
