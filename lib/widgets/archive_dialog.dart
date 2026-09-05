import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_manager/providers/app_state.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';

class ArchiveDialog extends StatelessWidget {
  const ArchiveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final summary = appState.getArchiveSummary();

    if (summary == null) {
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.expenseSoftTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.archive_outlined,
                    color: AppColors.expenseCoral,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start New Month?',
                        style: AppTypography.sectionHeader(),
                      ),
                      Text(
                        'Archive current month data',
                        style: AppTypography.caption(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 20),

            Text(
              'Current Month Summary',
              style: AppTypography.cardTitle().copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _buildSummaryItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Cash Balance',
              value: '\$${summary['cashBalance'].toStringAsFixed(2)}',
              color: AppColors.incomeGreen,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              icon: Icons.credit_card_outlined,
              label: 'Visa Balance',
              value: '\$${summary['visaBalance'].toStringAsFixed(2)}',
              color: AppColors.brandBlue,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              icon: Icons.receipt_long_outlined,
              label: 'Transactions',
              value: '${summary['transactionsCount']} total',
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              icon: Icons.savings_outlined,
              label: 'Savings',
              value: '\$${summary['savings'].toStringAsFixed(2)}',
              color: AppColors.incomeGreen,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              icon: Icons.calendar_today_outlined,
              label: 'Monthly Billings',
              value: '\$${summary['totalBillings'].toStringAsFixed(2)}',
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              icon: Icons.payments_outlined,
              label: 'Salary to Add',
              value: '\$${summary['salaryAmount'].toStringAsFixed(2)}',
              color: AppColors.incomeGreen,
            ),

            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.incomeSoftBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What happens next:',
                    style: AppTypography.cardTitle().copyWith(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRuleItem(
                    icon: Icons.check_circle_outline,
                    text: 'Transactions will be cleared',
                    color: AppColors.incomeGreen,
                  ),
                  const SizedBox(height: 8),
                  _buildRuleItem(
                    icon: Icons.check_circle_outline,
                    text: 'Savings will reset to 0',
                    color: AppColors.incomeGreen,
                  ),
                  const SizedBox(height: 8),
                  _buildRuleItem(
                    icon: Icons.check_circle_outline,
                    text: 'Monthly billings will remain',
                    color: AppColors.incomeGreen,
                  ),
                  const SizedBox(height: 8),
                  _buildRuleItem(
                    icon: Icons.check_circle_outline,
                    text: 'Balances will be carried over',
                    color: AppColors.incomeGreen,
                  ),
                  const SizedBox(height: 8),
                  _buildRuleItem(
                    icon: Icons.check_circle_outline,
                    text: 'Salary will be added to ${summary['salaryAccount']}',
                    color: AppColors.incomeGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expenseCoral,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Confirm Archive'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyText().copyWith(
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

Future<bool?> showArchiveDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const ArchiveDialog(),
  );
}