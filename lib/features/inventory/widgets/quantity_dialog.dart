import 'package:flutter/material.dart';
import 'package:supermarket_erp_demo/features/inventory/widgets/inventory_card.dart';

class QuantityDialog extends StatefulWidget {
  final int maxStock;

  const QuantityDialog({required this.maxStock});

  @override
  State<QuantityDialog> createState() => QuantityDialogState();
}
class QuantityDialogState extends State<QuantityDialog> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 480;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      title: const Text('Select Quantity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Available: ${widget.maxStock}'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                visualDensity: VisualDensity.compact,
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
              ),
              Text(
                quantity.toString(),
                style: TextStyle(fontSize: isCompact ? 18 : 20),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                visualDensity: VisualDensity.compact,
                onPressed: quantity < widget.maxStock
                    ? () => setState(() => quantity++)
                    : null,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, quantity),
          child: const Text('Add'),
        ),
      ],
    );
  }
}


