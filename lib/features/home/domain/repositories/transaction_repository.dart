import 'package:budget_beacon/features/home/domain/models/budget_transaction.dart';

abstract class TransactionRepository {
  Future<List<BudgetTransaction>> getTransactions();
  Future<void> addTransaction(BudgetTransaction transaction);
  Future<void> updateTransaction(BudgetTransaction transaction);
  Future<void> deleteTransaction(String transactionId);
}
