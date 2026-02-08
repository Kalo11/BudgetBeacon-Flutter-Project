import 'dart:collection';

import 'package:budget_beacon/features/home/domain/models/budget_transaction.dart';
import 'package:budget_beacon/features/home/domain/repositories/transaction_repository.dart';
import 'package:flutter/foundation.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required TransactionRepository repository,
    DateTime Function()? now,
  }) : _repository = repository,
       _now = now ?? DateTime.now;

  final TransactionRepository _repository;
  final DateTime Function() _now;

  bool _isLoading = false;
  String? _errorMessage;
  List<BudgetTransaction> _transactions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UnmodifiableListView<BudgetTransaction> get transactions =>
      UnmodifiableListView(_transactions);

  double get monthlyIncome => _monthlyTotalForType(TransactionType.income);
  double get monthlySpending => _monthlyTotalForType(TransactionType.expense);
  double get monthlyBalance => monthlyIncome - monthlySpending;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _repository.getTransactions();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      _errorMessage = 'Could not load transactions.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(BudgetTransaction transaction) async {
    await _mutate(
      operation: () => _repository.addTransaction(transaction),
      fallbackError: 'Could not add transaction.',
    );
  }

  Future<void> updateTransaction(BudgetTransaction transaction) async {
    await _mutate(
      operation: () => _repository.updateTransaction(transaction),
      fallbackError: 'Could not update transaction.',
    );
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _mutate(
      operation: () => _repository.deleteTransaction(transactionId),
      fallbackError: 'Could not delete transaction.',
    );
  }

  Future<void> _mutate({
    required Future<void> Function() operation,
    required String fallbackError,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await operation();
      _transactions = await _repository.getTransactions();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      _errorMessage = fallbackError;
    } finally {
      notifyListeners();
    }
  }

  double _monthlyTotalForType(TransactionType type) {
    final now = _now();
    return _transactions
        .where((transaction) {
          return transaction.type == type &&
              transaction.date.year == now.year &&
              transaction.date.month == now.month;
        })
        .fold(0, (total, item) => total + item.amount);
  }
}
