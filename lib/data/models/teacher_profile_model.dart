class TeacherProfileModel {
  final String userId;
  final List<String> groupIds;
  final List<String> subjectIds;

  TeacherProfileModel({
    required this.userId,
    this.groupIds = const [],
    this.subjectIds = const [],
  });

  TeacherProfileModel copyWith({
    List<String>? groupIds,
    List<String>? subjectIds,
  }) {
    return TeacherProfileModel(
      userId: userId,
      groupIds: groupIds ?? this.groupIds,
      subjectIds: subjectIds ?? this.subjectIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'groupIds': groupIds,
      'subjectIds': subjectIds,
    };
  }

  factory TeacherProfileModel.fromMap(Map<String, dynamic> map) {
    return TeacherProfileModel(
      userId: map['userId'] ?? '',
      groupIds: List<String>.from(map['groupIds'] ?? []),
      subjectIds: List<String>.from(map['subjectIds'] ?? []),
    );
  }
}
