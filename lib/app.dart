import 'package:budget_beacon/core/theme/app_theme.dart';
import 'package:budget_beacon/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

class BudgetBeaconApp extends StatelessWidget {
  const BudgetBeaconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BudgetBeacon',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
