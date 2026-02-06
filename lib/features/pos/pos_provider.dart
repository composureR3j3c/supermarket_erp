import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/product.dart';
import '../inventory/product_provider.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class POSNotifier extends StateNotifier<List<CartItem>> {
  final ProductNotifier productNotifier;

  POSNotifier(this.productNotifier) : super([]);

  void addToCart(Product product) {
    final index = state.indexWhere((c) => c.product.id == product.id);
    if (index >= 0) {
      state[index].quantity += 1;
      state = [...state];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((c) => c.product.id != productId).toList();
  }

  double get total =>
      state.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  void checkout() {
    // Reduce stock
    for (final item in state) {
      productNotifier.updateStock(
        item.product.id,
        item.product.stockQty - item.quantity,
      );
    }
    state = [];
  }
}

// Provider
final posProvider =
    StateNotifierProvider<POSNotifier, List<CartItem>>((ref) {
  final productsNotifier = ref.read(productsProvider.notifier);
  return POSNotifier(productsNotifier);
});
