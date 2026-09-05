import 'package:flutter/material.dart';
import 'package:wallet_manager/models/archive_summary.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';

class ArchiveSummaryCard extends StatelessWidget {
  final ArchiveSummary summary;
  final VoidCallback onTap;

  const ArchiveSummaryCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.monthYearDisplay,
                        style: AppTypography.sectionHeader(),
                      ),
                      if (summary.archivedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Archived on ${_formatDate(summary.archivedAt!)}',
                          style: AppTypography.caption(),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.incomeSoftBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 12,
                        color: AppColors.brandBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Closed',
                        style: AppTypography.caption().copyWith(
                          color: AppColors.brandBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(height: 1, color: AppColors.divider),
            const SizedBox(height: 16),

            Text(
              'Closing Balance',
              style: AppTypography.caption(),
            ),
            const SizedBox(height: 4),
            Text(
              summary.totalBalanceDisplay,
              style: AppTypography.heroNumber().copyWith(
                color: AppColors.textDark,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildAccountBreakdown(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Cash',
                    amount: summary.cashBalanceDisplay,
                    color: AppColors.incomeGreen,
                    backgroundColor: AppColors.incomeSoftTint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAccountBreakdown(
                    icon: Icons.credit_card_outlined,
                    label: 'Visa',
                    amount: summary.visaBalanceDisplay,
                    color: AppColors.brandBlue,
                    backgroundColor: AppColors.incomeSoftBg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  icon: Icons.savings_outlined,
                  label: summary.savingsDisplay,
                  color: AppColors.incomeGreen,
                ),
                _buildInfoChip(
                  icon: Icons.receipt_long_outlined,
                  label: '${summary.transactionsCount} transactions',
                  color: AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: AppTypography.cardTitle().copyWith(
                    color: AppColors.brandBlue,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.brandBlue,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBreakdown({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: AppTypography.cardTitle().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption().copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}