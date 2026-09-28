class GroupModel {
  final String groupId;
  final String teacherId;
  final String teacherName;
  final String name;
  final String subjectId;
  final String subjectName;
  final String groupCode;
  final List<String> studentIds;
  final String description;
  final DateTime createdAt;

  GroupModel({
    required this.groupId,
    required this.teacherId,
    required this.teacherName,
    required this.name,
    required this.subjectId,
    required this.subjectName,
    required this.groupCode,
    this.studentIds = const [],
    this.description = '',
    required this.createdAt,
  });

  int get studentCount => studentIds.length;

  GroupModel copyWith({
    String? name,
    String? description,
    List<String>? studentIds,
  }) {
    return GroupModel(
      groupId: groupId,
      teacherId: teacherId,
      teacherName: teacherName,
      name: name ?? this.name,
      subjectId: subjectId,
      subjectName: subjectName,
      groupCode: groupCode,
      studentIds: studentIds ?? this.studentIds,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'name': name,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'groupCode': groupCode,
      'studentIds': studentIds,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      name: map['name'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      groupCode: (map['groupCode'] ?? '').toString().trim().toUpperCase(),
      studentIds: List<String>.from(map['studentIds'] ?? []),
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
