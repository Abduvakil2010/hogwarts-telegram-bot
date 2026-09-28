import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hogwarts/data/models/user_model.dart';
import 'package:hogwarts/data/repositories/database_repository.dart';
import 'package:hogwarts/data/services/local_storage_service.dart';
import 'package:hogwarts/data/services/telegram_verification_service.dart';
import 'package:hogwarts/features/auth/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseRepository().initialize();
  });

  Future<void> verifyRoleSession({
    required UserRole role,
    required String code,
    required String fullName,
  }) async {
    final registrationAuth = AuthProvider(
      telegramVerificationService: TelegramVerificationService(
        client: MockClient((request) async {
          expect(jsonDecode(request.body), {'code': code});
          return http.Response('{"valid":true}', 200);
        }),
      ),
    );
    await registrationAuth.sessionRestoration;

    registrationAuth.setSelectedRole(role);
    registrationAuth.setTelegramId(code);
    expect(await registrationAuth.verifyTelegramId(), isTrue);
    registrationAuth.setFullName(fullName);
    expect(await registrationAuth.completeRegistration(), isTrue);

    final registeredUser = registrationAuth.currentUser!;
    expect(await LocalStorageService.getCurrentUserId(), registeredUser.id);
    final savedUsers = await LocalStorageService.loadCollection('users');
    expect(savedUsers!.any((user) => user['id'] == registeredUser.id), isTrue);
    registrationAuth.dispose();

    final refreshedAuth = AuthProvider(
      telegramVerificationService: TelegramVerificationService(
        client: MockClient((_) async => http.Response('', 500)),
      ),
    );
    expect(refreshedAuth.isLoading, isTrue);
    await refreshedAuth.sessionRestoration;

    expect(refreshedAuth.isAuthenticated, isTrue);
    expect(refreshedAuth.currentUser?.id, registeredUser.id);
    expect(refreshedAuth.currentUser?.fullName, fullName);
    expect(refreshedAuth.currentUser?.role, role);

    await refreshedAuth.logout();
    expect(await LocalStorageService.getCurrentUserId(), isNull);
    refreshedAuth.dispose();
  }

  test('student session and profile restore after provider recreation',
      () async {
    await verifyRoleSession(
      role: UserRole.student,
      code: '271845',
      fullName: 'Student Session Test',
    );
  });

  test('teacher session and profile restore after provider recreation',
      () async {
    await verifyRoleSession(
      role: UserRole.teacher,
      code: '638204',
      fullName: 'Teacher Session Test',
    );
  });
}
