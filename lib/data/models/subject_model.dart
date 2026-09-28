class SubjectModel {
  final String subjectId;
  final String name;
  final String createdBy;
  final bool isDefault;
  final DateTime createdAt;

  SubjectModel({
    required this.subjectId,
    required this.name,
    required this.createdBy,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectId': subjectId,
      'name': name,
      'createdBy': createdBy,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      subjectId: map['subjectId'] ?? '',
      name: map['name'] ?? '',
      createdBy: map['createdBy'] ?? 'system',
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static List<SubjectModel> get defaultSubjects => [
        SubjectModel(
          subjectId: 'sub_math',
          name: 'Matematika',
          createdBy: 'system',
          isDefault: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        SubjectModel(
          subjectId: 'sub_eng',
          name: 'Ingliz tili',
          createdBy: 'system',
          isDefault: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        SubjectModel(
          subjectId: 'sub_phys',
          name: 'Fizika',
          createdBy: 'system',
          isDefault: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        SubjectModel(
          subjectId: 'sub_chem',
          name: 'Kimyo',
          createdBy: 'system',
          isDefault: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        SubjectModel(
          subjectId: 'sub_hist',
          name: 'Tarix',
          createdBy: 'system',
          isDefault: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        SubjectModel(
          subjectId: 'sub_native',
          name: 'Ona tili',
          createdBy: 'system',
          isDefault: true,
          createdAt: DateTime(2026, 1, 1),
        ),
        SubjectModel(
          subjectId: 'sub_bio',
          name: 'Biologiya',
          createdBy: 'system',
          isDefault: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];
}
