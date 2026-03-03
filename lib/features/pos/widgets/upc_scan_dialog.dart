import 'package:flutter/material.dart';
import 'package:supermarket_erp_demo/shared/models/product.dart';
import 'upc_camera_scanner_page.dart';

class UpcScanDialog extends StatefulWidget {
  const UpcScanDialog({super.key, required this.products});

  final List<Product> products;

  @override
  State<UpcScanDialog> createState() => _UpcScanDialogState();
}

class _UpcScanDialogState extends State<UpcScanDialog> {
  final _upcCtrl = TextEditingController();
  Product? _found;
  String? _error;

  @override
  void dispose() {
    _upcCtrl.dispose();
    super.dispose();
  }

  void _findProduct() {
    final upc = _upcCtrl.text.trim();
    if (upc.isEmpty) {
      setState(() {
        _found = null;
        _error = 'Enter or scan a UPC';
      });
      return;
    }

    Product? match;
    for (final p in widget.products) {
      if (p.sku.toLowerCase() == upc.toLowerCase()) {
        match = p;
        break;
      }
    }

    setState(() {
      _found = match;
      _error = match == null ? 'No product found for UPC: $upc' : null;
    });
  }

  Future<void> _scanWithCamera() async {
    final upc = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const UpcCameraScannerPage()),
    );
    if (upc == null || upc.isEmpty) return;

    _upcCtrl.text = upc;
    _findProduct();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      title: const Text('Scan UPC'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _upcCtrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'UPC',
                hintText: 'Scan barcode or enter UPC',
                errorText: _error,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Scan with camera',
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanWithCamera,
                    ),
                    IconButton(
                      tooltip: 'Find product',
                      icon: const Icon(Icons.search),
                      onPressed: _findProduct,
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => _findProduct(),
            ),
            if (_found != null) ...[
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _found!.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('UPC/SKU: ${_found!.sku}'),
                      Text('Price: \$${_found!.price.toStringAsFixed(2)}'),
                      Text('Stock: ${_found!.stockQty}'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _found == null
              ? null
              : () => Navigator.pop(context, _found),
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}
