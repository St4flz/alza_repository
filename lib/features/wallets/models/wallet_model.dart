import 'package:flutter/material.dart';

class Wallet {
  final String id;
  String name;
  double balance;
  IconData icon;
  Color color;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
  });

  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    IconData? icon,
    Color? color,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      icon: parseIcon(json['icon']?.toString()),
      color: parseColor(json['color']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'icon': iconToString(icon),
      'color': colorToHex(color),
    };
  }

  // Mapeo manual y estático de íconos compatibles con WalletEditSheet
  static const Map<String, IconData> _iconMap = {
    'badge_outlined': Icons.badge_outlined,
    'savings_outlined': Icons.savings_outlined,
    'menu_book_rounded': Icons.menu_book_rounded,
    'account_balance_wallet_outlined': Icons.account_balance_wallet_outlined,
    'credit_card_rounded': Icons.credit_card_rounded,
    'account_balance_rounded': Icons.account_balance_rounded,
    'attach_money_rounded': Icons.attach_money_rounded,
    'storefront_rounded': Icons.storefront_rounded,
  };

  static IconData parseIcon(String? iconStr) {
    if (iconStr == null) return Icons.account_balance_wallet_outlined;
    return _iconMap[iconStr] ?? Icons.account_balance_wallet_outlined;
  }

  static String iconToString(IconData icon) {
    for (var entry in _iconMap.entries) {
      if (entry.value.codePoint == icon.codePoint) {
        return entry.key;
      }
    }
    return 'account_balance_wallet_outlined';
  }

  static Color parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return const Color(0xFF00D764);
    try {
      final cleanHex = colorStr.replaceAll('#', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return const Color(0xFF00D764);
    }
  }

  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
