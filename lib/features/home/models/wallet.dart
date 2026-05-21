import 'package:flutter/material.dart';

class Wallet {
  final String name;
  final IconData icon;
  final String totalAmount;
  final int movementsCount;

  const Wallet({
    required this.name,
    required this.icon,
    required this.totalAmount,
    required this.movementsCount,
  });
}
