import 'package:flutter/material.dart';
import 'package:pockettracer/vo/balance.dart';
import 'package:pockettracer/vo/transaction.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final Balance _balance = Balance();
  String _selectedPeriod = 'Month';
  final List<String> _periods = ['Week', 'Month', 'Year'];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateDateRange('Month');
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case 'Week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = _startDate.add(const Duration(days: 6));
          break;
        case 'Month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'Year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31);
          break;
      }
    });
  }

  List<Transaction> _getFilteredTransactions() {
    return _balance.transactions.where((transaction) {
      return transaction.date
              .isAfter(_startDate.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'Week':
        return '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d').format(_endDate)}';
      case 'Month':
        return DateFormat('MMMM yyyy').format(_startDate);
      case 'Year':
        return DateFormat('yyyy').format(_startDate);
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListenableBuilder(
        listenable: _balance,
        builder: (context, child) {
          if (_balance.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTransactions = _getFilteredTransactions();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildPeriodSelector(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _getPeriodLabel(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    _buildNavigationButtons(),
                    _buildSummaryCards(filteredTransactions),
                    _buildExpenseChart(filteredTransactions),
                    _buildCategoryBreakdown(filteredTransactions),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              _buildRecentTransactions(filteredTransactions),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            setState(() {
              switch (_selectedPeriod) {
                case 'Week':
                  _startDate = _startDate.subtract(const Duration(days: 7));
                  _endDate = _endDate.subtract(const Duration(days: 7));
                  break;
                case 'Month':
                  _startDate =
                      DateTime(_startDate.year, _startDate.month - 1, 1);
                  _endDate = DateTime(_startDate.year, _startDate.month + 1, 0);
                  break;
                case 'Year':
                  _startDate = DateTime(_startDate.year - 1, 1, 1);
                  _endDate = DateTime(_startDate.year - 1, 12, 31);
                  break;
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            final now = DateTime.now();
            if (_endDate.isBefore(now)) {
              setState(() {
                switch (_selectedPeriod) {
                  case 'Week':
                    _startDate = _startDate.add(const Duration(days: 7));
                    _endDate = _endDate.add(const Duration(days: 7));
                    break;
                  case 'Month':
                    _startDate =
                        DateTime(_startDate.year, _startDate.month + 1, 1);
                    _endDate =
                        DateTime(_startDate.year, _startDate.month + 2, 0);
                    break;
                  case 'Year':
                    _startDate = DateTime(_startDate.year + 1, 1, 1);
                    _endDate = DateTime(_startDate.year + 1, 12, 31);
                    break;
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SegmentedButton<String>(
        segments: _periods.map((period) {
          return ButtonSegment<String>(
            value: period,
            label: Text(period),
          );
        }).toList(),
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          _updateDateRange(newSelection.first);
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        totalExpenses += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_upward, color: Colors.green),
                        Text(
                          'Income',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalIncome.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.red),
                        Text(
                          'Expenses',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalExpenses.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(List<Transaction> transactions) {
    Map<String, double> categoryExpenses = {};
    double totalExpenses = 0;

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        categoryExpenses[transaction.category] =
            (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
        totalExpenses += transaction.amount;
      }
    }

    final sections = categoryExpenses.entries.map((entry) {
      final percentage = (entry.value / totalExpenses * 100).toStringAsFixed(1);
      return PieChartSectionData(
        value: entry.value,
        title: '$percentage%',
        radius: 120, // Increased radius
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        showTitle: entry.value / totalExpenses > 0.05,
      );
    }).toList();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 24), // Increased vertical padding
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align items to the start
          children: [
            Text(
              'Expense Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24), // Increased spacing
            Container(
              height: 300, // Increased height
              padding:
                  const EdgeInsets.symmetric(vertical: 16), // Added padding
              child: sections.isEmpty
                  ? const Center(child: Text('No expenses in this period'))
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 60, // Increased center space
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            // Add touch interaction if needed
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24), // Increased spacing
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 12, // Increased spacing
                runSpacing: 12, // Increased run spacing
                children: categoryExpenses.entries.map((entry) {
                  final percentage =
                      (entry.value / totalExpenses * 100).toStringAsFixed(1);
                  return Chip(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8), // Added padding
                    label: Text(
                      '${entry.key}: $percentage%',
                      style: const TextStyle(
                          fontSize: 13), // Slightly increased font size
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<Transaction> transactions) {
    Map<String, double> categoryTotals = {};
    for (var transaction in transactions) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...categoryTotals.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              trailing: Text(
                '\$${entry.value.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (transactions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No transactions in this period')),
            );
          }

          final transaction = transactions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: transaction.isExpense
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                child: Icon(
                  transaction.isExpense
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: transaction.isExpense ? Colors.red : Colors.green,
                ),
              ),
              title: Text(
                transaction.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${transaction.category} • ${DateFormat('MMM d, y').format(transaction.date)}',
              ),
              trailing: Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: transaction.isExpense ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
        childCount: transactions.length,
      ),
    );
  }
}
