class TelegramIdModel {
  final String id;
  final String code; // 6-digit numeric string
  final String status; // 'active' or 'used'
  final DateTime createdAt;
  final DateTime? usedAt;
  final String? usedByUserId;

  TelegramIdModel({
    required this.id,
    required this.code,
    this.status = 'active',
    required this.createdAt,
    this.usedAt,
    this.usedByUserId,
  });

  bool get isUsed => status.toLowerCase() == 'used';
  bool get isActive => status.toLowerCase() == 'active';

  TelegramIdModel markUsed(String userId) {
    return TelegramIdModel(
      id: id,
      code: code,
      status: 'used',
      createdAt: createdAt,
      usedAt: DateTime.now(),
      usedByUserId: userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'usedByUserId': usedByUserId,
    };
  }

  factory TelegramIdModel.fromMap(Map<String, dynamic> map) {
    return TelegramIdModel(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      usedAt: map['usedAt'] != null ? DateTime.tryParse(map['usedAt']) : null,
      usedByUserId: map['usedByUserId'],
    );
  }
}
