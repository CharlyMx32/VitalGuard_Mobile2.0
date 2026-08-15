import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        debugPrint(
          '[DeviceService] getPatientDevice: unexpected response type: ${data.runtimeType}, data: $data',
        );
        return null;
      }
      final normalized = normalizeJsonKeys(data) as Map<String, dynamic>;
      final device = Device.fromJson(normalized);
      _cached = device;
      await _storage.saveDevice(device);
      return device;
    } on DioException {
      final cached = await _loadCache();
      if (cached != null && cached.patientId == patientId) return cached;
      return null;
    }
  }

  Future<Device> saveDeviceByCode(String code, {int? patientId}) async {
    try {
      final response = await _client.post(
        '/devices/vincular',
        data: {'deviceId': code, 'patientId': ?patientId},
      );
      debugPrint('[DeviceService] vincular response: ${response.data}');
      final data = response.data;
      if (data is Map<String, dynamic> && data['device'] is Map) {
        final normalized =
            normalizeJsonKeys(data['device']) as Map<String, dynamic>;
        final device = Device.fromJson(normalized);
        _cached = device;
        await _storage.saveDevice(device);
        return device;
      }
      throw Exception('Respuesta inesperada del servidor');
    } on DioException catch (e) {
      debugPrint(
        '[DeviceService] vincular error: ${e.response?.statusCode} ${e.response?.data}',
      );
      rethrow;
    }
  }

  /// Crea un dispositivo mock local (para testing sin backend/token real)
  Future<Device> saveDeviceMock(String code, {int? patientId}) async {
    final device = Device(
      id: DateTime.now().millisecondsSinceEpoch,
      uniqueCode: code,
      patientId: patientId,
      isOnline: true,
      firmwareVersion: '1.0.0-mock',
      createdAt: DateTime.now(),
    );
    _cached = device;
    await _storage.saveDevice(device);
    debugPrint('[DeviceService] mock device saved: ${device.uniqueCode}');
    return device;
  }

  Future<void> unlinkDevice(int deviceId) async {
    try {
      await _client.delete('/devices/$deviceId');
      _cached = null;
      await _storage.clearDevice();
    } on DioException catch (e) {
      debugPrint(
        '[DeviceService] unlink error: ${e.response?.statusCode} ${e.response?.data}',
      );
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _cached = null;
    await _storage.clearDevice();
  }
}
