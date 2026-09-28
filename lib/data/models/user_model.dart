enum UserRole {
  student,
  teacher,
  superAdmin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
      case 'o‘qituvchi':
        return UserRole.teacher;
      case 'admin':
      case 'super_admin':
        return UserRole.superAdmin;
      case 'student':
      case 'o‘quvchi':
      default:
        return UserRole.student;
    }
  }

  String toDbString() {
    switch (this) {
      case UserRole.teacher:
        return 'teacher';
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.student:
        return 'student';
    }
  }
}

class UserModel {
  final String id;
  final UserRole role;
  final String fullName;
  final String telegramId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String language;
  final String theme;

  UserModel({
    required this.id,
    required this.role,
    required this.fullName,
    required this.telegramId,
    required this.createdAt,
    required this.updatedAt,
    this.language = 'uz',
    this.theme = 'light',
  });

  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;
  bool get isAdmin => role == UserRole.superAdmin;

  UserModel copyWith({
    String? fullName,
    String? language,
    String? theme,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      role: role,
      fullName: fullName ?? this.fullName,
      telegramId: telegramId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role.toDbString(),
      'fullName': fullName,
      'telegramId': telegramId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'language': language,
      'theme': theme,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'student'),
      fullName: map['fullName'] ?? '',
      telegramId: map['telegramId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      language: map['language'] ?? 'uz',
      theme: map['theme'] ?? 'light',
    );
  }
}
