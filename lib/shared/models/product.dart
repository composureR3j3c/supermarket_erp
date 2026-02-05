import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String sku;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int stockQty;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final DateTime? expiryDate;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stockQty,
    required this.category,
    this.expiryDate,
  });
}
