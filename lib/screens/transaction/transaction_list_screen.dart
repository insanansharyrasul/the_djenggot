import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_state.dart';
import 'package:the_djenggot/models/transaction/transaction_history.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/empty_state.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/transaction/transaction_filter_fab.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  DateTime? startDate;
  DateTime? endDate;
  TransactionType? selectedType;
  String sortBy = 'date';
  bool ascending = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daftar Transaksi",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoaded) {
            var transactions = state.transactions;

            // Apply date filter
            if (startDate != null && endDate != null) {
              transactions = transactions.where((t) {
                final date = DateTime.parse(t.timestamp);
                return date.isAfter(startDate!) &&
                    date.isBefore(endDate!.add(const Duration(days: 1)));
              }).toList();
            }

            // Apply type filter
            if (selectedType != null) {
              transactions = transactions
                  .where(
                      (t) => t.transactionType.idTransactionType == selectedType!.idTransactionType)
                  .toList();
            }

            // Apply sorting
            transactions.sort((a, b) {
              switch (sortBy) {
                case 'date':
                  return ascending
                      ? a.timestamp.compareTo(b.timestamp)
                      : b.timestamp.compareTo(a.timestamp);
                case 'amount':
                  return ascending
                      ? a.transactionAmount.compareTo(b.transactionAmount)
                      : b.transactionAmount.compareTo(a.transactionAmount);
                case 'items':
                  return ascending
                      ? (a.items?.length ?? 0).compareTo(b.items?.length ?? 0)
                      : (b.items?.length ?? 0).compareTo(a.items?.length ?? 0);
                default:
                  return 0;
              }
            });

            if (transactions.isEmpty) {
              return const Expanded(
                child: EmptyState(
                  icon: Iconsax.receipt,
                  title: "Belum ada transaksi",
                  subtitle:
                      "Tambahkan transaksi baru dengan menekan tombol '+' di pojok kanan bawah.",
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _reloadTransactions();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildTransactionCard(context, transaction);
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: BlocBuilder<TransactionTypeBloc, TransactionTypeState>(
        builder: (context, state) {
          if (state is TransactionTypeLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TransactionFilterFab(
                  startDate: startDate,
                  endDate: endDate,
                  selectedType: selectedType,
                  sortBy: sortBy,
                  ascending: ascending,
                  transactionTypes: state.transactionTypes,
                  onDateRangeChanged: (start, end) {
                    setState(() {
                      startDate = start;
                      endDate = end;
                    });
                  },
                  onTypeChanged: (type) {
                    setState(() {
                      selectedType = type;
                    });
                  },
                  onSortChanged: (field, asc) {
                    setState(() {
                      sortBy = field;
                      ascending = asc;
                    });
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () => context.push('/add-transaction'),
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
              (_) async {
                _reloadTransactions();
              },
            );
          },
        ),
        onTap: () {
          context.push('/transaction-detail/${transaction.idTransactionHistory}').then(
            (_) async {
              _reloadTransactions();
            },
          );
        },
      ),
    );
  }

  void _reloadTransactions() {
    context.read<TransactionBloc>().add(LoadTransactions());
  }
}
