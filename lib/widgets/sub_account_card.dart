import 'package:flutter/material.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';

class SubAccountCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const SubAccountCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.caption(),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: AppTypography.cardTitle().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}