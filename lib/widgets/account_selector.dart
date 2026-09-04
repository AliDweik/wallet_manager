
import 'package:flutter/material.dart';
import 'package:wallet_manager/models/transaction.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';

class AccountSelector extends StatelessWidget {
  final AccountType selectedAccount;
  final double cashBalance;
  final double visaBalance;
  final Function(AccountType) onAccountChanged;

  const AccountSelector({
    super.key,
    required this.selectedAccount,
    required this.cashBalance,
    required this.visaBalance,
    required this.onAccountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Account',
          style: AppTypography.cardTitle(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAccountCard(
                account: AccountType.cash,
                title: 'Cash',
                balance: cashBalance,
                icon: Icons.account_balance_wallet,
                iconColor: AppColors.incomeGreen,
                iconBackground: AppColors.incomeSoftTint,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: _buildAccountCard(
                account: AccountType.visa,
                title: 'Visa',
                balance: visaBalance,
                icon: Icons.credit_card,
                iconColor: AppColors.brandBlue,
                iconBackground: AppColors.incomeSoftBg,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountCard({
    required AccountType account,
    required String title,
    required double balance,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    final isSelected = selectedAccount == account;

    return GestureDetector(
      onTap: () => onAccountChanged(account),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.brandBlue : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.brandBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.brandBlue,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.caption(),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: AppTypography.cardTitle().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}