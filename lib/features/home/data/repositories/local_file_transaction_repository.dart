import 'dart:convert';
import 'dart:io';

import 'package:budget_beacon/features/home/domain/models/budget_transaction.dart';
import 'package:budget_beacon/features/home/domain/repositories/transaction_repository.dart';

class LocalFileTransactionRepository implements TransactionRepository {
  LocalFileTransactionRepository({Future<File> Function()? storageFileFactory})
    : _storageFileFactory = storageFileFactory ?? _defaultStorageFile;

  static const _directoryName = 'BudgetBeacon';
  static const _fileName = 'transactions.json';

  final Future<File> Function() _storageFileFactory;

  @override
  Future<List<BudgetTransaction>> getTransactions() async {
    final file = await _storageFileFactory();
    if (!await file.exists()) {
      return [];
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final transactions = decoded
          .map(
            (item) => BudgetTransaction.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addTransaction(BudgetTransaction transaction) async {
    final transactions = await getTransactions();
    transactions.removeWhere((item) => item.id == transaction.id);
    transactions.add(transaction);
    await _saveTransactions(transactions);
  }

  @override
  Future<void> updateTransaction(BudgetTransaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      transactions.add(transaction);
    } else {
      transactions[index] = transaction;
    }
    await _saveTransactions(transactions);
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final transactions = await getTransactions();
    transactions.removeWhere((item) => item.id == transactionId);
    await _saveTransactions(transactions);
  }

  Future<void> _saveTransactions(List<BudgetTransaction> transactions) async {
    final file = await _storageFileFactory();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    final payload = jsonEncode(
      transactions.map((item) => item.toJson()).toList(),
    );
    await file.writeAsString(payload, flush: true);
  }

  static Future<File> _defaultStorageFile() async {
    final basePath =
        Platform.environment['LOCALAPPDATA'] ??
        Platform.environment['APPDATA'] ??
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.current.path;

    final directory = Directory(
      '$basePath${Platform.pathSeparator}$_directoryName',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return File('${directory.path}${Platform.pathSeparator}$_fileName');
  }
}
