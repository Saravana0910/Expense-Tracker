import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _budgetController = TextEditingController();
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(budgetProvider);
    final monthlySpentAsync = ref.watch(monthlySpentProvider(_selectedMonth));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Month',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: _selectMonth,
                      child: Text(
                        DateFormat.yMMMM().format(_selectedMonth),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current budget
            budgetAsync.when(
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading budget: $error'),
                ),
              ),
              data: (budget) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Monthly Budget',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (budget != null)
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showSetBudgetDialog(budget.amount),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (budget == null)
                        Column(
                          children: [
                            const Text('No budget set for this month'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _showSetBudgetDialog,
                              child: const Text('Set Budget'),
                            ),
                          ],
                        )
                      else
                        monthlySpentAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                          data: (spent) => _buildBudgetProgress(context, budget.amount, spent),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Budget history
            Text(
              'Budget History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // TODO: Add budget history list
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Budget history will be displayed here'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final uri = GoRouter.of(context).routeInformationProvider.value.uri;
    final location = uri.path;
    int currentIndex = 3;
    
    if (location.startsWith('/transactions')) {
      currentIndex = 1;
    } else if (location.startsWith('/analytics')) {
      currentIndex = 2;
    } else if (location == '/') {
      currentIndex = 0;
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

  Widget _buildBudgetProgress(BuildContext context, double budget, double spent) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final remaining = budget - spent;
    final progress = (spent / budget).clamp(0.0, 1.0);
    final isOverBudget = spent > budget;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: ${currencyFormat.format(spent)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Budget: ${currencyFormat.format(budget)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            isOverBudget ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              remaining >= 0
                  ? 'Remaining: ${currencyFormat.format(remaining)}'
                  : 'Over budget: ${currencyFormat.format(remaining.abs())}',
              style: TextStyle(
                color: remaining >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (isOverBudget)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You have exceeded your budget!',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
      // Load budget for the newly selected month.
      ref.read(budgetProvider.notifier).loadForMonth(_selectedMonth);
    }
  }

  void _showSetBudgetDialog([double? currentAmount]) {
    if (currentAmount != null) {
      _budgetController.text = currentAmount.toString();
    } else {
      _budgetController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentAmount != null ? 'Update Budget' : 'Set Budget'),
        content: TextFormField(
          controller: _budgetController,
          decoration: const InputDecoration(
            labelText: 'Monthly Budget',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(_budgetController.text);
              if (amount != null && amount > 0) {
                try {
                  await ref.read(budgetProvider.notifier).setMonthlyBudget(amount, _selectedMonth);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budget updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}