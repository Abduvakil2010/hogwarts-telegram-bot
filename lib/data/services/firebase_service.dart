import 'package:url_launcher/url_launcher.dart';

/// Firebase Collections and Architecture Configuration.
///
/// The project is currently using a local persistence layer, but this service
/// keeps the naming and sync contract aligned with the Firebase/firestore design
/// expected by the app.
class FirebaseService {
  // Collection Names matching requirements
  static const String colUsers = 'users';
  static const String colStudents = 'students';
  static const String colTeachers = 'teachers';
  static const String colTelegramIds = 'telegram_ids';
  static const String colSubjects = 'subjects';
  static const String colGroups = 'groups';
  static const String colTests = 'tests';
  static const String colTestResults = 'test_results';
  static const String colProducts = 'products';
  static const String colPurchases = 'purchases';
  static const String colPointTransactions = 'point_transactions';
  static const String colNotifications = 'notifications';

  static const String telegramBotUsername = 'HogwartsEduApp_bot';

  /// Checks whether live Firebase connection is active.
  static bool get isFirebaseInitialized => false; // Can be toggled with firebase_core

  static Future<void> syncCollection({
    required String collection,
    required List<Map<String, dynamic>> data,
  }) async {
    // Placeholder for a future Firebase sync implementation.
    // In the current app, data is kept in-memory and persisted locally.
    // This keeps the collection contract stable for future backend migration.
    await Future<void>.value();
    if (collection.isEmpty || data.isEmpty) {
      return;
    }
  }

  static Uri buildTelegramBotUri({required String code}) {
    final payload = 'hogwarts_${code.trim()}';
    return Uri.parse('https://t.me/$telegramBotUsername?start=${Uri.encodeComponent(payload)}');
  }

  static Uri buildTelegramDeepLink({required String code}) {
    final payload = 'hogwarts_${code.trim()}';
    return Uri(scheme: 'tg', host: 'resolve', queryParameters: {
      'domain': telegramBotUsername,
      'start': payload,
    });
  }

  static Future<bool> openTelegramBot({required String code}) async {
    final deepLink = buildTelegramDeepLink(code: code);
    final webLink = buildTelegramBotUri(code: code);

    if (await canLaunchUrl(deepLink)) {
      final launched = await launchUrl(
        deepLink,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    }

    if (await canLaunchUrl(webLink)) {
      final launched = await launchUrl(
        webLink,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    }

    return false;
  }
}
