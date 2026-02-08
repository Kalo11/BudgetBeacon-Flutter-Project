import 'package:budget_beacon/core/theme/app_theme.dart';
import 'package:budget_beacon/features/home/data/repositories/local_file_transaction_repository.dart';
import 'package:budget_beacon/features/home/domain/repositories/transaction_repository.dart';
import 'package:budget_beacon/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

class BudgetBeaconApp extends StatelessWidget {
  const BudgetBeaconApp({super.key, TransactionRepository? repository})
    : _repository = repository;

  final TransactionRepository? _repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BudgetBeacon',
      theme: AppTheme.lightTheme,
      home: HomeScreen(
        repository: _repository ?? LocalFileTransactionRepository(),
      ),
    );
  }
}
