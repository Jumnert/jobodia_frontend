import 'dart:convert';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:jobodia_frontend/core/config/app_environment.dart';

enum OAuthProvider { google, github }

class OAuthLoginResult {
  const OAuthLoginResult({
    required this.status,
    required this.email,
    this.token,
    this.setupToken,
    this.role,
    this.userId,
    this.username,
    this.avatarUrl,
  });

  final String status;
  final String email;
  final String? token;
  final String? setupToken;
  final String? role;
  final String? userId;
  final String? username;
  final String? avatarUrl;

  bool get requiresRoleSelection => status == 'REQUIRES_ROLE_SELECTION';

  factory OAuthLoginResult.fromJson(Map<String, dynamic> json) {
    return OAuthLoginResult(
      status: json['status'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String?,
      setupToken: json['setupToken'] as String?,
      role: json['role'] as String?,
      userId: json['userId'] as String?,
      username: json['username'] as String? ?? json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Authentication repository.
///
/// Production uses the Spring authentication endpoints. UAT keeps deterministic
/// mock responses so testers can exercise the UI without production accounts.
class AuthRepository {
  AuthRepository({String? baseUrl, bool? useMockAuth})
    : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
      useMockAuth = useMockAuth ?? AppConfig.useMockAuth;

  static const callbackScheme = 'jobodia';
  static const callbackUri = '$callbackScheme://oauth/callback';

  final String baseUrl;
  final bool useMockAuth;
  PasswordLoginResult? lastPasswordLoginResult;

  static void _validateCredentials(String email, String password) {
    if (email.isEmpty || !email.contains('@')) {
      throw ArgumentError('Invalid email address');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }
  }

  Future<OAuthLoginResult> loginWithOAuth(OAuthProvider provider) async {
    if (useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return OAuthLoginResult(
        status: 'AUTHENTICATED',
        email: '${provider.name}@jobodia.uat',
        token: 'uat-${provider.name}-token',
        role: 'SEEKER',
        userId: 'uat-${provider.name}-user',
        username: provider.name,
      );
    }
    final authorizationUri = Uri.parse(
      '$baseUrl/oauth2/authorization/${provider.name}',
    ).replace(queryParameters: const {'redirect_uri': callbackUri});

    final callback = await FlutterWebAuth2.authenticate(
      url: authorizationUri.toString(),
      callbackUrlScheme: callbackScheme,
    );
    final callbackResult = Uri.parse(callback);
    final providerError = callbackResult.queryParameters['error'];
    if (providerError != null && providerError.isNotEmpty) {
      throw AuthRepositoryException(providerError);
    }

    final code = callbackResult.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const AuthRepositoryException(
        'The login provider did not return an authorization code.',
      );
    }

    final json = await _postJson('/api/v1/auth/oauth2/mobile/exchange', {
      'code': code,
    });
    final result = OAuthLoginResult.fromJson(json);
    if (result.status == 'AUTHENTICATED' &&
        (result.token == null || result.token!.isEmpty)) {
      throw const AuthRepositoryException(
        'The backend did not return a token.',
      );
    }
    if (result.requiresRoleSelection &&
        (result.setupToken == null || result.setupToken!.isEmpty)) {
      throw const AuthRepositoryException(
        'The backend did not return an account setup token.',
      );
    }
    return result;
  }

  Future<OAuthLoginResult> completeOAuthSignup({
    required String setupToken,
    required String role,
    required String email,
  }) async {
    if (useMockAuth) {
      return OAuthLoginResult(
        status: 'AUTHENTICATED',
        email: email,
        token: 'uat-oauth-token',
        role: role,
        userId: 'uat-oauth-user',
        username: email.split('@').first,
      );
    }
    final json = await _postJson('/api/v1/auth/oauth2/complete-signup', {
      'setupToken': setupToken,
      'role': role,
    });
    return OAuthLoginResult(
      status: 'AUTHENTICATED',
      email: email,
      token: json['token'] as String?,
      role: json['role'] as String?,
      userId: json['userId'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _sendPost(path, body);

    Map<String, dynamic> json = const {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) json = decoded;
    } on FormatException {
      // A safe fallback is returned below for non-JSON server errors.
    }

    return json;
  }

  Future<bool> fakeLogin(String email, String password) async {
    _validateCredentials(email, password);
    if (useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      lastPasswordLoginResult = PasswordLoginResult(
        token: 'uat-password-token',
        email: email,
        role: 'SEEKER',
        userId: 'uat-password-user',
        username: email.split('@').first,
      );
      return true;
    }

    final token = await _postText('/api/v1/auth/authenticate', {
      'email': email,
      'password': password,
    });
    lastPasswordLoginResult = PasswordLoginResult(
      token: token,
      email: email,
      role: _readJwtClaim(token, 'role') ?? 'SEEKER',
      userId: _readJwtClaim(token, 'userId') ?? email,
      username: _readJwtClaim(token, 'username') ?? email.split('@').first,
      avatarUrl: _readJwtClaim(token, 'avatarUrl'),
    );
    return true;
  }

  Future<bool> fakeSignUp(
    String username,
    String email,
    String password,
  ) async {
    _validateCredentials(email, password);
    if (useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return true;
    }
    await _postJson('/api/v1/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'role': 'SEEKER',
    });
    return true;
  }

  Future<bool> fakeVerifyOtp(String email, String otp) async {
    if (useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return true;
    }
    await _postJson('/api/v1/auth/verify-otp', {'email': email, 'otp': otp});
    return true;
  }

  Future<bool> fakeResendOtp(String email) async {
    if (useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return true;
    }
    await _postJson(
      '/api/v1/auth/resend-verification-otp?email=${Uri.encodeQueryComponent(email)}',
      const {},
    );
    return true;
  }

  Future<bool> fakeResetPassword(String newPassword) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> sendResetOtp(String email) async {
    if (useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return;
    }
    await _postJson(
      '/api/v1/auth/send-reset-otp?email=${Uri.encodeQueryComponent(email)}',
      const {},
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    if (useMockAuth) {
      await fakeResetPassword(password);
      return;
    }
    await _postJson('/api/v1/auth/reset-password', {
      'email': email,
      'otp': otp,
      'password': password,
    });
  }

  Future<String> _postText(String path, Map<String, dynamic> body) async {
    final response = await _sendPost(path, body);
    return response.body.trim();
  }

  Future<http.Response> _sendPost(
    String path,
    Map<String, dynamic> body,
  ) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } on Exception {
      throw const AuthRepositoryException(
        'Could not reach Jobodia. Check your connection and try again.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Authentication failed. Please try again.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          message =
              decoded['error'] as String? ??
              decoded['message'] as String? ??
              message;
        }
      } on FormatException {
        if (response.body.trim().isNotEmpty) message = response.body.trim();
      }
      throw AuthRepositoryException(message);
    }
    return response;
  }

  String? _readJwtClaim(String token, String claim) {
    final segments = token.split('.');
    if (segments.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(segments[1])),
      );
      final json = jsonDecode(payload);
      return json is Map<String, dynamic> ? json[claim]?.toString() : null;
    } on FormatException {
      return null;
    }
  }
}

class PasswordLoginResult {
  const PasswordLoginResult({
    required this.token,
    required this.email,
    required this.role,
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  final String token;
  final String email;
  final String role;
  final String userId;
  final String username;
  final String? avatarUrl;
}
