import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

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
            icon: Iconsax.import,
            title: "Impor Database",
            subtitle: "Impor database dari file .db (akan menggantikan data yang ada)",
            onTap: () => _confirmImportDatabase(context),
          ),
          _buildSettingItem(
            icon: Iconsax.export,
            title: "Ekspor Database",
            subtitle: "Simpan database ke folder Download",
            onTap: () => _exportDatabase(context),
          ),
          _buildSettingItem(
            icon: Iconsax.profile_2user,
            title: "Laporkan Masalah",
            subtitle: "Laporkan masalah atau bug yang ditemukan",
            onTap: () {
              _openGmail();
            },
          ),
          _buildSettingItem(
            icon: Iconsax.information,
            title: "Versi Aplikasi",
            subtitle: "1.1.0",
            showArrow: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _confirmImportDatabase(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Peringatan Import Database'),
          content: const Text(
            'Import database akan menimpa semua data yang ada saat ini. '
            'Pastikan Anda telah melakukan backup data. Lanjutkan?',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Impor'),
              onPressed: () {
                Navigator.pop(dialogContext);
                _importDatabase(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _importDatabase(BuildContext context) async {
    try {
      // Try with a different approach using ANY file type
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Pilih Database File (.db)',
        // Don't use custom file filter since it doesn't work on Android
      );

      if (result == null || result.files.isEmpty) {
        return; // User canceled the picker
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan path file')),
        );
        return;
      }

      // Check if it's a database file (ends with .db)
      if (!filePath.toLowerCase().endsWith('.db')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File harus berformat .db (SQLite Database)')),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext loadingContext) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Import the database
      final success = await DatabaseHelper.instance.importDatabase(filePath);

      // Close loading indicator
      Navigator.pop(context);

      // Show result dialog
      if (success) {
        showDialog(
          context: context,
          builder: (BuildContext resultContext) {
            return AlertDialog(
              title: const Text('Import Berhasil'),
              content: const Text('Database telah berhasil diimpor. Semua data telah diperbarui.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(resultContext);
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext resultContext) {
            return AlertDialog(
              title: const Text('Import Gagal'),
              content: const Text('Terjadi kesalahan saat mengimpor database. '
                  'Pastikan file yang dipilih adalah database TheDjenggot yang valid.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(resultContext);
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Close loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      showDialog(
        context: context,
        builder: (BuildContext errorContext) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(errorContext);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _exportDatabase(BuildContext context) async {
    bool hasPermission = false;
    final navigator = Navigator.of(context);

    final storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      final requestResult = await Permission.storage.request();
      if (requestResult.isGranted) {
        hasPermission = true;
      }
    } else {
      hasPermission = true;
    }

    final manageStatus = await Permission.manageExternalStorage.status;
    if (!manageStatus.isGranted) {
      final requestResult = await Permission.manageExternalStorage.request();
      if (requestResult.isGranted) {
        hasPermission = true;
      }
    } else {
      hasPermission = true;
    }

    if (!hasPermission) {
      if (await Permission.storage.isPermanentlyDenied ||
          await Permission.manageExternalStorage.isPermanentlyDenied) {
        _showPermissionDeniedDialog(context);
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan diperlukan untuk ekspor database')),
        );
        return;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final result = await DatabaseHelper.instance.exportDatabase();

      navigator.pop();

      if (result != null) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Database Berhasil Diekspor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Database telah tersimpan di folder:'),
                  const SizedBox(height: 8),
                  Text(
                    result,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Bagikan'),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Share.shareXFiles(
                      [XFile(result)],
                      subject: 'Database Backup The Djenggot',
                    );
                  },
                ),
                TextButton(
                  child: const Text('Tutup'),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Ekspor Gagal'),
              content: const Text('Terjadi kesalahan saat mengekspor database.'),
              actions: [
                TextButton(
                  child: const Text('Tutup'),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      navigator.pop();

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Terjadi Kesalahan'),
            content: Text('Error: ${e.toString()}'),
            actions: [
              TextButton(
                child: const Text('Tutup'),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _openGmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'insanansryrasul21@gmail.com',
      query: 'subject=Report bug&body=Masalah yang ditemukan: ',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      debugPrint('Could not launch $emailUri: $e');
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

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Izin Ditolak'),
          content: const Text(
              'Izin penyimpanan diperlukan untuk ekspor database. Silakan izinkan akses penyimpanan di pengaturan.'),
          actions: [
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }
}
