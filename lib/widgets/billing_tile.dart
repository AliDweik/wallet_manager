import 'package:flutter/material.dart';
import 'package:wallet_manager/models/monthly_billing.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';

class BillingTile extends StatelessWidget {
  final MonthlyBilling billing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BillingTile({
    super.key,
    required this.billing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.incomeSoftBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconForBilling(billing.iconName),
              color: AppColors.brandBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  billing.name,
                  style: AppTypography.cardTitle(),
                ),
                const SizedBox(height: 2),
                Text(
                  'Due day ${billing.dueDay}',
                  style: AppTypography.caption(),
                ),
              ],
            ),
          ),

          Text(
            '\$${billing.amount.toStringAsFixed(2)}',
            style: AppTypography.cardTitle().copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.textMuted,
            ),
            onPressed: onEdit,
          ),

          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.expenseCoral,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  IconData _getIconForBilling(String? iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home_outlined;
      case 'bolt':
        return Icons.bolt_outlined;
      case 'wifi':
        return Icons.wifi_outlined;
      case 'fitness':
        return Icons.fitness_center_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'car':
        return Icons.directions_car_outlined;
      case 'subscription':
        return Icons.subscriptions_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}