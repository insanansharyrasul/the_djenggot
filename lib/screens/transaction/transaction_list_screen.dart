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
import 'package:the_djenggot/utils/currency_formatter_util.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Iconsax.chart),
            tooltip: 'Profit and Loss',
            onPressed: () {
              context.push('/profit-loss');
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoaded) {
            var transactions = state.transactions;

            if (startDate != null && endDate != null) {
              transactions = transactions.where((t) {
                final date = DateTime.parse(t.timestamp);
                return date.isAfter(startDate!) &&
                    date.isBefore(endDate!.add(const Duration(days: 1)));
              }).toList();
            }

            if (selectedType != null) {
              transactions = transactions
                  .where(
                      (t) => t.transactionType.idTransactionType == selectedType!.idTransactionType)
                  .toList();
            }

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
              return const EmptyState(
                icon: Iconsax.receipt,
                title: "Belum ada transaksi",
                subtitle:
                    "Tambahkan transaksi baru dengan menekan tombol '+' di pojok kanan bawah.",
              );
            }

            final groupedTransactions = _groupTransactionsByDate(transactions);

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _reloadTransactions();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedTransactions.length,
                      itemBuilder: (context, index) {
                        final dateKey = groupedTransactions.keys.elementAt(index);
                        final dateTransactions = groupedTransactions[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                dateKey,
                                style: AppTheme.headline.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkText,
                                ),
                              ),
                            ),
                            ...dateTransactions
                                .map((transaction) => _buildTransactionCard(context, transaction)),
                            const SizedBox(height: 8),
                          ],
                        );
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
    final date = DateTime.parse(transaction.timestamp);
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(23),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            getIconFromString(transaction.transactionType.transactionTypeIcon),
            color: AppTheme.primary,
            size: 28,
          ),
        ),
        title: Text(
          transaction.transactionType.transactionTypeName,
          style: AppTheme.headline.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CurrencyFormatterUtil.formatCurrency(transaction.transactionAmount),
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTheme.fontName),
            ),
            Text(
              formattedDate,
              style:
                  const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: AppTheme.fontName),
            ),
            Text(
              "${transaction.items?.length ?? 0} items",
              style: const TextStyle(fontSize: 12, fontFamily: AppTheme.fontName),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Iconsax.arrow_right_3, color: AppTheme.grey),
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

  Map<String, List<TransactionHistory>> _groupTransactionsByDate(
      List<TransactionHistory> transactions) {
    final Map<String, List<TransactionHistory>> groupedTransactions = {};

    for (var transaction in transactions) {
      final date = DateFormat('dd MMM yyyy').format(DateTime.parse(transaction.timestamp));
      if (groupedTransactions.containsKey(date)) {
        groupedTransactions[date]!.add(transaction);
      } else {
        groupedTransactions[date] = [transaction];
      }
    }

    return groupedTransactions;
  }
}
