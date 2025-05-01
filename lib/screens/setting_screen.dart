import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Setting",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          top: 32,
          left: 32,
          right: 32,
        ),
        children: [
          _buildSectionHeader("Kategori"),
          _buildSettingItem(
            icon: Iconsax.menu_board,
            title: "Kelola Tipe Menu",
            subtitle: "Tambah, ubah, atau hapus kategori menu",
            onTap: () => _navigateToTypeScreen(context, 'menu'),
          ),
          _buildSettingItem(
            icon: Iconsax.box,
            title: "Kelola Tipe Stok",
            subtitle: "Tambah, ubah, atau hapus kategori stok",
            onTap: () => _navigateToTypeScreen(context, 'stock'),
          ),
          _buildSettingItem(
            icon: Iconsax.receipt,
            title: "Kelola Tipe Transaksi",
            subtitle: "Tambah, ubah, atau hapus kategori transaksi",
            onTap: () => _navigateToTypeScreen(context, 'transaction'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Aplikasi"),
          _buildSettingItem(
            icon: Iconsax.information,
            title: "Versi Aplikasi",
            subtitle: "1.0.0",
            showArrow: false,
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Iconsax.profile_2user,
            title: "Laporkan Masalah",
            subtitle: "Laporkan masalah atau bug yang ditemukan",
            onTap: () {
              _openWhatsapp();
            },
          )
        ],
      ),
    );
  }

  void _openWhatsapp() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'insanansryrasul21@gmail.com',
      query: 'subject=Report bug&body=Masalah yang ditemukan: ',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
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
        context.push('/menu-types');
        break;
      case 'stock':
        context.push('/stock-types');
        break;
      case 'transaction':
        context.push('/transaction-types');
        break;
    }
  }
}
