class Transfer {
  final String id;
  final String userId;
  final String originWalletId;
  final String destWalletId;
  final double amount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transfer({
    required this.id,
    required this.userId,
    required this.originWalletId,
    required this.destWalletId,
    required this.amount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      originWalletId: json['origin_wallet_id']?.toString() ?? '',
      destWalletId: json['dest_wallet_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'origin_wallet_id': originWalletId,
      'dest_wallet_id': destWalletId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
