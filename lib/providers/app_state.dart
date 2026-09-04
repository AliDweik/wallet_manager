import 'package:flutter/material.dart';
import 'package:wallet_manager/models/app_data.dart';
import 'package:wallet_manager/models/monthly_billing.dart';
import 'package:wallet_manager/models/transaction.dart';
import 'package:wallet_manager/services/calculation_service.dart';
import 'package:wallet_manager/services/storage_service.dart';


class AppState extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  AppData? _data;
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;

  AppData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSaving => _isSaving;

  double get totalMoney => _data != null ? CalculationService.getTotalMoney(_data!) : 0;
  double get cashBalance => _data?.cashBalance ?? 0;
  double get visaBalance => _data?.visaBalance ?? 0;
  double get savings => _data?.savings ?? 0;
  double get salaryAmount => _data?.salaryAmount ?? 0;
  int get salaryDay => _data?.salaryDay ?? 28;
  String get salaryAccount => _data?.salaryAccount ?? 'cash';

  List<MonthlyBilling> get monthlyBillings => _data?.monthlyBillings ?? [];
  List<Transaction> get transactions => _data?.transactions ?? [];

  double get totalMonthlyBillings => _data != null
      ? CalculationService.getTotalMonthlyBillings(_data!)
      : 0;

  double get dailyLimit => _data != null
      ? CalculationService.getDailyLimit(_data!)
      : 0;

  double get todaySpent => _data != null
      ? CalculationService.getTodaySpent(_data!)
      : 0;

  double get todayIncome => _data != null
      ? CalculationService.getTodayIncome(_data!)
      : 0;

  double get remainingToday => _data != null
      ? CalculationService.getRemainingToday(_data!)
      : 0;

  double get monthSpent => _data != null
      ? CalculationService.getMonthSpent(_data!)
      : 0;

  double get monthIncome => _data != null
      ? CalculationService.getMonthIncome(_data!)
      : 0;

  double get dailyLimitProgress => _data != null
      ? CalculationService.getDailyLimitProgress(_data!)
      : 0;

  bool get isSalaryDay => _data != null
      ? CalculationService.isSalaryDay(_data!)
      : false;

  bool get shouldPromptArchive => _data != null
      ? CalculationService.shouldPromptArchive(_data!)
      : false;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _storageService.loadOrCreateData();
    } catch (e) {
      _error = 'Failed to load data: $e';
      print('Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    if (_data == null) return;

    _isSaving = true;
    notifyListeners();

    try {
      await _storageService.saveActiveData(_data!);
    } catch (e) {
      _error = 'Failed to save data: $e';
      print('Save error: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required AccountType account,
    required DateTime date,
    String? note,
  }) async {
    if (_data == null) return;

    final transaction = Transaction.create(
      amount: amount,
      type: type,
      account: account,
      date: date,
      note: note,
    );

    _data!.transactions.add(transaction);

    if (account == AccountType.cash) {
      _data!.cashBalance = CalculationService.calculateNewBalance(
        _data!.cashBalance,
        transaction,
      );
    } else {
      _data!.visaBalance = CalculationService.calculateNewBalance(
        _data!.visaBalance,
        transaction,
      );
    }

    notifyListeners();
    await _saveData();
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (_data == null) return;

    final transactionIndex = _data!.transactions.indexWhere(
            (t) => t.id == transactionId
    );

    if (transactionIndex == -1) return;

    final transaction = _data!.transactions[transactionIndex];
    _data!.transactions.removeAt(transactionIndex);

    if (transaction.account == AccountType.cash) {
      _data!.cashBalance = CalculationService.calculateNewBalance(
        _data!.cashBalance,
        Transaction(
          id: transaction.id,
          amount: transaction.amount,
          type: transaction.type == TransactionType.expense
              ? TransactionType.income
              : TransactionType.expense,
          account: transaction.account,
          date: transaction.date,
          note: transaction.note,
        ),
      );
    } else {
      _data!.visaBalance = CalculationService.calculateNewBalance(
        _data!.visaBalance,
        Transaction(
          id: transaction.id,
          amount: transaction.amount,
          type: transaction.type == TransactionType.expense
              ? TransactionType.income
              : TransactionType.expense,
          account: transaction.account,
          date: transaction.date,
          note: transaction.note,
        ),
      );
    }

    notifyListeners();
    await _saveData();
  }

  Future<void> addMonthlyBilling({
    required String name,
    required double amount,
    required int dueDay,
    String? iconName,
  }) async {
    if (_data == null) return;

    final billing = MonthlyBilling.create(
      name: name,
      amount: amount,
      dueDay: dueDay,
      iconName: iconName,
    );

    _data!.monthlyBillings.add(billing);
    notifyListeners();
    await _saveData();
  }

  Future<void> editMonthlyBilling({
    required String billingId,
    String? name,
    double? amount,
    int? dueDay,
    String? iconName,
  }) async {
    if (_data == null) return;

    final billingIndex = _data!.monthlyBillings.indexWhere(
            (b) => b.id == billingId
    );

    if (billingIndex == -1) return;

    final oldBilling = _data!.monthlyBillings[billingIndex];
    _data!.monthlyBillings[billingIndex] = MonthlyBilling(
      id: oldBilling.id,
      name: name ?? oldBilling.name,
      amount: amount ?? oldBilling.amount,
      dueDay: dueDay ?? oldBilling.dueDay,
      iconName: iconName ?? oldBilling.iconName,
    );

    notifyListeners();
    await _saveData();
  }

  Future<void> deleteMonthlyBilling(String billingId) async {
    if (_data == null) return;

    _data!.monthlyBillings.removeWhere((b) => b.id == billingId);
    notifyListeners();
    await _saveData();
  }

  Future<void> updateSavings(double newSavings) async {
    if (_data == null) return;

    _data!.savings = newSavings;
    notifyListeners();
    await _saveData();
  }

  Future<void> updateBalances({
    double? cashBalance,
    double? visaBalance,
  }) async {
    if (_data == null) return;

    if (cashBalance != null) {
      _data!.cashBalance = cashBalance;
    }

    if (visaBalance != null) {
      _data!.visaBalance = visaBalance;
    }

    notifyListeners();
    await _saveData();
  }

  Future<void> updateSalarySettings({
    double? amount,
    int? day,
    String? account,
  }) async {
    if (_data == null) return;

    if (amount != null) {
      _data!.salaryAmount = amount;
    }

    if (day != null) {
      _data!.salaryDay = day;
    }

    if (account != null) {
      _data!.salaryAccount = account;
    }

    notifyListeners();
    await _saveData();
  }

  Future<void> archiveCurrentMonth() async {
    if (_data == null) return;

    try {
      await _storageService.archiveCurrentMonth(_data!);

      _data!.resetForNewMonth();

      _data!.addSalary();

      await _storageService.saveActiveData(_data!);

      notifyListeners();
    } catch (e) {
      _error = 'Failed to archive month: $e';
      print('Archive error: $e');
      notifyListeners();
    }
  }

  List<Transaction> getRecentTransactions({int limit = 10}) {
    if (_data == null) return [];
    return CalculationService.getRecentTransactions(_data!, limit: limit);
  }

  List<Transaction> getTransactionsForDate(DateTime date) {
    if (_data == null) return [];

    return _data!.transactions.where((t) {
      return t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day;
    }).toList();
  }

  Map<String, dynamic>? getArchiveSummary() {
    if (_data == null) return null;
    return CalculationService.getArchiveSummary(_data!);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}