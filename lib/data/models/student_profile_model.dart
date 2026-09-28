class StudentProfileModel {
  final String userId;
  final List<String> groupIds;
  final int totalPoints;

  StudentProfileModel({
    required this.userId,
    this.groupIds = const [],
    this.totalPoints = 0,
  });

  StudentProfileModel copyWith({
    List<String>? groupIds,
    int? totalPoints,
  }) {
    return StudentProfileModel(
      userId: userId,
      groupIds: groupIds ?? this.groupIds,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'groupIds': groupIds,
      'totalPoints': totalPoints,
    };
  }

  factory StudentProfileModel.fromMap(Map<String, dynamic> map) {
    return StudentProfileModel(
      userId: map['userId'] ?? '',
      groupIds: List<String>.from(map['groupIds'] ?? []),
      totalPoints: (map['totalPoints'] as num?)?.toInt() ?? 0,
    );
  }
}
