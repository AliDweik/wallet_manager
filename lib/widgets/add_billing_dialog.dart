import 'package:flutter/material.dart';
import 'package:wallet_manager/models/monthly_billing.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';

class AddBillingDialog extends StatefulWidget {
  final MonthlyBilling? existingBilling;

  const AddBillingDialog({
    super.key,
    this.existingBilling,
  });

  @override
  State<AddBillingDialog> createState() => _AddBillingDialogState();
}

class _AddBillingDialogState extends State<AddBillingDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int _dueDay = 1;
  String _iconName = 'receipt_long';
  String _errorMessage = '';

  bool get _isEditing => widget.existingBilling != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingBilling!.name;
      _amountController.text = widget.existingBilling!.amount.toStringAsFixed(2);
      _dueDay = widget.existingBilling!.dueDay;
      _iconName = widget.existingBilling!.iconName ?? 'receipt_long';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a billing name';
      });
      return;
    }

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount';
      });
      return;
    }

    Navigator.pop(context, {
      'name': name,
      'amount': amount,
      'dueDay': _dueDay,
      'iconName': _iconName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        _isEditing ? 'Edit Billing' : 'Add Billing',
        style: AppTypography.sectionHeader(),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Billing Name',
                hintText: 'e.g., Apartment Rent',
              ),
            ),
            const SizedBox(height: 16),

            // Amount field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Due Day',
              style: AppTypography.cardTitle(),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _dueDay,
              decoration: const InputDecoration(
                labelText: 'Day of month',
              ),
              items: List.generate(31, (index) => index + 1).map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text('Day $day'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _dueDay = value ?? 1;
                });
              },
            ),
            const SizedBox(height: 16),

            Text(
              'Icon',
              style: AppTypography.cardTitle(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildIconOption('receipt_long', Icons.receipt_long_outlined),
                _buildIconOption('home', Icons.home_outlined),
                _buildIconOption('bolt', Icons.bolt_outlined),
                _buildIconOption('wifi', Icons.wifi_outlined),
                _buildIconOption('fitness', Icons.fitness_center_outlined),
                _buildIconOption('phone', Icons.phone_outlined),
                _buildIconOption('water', Icons.water_drop_outlined),
                _buildIconOption('car', Icons.directions_car_outlined),
              ],
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: AppTypography.caption().copyWith(
                  color: AppColors.expenseCoral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 44),
          ),
          child: Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildIconOption(String iconName, IconData icon) {
    final isSelected = _iconName == iconName;

    return GestureDetector(
      onTap: () {
        setState(() {
          _iconName = iconName;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.incomeSoftTint : AppColors.surfaceBase,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.brandBlue : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.brandBlue : AppColors.textMuted,
          size: 24,
        ),
      ),
    );
  }
}