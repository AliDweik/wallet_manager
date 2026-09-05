import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_manager/providers/app_state.dart';
import 'package:wallet_manager/models/transaction.dart';
import 'package:wallet_manager/theme/app_colors.dart';
import 'package:wallet_manager/theme/app_typography.dart';
import 'package:wallet_manager/widgets/type_toggle.dart';
import 'package:wallet_manager/widgets/amount_input.dart';
import 'package:wallet_manager/widgets/account_selector.dart';
import 'package:wallet_manager/utlils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isEmbedded; // Add this parameter

  const AddTransactionScreen({
    super.key,
    this.isEmbedded = false, // Default to false (pushed route)
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  TransactionType _selectedType = TransactionType.expense;
  AccountType _selectedAccount = AccountType.cash;
  DateTime _selectedDate = DateTime.now();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Auto focus on amount field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    // Validate amount
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount';
      });
      return;
    }

    // Clear error
    setState(() {
      _errorMessage = '';
    });

    // Clean the note text
    final note = _noteController.text.trim();
    final cleanedNote = _cleanNote(note);

    // Save transaction
    final appState = context.read<AppState>();
    await appState.addTransaction(
      amount: amount,
      type: _selectedType,
      account: _selectedAccount,
      date: _selectedDate,
      note: cleanedNote.isEmpty ? null : cleanedNote,
    );

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaction added successfully',
            style: AppTypography.bodyText().copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.incomeGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back ONLY if not embedded
      if (!widget.isEmbedded) {
        Navigator.pop(context);
      } else {
        // If embedded, clear the form for next transaction
        _clearForm();
      }
    }
  }

  void _clearForm() {
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _selectedType = TransactionType.expense;
      _selectedAccount = AccountType.cash;
      _selectedDate = DateTime.now();
      _errorMessage = '';
    });
    _amountFocusNode.requestFocus();
  }

  String _cleanNote(String note) {
    if (note.isEmpty) return '';

    // Split by lines
    final lines = note.split('\n');

    // Remove empty lines from the beginning
    int startIndex = 0;
    while (startIndex < lines.length && lines[startIndex].trim().isEmpty) {
      startIndex++;
    }

    // Remove empty lines from the end
    int endIndex = lines.length - 1;
    while (endIndex >= startIndex && lines[endIndex].trim().isEmpty) {
      endIndex--;
    }

    // If all lines are empty, return empty string
    if (startIndex > endIndex) {
      return '';
    }

    // Get the non-empty portion
    final cleanedLines = lines.sublist(startIndex, endIndex + 1);

    // Trim each line
    final trimmedLines = cleanedLines.map((line) => line.trim()).toList();

    // Join back with newlines
    return trimmedLines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            TypeToggle(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
            const SizedBox(height: 16),

            // Amount input
            AmountInput(
              controller: _amountController,
              focusNode: _amountFocusNode,
              onChanged: (_) {
                if (_errorMessage.isNotEmpty) {
                  setState(() {
                    _errorMessage = '';
                  });
                }
              },
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: AppTypography.caption().copyWith(
                  color: AppColors.expenseCoral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Account selector
            AccountSelector(
              selectedAccount: _selectedAccount,
              cashBalance: appState.cashBalance,
              visaBalance: appState.visaBalance,
              onAccountChanged: (account) {
                setState(() {
                  _selectedAccount = account;
                });
              },
            ),
            const SizedBox(height: 24),

            // Date picker
            Text(
              'Date',
              style: AppTypography.cardTitle(),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      Formatters.formatRelativeDay(_selectedDate),
                      style: AppTypography.bodyText(),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Note field
            Text(
              'Note (Optional)',
              style: AppTypography.cardTitle(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                hintStyle: AppTypography.bodyText().copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saveTransaction,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check),
                  const SizedBox(width: 8),
                  Text(
                    'Save Transaction',
                    style: AppTypography.cardTitle().copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}