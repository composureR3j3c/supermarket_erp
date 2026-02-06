import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/product.dart';
import 'product_provider.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: () {
          ref.read(productsProvider.notifier).addProduct(
                Product(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: 'Product ${products.length + 1}',
                  sku: 'SKU-${products.length + 1}',
                  category: 'General',
                  price: 10,
                  stockQty: 5,
                ),
              );
        },
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: isWide
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) =>
                          _ProductCard(products[i], ref),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (_, i) =>
                          _ProductCard(products[i], ref),
                    ),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final WidgetRef ref;

  const _ProductCard(this.product, this.ref);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('SKU: ${product.sku}'),
            Text('Category: ${product.category}'),
            const SizedBox(height: 4),
            Text('Stock: ${product.stockQty}'),
            Text('Price: \$${product.price}'),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Decrease stock',
                  icon: const Icon(Icons.remove),
                  onPressed: product.stockQty <= 0
                      ? null
                      : () {
                          ref
                              .read(productsProvider.notifier)
                              .updateStock(
                                product.id,
                                product.stockQty - 1,
                              );
                        },
                ),
                IconButton(
                  tooltip: 'Increase stock',
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    ref
                        .read(productsProvider.notifier)
                        .updateStock(
                          product.id,
                          product.stockQty + 1,
                        );
                  },
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(productsProvider.notifier)
                        .deleteProduct(product.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
