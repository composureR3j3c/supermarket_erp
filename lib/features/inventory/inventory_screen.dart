import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_erp_demo/features/inventory/widgets/inventory_card.dart';
import 'product_provider.dart';
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.8,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => InventoryCard(products[i], ref),
              )
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (_, i) => InventoryCard(products[i], ref),
              ),
      ),
    );
  }
}

