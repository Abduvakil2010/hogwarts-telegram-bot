import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hogwarts/core/localization/localization_provider.dart';
import 'package:hogwarts/core/theme/theme_provider.dart';
import 'package:hogwarts/data/services/telegram_verification_service.dart';
import 'package:hogwarts/features/auth/auth_provider.dart';
import 'package:hogwarts/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app renders Hogwarts branding on startup', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocalizationProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const HogwartsApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.textContaining('HOGWARTS'), findsWidgets);
    expect(find.text("O'QUV MARKAZI"), findsOneWidget);
  });

  test('Telegram verification sends the exact code to the shared API',
      () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'http://localhost:8000/verify-code');
      expect(jsonDecode(request.body), {'code': '123456'});
      return http.Response('{"valid":true}', 200);
    });
    final service = TelegramVerificationService(
      client: client,
      baseUrl: 'http://localhost:8000',
    );

    await service.verifyCode(' 123456 ');
  });

  test('Telegram verification reports expired codes from the API', () async {
    final client = MockClient((_) async {
      return http.Response('{"valid":false,"error":"expired_code"}', 410);
    });
    final service = TelegramVerificationService(client: client);

    await expectLater(
      service.verifyCode('123456'),
      throwsA(
        isA<TelegramVerificationException>().having(
          (error) => error.code,
          'code',
          'expired_code',
        ),
      ),
    );
  });
}
