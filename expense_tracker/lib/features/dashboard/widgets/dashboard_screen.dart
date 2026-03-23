import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/providers/providers.dart';
import 'package:expense_tracker/core/models/transaction.dart';
import 'package:expense_tracker/core/models/budget.dart';
import 'package:expense_tracker/core/models/user.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final totalSpentAsync = ref.watch(totalSpentProvider);
    final categorySpendingAsync = ref.watch(categorySpendingProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (transactions) => _buildDashboard(
          context,
          ref,
          transactions,
          totalSpentAsync.value ?? 0,
          categorySpendingAsync.value ?? {},
          budgetAsync.value,
          userAsync.value,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-transaction'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
    double totalSpent,
    Map<String, double> categorySpending,
    Budget? budget,
    User? user,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final recentTransactions = transactions.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text(
            'Hello, ${user?.name ?? 'User'}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Balance Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Spent',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(totalSpent),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (budget != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Budget: ${currencyFormat.format(budget.amount)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    LinearProgressIndicator(
                      value: (totalSpent / budget.amount).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        totalSpent > budget.amount
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Category Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending by Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: categorySpending.isEmpty
                        ? const Center(child: Text('No data yet'))
                        : PieChart(
                            PieChartData(
                              sections: _buildPieSections(categorySpending),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...recentTransactions.map((transaction) => _buildTransactionItem(context, transaction)),
          if (recentTransactions.isEmpty)
            const Center(child: Text('No transactions yet')),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> categorySpending) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    final total = categorySpending.values.fold(0.0, (sum, value) => sum + value);

    return categorySpending.entries.map((entry) {
      final index = AppConstants.categories.indexOf(entry.key);
      final color = colors[index % colors.length];

      return PieChartSectionData(
        value: entry.value,
        title: '${(entry.value / total * 100).toStringAsFixed(1)}%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            transaction.category[0].toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(transaction.category),
        subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final location = GoRouter.of(context).routeInformationProvider.value.location;
    int currentIndex = 0;
    
    if (location.startsWith('/transactions')) {
      currentIndex = 1;
    } else if (location.startsWith('/analytics')) {
      currentIndex = 2;
    } else if (location.startsWith('/budget')) {
      currentIndex = 3;
    }
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/transactions');
            break;
          case 2:
            context.go('/analytics');
            break;
          case 3:
            context.go('/budget');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Budget',
        ),
      ],
    );
  }
}