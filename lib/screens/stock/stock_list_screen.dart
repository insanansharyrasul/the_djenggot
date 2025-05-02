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
import 'package:the_djenggot/widgets/empty_state.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/stock/stock_filter_fab.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _currentSort = 'nameAsc';
  StockType? _selectedType;
  List<Stock> _filteredStocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StockBloc>(context).add(LoadStock());
    context.read<StockTypeBloc>().add(LoadStockTypes());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchQuery != _searchController.text) {
      setState(() {
        _searchQuery = _searchController.text;
      });
      BlocProvider.of<StockBloc>(context).add(
        SearchStock(_searchController.text),
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Stock> _getFilteredStocks(List<Stock> stocks) {
    var filtered = stocks;

    if (_selectedType != null) {
      filtered = filtered
          .where((stock) => stock.idStockType.idStockType == _selectedType!.idStockType)
          .toList();
    }

    switch (_currentSort) {
      case 'nameAsc':
        filtered.sort((a, b) => a.stockName.compareTo(b.stockName));
        break;
      case 'nameDesc':
        filtered.sort((a, b) => b.stockName.compareTo(a.stockName));
        break;
      case 'quantityAsc':
        filtered.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case 'quantityDesc':
        filtered.sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
        break;
      case 'typeAsc':
        filtered.sort((a, b) => a.idStockType.stockTypeName.compareTo(b.idStockType.stockTypeName));
        break;
      case 'typeDesc':
        filtered.sort((a, b) => b.idStockType.stockTypeName.compareTo(a.idStockType.stockTypeName));
        break;
    }

    return filtered;
  }

  void _updateFilteredStocks(List<Stock> stocks) {
    _filteredStocks = _getFilteredStocks(stocks);
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Daftar Stok",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBox(),
            const SizedBox(height: 16),
            _buildStockList(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildSearchBox() {
    return Container(
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
          hintStyle: AppTheme.body1,
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
    );
  }

  Widget _buildStockList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<StockBloc>(context).add(LoadStock());
        },
        child: BlocConsumer<StockBloc, StockState>(
          listener: (context, state) {
            if (state is StockLoaded) {
              _updateFilteredStocks(state.stocks);
            }
          },
          builder: (context, state) {
            if (state is StockLoading && _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StockLoaded) {
              if (_filteredStocks.isEmpty) {
                return _buildEmptyState();
              }
              return _buildStockListView(_filteredStocks);
            }

            return _buildNoStocksState();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        const EmptyState(
          icon: Iconsax.box,
          title: "Tidak ada stok yang ditemukan.",
          subtitle: "Coba ubah filter atau kata kunci pencarian",
        ),
      ],
    );
  }

  Widget _buildNoStocksState() {
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
  }

  Widget _buildStockListView(List<Stock> stocks) {
    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        if (index > 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildStockItem(stocks[index]),
          );
        }
        return _buildStockItem(stocks[index]);
      },
    );
  }

  Widget _buildStockItem(Stock stock) {
    final stockUnit = stock.idStockType.stockUnit;
    final isLowStock = stock.stockThreshold != null && stock.stockQuantity <= stock.stockThreshold!;

    return Card(
      color: AppTheme.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLowStock ? const BorderSide(color: Colors.red) : BorderSide.none,
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
              _buildStockInfoRow(
                Iconsax.category,
                stock.idStockType.stockTypeName,
                isLowStock: false,
              ),
              const SizedBox(height: 4),
              _buildStockInfoRow(
                Iconsax.chart_1,
                "Kuantitas: ${stock.stockQuantity}${stockUnit.isNotEmpty ? ' $stockUnit' : ''}",
                isLowStock: isLowStock,
              ),
              if (stock.stockThreshold != null && stock.stockThreshold! > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: _buildStockInfoRow(
                    Iconsax.warning_2,
                    "Minimum: ${stock.stockThreshold}${stockUnit.isNotEmpty ? ' $stockUnit' : ''}",
                    isLowStock: isLowStock,
                  ),
                ),
            ],
          ),
          trailing: Icon(Iconsax.arrow_right_3, color: Colors.grey.shade400),
          onTap: () {
            context.push('/stock-detail', extra: stock);
          },
        ),
      ),
    );
  }

  Widget _buildStockInfoRow(IconData icon, String text, {required bool isLowStock}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isLowStock ? Colors.red : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTheme.stockDetail.copyWith(
            color: isLowStock ? Colors.red : Colors.grey,
            fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons() {
    return BlocBuilder<StockTypeBloc, StockTypeState>(
      builder: (context, state) {
        if (state is StockTypeLoaded) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StockFilterFab(
                selectedType: _selectedType,
                sortBy: _currentSort,
                stockTypes: state.stockTypes,
                onTypeChanged: (type) {
                  setState(() {
                    _selectedType = type;
                    if (state is StockLoaded) {
                      _updateFilteredStocks((state as StockLoaded).stocks);
                    }
                  });
                },
                onSortChanged: (sort) {
                  setState(() {
                    _currentSort = sort;
                    if (state is StockLoaded) {
                      _updateFilteredStocks((state as StockLoaded).stocks);
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                onPressed: () => context.push('/add-edit-stock'),
                backgroundColor: AppTheme.primary,
                child: const Icon(Iconsax.add),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
