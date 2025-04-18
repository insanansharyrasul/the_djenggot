import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            "Pengaturan",
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.w500,
              fontSize: 18,
              letterSpacing: 0.5,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          // Categories section
          _buildSectionHeader("Kategori"),

          // Menu Types
          _buildSettingItem(
            icon: Iconsax.menu_board,
            title: "Kelola Tipe Menu",
            subtitle: "Tambah, ubah, atau hapus kategori menu",
            onTap: () => _navigateToTypeScreen(context, 'menu'),
          ),

          // Stock Types
          _buildSettingItem(
            icon: Iconsax.box,
            title: "Kelola Tipe Stok",
            subtitle: "Tambah, ubah, atau hapus kategori stok",
            onTap: () => _navigateToTypeScreen(context, 'stock'),
          ),

          // Transaction Types (currently there's no specific screen for this)
          _buildSettingItem(
            icon: Iconsax.receipt,
            title: "Kelola Tipe Transaksi",
            subtitle: "Tambah, ubah, atau hapus kategori transaksi",
            onTap: () => _navigateToTypeScreen(context, 'transaction'),
          ),

          const SizedBox(height: 24),

          // App section
          _buildSectionHeader("Aplikasi"),

          // App Version
          _buildSettingItem(
            icon: Iconsax.information,
            title: "Versi Aplikasi",
            subtitle: "1.0.0",
            showArrow: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Card(
      elevation: 0,
      color: AppTheme.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: AppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: showArrow ? const Icon(Iconsax.arrow_right_3) : null,
        onTap: onTap,
      ),
    );
  }

  void _navigateToTypeScreen(BuildContext context, String typeCategory) {
    switch (typeCategory) {
      case 'menu':
        // Navigate to the menu type management screen
        // This pushes to the add-edit screen with null, which means adding a new type
        // You might want to create a dedicated list screen for types instead
        // context.push('/add-edit-menu-type');
        context.push('/menu-types');
        break;
      case 'stock':
        // Navigate to the stock type management screen
        // context.push('/add-edit-stock-type');
        context.push('/stock-types');
        break;
      case 'transaction':
        // This would need a new route for transaction types
        // For now, we could show a dialog or snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Fitur tipe transaksi belum tersedia"),
            backgroundColor: AppTheme.primary,
          ),
        );
        break;
    }
  }
}
