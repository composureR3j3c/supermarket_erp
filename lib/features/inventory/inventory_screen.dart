import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/product.dart';
import 'product_provider.dart';
import '../pos/pos_provider.dart';
import 'widgets/add_product_dialog.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            tooltip: 'Go to POS',
            icon: const Icon(Icons.point_of_sale),
            onPressed: () => Navigator.pushNamed(context, '/pos'),
          ),
        ],
      ),
     floatingActionButton: FloatingActionButton.extended(
  icon: const Icon(Icons.add),
  label: const Text('Add'),
  onPressed: () async {
    final result = await showDialog(
      context: context,
      builder: (_) => const AddProductDialog(),
    );

    if (result != null) {
      ref.read(productsProvider.notifier).addProduct(result);
    }
  },
),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: products.isEmpty
            ? const Center(child: Text('No products'))
            : isWide
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) =>
                        _InventoryCard(products[i], ref),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, i) =>
                        _InventoryCard(products[i], ref),
                  ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final product;
  final WidgetRef ref;

  const _InventoryCard(this.product, this.ref);

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
            Text('Stock: ${product.stockQty}'),
            Text('Price: ${product.price}'),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Add to cart',
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: product.stockQty <= 0
                      ? null
                      : () {
                          ref
                              .read(posProvider.notifier)
                              .addToCart(product);

                          // Redirect immediately to POS
                          Navigator.pushNamed(context, '/pos');
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
