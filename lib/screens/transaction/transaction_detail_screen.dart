// ignore_for_file: use_build_context_synchronously
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/models/transaction/transaction_history.dart';
import 'package:the_djenggot/models/transaction/transaction_item.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String id;

  const TransactionDetailScreen({super.key, required this.id});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactionById(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: const Text(
          "Detail Transaksi",
          style: AppTheme.appBarTitle,
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppTheme.danger),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is TransactionDetailLoaded) {
            final transaction = state.transaction;
            return _buildTransactionDetail(context, transaction);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTransactionDetail(BuildContext context, TransactionHistory transaction) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final date = DateTime.parse(transaction.timestamp);
    final formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(date);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Transaction Info Card
        Card(
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
                Row(
                  children: [
                    Icon(
                      getIconFromString(transaction.transactionType.transactionTypeIcon),
                      color: AppTheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.transactionType.transactionTypeName,
                          style:
                              AppTheme.headline.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  formatter.format(transaction.transactionAmount),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                if (transaction.imageEvident.isNotEmpty) ...[
                  const Text(
                    "Bukti Pembayaran",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _showFullScreenImage(context, transaction.imageEvident);
                    },
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: MemoryImage(transaction.imageEvident),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Transaction Items
        Text(
          "Daftar Item",
          style: AppTheme.headline.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Items List
        if (transaction.items != null && transaction.items!.isNotEmpty)
          ...transaction.items!.map((item) => _buildItemCard(context, item, formatter))
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text("Tidak ada item"),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, TransactionItem item, NumberFormat formatter) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
              child: Center(
                  child: Image.memory(
                item.menu.menuImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menu.menuName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    formatter.format(item.menu.menuPrice),
                    style: const TextStyle(
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "x${item.transactionQuantity}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        type: "confirm",
        title: "Hapus Transaksi",
        message: "Apakah Anda yakin ingin menghapus transaksi ini?",
        onOkPress: () async {
          Navigator.pop(dialogContext);

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext loadingContext) => AppDialog(
              type: "loading",
              title: "Memproses",
              message: "Mohon tunggu...",
              onOkPress: () {},
            ),
          );

          context.read<TransactionBloc>().add(DeleteTransactionEvent(widget.id));

          Navigator.pop(context); // Close the loading dialog

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext successContext) => AppDialog(
              type: "success",
              title: "Berhasil",
              message: "Transaksi berhasil dihapus",
              onOkPress: () {
                Navigator.pop(successContext);
              },
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context); // Back to transactions list
            Navigator.pop(context); 
          });
        },
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withAlpha(5),
                    ),
                    child: const Icon(
                      Iconsax.close_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
