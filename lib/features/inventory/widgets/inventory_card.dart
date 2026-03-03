import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_erp_demo/features/inventory/product_provider.dart';
import 'package:supermarket_erp_demo/features/inventory/widgets/addto_cart_btn.dart';

class InventoryCard extends StatelessWidget {
  final product;
  final WidgetRef ref;

  const InventoryCard(this.product, this.ref, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text('Stock: ${product.stockQty}'),
            Text('Price: \$${product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AddtoCartBtn(product: product, ref: ref),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  visualDensity: VisualDensity.compact,
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
