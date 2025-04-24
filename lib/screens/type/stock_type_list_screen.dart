// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_state.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/empty_state.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class StockTypeListScreen extends StatefulWidget {
  const StockTypeListScreen({super.key});

  @override
  State<StockTypeListScreen> createState() => _StockTypeListScreenState();
}

class _StockTypeListScreenState extends State<StockTypeListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StockTypeBloc>().add(LoadStockTypes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: const Text(
          "Daftar Tipe Stok",
          style: AppTheme.appBarTitle,
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle),
            onPressed: () {
              context.push('/add-stock-type');
            },
          ),
        ],
      ),
      body: BlocBuilder<StockTypeBloc, StockTypeState>(
        builder: (context, state) {
          if (state is StockTypeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StockTypeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is StockTypeLoaded) {
            final stockTypes = state.stockTypes;

            if (stockTypes.isEmpty) {
              return const EmptyState(
                icon: Iconsax.box,
                title: "Belum ada tipe stok",
                subtitle: "Tambahkan tipe stok baru dengan menekan tombol '+' di pojok kanan atas.",
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stockTypes.length,
              itemBuilder: (context, index) {
                final stockType = stockTypes[index];
                return _buildStockTypeCard(context, stockType);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStockTypeCard(BuildContext context, StockType stockType) {
    return Card(
      color: AppTheme.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          getIconFromString(stockType.stockTypeIcon),
          color: AppTheme.primary,
          size: 28,
        ),
        title: Text(
          stockType.stockTypeName,
          style: AppTheme.headline.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Satuan: ${stockType.stockUnit}",
          style: AppTheme.subtitle,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit, color: AppTheme.primary),
              onPressed: () {
                context.push('/edit-stock-type/${stockType.idStockType}');
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppTheme.danger),
              onPressed: () {
                _showDeleteConfirmation(context, stockType);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StockType stockType) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        type: "confirm",
        title: "Hapus Tipe Stok",
        message: "Apakah Anda yakin ingin menghapus tipe stok '${stockType.stockTypeName}'?",
        onOkPress: () async {
          Navigator.pop(dialogContext);

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext loadingContext) => AppDialog(
              type: "loading",
              title: "Memproses",
              message: "Mohon tunggu...",
              onOkPress: () {
                Navigator.pop(loadingContext);
              },
            ),
          );

          context.read<StockTypeBloc>().add(DeleteStockType(stockType));

          Navigator.pop(context);

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext successContext) => AppDialog(
              type: "success",
              title: "Berhasil",
              message: "Tipe stok berhasil dihapus",
              onOkPress: () {
                Navigator.pop(successContext);
              },
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        },
        // showCancelButton: true,
      ),
    );
  }
}
