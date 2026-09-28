class TestResultModel {
  final String resultId;
  final String testId;
  final String testTitle;
  final String studentId;
  final String studentName;
  final int correctCount;
  final int wrongCount;
  final int earnedPoints;
  final Map<int, String> answers;
  final DateTime submittedAt;

  TestResultModel({
    required this.resultId,
    required this.testId,
    required this.testTitle,
    required this.studentId,
    required this.studentName,
    required this.correctCount,
    required this.wrongCount,
    required this.earnedPoints,
    this.answers = const {},
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> answersMap = {};
    answers.forEach((k, v) => answersMap[k.toString()] = v);

    return {
      'resultId': resultId,
      'testId': testId,
      'testTitle': testTitle,
      'studentId': studentId,
      'studentName': studentName,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'earnedPoints': earnedPoints,
      'answers': answersMap,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory TestResultModel.fromMap(Map<String, dynamic> map) {
    final Map<int, String> answers = {};
    if (map['answers'] is Map) {
      (map['answers'] as Map).forEach((k, v) {
        final keyNum = int.tryParse(k.toString());
        if (keyNum != null) {
          answers[keyNum] = v.toString();
        }
      });
    }

    return TestResultModel(
      resultId: map['resultId'] ?? '',
      testId: map['testId'] ?? '',
      testTitle: map['testTitle'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      correctCount: (map['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (map['wrongCount'] as num?)?.toInt() ?? 0,
      earnedPoints: (map['earnedPoints'] as num?)?.toInt() ?? 0,
      answers: answers,
      submittedAt: map['submittedAt'] != null
          ? DateTime.tryParse(map['submittedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
