import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pos_provider.dart';

class POSScreen extends ConsumerWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('POS')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (_, i) {
                final item = cart[i];
                return ListTile(
                  title: Text(item.product.name),
                  subtitle: Text(
                    '${item.quantity} × \$${item.product.price}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        notifier.removeFromCart(item.product.id),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total: \$${notifier.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: cart.isEmpty
                      ? null
                      : () {
                          notifier.checkout();
                          Navigator.pop(context);
                        },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
