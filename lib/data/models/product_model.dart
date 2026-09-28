class ProductModel {
  final String productId;
  final String teacherId;
  final String teacherName;
  final List<String> groupIds; // If empty or contains 'all', visible to all groups of this teacher
  final String name;
  final String imageUrl;
  final int price; // In ⭐ points
  final bool active;
  final DateTime createdAt;

  ProductModel({
    required this.productId,
    required this.teacherId,
    required this.teacherName,
    this.groupIds = const [],
    required this.name,
    this.imageUrl = '',
    required this.price,
    this.active = true,
    required this.createdAt,
  });

  bool isVisibleToGroup(String groupId) {
    if (groupIds.isEmpty || groupIds.contains('all')) return true;
    return groupIds.contains(groupId);
  }

  ProductModel copyWith({
    bool? active,
    String? name,
    int? price,
    String? imageUrl,
    List<String>? groupIds,
  }) {
    return ProductModel(
      productId: productId,
      teacherId: teacherId,
      teacherName: teacherName,
      groupIds: groupIds ?? this.groupIds,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      active: active ?? this.active,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'groupIds': groupIds,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      groupIds: List<String>.from(map['groupIds'] ?? []),
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      active: map['active'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
