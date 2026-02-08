import 'package:budget_beacon/features/home/presentation/widgets/metric_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('BudgetBeacon')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      amount: '\$4,800',
                      icon: Icons.arrow_downward_rounded,
                      accentColor: const Color(0xFF2B8A3E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: 'Spending',
                      amount: '\$2,960',
                      icon: Icons.arrow_upward_rounded,
                      accentColor: const Color(0xFFC92A2A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Upcoming Bills',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.bolt_rounded),
                      title: Text('Electricity'),
                      subtitle: Text('Due in 3 days'),
                      trailing: Text('\$98'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.wifi_rounded),
                      title: Text('Internet'),
                      subtitle: Text('Due in 6 days'),
                      trailing: Text('\$65'),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.home_rounded),
                      title: Text('Rent'),
                      subtitle: Text('Due in 8 days'),
                      trailing: Text('\$1,450'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
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
        ),
      ),
    );
  }
}
