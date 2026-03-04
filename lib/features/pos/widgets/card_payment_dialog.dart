import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardPaymentResult {
  final String maskedCardNumber;

  const CardPaymentResult({required this.maskedCardNumber});
}

class CardPaymentDialog extends StatefulWidget {
  final double amount;

  const CardPaymentDialog({super.key, required this.amount});

  @override
  State<CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<CardPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String _digitsOnly(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

  String _maskCard(String digits) {
    if (digits.length < 4) return '****';
    final last4 = digits.substring(digits.length - 4);
    return '**** **** **** $last4';
  }

  bool _isValidExpiry(String value) {
    final cleaned = value.trim();
    final match = RegExp(r'^([0-1][0-9])\/([0-9]{2})$').firstMatch(cleaned);
    if (match == null) return false;

    final month = int.parse(match.group(1)!);
    if (month < 1 || month > 12) return false;

    final yearTwoDigits = int.parse(match.group(2)!);
    final now = DateTime.now();
    final year = 2000 + yearTwoDigits;

    final expiresAt = DateTime(year, month + 1, 0, 23, 59, 59);
    return !expiresAt.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 480;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      title: const Text('Credit Card Payment'),
      content: SizedBox(
        width: 430,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: \$${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cardCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    hintText: '16 digits',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                  ],
                  validator: (v) {
                    final digits = _digitsOnly(v ?? '');
                    if (digits.length < 13 || digits.length > 19) {
                      return 'Invalid card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Expiry',
                          hintText: 'MM/YY',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        validator: (v) {
                          if (!_isValidExpiry(v ?? '')) return 'Invalid expiry';
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: compact ? 8 : 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvCtrl,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          hintText: '3 or 4 digits',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (v) {
                          final digits = _digitsOnly(v ?? '');
                          if (digits.length < 3 || digits.length > 4) {
                            return 'Invalid CVV';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cardholder Name',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
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
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final digits = _digitsOnly(_cardCtrl.text);
            Navigator.pop(
              context,
              CardPaymentResult(maskedCardNumber: _maskCard(digits)),
            );
          },
          child: const Text('Charge Card'),
        ),
      ],
    );
  }
}
