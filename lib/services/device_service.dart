import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../models/device.dart';

class DeviceService extends ChangeNotifier {
  final ApiClient _client;
  final StorageService _storage;
  Device? _cached;

  DeviceService(this._client, this._storage);

  dynamic _normalizeKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final result = <String, dynamic>{};
      value.forEach((key, val) {
        String camelKey = key.replaceAllMapped(
          RegExp(r'_([a-z])'),
          (match) => match.group(1)!.toUpperCase(),
        );
        if (camelKey == 'deviceCompartments') camelKey = 'compartments';
        result[camelKey] = _normalizeKeys(val);
      });
      return result;
    } else if (value is List) {
      return value.map((e) => _normalizeKeys(e)).toList();
    }
    return value;
  }

  Future<Device> _loadCache() async {
    if (_cached != null) return _cached!;
    final stored = await _storage.loadDevice();
    if (stored != null) {
      _cached = stored;
    } else {
      _cached = _defaultDevice;
      await _storage.saveDevice(_cached!);
    }
    return _cached!;
  }

  Future<Device?> getPatientDevice(int patientId) async {
    try {
      final response = await _client.get('/devices/patient/$patientId');
      if (response.data == null) return null;
      final normalized = _normalizeKeys(response.data) as Map<String, dynamic>;
      final device = Device.fromJson(normalized);
      _cached = device;
      await _storage.saveDevice(device);
      return device;
    } on DioException {
      return _loadCache();
    }
  }

  static final Device _defaultDevice = Device(
    id: 1,
    uniqueCode: 'VG-001',
    patientId: 1,
    responsibleCaregiverId: 1,
    isOnline: true,
    lastSyncAt: null,
    firmwareVersion: '2.1.0',
    compartments: const [
      DeviceCompartment(id: 1, deviceId: 1, compartmentNumber: 1),
      DeviceCompartment(id: 2, deviceId: 1, compartmentNumber: 2),
      DeviceCompartment(id: 3, deviceId: 1, compartmentNumber: 3),
      DeviceCompartment(id: 4, deviceId: 1, compartmentNumber: 4),
      DeviceCompartment(id: 5, deviceId: 1, compartmentNumber: 5),
      DeviceCompartment(id: 6, deviceId: 1, compartmentNumber: 6),
    ],
  );
}
