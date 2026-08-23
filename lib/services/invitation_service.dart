import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../utils/json_utils.dart';
import '../models/enums.dart';
import '../models/invitation.dart';

class InvitationService {
  final ApiClient _client;

  InvitationService(this._client);

  Future<Invitation> inviteByEmail(
    int patientId, {
    required String email,
    InvitationRole role = InvitationRole.caregiver,
    KinshipType? kinship,
    String? message,
  }) async {
    final data = <String, dynamic>{
      'inviteeEmail': email,
      'inviteeRole': role == InvitationRole.doctor ? 'DOCTOR' : 'CAREGIVER',
      if (kinship != null) 'kinship': kinship.apiValue,
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    };
    try {
      final response = await _client.post('/invitations/patients/$patientId', data: data);
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      return Invitation.fromJson(normalized);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<String?> _getStoredEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('vitalguard_user');
      if (userJson != null) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        final email = map['email'] as String?;
        if (email != null && email.trim().isNotEmpty) return email.trim();
      }
    } catch (_) {}
    return null;
  }

  Future<List<Invitation>> getPending() async {
    try {
      final email = await _getStoredEmail();
      final response = await _client.get('/invitations/pending',
          queryParameters: email != null ? {'email': email} : null);
      final normalized = normalizeJsonKeys(response.data) as List;
      return normalized
          .map((e) => Invitation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<List<Invitation>> getSent() async {
    try {
      final response = await _client.get('/invitations/sent');
      final normalized = normalizeJsonKeys(response.data) as List;
      return normalized
          .map((e) => Invitation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<Invitation> accept(int id, {String? token}) async {
    try {
      final email = await _getStoredEmail();
      final qp = <String, dynamic>{};
      if (token != null) qp['token'] = token;
      if (email != null) qp['email'] = email;
      final response = await _client.post(
        '/invitations/$id/accept',
        queryParameters: qp.isEmpty ? null : qp,
      );
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      return Invitation.fromJson(normalized);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<Invitation> acceptByToken(String token) async {
    final normalizedCode = token.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    try {
      final response = await _client.post('/invitations/accept', data: {'token': normalizedCode.toLowerCase()});
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      return Invitation.fromJson(normalized);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<Invitation> reject(int id, {String? token}) async {
    try {
      final email = await _getStoredEmail();
      final qp = <String, dynamic>{};
      if (token != null) qp['token'] = token;
      if (email != null) qp['email'] = email;
      final response = await _client.post(
        '/invitations/$id/reject',
        queryParameters: qp.isEmpty ? null : qp,
      );
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      return Invitation.fromJson(normalized);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<Invitation> cancel(int id) async {
    try {
      final response = await _client.post('/invitations/$id/cancel');
      final normalized = normalizeJsonKeys(response.data) as Map<String, dynamic>;
      return Invitation.fromJson(normalized);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  String _errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final message = data['message'];
      if (message is String) return message;
      if (message is List && message.isNotEmpty) return message.join(', ');
    }
    return 'No se pudo completar la operación. Intenta de nuevo.';
  }
}
