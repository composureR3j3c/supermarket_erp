import 'package:hive/hive.dart';
import '../../shared/models/product.dart';

class ProductRepository {
  final Box<Product> _box = Hive.box<Product>('products');

  List<Product> getAll() {
    return _box.values.toList();
  }

  Future<void> add(Product product) async {
    await _box.put(product.id, product);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
