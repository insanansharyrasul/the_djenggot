import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StockBloc>(context).add(LoadStock());
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          "Stok",
          style: TextStyle(
            fontFamily: DjenggotAppTheme.fontName,
            fontWeight: FontWeight.w500,
            fontSize: 18,
            letterSpacing: 0.5,
            color: Colors.black, // Replace with your theme color
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<StockBloc, StockState>(builder: (context, state) {
          if (state is StockLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is StockLoaded) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.stocks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.stocks[index].name),
                  subtitle: Text("Kuantitas: ${state.stocks[index].quantity}"),
                );
              },
            );
          } 
          return Container();
        })

        
      ],
    );
  }
}
