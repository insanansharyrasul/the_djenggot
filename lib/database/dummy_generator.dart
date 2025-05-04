import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/repository/stock_repository.dart';
import 'package:uuid/uuid.dart';

class DummyDataGenerator {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final StockRepository _stockRepository = StockRepository();

  Future<void> generateDummyData() async {
    final existingStocks = await _stockRepository.getAllStocks();
    if (existingStocks.isNotEmpty) {
      return;
    }

    final stockTypes = await _createDummyStockTypes();

    for (var stockType in stockTypes) {
      await _createDummyStocksForType(stockType);
    }

    // Generate menu data
    final menuTypes = await _createDummyMenuTypes();

    // Generate transaction type data
    await _createDummyTransactionTypes();

    for (var menuType in menuTypes) {
      await _createDummyMenusForType(menuType);
    }
  }

  Future<List<StockType>> _createDummyStockTypes() async {
    final List<Map<String, String>> typeData = [
      {'name': 'Bahan Pokok', 'icon': 'stock', 'unit': 'kg'},
      {'name': 'Bumbu Dapur', 'icon': 'herbs', 'unit': 'gram'},
      {'name': 'Minuman', 'icon': 'glass', 'unit': 'liter'},
      {'name': 'Peralatan', 'icon': 'fork_knife', 'unit': 'pcs'}
    ];

    List<StockType> createdTypes = [];

    for (var data in typeData) {
      final String typeId = "stocktype-${const Uuid().v4()}";

      final stockType = StockType(
        idStockType: typeId,
        stockTypeName: data['name']!,
        stockTypeIcon: data['icon']!,
        stockUnit: data['unit']!,
      );

      await _databaseHelper.insertQuery('STOCK_TYPE', {
        'id_stock_type': typeId,
        'stock_type_name': data['name'],
        'stock_type_icon': data['icon'],
        'stock_unit': data['unit'],
      });

      createdTypes.add(stockType);
    }

    return createdTypes;
  }

  Future<void> _createDummyStocksForType(StockType stockType) async {
    final List<Map<String, dynamic>> stocksData = [];

    switch (stockType.stockTypeName) {
      case 'Bahan Pokok':
        stocksData.addAll([
          {'name': 'Beras', 'quantity': 50, 'threshold': 10, 'price': 15000},
          {'name': 'Gula', 'quantity': 25, 'threshold': 5, 'price': 12000},
          {'name': 'Tepung', 'quantity': 15, 'threshold': 3, 'price': 8000},
          {'name': 'Minyak Goreng', 'quantity': 20, 'threshold': 5, 'price': 20000},
        ]);
        break;
      case 'Bumbu Dapur':
        stocksData.addAll([
          {'name': 'Garam', 'quantity': 500, 'threshold': 100, 'price': 5000},
          {'name': 'Merica', 'quantity': 200, 'threshold': 50, 'price': 7000},
          {'name': 'Ketumbar', 'quantity': 300, 'threshold': 75, 'price': 6000},
          {'name': 'Bawang Putih', 'quantity': 1000, 'threshold': 200, 'price': 15000},
        ]);
        break;
      case 'Minuman':
        stocksData.addAll([
          {'name': 'Air Mineral', 'quantity': 30, 'threshold': 10, 'price': 5000},
          {'name': 'Teh', 'quantity': 20, 'threshold': 5, 'price': 10000},
          {'name': 'Sirup', 'quantity': 10, 'threshold': 2, 'price': 25000},
          {'name': 'Kopi', 'quantity': 5, 'threshold': 2, 'price': 30000},
        ]);
        break;
      case 'Peralatan':
        stocksData.addAll([
          {'name': 'Piring', 'quantity': 24, 'threshold': 5, 'price': 10000},
          {'name': 'Gelas', 'quantity': 36, 'threshold': 10, 'price': 5000},
          {'name': 'Sendok', 'quantity': 48, 'threshold': 12, 'price': 2000},
          {'name': 'Garpu', 'quantity': 48, 'threshold': 12, 'price': 2000},
        ]);
        break;
    }

    for (var data in stocksData) {
      await _stockRepository.addStok({
        'stock_name': data['name'],
        'stock_quantity': data['quantity'],
        'id_stock_type': stockType.idStockType,
        'stock_threshold': data['threshold'],
        'price': data['price'],
      });
    }
  }

  Future<List<MenuType>> _createDummyMenuTypes() async {
    final List<Map<String, String>> typeData = [
      {'name': 'Makanan Utama', 'icon': 'restaurant'},
      {'name': 'Makanan Ringan', 'icon': 'fast_food'},
      {'name': 'Minuman', 'icon': 'glass'},
      {'name': 'Dessert', 'icon': 'cake'}
    ];

    List<MenuType> createdTypes = [];

    for (var data in typeData) {
      final String typeId = "menutype-${const Uuid().v4()}";

      final menuType = MenuType(
        idMenuType: typeId,
        menuTypeName: data['name']!,
        menuTypeIcon: data['icon']!,
      );

      await _databaseHelper.insertQuery('MENU_TYPE', {
        'id_menu_type': typeId,
        'menu_type_name': data['name'],
        'menu_type_icon': data['icon'],
      });

      createdTypes.add(menuType);
    }

    return createdTypes;
  }

