import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class BackendException implements Exception {
  const BackendException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class BackendService {
  static const baseUrl = 'https://otuatyepmgqlmllmwlkc.supabase.co';
  static const publishableKey = 'sb_publishable_vtZ6-rEHNQz7GcEOFA1mdg_U5kizLp6';

  static final Uri _loginUri = Uri.parse('$baseUrl/functions/v1/pin-login');
  static final Uri _apiUri = Uri.parse('$baseUrl/functions/v1/trip-api');

  Map<String, String> get _baseHeaders => const {
        'Content-Type': 'application/json',
        'apikey': publishableKey,
      };

  Future<TripSession> login(String pin) async {
    final response = await http.post(
      _loginUri,
      headers: _baseHeaders,
      body: jsonEncode({'pin': pin}),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendException(
        (body['message'] ?? body['error'] ?? 'Login non riuscito').toString(),
        statusCode: response.statusCode,
      );
    }

    return TripSession(
      token: body['token'].toString(),
      expiresAt: DateTime.parse(body['expiresAt'].toString()),
      user: UserProfile.fromJson(Map<String, dynamic>.from(body['user'] as Map)),
    );
  }

  Future<Map<String, dynamic>> api(
    String token,
    String action, [
    Map<String, dynamic> data = const {},
  ]) async {
    final response = await http.post(
      _apiUri,
      headers: {
        ..._baseHeaders,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'action': action, ...data}),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendException(
        (body['message'] ?? body['error'] ?? 'Errore backend').toString(),
        statusCode: response.statusCode,
      );
    }
    return body;
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.trim().isEmpty) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw BackendException(
        'Risposta non valida dal server',
        statusCode: response.statusCode,
      );
    }
  }
}
