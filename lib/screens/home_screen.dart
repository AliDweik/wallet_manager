import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_manager/providers/app_state.dart';
import 'package:wallet_manager/screens/add_transaction_screen.dart';
import 'package:wallet_manager/screens/settings_screen.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';
import 'package:wallet_manager/utlils/formatters.dart';
import 'package:wallet_manager/widgets/archive_dialog.dart';
import 'package:wallet_manager/widgets/daily_limit_meter.dart';
import 'package:wallet_manager/widgets/hero_balance_card.dart';
import 'package:wallet_manager/widgets/sub_account_card.dart';
import 'package:wallet_manager/widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isBalanceVisible = true;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (appState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.expenseCoral),
              const SizedBox(height: 16),
              Text(
                appState.error!,
                style: AppTypography.bodyText(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => appState.initialize(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wallet Manager'),
            Text(
              Formatters.formatMonthYear(DateTime.now()),
              style: AppTypography.caption(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {
              // TODO: Navigate to month selector
            },
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryNavy,
            child: Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.initialize(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroBalanceCard(
                totalBalance: appState.totalMoney,
                isVisible: _isBalanceVisible,
                onToggleVisibility: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  SubAccountCard(
                    title: 'Cash in Wallet',
                    amount: appState.cashBalance,
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.incomeGreen,
                    iconBackground: AppColors.incomeSoftTint,
                  ),
                  const SizedBox(width: 12),
                  SubAccountCard(
                    title: 'Visa Card',
                    amount: appState.visaBalance,
                    icon: Icons.credit_card,
                    iconColor: AppColors.brandBlue,
                    iconBackground: AppColors.incomeSoftBg,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DailyLimitMeter(
                dailyLimit: appState.dailyLimit,
                todaySpent: appState.todaySpent,
                remainingToday: appState.remainingToday,
                progress: appState.dailyLimitProgress,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: AppTypography.sectionHeader(),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all transactions
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (appState.transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: AppColors.textMuted.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No transactions yet',
                        style: AppTypography.cardTitle(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the + button to add your first transaction',
                        style: AppTypography.caption(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...appState.getRecentTransactions(limit: 5).map((transaction) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TransactionTile(transaction: transaction),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryNavy,
        onPressed: () {
          _navigateToAddTransaction();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: _handleNavigation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            activeIcon: Icon(Icons.archive),
            label: 'Archive',
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        setState(() {
          _currentTab = 0;
        });
        break;

      case 1:
        _navigateToAddTransaction();
        break;

      case 2:
        _navigateToSettings();
        break;

      case 3:
        _showArchiveDialog();
        break;
    }
  }

  void _navigateToAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );

    if (mounted) {
      setState(() {
        _currentTab = 0;
      });
    }
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );

    if (mounted) {
      setState(() {
        _currentTab = 0;
      });
    }
  }

  Future<void> _showArchiveDialog() async {
    final confirmed = await showArchiveDialog(context);

    if (confirmed == true) {
      final appState = context.read<AppState>();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await appState.archiveCurrentMonth();

      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'New month started successfully!',
              style: AppTypography.bodyText().copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.incomeGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (mounted) {
        setState(() {
          _currentTab = 0;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _currentTab = 0;
        });
      }
    }
  }
}
