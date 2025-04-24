// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_event.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_state.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/empty_state.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class TransactionTypeListScreen extends StatefulWidget {
  const TransactionTypeListScreen({super.key});

  @override
  State<TransactionTypeListScreen> createState() => _TransactionTypeListScreenState();
}

class _TransactionTypeListScreenState extends State<TransactionTypeListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionTypeBloc>().add(LoadTransactionTypes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: const Text(
          "Daftar Tipe Transaksi",
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
              context.push('/add-transaction-type');
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionTypeBloc, TransactionTypeState>(
        builder: (context, state) {
          if (state is TransactionTypeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionTypeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is TransactionTypeLoaded) {
            final transactionTypes = state.transactionTypes;

            if (transactionTypes.isEmpty) {
              return const EmptyState(
                icon: Iconsax.receipt,
                title: "Belum ada tipe transaksi",
                subtitle:
                    "Tambahkan tipe transaksi baru dengan menekan tombol '+' di pojok kanan atas.",
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactionTypes.length,
              itemBuilder: (context, index) {
                final transactionType = transactionTypes[index];
                return _buildTransactionTypeCard(context, transactionType);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTransactionTypeCard(BuildContext context, TransactionType transactionType) {
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
          getIconFromString(transactionType.transactionTypeIcon),
          color: AppTheme.primary,
          size: 28,
        ),
        title: Text(
          transactionType.transactionTypeName,
          style: AppTheme.headline.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit, color: AppTheme.primary),
              onPressed: () {
                context.push('/edit-transaction-type/${transactionType.idTransactionType}');
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppTheme.danger),
              onPressed: () {
                _showDeleteConfirmation(context, transactionType);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TransactionType transactionType) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        type: "confirm",
        title: "Hapus Tipe Transaksi",
        message:
            "Apakah Anda yakin ingin menghapus tipe transaksi '${transactionType.transactionTypeName}'?",
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

          context
              .read<TransactionTypeBloc>()
              .add(DeleteTransactionType(transactionType.idTransactionType));

          Navigator.pop(context);

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext successContext) => AppDialog(
              type: "success",
              title: "Berhasil",
              message: "Tipe transaksi berhasil dihapus",
              onOkPress: () {
                Navigator.pop(successContext);
              },
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        },
      ),
    );
  }
}
