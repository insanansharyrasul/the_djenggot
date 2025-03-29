import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class AddEditStockScreen extends StatefulWidget {
  const AddEditStockScreen({super.key});

  @override
  State<AddEditStockScreen> createState() => _AddEditStockScreenState();
}

class _AddEditStockScreenState extends State<AddEditStockScreen> {
  TextEditingController stockName = TextEditingController();
  TextEditingController stockQuantity = TextEditingController();
  TextEditingController category = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DjenggotAppTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DjenggotAppTheme.background,
        centerTitle: true,
        title: const Text("Add/Edit Stock", style: DjenggotAppTheme.appBarTitle),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration:
                  InputDecoration(labelText: "Nama Stok", labelStyle: DjenggotAppTheme.textField),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                  labelText: "Kuantitas Stok", labelStyle: DjenggotAppTheme.textField),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text("Kategori Stok", style: DjenggotAppTheme.textField),
            SizedBox(height: 8),
            DropdownButton(
              items: [DropdownMenuItem(child: Text("a"))],
              onChanged: (value) {},
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle save action
              },
              child: Text("Simpan", style: DjenggotAppTheme.buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
