import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_manager/models/monthly_billing.dart';
import 'package:wallet_manager/providers/app_state.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';
import 'package:wallet_manager/widgets/add_billing_dialog.dart';
import 'package:wallet_manager/widgets/billing_tile.dart';
import 'package:wallet_manager/widgets/section_card.dart';

class SettingsScreen extends StatefulWidget {
  final bool isEmbedded;

  const SettingsScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _savingsController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _visaController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  int _salaryDay = 28;
  String _salaryAccount = 'cash';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      _loadValues(appState);
    });
  }

  void _loadValues(AppState appState) {
    _savingsController.text = appState.savings.toStringAsFixed(2);
    _cashController.text = appState.cashBalance.toStringAsFixed(2);
    _visaController.text = appState.visaBalance.toStringAsFixed(2);
    _salaryController.text = appState.salaryAmount.toStringAsFixed(2);
    _salaryDay = appState.salaryDay;
    _salaryAccount = appState.salaryAccount;
  }

  @override
  void dispose() {
    _savingsController.dispose();
    _cashController.dispose();
    _visaController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _showAddBillingDialog({MonthlyBilling? existingBilling}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddBillingDialog(existingBilling: existingBilling),
    );

    if (result != null) {
      final appState = context.read<AppState>();

      if (existingBilling != null) {
        await appState.editMonthlyBilling(
          billingId: existingBilling.id,
          name: result['name'],
          amount: result['amount'],
          dueDay: result['dueDay'],
          iconName: result['iconName'],
        );
      } else {
        await appState.addMonthlyBilling(
          name: result['name'],
          amount: result['amount'],
          dueDay: result['dueDay'],
          iconName: result['iconName'],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingBilling != null
                  ? 'Billing updated successfully'
                  : 'Billing added successfully',
              style: AppTypography.bodyText().copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.incomeGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteBilling(MonthlyBilling billing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Billing',
          style: AppTypography.sectionHeader(),
        ),
        content: Text(
          'Are you sure you want to delete "${billing.name}"?',
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
      final appState = context.read<AppState>();
      await appState.deleteMonthlyBilling(billing.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Billing deleted',
              style: AppTypography.bodyText().copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.expenseCoral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    final appState = context.read<AppState>();

    final savings = double.tryParse(_savingsController.text) ?? 0;
    final cash = double.tryParse(_cashController.text) ?? 0;
    final visa = double.tryParse(_visaController.text) ?? 0;
    final salary = double.tryParse(_salaryController.text) ?? 0;

    await appState.updateSavings(savings);

    await appState.updateBalances(
      cashBalance: cash,
      visaBalance: visa,
    );

    await appState.updateSalarySettings(
      amount: salary,
      day: _salaryDay,
      account: _salaryAccount,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Settings saved successfully',
            style: AppTypography.bodyText().copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.incomeGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure recurring finances & salary',
              style: AppTypography.bodyText().copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Monthly Savings Target',
              subtitle: 'Set aside money for savings',
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.incomeSoftTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.incomeGreen,
                  size: 20,
                ),
              ),
              child: TextField(
                controller: _savingsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Savings Amount',
                  prefixText: '\$ ',
                ),
              ),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Monthly Billings',
              subtitle: 'Recurring expenses',
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.incomeSoftBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${appState.monthlyBillings.length} Active',
                  style: AppTypography.caption().copyWith(
                    color: AppColors.brandBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: \$${appState.totalMonthlyBillings.toStringAsFixed(2)}',
                    style: AppTypography.cardTitle().copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (appState.monthlyBillings.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBase,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No monthly billings',
                            style: AppTypography.cardTitle(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add your recurring expenses',
                            style: AppTypography.caption(),
                          ),
                        ],
                      ),
                    )
                  else
                    ...appState.monthlyBillings.map((billing) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BillingTile(
                          billing: billing,
                          onEdit: () => _showAddBillingDialog(existingBilling: billing),
                          onDelete: () => _deleteBilling(billing),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    onPressed: () => _showAddBillingDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Billing'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Starting Balances',
              subtitle: 'Edit your current balances',
              child: Column(
                children: [
                  TextField(
                    controller: _cashController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cash Balance',
                      prefixText: '\$ ',
                      prefixIcon: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.incomeGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _visaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Visa Balance',
                      prefixText: '\$ ',
                      prefixIcon: Icon(
                        Icons.credit_card_outlined,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Salary & Income Schedule',
              subtitle: 'Configure your monthly income',
              child: Column(
                children: [
                  TextField(
                    controller: _salaryController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Salary Amount',
                      prefixText: '\$ ',
                      prefixIcon: Icon(
                        Icons.payments_outlined,
                        color: AppColors.incomeGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    value: _salaryDay,
                    decoration: const InputDecoration(
                      labelText: 'Salary Day',
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    items: List.generate(31, (index) => index + 1).map((day) {
                      return DropdownMenuItem(
                        value: day,
                        child: Text('Day $day of each month'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _salaryDay = value ?? 28;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _salaryAccount,
                    decoration: const InputDecoration(
                      labelText: 'Default Deposit Account',
                      prefixIcon: Icon(
                        Icons.account_balance_outlined,
                        color: AppColors.textMuted,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'cash',
                        child: Text('Cash'),
                      ),
                      DropdownMenuItem(
                        value: 'visa',
                        child: Text('Visa'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _salaryAccount = value ?? 'cash';
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveSettings,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check),
                  const SizedBox(width: 8),
                  Text(
                    'Save Settings',
                    style: AppTypography.cardTitle().copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}