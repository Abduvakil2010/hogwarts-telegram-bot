class Validators {
  /// Validates that an ID is non-empty and strictly 6 numeric digits
  static bool isValidTelegramId(String? id) {
    if (id == null) return false;
    final trimmed = id.trim();
    final regex = RegExp(r'^\d{6}$');
    return regex.hasMatch(trimmed);
  }

  /// Validates non-empty string with minimum length
  static bool isValidName(String? name) {
    if (name == null) return false;
    return name.trim().length >= 2;
  }

  /// Validates group code format e.g. ABC-1234
  static bool isValidGroupCode(String? code) {
    if (code == null) return false;
    return code.trim().length >= 4;
  }

  /// Parses answers string like "1-A, 2-C, 3-B" or "1A 2C 3B" into Map<int, String>
  static Map<int, String> parseAnswers(String raw) {
    final Map<int, String> answers = {};
    if (raw.trim().isEmpty) return answers;

    // Split by comma, newline or whitespace
    final tokens = raw.replaceAll('\n', ',').split(',');
    for (var token in tokens) {
      token = token.trim();
      if (token.isEmpty) continue;

      // Match patterns like "1-A" or "1:A" or "1A"
      final match = RegExp(r'(\d+)\s*[-:\s]?\s*([A-Za-z])').firstMatch(token);
      if (match != null) {
        final qNum = int.tryParse(match.group(1) ?? '');
        final opt = match.group(2)?.toUpperCase();
        if (qNum != null && opt != null) {
          answers[qNum] = opt;
        }
      }
    }
    return answers;
  }

  /// Formats answer map back into standard string "1-A, 2-C, 3-B"
  static String formatAnswersMap(Map<int, String> map) {
    final sortedKeys = map.keys.toList()..sort();
    return sortedKeys.map((k) => '$k-${map[k]}').join(', ');
  }
}
