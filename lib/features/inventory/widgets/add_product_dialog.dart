import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/product.dart';
import '../product_provider.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  const AddProductDialog({super.key});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Product'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _skuCtrl,
                  decoration: const InputDecoration(labelText: 'SKU'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      double.tryParse(v ?? '') == null ? 'Invalid price' : null,
                ),
                TextFormField(
                  controller: _stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock Qty'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      int.tryParse(v ?? '') == null ? 'Invalid stock' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final product = Product(
              id: const Uuid().v4(),
              name: _nameCtrl.text,
              sku: _skuCtrl.text,
              category: _categoryCtrl.text,
              price: double.parse(_priceCtrl.text),
              stockQty: int.parse(_stockCtrl.text),
            );

            ref.read(productsProvider.notifier).addProduct(product);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
