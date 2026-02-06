import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pos/pos_provider.dart';
import 'product_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            onPressed: () {
              Navigator.pushNamed(context, '/pos');
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return ListTile(
            title: Text(product.name),
            subtitle: Text(
              'Stock: ${product.stockQty} | \$${product.price}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: product.stockQty <= 0
                  ? null
                  : () {
                      ref
                          .read(posProvider.notifier)
                          .addToCart(product);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart'),
                          duration: Duration(milliseconds: 800),
                        ),
                      );
                    },
            ),
          );
        },
      ),
    );
  }
}
