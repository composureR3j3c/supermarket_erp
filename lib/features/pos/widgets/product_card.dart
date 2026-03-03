import 'package:flutter/material.dart';
import 'package:supermarket_erp_demo/shared/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final void Function(int quantity)? onAdd;

  const ProductCard({super.key, required this.product, required this.onAdd});

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
              child: AddItem(
                outOfStock: product.stockQty == 0,
                maxQty: product.stockQty,
                onAdd: onAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddItem extends StatefulWidget {
  const AddItem({
    super.key,
    required this.outOfStock,
    required this.onAdd,
    this.maxQty,
  });

  final bool outOfStock;
  final void Function(int quantity)? onAdd;
  final int? maxQty;

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  int quantity = 1;

  void increment() {
    if (widget.maxQty != null && quantity >= widget.maxQty!) return;
    setState(() => quantity++);
  }

  void decrement() {
    if (quantity > 1) {
      setState(() => quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.outOfStock)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: decrement,
                icon: const Icon(Icons.remove),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: increment,
                icon: const Icon(Icons.add),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        const SizedBox(height: 6),
        ElevatedButton.icon(
          onPressed: widget.outOfStock
              ? null
              : () => widget.onAdd?.call(quantity),
          icon: const Icon(Icons.shopping_cart),
          label: Text(widget.outOfStock ? 'Out of Stock' : 'Add'),
        ),
      ],
    );
  }
}
