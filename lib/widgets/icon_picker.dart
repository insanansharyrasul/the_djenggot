import 'package:flutter/material.dart';

class IconPicker extends StatefulWidget {
  final Function(String iconName, IconData icon) onIconSelected;
  final String? currentIconName;

  const IconPicker({
    super.key,
    required this.onIconSelected,
    this.currentIconName,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  String searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Get all Iconsax icons
    final Map<String, IconData> iconsaxIcons = getAllIconsaxIcons();

    // Filter icons based on search query
    final filteredIcons = searchQuery.isEmpty
        ? iconsaxIcons
        : Map.fromEntries(iconsaxIcons.entries.where((entry) =>
            entry.key.toLowerCase().contains(searchQuery.toLowerCase())));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Select Icon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search icons',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                final entry = filteredIcons.entries.elementAt(index);
                final isSelected = entry.key == widget.currentIconName;

                return InkWell(
                  onTap: () {
                    widget.onIconSelected(entry.key, entry.value);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          isSelected ? Border.all(color: Colors.blue) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(entry.value,
                            size: 28, color: isSelected ? Colors.blue : null),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to get all available Iconsax icons
  Map<String, IconData> getAllIconsaxIcons() {
    return {
      // Food-related icons
      'coffee': Icons.coffee,
      'cup': Icons.coffee_maker,
      'cake': Icons.cake,
      'milk': Icons.breakfast_dining,
      'glass': Icons.local_drink,
      'egg': Icons.egg_alt,
      'meat': Icons.set_meal,
      'restaurant': Icons.restaurant,
      'cocktail': Icons.local_bar,
      'chef': Icons.restaurant_menu,
      'fork_knife': Icons.flatware,
      'cooking': Icons.kitchen,
      'apple': Icons.apple,
      'bread': Icons.bakery_dining,
      'fish': Icons.set_meal,
      'chicken': Icons.food_bank,
      'herbs': Icons.grass,
      'juice': Icons.local_drink,
      'fast_food': Icons.fastfood,
      'dinner': Icons.dinner_dining,
      'lunch': Icons.lunch_dining,
      'breakfast': Icons.breakfast_dining,
      'ice_cream': Icons.icecream,
      'pizza': Icons.local_pizza,

      // Payment-related icons
      'wallet': Icons.account_balance_wallet,
      'card': Icons.credit_card,
      'card_pos': Icons.point_of_sale,
      'card_add': Icons.add_card,
      'card_tick': Icons.credit_score,
      'money': Icons.attach_money,
      'money_add': Icons.money_off_csred,
      'money_remove': Icons.money_off,
      'receipt': Icons.receipt_long,
      'receipt_2': Icons.receipt,
      'receipt_item': Icons.request_page,
      'discount': Icons.local_offer,
      'dollar': Icons.attach_money,
      'dollar_circle': Icons.monetization_on,
      'coin': Icons.savings,
      'money_send': Icons.send_to_mobile,
      'money_receive': Icons.savings,
      'transaction': Icons.sync_alt,
      'wallet_add': Icons.add_card,
      'wallet_check': Icons.credit_score,
      'bank': Icons.account_balance,
      'bill': Icons.receipt,
      'qris': Icons.qr_code,
      'payment': Icons.payments,
      'credit_card': Icons.credit_card,
      'cash': Icons.paid,
      'currency_exchange': Icons.currency_exchange,
      'atm': Icons.atm,

      // Stock/Inventory-related icons
      'box': Icons.inventory_2,
      'box_add': Icons.add_box,
      'box_remove': Icons.indeterminate_check_box,
      'box_tick': Icons.check_box,
      'box_time': Icons.pending_actions,
      'box_search': Icons.pageview,
      'archive': Icons.archive,
      'archive_add': Icons.archive,
      'archive_tick': Icons.inventory,
      'clipboard': Icons.assignment,
      'clipboard_text': Icons.assignment,
      'clipboard_tick': Icons.assignment_turned_in,
      'clipboard_export': Icons.assignment_return,
      'clipboard_import': Icons.assignment_returned,
      'chart': Icons.bar_chart,
      'chart_square': Icons.insert_chart,
      'trend_up': Icons.trending_up,
      'trend_down': Icons.trending_down,
      'status_up': Icons.upload,
      'barcode': Icons.qr_code_scanner,
      'scanner': Icons.document_scanner,
      'tag': Icons.local_offer,
      'truck': Icons.local_shipping,
      'package': Icons.inventory_2,
      'stock': Icons.inventory,
      'warehouse': Icons.warehouse,
      'categories': Icons.category,
      'list': Icons.list_alt,
      'shelves': Icons.shelves,
      'delivery': Icons.delivery_dining,
      'supplies': Icons.home_repair_service,
      'boxes': Icons.all_inbox,
      'moving': Icons.move_to_inbox,
    };
  }
}

// Helper function to show the icon picker
void showIconPickerBottomSheet(
  BuildContext context, {
  required Function(String iconName, IconData icon) onIconSelected,
  String? currentIconName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => IconPicker(
      onIconSelected: onIconSelected,
      currentIconName: currentIconName,
    ),
  );
}

// Function to get IconData from string name
IconData? getIconFromString(String? iconName) {
  if (iconName == null || iconName.isEmpty) return null;

  final icons = _IconPickerState().getAllIconsaxIcons();
  return icons[iconName];
}
