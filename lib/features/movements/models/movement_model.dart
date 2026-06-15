import 'package:alza/features/movements/models/tag_model.dart';

class Movement {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final String type; // "expense" | "income"
  final String walletId;
  final String walletName;
  final String categoryId;
  final String categoryName;
  final List<Tag> tags;
  final DateTime createdAt;

  Movement({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.type,
    required this.walletId,
    required this.walletName,
    required this.categoryId,
    required this.categoryName,
    required this.tags,
    required this.createdAt,
  });

  factory Movement.fromJson(Map<String, dynamic> json) {
    var tagsList = <Tag>[];
    if (json['tags'] != null) {
      tagsList = (json['tags'] as List)
          .map((item) => Tag.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Movement(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? 'expense',
      walletId: json['wallet_id']?.toString() ?? '',
      walletName: json['wallet_name']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      tags: tagsList,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'type': type,
      'wallet_id': walletId,
      'wallet_name': walletName,
      'category_id': categoryId,
      'category_name': categoryName,
      'tags': tags.map((t) => t.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
