
import 'package:flutter/material.dart';
import 'package:wallet_manager/models/transaction.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';
import 'package:wallet_manager/utlils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExpense
                  ? AppColors.expenseSoftTint
                  : AppColors.incomeSoftTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpense ? Icons.south_east : Icons.north_east,
              color: isExpense
                  ? AppColors.expenseCoral
                  : AppColors.incomeGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note ?? transaction.typeLabel,
                  style: AppTypography.cardTitle().copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.formatRelativeDay(transaction.date)} • ${transaction.accountLabel}',
                  style: AppTypography.caption(),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
            style: AppTypography.cardTitle().copyWith(
              color: isExpense
                  ? AppColors.expenseCoral
                  : AppColors.incomeGreen,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}