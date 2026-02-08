import 'package:budget_beacon/app.dart';
import 'package:budget_beacon/features/home/domain/models/budget_transaction.dart';
import 'package:budget_beacon/features/home/domain/repositories/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows dashboard with empty local transaction state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BudgetBeaconApp(repository: InMemoryTransactionRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('BudgetBeacon'), findsOneWidget);
    expect(find.text('Monthly Snapshot'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(find.textContaining('No transactions yet'), findsOneWidget);
    expect(find.text('Add Transaction'), findsOneWidget);
  });
}

class InMemoryTransactionRepository implements TransactionRepository {
  final List<BudgetTransaction> _items = [];

  @override
  Future<void> addTransaction(BudgetTransaction transaction) async {
    _items.removeWhere((item) => item.id == transaction.id);
    _items.add(transaction);
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    _items.removeWhere((item) => item.id == transactionId);
  }

  @override
  Future<List<BudgetTransaction>> getTransactions() async {
    final copy = List<BudgetTransaction>.from(_items);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  @override
  Future<void> updateTransaction(BudgetTransaction transaction) async {
    final index = _items.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      _items.add(transaction);
    } else {
      _items[index] = transaction;
    }
  }
}
