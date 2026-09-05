import 'package:flutter/material.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';

class ArchiveSuccessDialog extends StatelessWidget {
  final String salaryAmount;
  final String accountType;

  const ArchiveSuccessDialog({
    super.key,
    required this.salaryAmount,
    required this.accountType,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
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
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.incomeSoftTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.incomeGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'New Month Started!',
              style: AppTypography.sectionHeader().copyWith(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Salary of \$$salaryAmount has been added to your $accountType account.',
              style: AppTypography.bodyText().copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Start New Month'),
            ),
          ],
        ),
      ),
    );
  }
}