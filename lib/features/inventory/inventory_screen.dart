import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/product.dart';
import 'product_provider.dart';
import 'widgets/add_product_dialog.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddProductDialog(),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: products.isEmpty
            ? const Center(child: Text('No products yet'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('SKU')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: products.map((product) {
                    final lowStock = product.stockQty < 5;

                    return DataRow(
                      color: lowStock
                          ? MaterialStateProperty.all(
                              Colors.red.withOpacity(0.1),
                            )
                          : null,
                      cells: [
                        DataCell(Text(product.name)),
                        DataCell(Text(product.sku)),
                        DataCell(Text(product.category)),
                        DataCell(Text(product.price.toStringAsFixed(2))),
                        DataCell(
                          Text(
                            product.stockQty.toString(),
                            style: TextStyle(
                              color: lowStock ? Colors.red : null,
                              fontWeight:
                                  lowStock ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              ref
                                  .read(productsProvider.notifier)
                                  .deleteProduct(product.id);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
