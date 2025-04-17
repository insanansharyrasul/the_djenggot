import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  TextEditingController search = TextEditingController();
  String sortBy = "name";
  String descending = "asc";

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StockBloc>(context).add(LoadStock());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<StockBloc>(context).add(LoadStock());
        },
        child: ListView(
          children: [
            Text(
              "Stok",
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                letterSpacing: 0.5,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: SearchBar(
                  controller: search,
                  elevation: WidgetStateProperty.all(0.0),
                  backgroundColor: WidgetStateProperty.all(AppTheme.white),
                  hintText: "Cari Stok",
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppTheme.white),
                    ),
                  ),
                  onChanged: (value) {
                    BlocProvider.of<StockBloc>(context).add(
                      SearchStock(value),
                    );
                  },
                )),
                PopupMenuButton(
                  icon: Icon(Iconsax.sort),
                  color: AppTheme.white,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: "name",
                      child: Text("Nama Stok", style: AppTheme.textField),
                    ),
                    PopupMenuItem(
                      value: "quantity",
                      child: Text("Kuantitas", style: AppTheme.textField),
                    ),
                  ],
                  iconSize: 24,
                  onSelected: (value) {
                    setState(() {
                      sortBy = value;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      descending = descending == "asc" ? "desc" : "asc";
                    });
                  },
                  child:
                      descending == "asc" ? Icon(Icons.arrow_upward) : Icon(Icons.arrow_downward),
                )
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<StockBloc, StockState>(builder: (context, state) {
              if (state is StockLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is StockLoaded) {
                final sortedStocks = List<Stock>.from(state.stocks)
                  ..sort((a, b) {
                    int comparison;
                    if (sortBy == "name") {
                      comparison = a.stockName.compareTo(b.stockName);
                    } else {
                      comparison = a.stockQuantity.compareTo(b.stockQuantity);
                    }
                    return descending == "asc" ? comparison : -comparison;
                  });

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedStocks.length,
                  itemBuilder: (context, index) {
                    final stockUnit = sortedStocks[index].idStockType.stockUnit;
                    return ListTile(
                      title: Text(
                        sortedStocks[index].stockName,
                        style: AppTheme.textField,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kuantitas: ${sortedStocks[index].stockQuantity}${stockUnit != null && stockUnit.isNotEmpty ? ' $stockUnit' : ''}",
                            style: AppTheme.subtitle,
                          ),
                          if (sortedStocks[index].stockThreshold != null &&
                              sortedStocks[index].stockThreshold! > 0)
                            Text(
                              "Batas minimum: ${sortedStocks[index].stockThreshold}${stockUnit != null && stockUnit.isNotEmpty ? ' $stockUnit' : ''}",
                              style: AppTheme.subtitle.copyWith(
                                color: sortedStocks[index].stockQuantity <=
                                        sortedStocks[index].stockThreshold!
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                              onTap: () {
                                context.push('/add-edit-stock', extra: sortedStocks[index]);
                              },
                              child: const Icon(Iconsax.edit)),
                          const SizedBox(width: 16),
                          GestureDetector(
                              onTap: () {
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
                                          DeleteStock(state.stocks[index].idStock),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: const Icon(Iconsax.trash, color: Colors.red)),
                        ],
                      ),
                    );
                  },
                );
              }
              return Container();
            })
          ],
        ),
      ),
    );
  }
}
