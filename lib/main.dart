import 'package:flutter/material.dart';
import 'package:alza/theme/app_colors.dart';
import 'package:alza/views/dashboard_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alza+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.blanco.solid,
        primaryColor: AppColors.verde.solid,
      ),
      home: const DashboardView(),
    );
  }
}
