import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet_manager/models/app_data.dart';
import 'package:wallet_manager/services/storage_service.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';
import 'package:wallet_manager/widgets/transaction_tile.dart';
import 'package:share_plus/share_plus.dart';



class ArchiveDetailsScreen extends StatefulWidget {
  final String fileName;
  final String monthYear;

  const ArchiveDetailsScreen({
    super.key,
    required this.fileName,
    required this.monthYear,
  });

  @override
  State<ArchiveDetailsScreen> createState() => _ArchiveDetailsScreenState();
}

class _ArchiveDetailsScreenState extends State<ArchiveDetailsScreen> {
  final StorageService _storageService = StorageService();
  AppData? _archiveData;
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0; // 0 = Summary, 1 = Transactions, 2 = Settings

  @override
  void initState() {
    super.initState();
    _loadArchiveData();
  }

  Future<void> _loadArchiveData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _storageService.loadArchiveData(widget.fileName);
      setState(() {
        _archiveData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load archive: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _shareArchive() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.fileName}');

      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Wallet Tracker Archive - ${widget.monthYear}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing archive: $e'),
          backgroundColor: AppColors.expenseCoral,
        ),
      );
    }
  }

  Future<void> _deleteArchive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Archive',
          style: AppTypography.sectionHeader(),
        ),
        content: Text(
          'Are you sure you want to delete the archive for ${widget.monthYear}? This cannot be undone.',
          style: AppTypography.bodyText(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseCoral,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteArchiveFile(widget.fileName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Archive deleted',
                style: AppTypography.bodyText().copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.expenseCoral,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting archive: $e'),
            backgroundColor: AppColors.expenseCoral,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: Text(widget.monthYear),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareArchive,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.expenseCoral),
            onPressed: _deleteArchive,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.expenseCoral,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.bodyText(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadArchiveData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _archiveData == null
          ? const Center(child: Text('No data available'))
          : Column(
        children: [
          // Tab selector
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Summary'),
                _buildTabButton(1, 'Transactions'),
                _buildTabButton(2, 'Settings'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildSummaryTab(),
                _buildTransactionsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.cardTitle().copyWith(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    final data = _archiveData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Closing Balance',
                      style: AppTypography.bodyText().copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sealed',
                            style: AppTypography.caption().copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${data.totalBalance.toStringAsFixed(2)}',
                  style: AppTypography.heroNumber(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildBalanceChip(
                      label: 'Cash',
                      amount: data.cashBalance,
                      icon: Icons.account_balance_wallet,
                    ),
                    const SizedBox(width: 8),
                    _buildBalanceChip(
                      label: 'Visa',
                      amount: data.visaBalance,
                      icon: Icons.credit_card,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick stats grid
          Row(
            children: [
              _buildStatCard(
                icon: Icons.savings_outlined,
                label: 'Savings',
                value: '\$${data.savings.toStringAsFixed(2)}',
                color: AppColors.incomeGreen,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.receipt_long_outlined,
                label: 'Billings',
                value: '\$${data.totalMonthlyBillings.toStringAsFixed(2)}',
                color: AppColors.brandBlue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.payments_outlined,
                label: 'Salary',
                value: '\$${data.salaryAmount.toStringAsFixed(2)}',
                color: AppColors.incomeGreen,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.calculate_outlined,
                label: 'Daily Limit',
                value: '\$${_calculateDailyLimit(data).toStringAsFixed(2)}',
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transaction summary
          Text(
            'Month Summary',
            style: AppTypography.sectionHeader(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  label: 'Total Transactions',
                  value: '${data.transactions.length}',
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  label: 'Total Spent',
                  value: '\$${_calculateTotalSpent(data).toStringAsFixed(2)}',
                  valueColor: AppColors.expenseCoral,
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  label: 'Total Income',
                  value: '\$${_calculateTotalIncome(data).toStringAsFixed(2)}',
                  valueColor: AppColors.incomeGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    final data = _archiveData!;
    final sortedTransactions = List.from(data.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions',
              style: AppTypography.cardTitle(),
            ),
            const SizedBox(height: 8),
            Text(
              'This month had no transactions',
              style: AppTypography.caption(),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = sortedTransactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TransactionTile(transaction: transaction),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    final data = _archiveData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Salary settings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salary Configuration',
                  style: AppTypography.sectionHeader(),
                ),
                const SizedBox(height: 16),
                _buildSettingRow(
                  icon: Icons.payments_outlined,
                  label: 'Salary Amount',
                  value: '\$${data.salaryAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Salary Day',
                  value: 'Day ${data.salaryDay}',
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  icon: Icons.account_balance_outlined,
                  label: 'Deposit Account',
                  value: data.salaryAccount == 'cash' ? 'Cash' : 'Visa',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monthly billings
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Billings',
                  style: AppTypography.sectionHeader(),
                ),
                const SizedBox(height: 16),
                if (data.monthlyBillings.isEmpty)
                  Text(
                    'No monthly billings',
                    style: AppTypography.caption(),
                  )
                else
                  ...data.monthlyBillings.map((billing) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSettingRow(
                        icon: Icons.receipt_long_outlined,
                        label: billing.name,
                        value: '\$${billing.amount.toStringAsFixed(2)} (Day ${billing.dueDay})',
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Starting balances
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Starting Balances',
                  style: AppTypography.sectionHeader(),
                ),
                const SizedBox(height: 16),
                _buildSettingRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Cash Balance',
                  value: '\$${data.cashBalance.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  icon: Icons.credit_card_outlined,
                  label: 'Visa Balance',
                  value: '\$${data.visaBalance.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildBalanceChip({
    required String label,
    required double amount,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption().copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: AppTypography.cardTitle().copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.caption(),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.cardTitle().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyText(),
        ),
        Text(
          value,
          style: AppTypography.cardTitle().copyWith(
            color: valueColor ?? AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.incomeSoftBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.brandBlue, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyText(),
          ),
        ),
        Text(
          value,
          style: AppTypography.cardTitle().copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Helper calculations
  double _calculateDailyLimit(AppData data) {
    final totalMoney = data.totalBalance;
    final totalBillings = data.totalMonthlyBillings;
    final daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    return (totalMoney - data.savings - totalBillings) / daysInMonth;
  }

  double _calculateTotalSpent(AppData data) {
    return data.transactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalIncome(AppData data) {
    return data.transactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }
}