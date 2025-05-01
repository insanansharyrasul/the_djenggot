import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class TransactionFilterFab extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final TransactionType? selectedType;
  final String sortBy;
  final bool ascending;
  final List<TransactionType> transactionTypes;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final Function(TransactionType?) onTypeChanged;
  final Function(String, bool) onSortChanged;

  const TransactionFilterFab({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedType,
    required this.sortBy,
    required this.ascending,
    required this.transactionTypes,
    required this.onDateRangeChanged,
    required this.onTypeChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Iconsax.filter,
      activeIcon: Iconsax.close_circle,
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.white,
      activeBackgroundColor: AppTheme.danger,
      activeForegroundColor: AppTheme.white,
      spacing: 8,
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      children: [
        SpeedDialChild(
          child: const Icon(Iconsax.calendar, color: AppTheme.primary),
          backgroundColor: AppTheme.white,
          labelStyle: AppTheme.subtitle.copyWith(color: AppTheme.darkText),
          label: 'Filter Tanggal',
          onTap: () async {
            final DateTimeRange? range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              currentDate: DateTime.now(),
              initialDateRange: startDate != null && endDate != null
                  ? DateTimeRange(start: startDate!, end: endDate!)
                  : null,
            );
            if (range != null) {
              onDateRangeChanged(range.start, range.end);
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Iconsax.category, color: AppTheme.primary),
          backgroundColor: AppTheme.white,
          labelStyle: AppTheme.subtitle.copyWith(color: AppTheme.darkText),
          label: 'Filter Tipe Transaksi',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Pilih Tipe Transaksi',
                    style: AppTheme.headline.copyWith(fontSize: 18)),
                backgroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Semua Tipe', style: AppTheme.body1),
                        selected: selectedType == null,
                        selectedColor: AppTheme.primary,
                        onTap: () {
                          onTypeChanged(null);
                          Navigator.pop(context);
                        },
                      ),
                      ...transactionTypes.map((type) => ListTile(
                            leading: Icon(
                                getIconFromString(type.transactionTypeIcon),
                                color: AppTheme.primary),
                            title: Text(type.transactionTypeName,
                                style: AppTheme.body1),
                            selected: selectedType?.idTransactionType ==
                                type.idTransactionType,
                            selectedColor: AppTheme.primary,
                            onTap: () {
                              onTypeChanged(type);
                              Navigator.pop(context);
                            },
                          )),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Iconsax.sort, color: AppTheme.primary),
          backgroundColor: AppTheme.white,
          labelStyle: AppTheme.subtitle.copyWith(color: AppTheme.darkText),
          label: 'Urutkan',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Urutkan Berdasarkan',
                    style: AppTheme.headline.copyWith(fontSize: 18)),
                backgroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Tanggal', style: AppTheme.body1),
                      trailing: sortBy == 'date'
                          ? Icon(
                              ascending
                                  ? Iconsax.arrow_up_1
                                  : Iconsax.arrow_down_1,
                              color: AppTheme.primary,
                            )
                          : null,
                      onTap: () {
                        onSortChanged(
                            'date', sortBy == 'date' ? !ascending : true);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Total Harga', style: AppTheme.body1),
                      trailing: sortBy == 'amount'
                          ? Icon(
                              ascending
                                  ? Iconsax.arrow_up_1
                                  : Iconsax.arrow_down_1,
                              color: AppTheme.primary,
                            )
                          : null,
                      onTap: () {
                        onSortChanged(
                            'amount', sortBy == 'amount' ? !ascending : true);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Jumlah Item', style: AppTheme.body1),
                      trailing: sortBy == 'items'
                          ? Icon(
                              ascending
                                  ? Iconsax.arrow_up_1
                                  : Iconsax.arrow_down_1,
                              color: AppTheme.primary,
                            )
                          : null,
                      onTap: () {
                        onSortChanged(
                            'items', sortBy == 'items' ? !ascending : true);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
