// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_state.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/empty_state.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class MenuTypeListScreen extends StatefulWidget {
  const MenuTypeListScreen({super.key});

  @override
  State<MenuTypeListScreen> createState() => _MenuTypeListScreenState();
}

class _MenuTypeListScreenState extends State<MenuTypeListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MenuTypeBloc>().add(LoadMenuTypes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: const Text(
          "Daftar Tipe Menu",
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
              context.push('/add-menu-type');
            },
          ),
        ],
      ),
      body: BlocBuilder<MenuTypeBloc, MenuTypeState>(
        builder: (context, state) {
          if (state is MenuTypeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MenuTypeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is MenuTypeLoaded) {
            final menuTypes = state.menuTypes;

            if (menuTypes.isEmpty) {
              return const EmptyState(
                icon: Iconsax.category,
                title: "Belum ada tipe menu",
                subtitle: "Tambahkan tipe menu baru dengan menekan tombol '+' di pojok kanan atas.",
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuTypes.length,
              itemBuilder: (context, index) {
                final menuType = menuTypes[index];
                return _buildMenuTypeCard(context, menuType);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildMenuTypeCard(BuildContext context, MenuType menuType) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          menuType.menuTypeIcon != null
              ? getIconFromString(menuType.menuTypeIcon!)
              : Iconsax.category,
          color: AppTheme.primary,
          size: 28,
        ),
        title: Text(
          menuType.menuTypeName,
          style: AppTheme.headline.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit, color: AppTheme.primary),
              onPressed: () {
                context.push('/edit-menu-type/${menuType.idMenuType}');
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppTheme.danger),
              onPressed: () {
                _showDeleteConfirmation(context, menuType);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MenuType menuType) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        type: "confirm",
        title: "Hapus Tipe Menu",
        message: "Apakah Anda yakin ingin menghapus tipe menu '${menuType.menuTypeName}'?",
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

          context.read<MenuTypeBloc>().add(DeleteMenuType(menuType.idMenuType));

          Navigator.pop(context);

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext successContext) => AppDialog(
              type: "success",
              title: "Berhasil",
              message: "Tipe menu berhasil dihapus",
              onOkPress: () {
                Navigator.pop(successContext);
              },
            ),
          );

          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              Navigator.pop(context);
            },
          );
        },
        // showCancelButton: true,
      ),
    );
  }
}
