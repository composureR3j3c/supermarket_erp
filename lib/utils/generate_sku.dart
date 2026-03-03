String generateSku() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'SKU-$timestamp';
}