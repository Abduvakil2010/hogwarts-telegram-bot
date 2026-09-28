enum PointTransactionType {
  testReward, // TEST_REWARD
  teacherAdd, // TEACHER_ADD
  teacherRemove, // TEACHER_REMOVE
  purchase; // PURCHASE

  static PointTransactionType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'TEST_REWARD':
        return PointTransactionType.testReward;
      case 'TEACHER_ADD':
        return PointTransactionType.teacherAdd;
      case 'TEACHER_REMOVE':
        return PointTransactionType.teacherRemove;
      case 'PURCHASE':
        return PointTransactionType.purchase;
      default:
        return PointTransactionType.testReward;
    }
  }

  String toDbString() {
    switch (this) {
      case PointTransactionType.testReward:
        return 'TEST_REWARD';
      case PointTransactionType.teacherAdd:
        return 'TEACHER_ADD';
      case PointTransactionType.teacherRemove:
        return 'TEACHER_REMOVE';
      case PointTransactionType.purchase:
        return 'PURCHASE';
    }
  }
}

class PointTransactionModel {
  final String transactionId;
  final String studentId;
  final String teacherId;
  final int amount; // Positive or negative
  final PointTransactionType type;
  final String reason;
  final DateTime createdAt;

  PointTransactionModel({
    required this.transactionId,
    required this.studentId,
    required this.teacherId,
    required this.amount,
    required this.type,
    this.reason = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'studentId': studentId,
      'teacherId': teacherId,
      'amount': amount,
      'type': type.toDbString(),
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PointTransactionModel.fromMap(Map<String, dynamic> map) {
    return PointTransactionModel(
      transactionId: map['transactionId'] ?? '',
      studentId: map['studentId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      type: PointTransactionType.fromString(map['type'] ?? 'TEST_REWARD'),
      reason: map['reason'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
