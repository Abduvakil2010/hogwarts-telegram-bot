enum PurchaseStatus {
  pending, // "Berilmagan"
  given; // "Berildi"

  static PurchaseStatus fromString(String status) {
    if (status.toLowerCase() == 'given' || status.toLowerCase() == 'berildi') {
      return PurchaseStatus.given;
    }
    return PurchaseStatus.pending;
  }

  String toDbString() {
    switch (this) {
      case PurchaseStatus.given:
        return 'given';
      case PurchaseStatus.pending:
        return 'pending';
    }
  }
}

class PurchaseModel {
  final String purchaseId;
  final String studentId;
  final String studentName;
  final String teacherId;
  final String productId;
  final String productName;
  final String productImageUrl;
  final String groupId;
  final int price;
  final PurchaseStatus status;
  final DateTime purchasedAt;
  final DateTime? givenAt;

  PurchaseModel({
    required this.purchaseId,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.productId,
    required this.productName,
    this.productImageUrl = '',
    this.groupId = '',
    required this.price,
    this.status = PurchaseStatus.pending,
    required this.purchasedAt,
    this.givenAt,
  });

  bool get isGiven => status == PurchaseStatus.given;
  bool get isPending => status == PurchaseStatus.pending;

  PurchaseModel copyWith({
    PurchaseStatus? status,
    DateTime? givenAt,
  }) {
    return PurchaseModel(
      purchaseId: purchaseId,
      studentId: studentId,
      studentName: studentName,
      teacherId: teacherId,
      productId: productId,
      productName: productName,
      productImageUrl: productImageUrl,
      groupId: groupId,
      price: price,
      status: status ?? this.status,
      purchasedAt: purchasedAt,
      givenAt: givenAt ?? this.givenAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'purchaseId': purchaseId,
      'studentId': studentId,
      'studentName': studentName,
      'teacherId': teacherId,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'groupId': groupId,
      'price': price,
      'status': status.toDbString(),
      'purchasedAt': purchasedAt.toIso8601String(),
      'givenAt': givenAt?.toIso8601String(),
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      purchaseId: map['purchaseId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImageUrl: map['productImageUrl'] ?? '',
      groupId: map['groupId'] ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      status: PurchaseStatus.fromString(map['status'] ?? 'pending'),
      purchasedAt: map['purchasedAt'] != null
          ? DateTime.tryParse(map['purchasedAt']) ?? DateTime.now()
          : DateTime.now(),
      givenAt: map['givenAt'] != null ? DateTime.tryParse(map['givenAt']) : null,
    );
  }
}
