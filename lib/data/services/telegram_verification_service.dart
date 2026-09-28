import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TelegramVerificationException implements Exception {
  final String code;

  const TelegramVerificationException(this.code);
}

class TelegramVerificationService {
  TelegramVerificationService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _baseUrl = (baseUrl ?? _defaultBaseUrl())
            .replaceFirst(RegExp(r'/+$'), '');

  final http.Client _client;
  final bool _ownsClient;
  final String _baseUrl;

  static String _defaultBaseUrl() {
  const configuredUrl = String.fromEnvironment('TELEGRAM_API_BASE_URL');
  if (configuredUrl.isNotEmpty) return configuredUrl;

  return 'https://hogwarts-telegram-bot.onrender.com';
}

  Future<void> verifyCode(String code) async {
    final cleanCode = code.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(cleanCode)) {
      throw const TelegramVerificationException('invalid_code');
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/verify-code'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'code': cleanCode}),
          )
          .timeout(const Duration(seconds: 10));

      final payload = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          payload is Map<String, dynamic> &&
          payload['valid'] == true) {
        return;
      }

      final error =
          payload is Map<String, dynamic> ? payload['error'] as String? : null;
      throw TelegramVerificationException(
        error ?? 'verification_unavailable',
      );
    } on TelegramVerificationException {
      rethrow;
    } on TimeoutException {
      throw const TelegramVerificationException('verification_unavailable');
    } catch (_) {
      throw const TelegramVerificationException('verification_unavailable');
    }
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
