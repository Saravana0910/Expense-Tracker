import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/transaction.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends ConsumerState<TransactionsListScreen> {
  String _selectedCategory = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Filter chips
          if (_selectedCategory != 'All' || _startDate != null || _endDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedCategory != 'All')
                    Chip(
                      label: Text(_selectedCategory),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = 'All';
                        });
                      },
                    ),
                  if (_startDate != null)
                    Chip(
                      label: Text('From ${DateFormat.yMMMd().format(_startDate!)}'),
                      onDeleted: () {
                        setState(() {
                          _startDate = null;
                        });
                      },
                    ),
                  if (_endDate != null)
                    Chip(
                      label: Text('To ${DateFormat.yMMMd().format(_endDate!)}'),
                      onDeleted: () {
                        setState(() {
                          _endDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Transactions list
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (transactions) => _buildTransactionsList(_filterTransactions(transactions)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final uri = GoRouter.of(context).routeInformationProvider.value.uri;
    final location = uri.path;
    int currentIndex = 1;
    
    if (location.startsWith('/analytics')) {
      currentIndex = 2;
    } else if (location.startsWith('/budget')) {
      currentIndex = 3;
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

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    return transactions.where((transaction) {
      // Category filter
      if (_selectedCategory != 'All' && transaction.category != _selectedCategory) {
        return false;
      }

      // Date filter
      if (_startDate != null && transaction.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && transaction.date.isAfter(_endDate!)) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return transaction.category.toLowerCase().contains(query) ||
               (transaction.notes?.toLowerCase().contains(query) ?? false) ||
               transaction.paymentMethod.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  Widget _buildTransactionsList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions found'));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Dismissible(
          key: Key(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Transaction'),
                content: const Text('Are you sure you want to delete this transaction?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction deleted')),
            );
          },
          child: _buildTransactionItem(transaction),
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat.yMMMd().format(transaction.date)),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(
                transaction.notes!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              transaction.paymentMethod,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['All', ...AppConstants.categories].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: Text(_startDate != null
                          ? DateFormat.yMMMd().format(_startDate!)
                          : 'Start Date'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: Text(_endDate != null
                          ? DateFormat.yMMMd().format(_endDate!)
                          : 'End Date'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _startDate = null;
                  _endDate = null;
                });
                Navigator.of(context).pop();
                this.setState(() {});
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                this.setState(() {});
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}