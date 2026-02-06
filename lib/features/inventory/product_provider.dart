import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_repository.dart';
import '../../shared/models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productsProvider = StateNotifierProvider<ProductNotifier, List<Product>>(
  (ref) => ProductNotifier(ref.read(productRepositoryProvider)),
);

class ProductNotifier extends StateNotifier<List<Product>> {
  final ProductRepository repository;

  ProductNotifier(this.repository) : super(repository.getAll());

  Future<void> addProduct(Product product) async {
    await repository.add(product);
    state = repository.getAll();
  }

  Future<void> deleteProduct(String id) async {
    await repository.delete(id);
    state = repository.getAll();
  }

  void updateStock(String id, int i) {
    final index = state.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final product = state[index];
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        sku: product.sku,
        category: product.category,
        price: product.price,
        stockQty: i,
      );
      repository.update(updatedProduct);
      state = repository.getAll();
    }
  }
}
