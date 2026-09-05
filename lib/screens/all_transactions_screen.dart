import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_manager/models/transaction.dart';
import 'package:wallet_manager/providers/app_state.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';
import 'package:wallet_manager/widgets/transaction_tile.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  String _searchQuery = '';
  String _filterType = 'all'; // all, expense, income
  String _filterAccount = 'all'; // all, cash, visa

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allTransactions = appState.transactions;

    // Apply filters
    final filteredTransactions = allTransactions.where((transaction) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final noteMatch = transaction.note?.toLowerCase().contains(searchLower) ?? false;
        final typeMatch = transaction.typeLabel.toLowerCase().contains(searchLower);
        final accountMatch = transaction.accountLabel.toLowerCase().contains(searchLower);

        if (!noteMatch && !typeMatch && !accountMatch) {
          return false;
        }
      }

      // Type filter
      if (_filterType == 'expense' && !transaction.isExpense) {
        return false;
      }
      if (_filterType == 'income' && !transaction.isIncome) {
        return false;
      }

      // Account filter
      if (_filterAccount == 'cash' && transaction.account.name != 'cash') {
        return false;
      }
      if (_filterAccount == 'visa' && transaction.account.name != 'visa') {
        return false;
      }

      return true;
    }).toList();

    // Sort by date (newest first)
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
              ),
            ),
          ),

          // Filter chips
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('all', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('expense', 'Expenses'),
                const SizedBox(width: 8),
                _buildFilterChip('income', 'Income'),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: AppColors.divider),
                const SizedBox(width: 8),
                _buildFilterChip('cash', 'Cash'),
                const SizedBox(width: 8),
                _buildFilterChip('visa', 'Visa'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transaction count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredTransactions.length} transactions',
                  style: AppTypography.caption(),
                ),
                if (filteredTransactions.isNotEmpty)
                  Text(
                    'Total: ${_calculateTotal(filteredTransactions)}',
                    style: AppTypography.caption().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Transactions list
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppColors.textMuted.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: AppTypography.cardTitle(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: AppTypography.caption(),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TransactionTile(transaction: transaction),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    bool isSelected;

    // Determine if this chip is selected
    if (value == 'all' || value == 'expense' || value == 'income') {
      // Type filters
      isSelected = _filterType == value;
    } else if (value == 'cash') {
      // Cash account filter
      isSelected = _filterAccount == 'cash';
    } else if (value == 'visa') {
      // Visa account filter
      isSelected = _filterAccount == 'visa';
    } else {
      isSelected = false;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (value == 'all') {
            _filterType = 'all';
          } else if (value == 'expense') {
            _filterType = 'expense';
          } else if (value == 'income') {
            _filterType = 'income';
          } else if (value == 'cash') {
            // Toggle cash filter
            _filterAccount = _filterAccount == 'cash' ? 'all' : 'cash';
          } else if (value == 'visa') {
            // Toggle visa filter
            _filterAccount = _filterAccount == 'visa' ? 'all' : 'visa';
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryNavy : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption().copyWith(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _calculateTotal(List transactions) {
    double total = 0;
    for (final transaction in transactions) {
      if (transaction.isExpense) {
        total -= transaction.amount;
      } else {
        total += transaction.amount;
      }
    }
    return '\$${total.toStringAsFixed(2)}';
  }
}