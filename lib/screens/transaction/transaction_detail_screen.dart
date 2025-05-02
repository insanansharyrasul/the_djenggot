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
import 'package:the_djenggot/widgets/full_screen_image_viewer.dart';
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
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                          style: const TextStyle(color: Colors.grey, fontFamily: AppTheme.fontName),
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
                  style: AppTheme.title,
                ),
                Text(
                  formatter.format(transaction.transactionAmount),
                  style: AppTheme.body1.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Uang Diterima",
                      style: AppTheme.body1,
                    ),
                    Text(
                      formatter.format(transaction.moneyReceived),
                      style: AppTheme.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Kembalian",
                      style: AppTheme.body1,
                    ),
                    Text(
                      formatter.format(transaction.moneyReceived - transaction.transactionAmount),
                      style: AppTheme.body1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                      showFullScreenImage(context, imageProvider: transaction.imageEvident);
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
        Text(
          "Daftar Item",
          style: AppTheme.headline.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (transaction.items != null && transaction.items!.isNotEmpty)
          ...transaction.items!.map((item) => _buildItemCard(context, item, formatter))
        else
          Card(
            color: AppTheme.white,
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
      color: AppTheme.white,
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

          final navigator = Navigator.of(context);
          navigator.pop(); 

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
            navigator.pop();
            navigator.pop();
          });
        },
      ),
    );
  }
}
