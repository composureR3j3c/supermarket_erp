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
      appBar: AppBar(title: const Text('Point of Sale'), centerTitle: false),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWide = width >= 1000;
          final crossAxisCount = width >= 1200
              ? 4
              : width >= 760
              ? 3
              : 2;

          return Row(
            children: [
              // PRODUCTS
              Expanded(
                flex: isWide ? 3 : 1,
                child: Padding(
                  padding: EdgeInsets.all(width < 480 ? 8 : 12),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: width < 480 ? 8 : 12,
                      mainAxisSpacing: width < 480 ? 8 : 12,
                      childAspectRatio: width < 480 ? 0.95 : 0.9,
                    ),
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onAdd: (qty) {
                          ref
                              .read(posProvider.notifier)
                              .addToCart(product, quantity: qty);
                        },
                      );
                    },
                  ),
                ),
              ),

              // CART (desktop only)
              if (isWide) SizedBox(width: 360, child: _CartPanel(cart: cart)),
            ],
          );
        },
      ),

      // CART bottom sheet for small screens
      bottomNavigationBar: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth >= 1000) return const SizedBox();
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
              children: cart.map((item) => CartItemWidget(item: item)).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
    final compact = MediaQuery.of(context).size.width < 400;

    return BottomAppBar(
      height: compact ? 64 : 70,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => _MobileCartSheet(cart: cart),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  'View Cart (${cart.length})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      ref.read(posProvider.notifier).checkout();
                    },
              child: Text('Checkout  \$${total.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCartSheet extends ConsumerWidget {
  final List<CartItem> cart;
  const _MobileCartSheet({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.read(posProvider.notifier).total;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Cart Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Cart is empty'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: cart.length,
                          itemBuilder: (_, index) =>
                              CartItemWidget(item: cart[index]),
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total: \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              ref.read(posProvider.notifier).checkout();
                              Navigator.pop(context);
                            },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
