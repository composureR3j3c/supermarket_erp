import 'package:flutter/material.dart';
import '../pos_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItem item;
  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(item.product.name),
      subtitle: Text('Price: ${item.product.price.toStringAsFixed(2)} x ${item.quantity}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          ref.read(posProvider.notifier).removeFromCart(item.product.id);
        },
      ),
    );
  }
}
