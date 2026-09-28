class TestModel {
  final String testId;
  final String teacherId;
  final String groupId;
  final String groupName;
  final String subjectId;
  final String subjectName;
  final String title;
  final String imageUrl;
  final int questionCount;
  final Map<int, String> correctAnswers; // E.g. {1: 'A', 2: 'B', 3: 'C'}
  final DateTime createdAt;
  final bool active;

  TestModel({
    required this.testId,
    required this.teacherId,
    required this.groupId,
    required this.groupName,
    required this.subjectId,
    required this.subjectName,
    required this.title,
    this.imageUrl = '',
    required this.questionCount,
    this.correctAnswers = const {},
    required this.createdAt,
    this.active = true,
  });

  /// Sanitized copy for student view: strips correct answers
  TestModel forStudent() {
    return TestModel(
      testId: testId,
      teacherId: teacherId,
      groupId: groupId,
      groupName: groupName,
      subjectId: subjectId,
      subjectName: subjectName,
      title: title,
      imageUrl: imageUrl,
      questionCount: questionCount,
      correctAnswers: const {}, // Stripped for security
      createdAt: createdAt,
      active: active,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> answersMap = {};
    correctAnswers.forEach((key, value) {
      answersMap[key.toString()] = value;
    });

    return {
      'testId': testId,
      'teacherId': teacherId,
      'groupId': groupId,
      'groupName': groupName,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'title': title,
      'imageUrl': imageUrl,
      'questionCount': questionCount,
      'correctAnswers': answersMap,
      'createdAt': createdAt.toIso8601String(),
      'active': active,
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    final Map<int, String> answers = {};
    if (map['correctAnswers'] is Map) {
      (map['correctAnswers'] as Map).forEach((k, v) {
        final keyNum = int.tryParse(k.toString());
        if (keyNum != null) {
          answers[keyNum] = v.toString();
        }
      });
    }

    return TestModel(
      testId: map['testId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      questionCount: (map['questionCount'] as num?)?.toInt() ?? 10,
      correctAnswers: answers,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      active: map['active'] ?? true,
    );
  }
}
