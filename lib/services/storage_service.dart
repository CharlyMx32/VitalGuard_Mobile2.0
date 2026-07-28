import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import '../models/treatment.dart';
import '../models/device.dart';
import '../models/caregiver.dart';
import '../models/voice_message.dart';

class StorageService {
  static const _keyPatients = 'data_patients';
  static const _keyTreatments = 'data_treatments';
  static const _keySchedules = 'data_schedules';
  static const _keyLogs = 'data_logs';
  static const _keyCaregivers = 'data_caregivers';
  static const _keyDevice = 'data_device';
  static const _keyVoiceMessages = 'data_voice_messages';

  // ── Patients ──

  Future<List<Patient>> loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyPatients);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> savePatients(List<Patient> patients) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(patients.map((e) => e.toJson()).toList());
    await prefs.setString(_keyPatients, json);
  }

  // ── Treatments ──

  Future<List<Treatment>> loadTreatments() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyTreatments);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Treatment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTreatments(List<Treatment> treatments) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(treatments.map((e) => e.toJson()).toList());
    await prefs.setString(_keyTreatments, json);
  }

  // ── Schedules ──

  Future<List<Schedule>> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keySchedules);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Schedule.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveSchedules(List<Schedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(schedules.map((e) => e.toJson()).toList());
    await prefs.setString(_keySchedules, json);
  }

  // ── Medication Logs ──

  Future<List<MedicationLog>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyLogs);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => MedicationLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveLogs(List<MedicationLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(logs.map((e) => e.toJson()).toList());
    await prefs.setString(_keyLogs, json);
  }

  // ── Caregivers ──

  Future<List<Caregiver>> loadCaregivers() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyCaregivers);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Caregiver.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCaregivers(List<Caregiver> caregivers) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(caregivers.map((e) => e.toJson()).toList());
    await prefs.setString(_keyCaregivers, json);
  }

  // ── Device ──

  Future<Device?> loadDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyDevice);
    if (json == null) return null;
    return Device.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveDevice(Device device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDevice, jsonEncode(device.toJson()));
  }

  // ── Voice Messages ──

  Future<List<VoiceMessage>> loadVoiceMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyVoiceMessages);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => VoiceMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveVoiceMessages(List<VoiceMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(messages.map((e) => e.toJson()).toList());
    await prefs.setString(_keyVoiceMessages, json);
  }

  // ── Clear all ──

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPatients);
    await prefs.remove(_keyTreatments);
    await prefs.remove(_keySchedules);
    await prefs.remove(_keyLogs);
    await prefs.remove(_keyCaregivers);
    await prefs.remove(_keyDevice);
    await prefs.remove(_keyVoiceMessages);
  }
}
