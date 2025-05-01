import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/transaction/daily_sales_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: ListView(
        children: [
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoaded) {
                return DailySalesCard(
                  transactions: state.transactions,
                  onDateChanged: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  selectedDate: selectedDate,
                );
              } else if (state is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return const Center(child: Text("Error loading transactions"));
              }
            },
          )
        ],
      ),
    );
  }
}