  Future<List<TransactionType>> _createDummyTransactionTypes() async {
    final List<Map<String, dynamic>> typeData = [
      {'name': 'Tunai', 'icon': 'cash', 'needEvidence': 0},
      {'name': 'Kartu Debit', 'icon': 'credit_card', 'needEvidence': 1},
      {'name': 'Kartu Kredit', 'icon': 'card', 'needEvidence': 1},
      {'name': 'QRIS', 'icon': 'qris', 'needEvidence': 1},
      {'name': 'Transfer Bank', 'icon': 'bank', 'needEvidence': 1},
      {'name': 'E-Wallet', 'icon': 'wallet', 'needEvidence': 1}
    ];

    List<TransactionType> createdTypes = [];

    for (var data in typeData) {
      final String typeId = "transactiontype-${const Uuid().v4()}";

      final transactionType = TransactionType(
        idTransactionType: typeId,
        transactionTypeName: data['name']!,
        transactionTypeIcon: data['icon']!,
      );

      await _databaseHelper.insertQuery('TRANSACTION_TYPE', {
        'id_transaction_type': typeId,
        'transaction_type_name': data['name'],
        'transaction_type_icon': data['icon'],
        'need_evidence': data['needEvidence'],
      });

      createdTypes.add(transactionType);
    }

    return createdTypes;
  }

  Future<void> _createDummyMenusForType(MenuType menuType) async {
    final List<Map<String, dynamic>> menusData = [];

    switch (menuType.menuTypeName) {
      case 'Makanan Utama':
        menusData.addAll([
          {'name': 'Spaghetti', 'price': 25000, 'image': 'Spaghetti.jpg'},
          {'name': 'Hamburg Steak', 'price': 30000, 'image': 'Hamburg steak.jpg'},
          {'name': 'Ikan Tongkol Goreng', 'price': 28000, 'image': 'Ikan tongkol goreng.jpg'},
          {'name': 'Ayam Dadu', 'price': 22000, 'image': 'Ayam dadu.jpg'},
        ]);
        break;
      case 'Makanan Ringan':
        menusData.addAll([
          {'name': 'Kentang Goreng', 'price': 15000, 'image': 'Kentang goreng.jpg'},
          {'name': 'Burger', 'price': 20000, 'image': 'Burger.jpg'},
          {'name': 'Makaroni Carbonara', 'price': 22000, 'image': 'Makaroni carbonara.jpg'},
          {'name': 'Telur Balado', 'price': 12000, 'image': 'Telur balado.jpg'},
        ]);
        break;
      case 'Minuman':
        menusData.addAll([
          {'name': 'Air Mineral', 'price': 5000, 'image': 'Air putih.jpg'},
          {'name': 'Jus Jeruk', 'price': 10000, 'image': 'Jus jeruk.jpg'},
          {'name': 'Jus Lemon', 'price': 12000, 'image': 'Jus lemon.jpg'},
          {'name': 'Jack Daniels', 'price': 35000, 'image': 'Jack Daniels.jpg'},
        ]);
        break;
      case 'Dessert':
        menusData.addAll([
          {'name': 'Cheesecake', 'price': 20000, 'image': 'Cheesecake.jpg'},
          {'name': 'Ice Cream', 'price': 15000, 'image': 'Ice cream.jpg'},
          {'name': 'Macaron', 'price': 18000, 'image': 'Macaron.jpg'},
          {'name': 'Strawberry Parfait', 'price': 22000, 'image': 'Strawberry parfait.jpg'},
        ]);
        break;
    }

    for (var data in menusData) {
      final Uint8List imageBytes = await _loadDummyImage(data['image']);

      final String menuId = "menu-${const Uuid().v4()}";
      await _databaseHelper.insertQuery('MENU', {
        'id_menu': menuId,
        'menu_name': data['name'],
        'menu_price': data['price'],
        'menu_image': imageBytes,
        'id_menu_type': menuType.idMenuType,
      });
    }
  }

  Future<Uint8List> _loadDummyImage(String imageName) async {
    try {
      final ByteData data = await rootBundle.load('assets/dummy_images/$imageName');
      final Uint8List imageBytes = data.buffer.asUint8List();

      // Compress the image
      final ui.Codec codec =
          await ui.instantiateImageCodec(imageBytes, targetWidth: 100, targetHeight: 100);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ByteData? compressedData =
          await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

      return compressedData!.buffer.asUint8List();
    } catch (e) {
      // If image doesn't exist, provide a default placeholder
      final ByteData data = await rootBundle.load('assets/images/app_icon.png');
      return data.buffer.asUint8List();
    }
  }
}
