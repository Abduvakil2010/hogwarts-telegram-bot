import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hogwarts/core/localization/app_localizations.dart';
import 'package:hogwarts/core/localization/localization_provider.dart';
import 'package:hogwarts/core/theme/theme_provider.dart';
import 'package:hogwarts/data/models/user_model.dart';
import 'package:hogwarts/data/repositories/database_repository.dart';
import 'package:hogwarts/data/services/telegram_verification_service.dart';
import 'package:hogwarts/features/auth/auth_provider.dart';
import 'package:hogwarts/features/student/student_main_screen.dart';
import 'package:hogwarts/features/teacher/teacher_main_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> expectRoundedNavigation(
    WidgetTester tester, {
    required UserRole role,
    required String code,
    required ThemeData theme,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final database = DatabaseRepository();
    await database.initialize();
    final auth = AuthProvider(
      telegramVerificationService: TelegramVerificationService(
        client: MockClient((_) async => http.Response('{"valid":true}', 200)),
      ),
    );
    await auth.sessionRestoration;
    auth.setSelectedRole(role);
    auth.setTelegramId(code);
    expect(await auth.verifyTelegramId(), isTrue);
    auth.setFullName('Navigation Test User');
    expect(await auth.completeRegistration(), isTrue);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DatabaseRepository>.value(value: database),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ],
        child: MaterialApp(
          theme: theme,
          locale: const Locale('uz'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: role == UserRole.teacher
              ? const TeacherMainScreen()
              : const StudentMainScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final navigation = find.byType(BottomNavigationBar);
    expect(navigation, findsOneWidget);
    expect(tester.widget<BottomNavigationBar>(navigation).items, hasLength(5));
    final clipFinder = find.ancestor(
      of: navigation,
      matching: find.byType(ClipRRect),
    );
    expect(clipFinder, findsOneWidget);
    expect(
      tester.widget<ClipRRect>(clipFinder).borderRadius,
      BorderRadius.circular(20),
    );

    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pump();
    expect(tester.widget<BottomNavigationBar>(navigation).currentIndex, 3);

    await tester.pumpWidget(const SizedBox());
    auth.dispose();
  }

  testWidgets('student navigation is rounded in light mode and still works',
      (tester) async {
    await expectRoundedNavigation(
      tester,
      role: UserRole.student,
      code: '271845',
      theme: ThemeData.light(),
    );
  });

  testWidgets('teacher navigation is rounded in dark mode and still works',
      (tester) async {
    await expectRoundedNavigation(
      tester,
      role: UserRole.teacher,
      code: '638204',
      theme: ThemeData.dark(),
    );
  });
}