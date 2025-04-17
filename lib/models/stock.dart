class Stock {
  String idStock;
  String stockName;
  int stockQuantity;

  Stock({
    required this.idStock,
    required this.stockName,
    required this.stockQuantity,
  });

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      idStock: map['id_stock'],
      stockName: map['stock_name'],
      stockQuantity: map['stock_quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_stock': idStock,
      'stock_name': stockName,
      'stock_quantity': stockQuantity,
    };
  }
}
