import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/config/app_environment.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final String baseUrl;

  Future<dynamic> get(String path, {bool requiresAuth = true}) =>
      _send('GET', path, requiresAuth: requiresAuth);

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) =>
      _send('POST', path, body: body);

  Future<dynamic> put(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) => _send('PUT', path, body: body, requiresAuth: requiresAuth);

  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) => _send('PATCH', path, body: body, requiresAuth: requiresAuth);

  Future<dynamic> delete(String path, {bool requiresAuth = true}) =>
      _send('DELETE', path, requiresAuth: requiresAuth);

  Future<String> authToken() async {
    if (!Get.isRegistered<SecureStorageService>()) return '';
    return await SecureStorageService.to.readSecure(
          AuthController.authTokenStorageKey,
        ) ??
        '';
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    final token = requiresAuth ? await authToken() : '';
    if (requiresAuth && token.isEmpty) {
      throw const ApiException('Please sign in again.', statusCode: 401);
    }

    late final http.Response response;
    final uri = Uri.parse('${baseUrl.replaceFirst(RegExp(r'/$'), '')}$path');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (requiresAuth) 'Authorization': 'Bearer $token',
    };
    try {
      response = await switch (method) {
        'GET' => http.get(uri, headers: headers),
        'POST' => http.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
        'PUT' => http.put(uri, headers: headers, body: jsonEncode(body)),
        'PATCH' => http.patch(uri, headers: headers, body: jsonEncode(body)),
        'DELETE' => http.delete(uri, headers: headers),
        _ => throw ArgumentError.value(method, 'method', 'Unsupported method'),
      }.timeout(const Duration(seconds: 15));
    } on Exception {
      throw const ApiException(
        'Could not reach Jobodia. Check your connection and try again.',
      );
    }

    dynamic decoded;
    if (response.body.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        decoded = response.body;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ??
                decoded['error']?.toString() ??
                'Request failed.'
          : 'Request failed.';
      throw ApiException(message, statusCode: response.statusCode);
    }
    return decoded;
  }
}
