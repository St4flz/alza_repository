class Category {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
