import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../inventory/product_provider.dart';
import 'pos_provider.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/product_card.dart';

class POSScreen extends ConsumerWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cart = ref.watch(posProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          return Row(
            children: [
              // PRODUCTS
              Expanded(
                flex: isWide ? 3 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onAdd: () {
                          ref.read(posProvider.notifier).addToCart(product);
                        },
                      );
                    },
                  ),
                ),
              ),

              // CART (desktop only)
              if (isWide)
                SizedBox(
                  width: 360,
                  child: _CartPanel(cart: cart),
                ),
            ],
          );
        },
      ),

      // CART bottom sheet for small screens
      bottomNavigationBar: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth > 900) return const SizedBox();
          return _MobileCartBar(cart: cart);
        },
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  final List<CartItem> cart;
  const _CartPanel({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.read(posProvider.notifier).total;

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Cart', style: TextStyle(fontSize: 18)),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: cart
                  .map((item) => CartItemWidget(item: item))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cart.isEmpty
                        ? null
                        : () {
                            ref.read(posProvider.notifier).checkout();
                          },
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileCartBar extends ConsumerWidget {
  final List<CartItem> cart;
  const _MobileCartBar({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.read(posProvider.notifier).total;

    return BottomAppBar(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      ref.read(posProvider.notifier).checkout();
                    },
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
