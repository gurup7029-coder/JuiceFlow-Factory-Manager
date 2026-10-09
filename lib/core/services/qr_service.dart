import 'dart:convert';
import '../../models/production_batch.dart';

class QrService {
  static String generateBatchQrPayload(ProductionBatch batch, String factoryName) {
    final Map<String, dynamic> payload = {
      'type': 'JUICEFLOW_BATCH',
      'batch_no': batch.batchNumber,
      'product': batch.productName,
      'planned': batch.plannedQty,
      'actual': batch.actualQty,
      'date': batch.productionDate.toIso8601String().split('T').first,
      'expiry': batch.expiryDate.toIso8601String().split('T').first,
      'qc': batch.qcStatus,
      'factory': factoryName,
    };
    return jsonEncode(payload);
  }

  static Map<String, dynamic>? parseBatchQrPayload(String rawString) {
    try {
      final decoded = jsonDecode(rawString);
      if (decoded is Map<String, dynamic> && decoded['type'] == 'JUICEFLOW_BATCH') {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
