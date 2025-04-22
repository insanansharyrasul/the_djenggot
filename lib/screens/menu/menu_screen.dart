import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/menu/menu_state.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: const Text(
          "Daftar Menu",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<MenuBloc>(context).add(LoadMenu());
          },
          child: ListView(
            children: [
              BlocBuilder<MenuBloc, MenuState>(builder: (context, state) {
                if (state is MenuLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MenuLoaded) {
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.menus.length,
                    itemBuilder: (context, index) {
                      final menu = state.menus[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/menu-detail/${menu.idMenu}');
                        },
                        child: GridTile(
                          child: Card(
                            color: AppTheme.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (menu.menuImage != null)
                                  Expanded(
                                    child: Image.memory(
                                      menu.menuImage!,
                                      height: 500,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Container(color: Colors.grey),
                                  ),
                                Text(
                                  menu.menuName,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                    color: AppTheme.nearlyBlue,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(getIconFromString(menu.idMenuType.menuTypeIcon)),
                                    Text(menu.idMenuType.menuTypeName),
                                  ],
                                ),
                                Text(
                                  NumberFormat.currency(
                                    locale: 'id_ID',
                                    decimalDigits: 0,
                                    symbol: 'Rp ',
                                  ).format(menu.menuPrice),
                                  style: AppTheme.body2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text("No data available"));
              })
            ],
          ),
        ),
      ),
    );
  }
}
