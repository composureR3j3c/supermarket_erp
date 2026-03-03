import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_erp_demo/features/inventory/widgets/quantity_dialog.dart';
import 'package:supermarket_erp_demo/features/pos/pos_provider.dart';

class AddtoCartBtn extends StatelessWidget {
  const AddtoCartBtn({
    super.key,
    required this.product,
    required this.ref,
  });

  final dynamic product;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Add to cart',
      icon: const Icon(Icons.add_shopping_cart),
      visualDensity: VisualDensity.compact,
      onPressed: product.stockQty <= 0
          ? null
          : () async {
              final qty = await showDialog<int>(
                context: context,
                builder: (_) =>
                    QuantityDialog(maxStock: product.stockQty),
              );
    
              if (qty != null && qty > 0) {
                ref
                    .read(posProvider.notifier)
                    .addToCart(product, quantity: qty);
    
                Navigator.pushNamed(context, '/pos');
              }
            },
    );
  }
}

