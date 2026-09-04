import 'package:flutter/material.dart';
import 'package:wallet_manager/theme/app_typography.dart';

import '../theme/app_colors.dart' show AppColors;

class DailyLimitMeter extends StatelessWidget {
  final double dailyLimit;
  final double todaySpent;
  final double remainingToday;
  final double progress;

  const DailyLimitMeter({
    super.key,
    required this.dailyLimit,
    required this.todaySpent,
    required this.remainingToday,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isOverBudget = remainingToday < 0;

    return Container(
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
              Text(
                'Daily Limit',
                style: AppTypography.cardTitle().copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppColors.expenseSoftTint
                      : AppColors.incomeSoftTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOverBudget ? 'Over Budget' : 'On Track',
                  style: AppTypography.caption().copyWith(
                    color: isOverBudget
                        ? AppColors.expenseCoral
                        : AppColors.incomeGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${dailyLimit.toStringAsFixed(2)}',
            style: AppTypography.sectionHeader().copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? AppColors.expenseCoral : AppColors.brandBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${todaySpent.toStringAsFixed(2)}',
                style: AppTypography.caption(),
              ),
              Text(
                'Remaining: \$${remainingToday.toStringAsFixed(2)}',
                style: AppTypography.caption().copyWith(
                  color: isOverBudget
                      ? AppColors.expenseCoral
                      : AppColors.incomeGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}