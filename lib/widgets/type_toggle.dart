import 'package:flutter/material.dart';
import 'package:wallet_manager/models/transaction.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';

class TypeToggle extends StatelessWidget {
  final TransactionType selectedType;
  final Function(TransactionType) onTypeChanged;

  const TypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(TransactionType.expense),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedType == TransactionType.expense
                      ? AppColors.expenseSoftTint
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.south_east,
                      size: 18,
                      color: selectedType == TransactionType.expense
                          ? AppColors.expenseCoral
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expense',
                      style: AppTypography.cardTitle().copyWith(
                        color: selectedType == TransactionType.expense
                            ? AppColors.expenseCoral
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(TransactionType.income),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedType == TransactionType.income
                      ? AppColors.incomeSoftTint
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.north_east,
                      size: 18,
                      color: selectedType == TransactionType.income
                          ? AppColors.incomeGreen
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Income',
                      style: AppTypography.cardTitle().copyWith(
                        color: selectedType == TransactionType.income
                            ? AppColors.incomeGreen
                            : AppColors.textMuted,
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
}