import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/app/routes/app_router.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';
import 'package:alza/features/home/providers/home_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MaterialApp.router(
        title: 'Alza+',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
