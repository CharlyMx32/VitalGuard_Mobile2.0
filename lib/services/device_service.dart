import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../utils/json_utils.dart';
import '../models/device.dart';

class DeviceService {
  final ApiClient _client;
  final StorageService _storage;
  Device? _cached;

  DeviceService(this._client, this._storage);

  Future<Device?> _loadCache() async {
    if (_cached != null) return _cached;
    _cached = await _storage.loadDevice();
    return _cached;
  }

  Future<Device?> getPatientDevice(int patientId) async {
    try {
      final response = await _client.get('/devices/patient/$patientId');
      if (response.data == null) return null;
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      final device = Device.fromJson(normalized);
      _cached = device;
      await _storage.saveDevice(device);
      return device;
    } on DioException {
      return _loadCache();
    }
  }
}
