import 'package:flutter/services.dart';

class CardReadResult {
  final String maskedPan;
  final String? cardBrand;
  final String? transactionRef;

  const CardReadResult({
    required this.maskedPan,
    this.cardBrand,
    this.transactionRef,
  });

  factory CardReadResult.fromMap(Map<dynamic, dynamic> map) {
    return CardReadResult(
      maskedPan: (map['maskedPan'] ?? '').toString(),
      cardBrand: map['cardBrand']?.toString(),
      transactionRef: map['transactionRef']?.toString(),
    );
  }
}

class CardReaderService {
  static const MethodChannel _channel = MethodChannel(
    'supermarket_erp_demo/card_reader',
  );

  Future<CardReadResult> readCard({
    required double amount,
    required String currency,
  }) async {
    try {
      final raw = await _channel.invokeMethod<dynamic>('readCard', {
        'amount': amount,
        'currency': currency,
      });

      if (raw is Map) {
        final result = CardReadResult.fromMap(raw);
        if (result.maskedPan.isEmpty) {
          throw PlatformException(
            code: 'invalid_reader_response',
            message: 'Card reader returned empty PAN.',
          );
        }
        return result;
      }

      throw PlatformException(
        code: 'invalid_reader_response',
        message: 'Card reader returned an invalid payload.',
      );
    } on MissingPluginException {
      throw PlatformException(
        code: 'reader_not_integrated',
        message:
            'POS card reader SDK is not integrated yet on this device build.',
      );
    }
  }
}
