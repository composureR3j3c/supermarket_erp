import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_erp_demo/features/inventory/widgets/quantity_dialog.dart';
import '../inventory/product_provider.dart';
import '../../shared/models/product.dart';
import 'pos_provider.dart';
import 'widgets/card_payment_dialog.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/product_card.dart';
import 'widgets/upc_scan_dialog.dart';

class POSScreen extends ConsumerWidget {
  const POSScreen({super.key});

  Future<void> _startCardCheckout(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> cart,
    double total, {
    bool closeAfterSuccess = false,
  }) async {
    if (cart.isEmpty) return;

    final paymentResult = await showDialog<CardPaymentResult>(
      context: context,
      builder: (_) => CardPaymentDialog(amount: total),
    );

    if (!context.mounted || paymentResult == null) return;

    ref.read(posProvider.notifier).checkout();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paid with ${paymentResult.maskedCardNumber}')),
    );

    if (closeAfterSuccess && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _scanUpcAndAdd(
    BuildContext context,
    WidgetRef ref,
    List<Product> products,
  ) async {
    final product = await showDialog<Product>(
      context: context,
      builder: (_) => UpcScanDialog(products: products),
    );

    if (!context.mounted) return;
    if (product == null) return;

    if (product.stockQty <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} is out of stock')),
        );
      }
      return;
    }

    final qty = await showDialog<int>(
      context: context,
      builder: (_) => QuantityDialog(maxStock: product.stockQty),
    );

    if (qty == null || qty <= 0) return;

    ref.read(posProvider.notifier).addToCart(product, quantity: qty);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${product.name} x$qty to cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cart = ref.watch(posProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Scan UPC',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scanUpcAndAdd(context, ref, products),
          ),
        ],
      ),
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
              if (isWide)
                SizedBox(
                  width: 360,
                  child: _CartPanel(
                    cart: cart,
                    onCheckout: (context, ref, cart, total) =>
                        _startCardCheckout(context, ref, cart, total),
                  ),
                ),
            ],
          );
        },
      ),

      // CART bottom sheet for small screens
      bottomNavigationBar: LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth >= 1000) return const SizedBox();
          return _MobileCartBar(
            cart: cart,
            onCheckout:
                (context, ref, cart, total, {closeAfterSuccess = false}) =>
                    _startCardCheckout(
                      context,
                      ref,
                      cart,
                      total,
                      closeAfterSuccess: closeAfterSuccess,
                    ),
          );
        },
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  final List<CartItem> cart;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> cart,
    double total,
  )
  onCheckout;

  const _CartPanel({required this.cart, required this.onCheckout});

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
                            onCheckout(context, ref, cart, total);
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
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> cart,
    double total, {
    bool closeAfterSuccess,
  })
  onCheckout;

  const _MobileCartBar({required this.cart, required this.onCheckout});

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
                    builder: (_) =>
                        _MobileCartSheet(cart: cart, onCheckout: onCheckout),
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
                      onCheckout(context, ref, cart, total);
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
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    List<CartItem> cart,
    double total, {
    bool closeAfterSuccess,
  })
  onCheckout;

  const _MobileCartSheet({required this.cart, required this.onCheckout});

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
                              onCheckout(
                                context,
                                ref,
                                cart,
                                total,
                                closeAfterSuccess: true,
                              );
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
