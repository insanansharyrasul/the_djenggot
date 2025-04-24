import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/models/transaction/transaction_history.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/empty_state.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    _reloadTransactions();
  }

  void _reloadTransactions() {
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: const Text(
          "Daftar Transaksi",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<TransactionBloc>().add(LoadTransactions());
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TransactionError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is TransactionLoaded) {
              final transactions = state.transactions;

              if (transactions.isEmpty) {
                return const EmptyState(
                  icon: Iconsax.receipt,
                  title: "Belum ada transaksi",
                  subtitle:
                      "Tambahkan transaksi baru dengan menekan tombol '+' di pojok kanan bawah.",
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionCard(context, transaction);
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionHistory transaction) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final date = DateTime.parse(transaction.timestamp);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

    return Card(
      elevation: 2,
      color: AppTheme.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          getIconFromString(transaction.transactionType.transactionTypeIcon),
          color: AppTheme.primary,
          size: 28,
        ),
        title: Text(
          transaction.transactionType.transactionTypeName,
          style: AppTheme.headline.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatter.format(transaction.transactionAmount),
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formattedDate,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              "${transaction.items?.length ?? 0} items",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Iconsax.eye, color: AppTheme.primary),
          onPressed: () {
            context.push('/transaction-detail/${transaction.idTransactionHistory}').then(
              (_) {
                _reloadTransactions();
              },
            );
          },
        ),
        onTap: () {
          context.push('/transaction-detail/${transaction.idTransactionHistory}').then(
            (_) {
              _reloadTransactions();
            },
          );
        },
      ),
    );
  }
}
