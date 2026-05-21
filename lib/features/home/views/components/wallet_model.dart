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
}
