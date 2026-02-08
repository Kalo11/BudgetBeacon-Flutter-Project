import 'package:budget_beacon/features/home/domain/models/budget_transaction.dart';
import 'package:budget_beacon/features/home/domain/repositories/transaction_repository.dart';
import 'package:budget_beacon/features/home/presentation/controllers/home_controller.dart';
import 'package:budget_beacon/features/home/presentation/widgets/metric_card.dart';
import 'package:budget_beacon/features/home/presentation/widgets/transaction_form_sheet.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final TransactionRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(repository: widget.repository);
    _controller.loadTransactions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openTransactionForm({BudgetTransaction? transaction}) async {
    final updatedTransaction = await TransactionFormSheet.show(
      context,
      initialTransaction: transaction,
    );
    if (updatedTransaction == null) {
      return;
    }

    if (transaction == null) {
      await _controller.addTransaction(updatedTransaction);
      _showSnackBar('Transaction added.');
    } else {
      await _controller.updateTransaction(updatedTransaction);
      _showSnackBar('Transaction updated.');
    }
  }

  Future<void> _deleteTransaction(BudgetTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: Text('Remove "${transaction.title}" from local history?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _controller.deleteTransaction(transaction.id);
    _showSnackBar('Transaction deleted.');
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('BudgetBeacon')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _controller.loadTransactions,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Monthly Snapshot',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Income',
                        amount: _formatCurrency(_controller.monthlyIncome),
                        icon: Icons.arrow_downward_rounded,
                        accentColor: const Color(0xFF2B8A3E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        label: 'Spending',
                        amount: _formatCurrency(_controller.monthlySpending),
                        icon: Icons.arrow_upward_rounded,
                        accentColor: const Color(0xFFC92A2A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: colors.primary,
                    ),
                    title: const Text('Net Cash Flow'),
                    subtitle: const Text('Income minus spending this month'),
                    trailing: Text(
                      _formatSignedCurrency(_controller.monthlyBalance),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _controller.monthlyBalance >= 0
                            ? const Color(0xFF2B8A3E)
                            : const Color(0xFFC92A2A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: () => _openTransactionForm(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                if (_controller.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: colors.errorContainer,
                    child: ListTile(
                      title: Text(
                        _controller.errorMessage!,
                        style: TextStyle(color: colors.onErrorContainer),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (_controller.transactions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'No transactions yet. Tap "Add" to create your first one.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                else
                  ..._controller.transactions.map(_buildTransactionTile),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openTransactionForm(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Transaction'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(BudgetTransaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final accentColor = isIncome
        ? const Color(0xFF2B8A3E)
        : const Color(0xFFC92A2A);
    final icon = isIncome ? Icons.south_east_rounded : Icons.north_east_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => _openTransactionForm(transaction: transaction),
        leading: CircleAvatar(
          backgroundColor: accentColor.withValues(alpha: 0.14),
          foregroundColor: accentColor,
          child: Icon(icon),
        ),
        title: Row(
          children: [
            Expanded(child: Text(transaction.title)),
            Text(
              _formatSignedCurrency(
                isIncome ? transaction.amount : -transaction.amount,
              ),
              style: TextStyle(color: accentColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        subtitle: Text(
          '${transaction.category} - ${_formatDate(transaction.date)}',
        ),
        trailing: IconButton(
          onPressed: () => _deleteTransaction(transaction),
          tooltip: 'Delete transaction',
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final absolute = value.abs();
    final fixed = absolute.toStringAsFixed(2);
    final parts = fixed.split('.');
    final wholeWithGrouping = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final formatted = '\$$wholeWithGrouping.${parts[1]}';
    return isNegative ? '-$formatted' : formatted;
  }

  String _formatSignedCurrency(double value) {
    final prefix = value >= 0 ? '+' : '-';
    return '$prefix${_formatCurrency(value.abs())}';
  }
}
