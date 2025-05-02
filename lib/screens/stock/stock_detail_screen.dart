import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class StockDetailScreen extends StatefulWidget {
  final Stock stock;

  const StockDetailScreen({super.key, required this.stock});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final TextEditingController _quantityController = TextEditingController();
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void refresh() {
    context.read<StockBloc>().add(LoadStock());
  }

  void _showTakeStockDialog(Stock stock) {
    _quantityController.text = "1"; // Default quantity

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ambil Stok"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Jumlah stok saat ini: ${stock.stockQuantity} ${stock.idStockType.stockUnit}",
                style: AppTheme.body1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Jumlah ${stock.idStockType.stockUnit}",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Iconsax.calculator),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Ambil"),
              onPressed: () {
                int quantity = int.tryParse(_quantityController.text) ?? 0;
                if (quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Jumlah harus lebih besar dari 0"),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                  return;
                }

                if (quantity > stock.stockQuantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Jumlah melebihi stok yang tersedia"),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                _updateStockQuantity(stock, -quantity);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddStockDialog(Stock stock) {
    _quantityController.text = "1"; // Default quantity

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tambah Stok"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Jumlah stok saat ini: ${stock.stockQuantity} ${stock.idStockType.stockUnit}",
                style: AppTheme.body1,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Jumlah ${stock.idStockType.stockUnit}",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Iconsax.calculator),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Tambah"),
              onPressed: () {
                int quantity = int.tryParse(_quantityController.text) ?? 0;
                if (quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Jumlah harus lebih besar dari 0"),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                _updateStockQuantity(stock, quantity);
              },
            ),
          ],
        );
      },
    );
  }

  void _updateStockQuantity(Stock stock, int change) {
    int newQuantity = stock.stockQuantity + change;
    if (newQuantity < 0) newQuantity = 0;

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

    context.read<StockBloc>().add(
          UpdateStock(
            stock,
            stock.stockName,
            newQuantity.toString(),
            stock.idStockType.idStockType,
            stock.stockThreshold!,
          ),
        );

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        type: "success",
        title: "Berhasil",
        message: change < 0 ? "Stok berhasil diambil" : "Stok berhasil ditambah",
        onOkPress: () {
          Navigator.pop(dialogContext);
        },
        okTitle: "Tutup",
      ),
    );

    final navigator = Navigator.of(context);
    Future.delayed(const Duration(seconds: 1), () {
      navigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Stok",
          style: AppTheme.appBarTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Iconsax.edit,
              color: AppTheme.nearlyBlue,
            ),
            onPressed: () {
              context.push('/add-edit-stock', extra: widget.stock);
            },
          ),
          IconButton(
            icon: const Icon(
              Iconsax.trash,
              color: Colors.red,
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
                        DeleteStock(widget.stock.idStock),
                      );
                      context.pop();
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: BlocBuilder<StockBloc, StockState>(
          builder: (context, state) {
            if (state is StockLoaded) {
              final stock = state.stocks.firstWhere(
                (stock) => stock.idStock == widget.stock.idStock,
                orElse: () => widget.stock,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withAlpha(23),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  getIconFromString(stock.idStockType.stockTypeIcon),
                                  color: AppTheme.primary,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                stock.stockName,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withAlpha(26),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  stock.idStockType.stockTypeName,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontSize: 14,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Informasi Detail",
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow("Kuantitas",
                                  "${stock.stockQuantity}${stock.idStockType.stockUnit.isNotEmpty ? ' ${stock.idStockType.stockUnit}' : ''}",
                                  icon: Iconsax.chart_1,
                                  isLowStock: stock.stockThreshold != null &&
                                      stock.stockQuantity <= stock.stockThreshold!),
                              if (stock.stockThreshold != null)
                                _buildInfoRow(
                                  "Batas Minimum",
                                  "${stock.stockThreshold}${stock.idStockType.stockUnit.isNotEmpty ? ' ${widget.stock.idStockType.stockUnit}' : ''}",
                                  icon: Iconsax.warning_2,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          Stock currentStock = widget.stock;
          if (state is StockLoaded) {
            currentStock = state.stocks.firstWhere(
              (s) => s.idStock == widget.stock.idStock,
              orElse: () => widget.stock,
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show these buttons only when menu is open
              if (_isMenuOpen) ...[
                FloatingActionButton(
                  heroTag: "take",
                  backgroundColor: Colors.redAccent,
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _isMenuOpen = false;
                    });
                    _showTakeStockDialog(currentStock);
                  },
                  tooltip: "Ambil Stok",
                  child: const Icon(Iconsax.minus),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "add",
                  backgroundColor: Colors.green,
                  mini: true,
                  onPressed: () {
                    setState(() {
                      _isMenuOpen = false;
                    });
                    _showAddStockDialog(currentStock);
                  },
                  tooltip: "Tambah Stok",
                  child: const Icon(Iconsax.add),
                ),
                const SizedBox(height: 16),
              ],
              // Main FAB that toggles the menu
              FloatingActionButton(
                heroTag: "main",
                backgroundColor: AppTheme.primary,
                onPressed: () {
                  setState(() {
                    _isMenuOpen = !_isMenuOpen;
                  });
                },
                tooltip: _isMenuOpen ? "Tutup" : "Kelola Stok",
                child: Icon(
                  _isMenuOpen ? Iconsax.close_circle : Iconsax.box_1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {IconData icon = Iconsax.info_circle, bool isLowStock = false, bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLowStock ? Colors.red.withAlpha(23) : Colors.grey.withAlpha(23),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isLowStock ? Colors.red : Colors.grey.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.body2.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.body1.copyWith(
                    fontSize: 16,
                    fontWeight: isLowStock ? FontWeight.bold : FontWeight.w500,
                    color: isLowStock ? Colors.red : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
