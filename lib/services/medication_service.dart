import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/medication.dart';

class MedicationService {
  final ApiClient _client;
  final StorageService _storage;
  List<Medication>? _cached;

  static final List<Medication> _fallback = [
    const Medication(id: 1, name: 'Paracetamol', presentation: 'Tableta 500mg'),
    const Medication(id: 2, name: 'Ibuprofeno', presentation: 'Tableta 400mg'),
    const Medication(id: 3, name: 'Aspirina', presentation: 'Tableta 100mg'),
    const Medication(id: 4, name: 'Naproxeno', presentation: 'Tableta 250mg'),
    const Medication(id: 5, name: 'Diclofenaco', presentation: 'Tableta 50mg'),
    const Medication(id: 6, name: 'Ketorolaco', presentation: 'Tableta 10mg'),
    const Medication(id: 7, name: 'Losartan', presentation: 'Tableta 50mg'),
    const Medication(id: 8, name: 'Enalapril', presentation: 'Tableta 10mg'),
    const Medication(id: 9, name: 'Amlodipino', presentation: 'Tableta 5mg'),
    const Medication(id: 10, name: 'Metoprolol', presentation: 'Tableta 50mg'),
    const Medication(id: 11, name: 'Valsartan', presentation: 'Tableta 80mg'),
    const Medication(id: 12, name: 'Metformina', presentation: 'Tableta 850mg'),
    const Medication(id: 13, name: 'Glibenclamida', presentation: 'Tableta 5mg'),
    const Medication(id: 14, name: 'Insulina NPH', presentation: 'Vial 100 UI/ml'),
    const Medication(id: 15, name: 'Omeprazol', presentation: 'Capsula 20mg'),
    const Medication(id: 16, name: 'Pantoprazol', presentation: 'Tableta 40mg'),
    const Medication(id: 17, name: 'Ranitidina', presentation: 'Tableta 150mg'),
    const Medication(id: 18, name: 'Domperidona', presentation: 'Tableta 10mg'),
    const Medication(id: 19, name: 'Amoxicilina', presentation: 'Capsula 500mg'),
    const Medication(id: 20, name: 'Azitromicina', presentation: 'Tableta 500mg'),
    const Medication(id: 21, name: 'Ciprofloxacino', presentation: 'Tableta 500mg'),
    const Medication(id: 22, name: 'Cefalexina', presentation: 'Capsula 500mg'),
    const Medication(id: 23, name: 'Vitamina C', presentation: 'Tableta 1g'),
    const Medication(id: 24, name: 'Vitamina D', presentation: 'Capsula 400 UI'),
    const Medication(id: 25, name: 'Vitamina B12', presentation: 'Tableta 1000mcg'),
    const Medication(id: 26, name: 'Calcio + Vitamina D', presentation: 'Tableta 600mg/400 UI'),
    const Medication(id: 27, name: 'Atorvastatina', presentation: 'Tableta 20mg'),
    const Medication(id: 28, name: 'Simvastatina', presentation: 'Tableta 20mg'),
    const Medication(id: 29, name: 'Levotiroxina', presentation: 'Tableta 50mcg'),
    const Medication(id: 30, name: 'Prednisona', presentation: 'Tableta 5mg'),
  ];

  MedicationService(this._client, this._storage);

  Future<List<Medication>> _loadCache() async {
    if (_cached != null) return _cached!;
    _cached = await _storage.loadMedications();
    return _cached!;
  }

  Future<List<Medication>> getMedications() async {
    try {
      final response = await _client.get('/medications');
      final normalized = normalizeJsonKeys(response.data) as List;
      final data = normalized
          .map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList();
      _cached = data;
      await _storage.saveMedications(data);
      return data;
    } on DioException {
      final cached = await _loadCache();
      if (cached.isNotEmpty) return cached;
      _cached = _fallback;
      return _fallback;
    }
  }

  Future<List<Medication>> searchMedications(String query) async {
    final all = await getMedications();
    if (query.trim().isEmpty) return all;
    final q = query.trim().toLowerCase();
    return all
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            (m.presentation?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  Future<Map<String, dynamic>> requestMedication({
    required int patientId,
    required String medicationName,
    required String presentation,
  }) async {
    final response = await _client.post('/medications/request', data: {
      'patientId': patientId,
      'medicationName': medicationName,
      'presentation': presentation,
    });
    return response.data as Map<String, dynamic>;
  }
}
