import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_manager/providers/app_state.dart';
import 'package:wallet_manager/screens/add_transaction_screen.dart';
import 'package:wallet_manager/screens/all_transactions_screen.dart';
import 'package:wallet_manager/screens/settings_screen.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';
import 'package:wallet_manager/utlils/formatters.dart';
import 'package:wallet_manager/widgets/archive_dialog.dart';
import 'package:wallet_manager/widgets/daily_limit_meter.dart';
import 'package:wallet_manager/widgets/hero_balance_card.dart';
import 'package:wallet_manager/widgets/sub_account_card.dart';
import 'package:wallet_manager/widgets/transaction_tile.dart';
import 'package:wallet_manager/screens/archive_list_screen.dart';

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
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildHomeTab(),
          _buildAddTab(),
          _buildSettingsTab(),
          _buildArchiveTab(),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
        backgroundColor: AppColors.primaryNavy,
        onPressed: () {
          _navigateToAddTransaction();
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
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

  PreferredSizeWidget _buildAppBar() {
    switch (_currentTab) {
      case 0:
        return AppBar(
          title: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Wallet Manager',style: AppTypography.sectionHeader(),),
                Text(
                  Formatters.formatMonthYear(DateTime.now()),
                  style: AppTypography.caption(),
                ),
              ],
            ),
          )
        );
      case 1:
        return AppBar(
          title: const Text('Add Transaction'),
        );
      case 2:
        return AppBar(
          title: const Text('Monthly Settings'),
        );
      case 3:
        return AppBar(
          title: const Text('Archived Months'),
          actions: [
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              onPressed: _showArchiveDialog,
            ),
          ],
        );
      default:
        return AppBar(
          title: const Text('Wallet Manager'),
        );
    }
  }

  Widget _buildHomeTab() {
    final appState = context.watch<AppState>();

    return RefreshIndicator(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllTransactionsScreen(),
                      ),
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (appState.transactions.isEmpty)
              Container(
                width: double.infinity,
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
    );
  }

  Widget _buildAddTab() {
    return const AddTransactionScreen(isEmbedded: true);
  }

  Widget _buildSettingsTab() {
    return const SettingsScreen(isEmbedded: true);
  }

  Widget _buildArchiveTab() {
    return const ArchiveListScreen(isEmbedded: true);
  }

  void _handleNavigation(int index) {
    setState(() {
      _currentTab = index;
    });
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

  Future<void> _showArchiveDialog() async {
    final confirmed = await showArchiveDialog(context);

    if (confirmed == true) {
      final appState = context.read<AppState>();

      // Archive the month
      await appState.archiveCurrentMonth();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Month archived successfully!',
              style: AppTypography.bodyText().copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.incomeGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}