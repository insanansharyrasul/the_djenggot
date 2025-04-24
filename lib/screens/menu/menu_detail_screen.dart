// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/menu/menu_state.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class MenuDetailScreen extends StatefulWidget {
  final Menu menu;
  const MenuDetailScreen({super.key, required this.menu});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  final formatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  void refresh() {
    context.read<MenuBloc>().add(LoadMenu());
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.background,
          centerTitle: true,
          title: const Text(
            'Detail Menu',
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
              icon: const Icon(Iconsax.edit, color: AppTheme.primary),
              onPressed: () {
                context.push('/edit-menu', extra: widget.menu);
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmation(context);
              },
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            refresh();
          },
          child: BlocBuilder<MenuBloc, MenuState>(
            builder: (context, state) {
              if (state is MenuLoaded) {
                final menu = state.menus.firstWhere(
                  (menu) => menu.idMenu == widget.menu.idMenu,
                  orElse: () => widget.menu,
                );
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    // Hero image with gradient overlay
                    GestureDetector(
                      onTap: () {
                        _showFullScreenImage(context, menu.menuImage);
                      },
                      child: Stack(
                        children: [
                          Card(
                            color: AppTheme.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 250,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(menu.menuImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(179), // Changed from withOpacity(0.7)
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Menu details card
                    Card(
                      color: AppTheme.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Menu Name
                            Text(
                              menu.menuName,
                              style: AppTheme.headline.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Menu Type with Icon
                            Row(
                              children: [
                                Icon(
                                  menu.idMenuType.menuTypeIcon.isNotEmpty
                                      ? getIconFromString(menu.idMenuType.menuTypeIcon)
                                      : Iconsax.category,
                                  color: AppTheme.nearlyBlue,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  menu.idMenuType.menuTypeName,
                                  style: AppTheme.subtitle.copyWith(
                                    color: AppTheme.nearlyBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 24),

                            // Price Display
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.nearlyBlue.withAlpha(23),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Iconsax.money,
                                    color: AppTheme.nearlyBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  formatter.format(menu.menuPrice),
                                  style: AppTheme.subtitle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.nearlyBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }

  void _showFullScreenImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withAlpha(67),
                    ),
                    child: const Icon(
                      Iconsax.close_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: "menu-image-${widget.menu.idMenu}",
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        type: "confirm",
        title: "Hapus Transaksi",
        message: "Apakah Anda yakin ingin menghapus transaksi ini?",
        onOkPress: () async {
          Navigator.pop(dialogContext);

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext loadingContext) => AppDialog(
              type: "loading",
              title: "Memproses",
              message: "Mohon tunggu...",
              onOkPress: () {},
            ),
          );

          context.read<MenuBloc>().add(DeleteMenu(widget.menu.idMenu));

          Navigator.pop(context); // Close the loading dialog

          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext successContext) => AppDialog(
              type: "success",
              title: "Berhasil",
              message: "Transaksi berhasil dihapus",
              onOkPress: () {
                Navigator.pop(successContext);
              },
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context); // Back to transactions list
          });
        },
      ),
    );
  }
}
