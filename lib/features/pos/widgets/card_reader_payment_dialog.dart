import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supermarket_erp_demo/features/pos/services/card_reader_service.dart';

class CardReaderPaymentDialog extends StatefulWidget {
  final double amount;
  final String currency;

  const CardReaderPaymentDialog({
    super.key,
    required this.amount,
    this.currency = 'USD',
  });

  @override
  State<CardReaderPaymentDialog> createState() =>
      _CardReaderPaymentDialogState();
}

class _CardReaderPaymentDialogState extends State<CardReaderPaymentDialog> {
  final CardReaderService _reader = CardReaderService();
  bool _isReading = false;
  String? _error;

  Future<void> _startReading() async {
    setState(() {
      _isReading = true;
      _error = null;
    });

    try {
      final result = await _reader.readCard(
        amount: widget.amount,
        currency: widget.currency,
      );
      if (!mounted) return;
      Navigator.pop(context, result);
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message ?? 'Failed to read card.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Failed to read card.');
    } finally {
      if (mounted) {
        setState(() => _isReading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startReading());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      title: const Text('Present Card'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Charge: ${widget.currency} ${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text('Tap, insert, or swipe card on the POS reader.'),
            const SizedBox(height: 12),
            if (_isReading)
              const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text('Waiting for card...')),
                ],
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isReading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isReading ? null : _startReading,
          child: const Text('Retry Reader'),
        ),
      ],
    );
  }
}
