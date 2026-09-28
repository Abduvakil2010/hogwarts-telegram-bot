import 'dart:math';

class CodeGenerator {
  static final Random _random = Random();

  /// Generates a strictly 6-digit numeric string for Telegram ID
  /// e.g. "583214"
  static String generateTelegramId() {
    final number = 100000 + _random.nextInt(900000);
    return number.toString();
  }

  /// Generates a unique group code based on subject abbreviation
  /// e.g. "MAT-7K29" or "ENG-9X42"
  static String generateGroupCode(String subjectName) {
    String prefix = 'GRP';
    final cleaned = subjectName.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    if (cleaned.length >= 3) {
      prefix = cleaned.substring(0, 3);
    } else if (cleaned.isNotEmpty) {
      prefix = cleaned.padRight(3, 'X');
    }

    const chars = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    final suffix = List.generate(4, (index) => chars[_random.nextInt(chars.length)]).join();
    return '$prefix-$suffix';
  }
}
