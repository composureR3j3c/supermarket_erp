import 'package:flutter/material.dart';
import 'package:supermarket_erp_demo/shared/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stockQty <= 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Stock: ${product.stockQty}',
              style: TextStyle(
                fontSize: 12,
                color: outOfStock ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: outOfStock ? null : onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
